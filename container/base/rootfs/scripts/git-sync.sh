#!/bin/bash

export SCRIPTS_DIR="${SCRIPTS_DIR:-/scripts}"

# shellcheck disable=SC1091
source "${SCRIPTS_DIR}/vars.sh"

export DEBUG="${DEBUG:-false}"
export FILES_CHANGED="false"
export MODE="${1:-partial}"
export SCRIPT_DONE=0

rsyncCall() {
    # shellcheck disable=SC2086
    RSYNC_COMMAND=$(rsync -i ${RSYNC_FLAGS} "${1}" "${2}")
    if [ -n "${RSYNC_COMMAND}" ]; then
        FILES_CHANGED="true"
    fi
}

cleanup() {
    SCRIPT_DONE=1
    # Remove restart pause file
    rm -f "${RESTART_PAUSE_FILE}"
}
trap "cleanup" SIGINT SIGTERM

if [ "${MODE}" = "watch" ]; then
    echo "git-sync: Start watching for git repo changes"
    count=1
    while true; do
        sleep 1
        if [ "${SCRIPT_DONE}" = 1 ]; then
            echo "git-sync: Exiting git sync watch."
            exit 0
        fi
        if [ $count -ge "${GIT_SYNC_WATCH_SLEEP_INTERVAL}" ]; then
            "${SCRIPTS_DIR}/git-sync.sh" partial
            count=1
        else
            (( count++ ))
        fi
    done
    exit 0
fi

echo "git-sync: Starting ${MODE} mode run at $(date +"%Y-%m-%d %T")"

REPO_REVISION="$(git -C "${GIT_SYNC_REPO_DIR}" log --format="%H" -n 1)"
SERVER_REVISION="${SERVER_REVISION:-}"
if [ -f "${REVISION_FILE}" ]; then
    SERVER_REVISION="$(cat "${REVISION_FILE}")"
fi

# Read plugin list file if available
if [ -f "${PLUGINS_LIST_CHECKSUM_FILE}" ]; then
    PLUGINS_LIST_CHECKSUM="$(cat "${PLUGINS_LIST_CHECKSUM_FILE}")"
    PLUGINS_LIST_CHECKSUM_NEW="$(md5sum "${GIT_SYNC_PLUGINS_INSTALL_FILE_BASE}" "${GIT_SYNC_PLUGINS_INSTALL_FILE}")"
else
    PLUGINS_LIST_CHECKSUM="$(md5sum "${GIT_SYNC_PLUGINS_INSTALL_FILE_BASE}" "${GIT_SYNC_PLUGINS_INSTALL_FILE}")"
    echo "${PLUGINS_LIST_CHECKSUM}" > "${PLUGINS_LIST_CHECKSUM_FILE}"
    PLUGINS_LIST_CHECKSUM_NEW="${PLUGINS_LIST_CHECKSUM}"
fi

# If it is a partial mode run and server vs repo revision and plugin list is the same, nothing to do here
if [ "${MODE}" = "partial" ] && \
    [ "${SERVER_REVISION}" = "${REPO_REVISION}" ] && [ "${PLUGINS_LIST_CHECKSUM}" = "${PLUGINS_LIST_CHECKSUM_NEW}" ]; then
    echo "git-sync: $(date +"%Y-%m-%d %T") Repo and Server Revision and plugin install list is the same no need to do update."
    exit 0
fi

if [ -f "${SERVER_STATUS_PLUGIN_STATUS_FILE}" ]; then
    server_status="$(cut -d' ' -f2 "${SERVER_STATUS_PLUGIN_STATUS_FILE}")"
    # When the status is `Starting`, we need to wait till it is `Ready`
    if [ "${server_status}" = "Starting" ]; then
        echo -n "git-sync: -> Server Status is ${server_status}: Waiting till status changes to other status ..."
        while true; do
            sleep 3

            if [ ! -e "${SERVER_STATUS_PLUGIN_STATUS_FILE}" ]; then
                echo "git-sync: $(date +"%Y-%m-%d %T") WARNING! Server Status file not found anymore, continuing plugins install ..."
                break
            fi

            server_status="$(cut -d' ' -f2 "${SERVER_STATUS_PLUGIN_STATUS_FILE}")"
            if [ "${server_status}" != "Starting" ]; then
                echo "git-sync: $(date +"%Y-%m-%d %T") Server Status is now ${server_status}, continuing plugin install ..."
                break
            fi
            echo "git-sync: $(date +"%Y-%m-%d %T") Server Status still not changed, waiting 3 seconds ..."
        done
    fi
fi
echo "$(date +"%Y-%m-%d %T") GITSYNC:${MODE}" > "${RESTART_PAUSE_FILE}"

CHANGED_FILES=$(git -C "${GIT_SYNC_REPO_DIR}" diff --name-only HEAD "${SERVER_REVISION}")
# shellcheck disable=SC2181
if [ $? -ne 0 ]; then
    echo "git-sync: Failed getting changed files from git, switching to full mode ..."
    export MODE="full"
fi
CHANGED_FILES="$(echo "${CHANGED_FILES}" | sort)"

# Partial update should not update jar files
if [ "${MODE}" = "partial" ]; then
    CHANGED_FILES="$(echo "${CHANGED_FILES}" | sed '/*.jar/d')"
    # shellcheck disable=SC2089
    RSYNC_FLAGS="$RSYNC_FLAGS --exclude='*.jar'"
fi
CHANGED_FILES="$(echo "${CHANGED_FILES}" | sed -r '/'"${GIT_SYNC_IGNORED_CHANGED_FILES}"'/d')"

# If there are no changed files and plugin list didn't change, exit early
if [ "${MODE}" = "partial" ] && [ -z "${CHANGED_FILES}" ] && [ "${PLUGINS_LIST_CHECKSUM}" = "${PLUGINS_LIST_CHECKSUM_NEW}" ]; then
    echo "git-sync: No changed files detected for partial sync. Exiting ..."
    echo "${REPO_REVISION}" > "${REVISION_FILE}"
    echo "${PLUGINS_LIST_CHECKSUM_NEW}" > "${PLUGINS_LIST_CHECKSUM_FILE}"
    rm -f "${RESTART_PAUSE_FILE}"
    exit 0
fi

# Clear plugins jars when there are changes
if [ "${MODE}" = "full" ]; then
    # Full Mode
    echo "git-sync: Clearing plugin dir jars ..."
    rm -rf "${DATA_DIR}/plugins/"*.jar
fi

# In case the plugin list checksum differs, do a full update BUT without jars
if [ "${PLUGINS_LIST_CHECKSUM}" != "${PLUGINS_LIST_CHECKSUM_NEW}" ]; then
    MODE="full"

    CHANGED_FILES="$(echo "${CHANGED_FILES}" | sed '/*.jar/d')"
    # shellcheck disable=SC2089
    RSYNC_FLAGS="$RSYNC_FLAGS --exclude='*.jar'"
fi

# Copying Plugins
if [ "${MODE}" = "partial" ]; then
    # Partial Mode
    while IFS= read -r FILE; do
        if [[ "${FILE}" =~ ^${GIT_SYNC_PLUGINS_DIR}.* ]]; then
            PLUGIN_NAME="$(echo "${FILE//"${GIT_SYNC_PLUGINS_DIR}/"}" | cut -d "/" -f1)"
            if ! (grep -qE "^${PLUGIN_NAME}" "${GIT_SYNC_PLUGINS_INSTALL_FILE_BASE}" "${GIT_SYNC_PLUGINS_INSTALL_FILE}"); then
                continue
            fi

            echo "git-sync: Copying ${PLUGIN_NAME} plugin ..."
            rsyncCall "${GIT_SYNC_REPO_DIR}/"${GIT_SYNC_PLUGINS_DIR}/"${PLUGIN_NAME}/" "${DATA_DIR}/plugins/"
        fi
    done <<< "${CHANGED_FILES}"
elif [ "${MODE}" = "full" ]; then
    PLUGINS_TO_INSTALL="$(sed -r -e '/^(|#.*)$/d' "${GIT_SYNC_PLUGINS_INSTALL_FILE_BASE}" "${GIT_SYNC_PLUGINS_INSTALL_FILE}" | sort | uniq)"
    while IFS= read -r PLUGIN_NAME; do
        echo "git-sync: Copying ${PLUGIN_NAME} plugin ..."
        rsyncCall "${GIT_SYNC_REPO_DIR}/${GIT_SYNC_PLUGINS_DIR}/${PLUGIN_NAME}/" "${DATA_DIR}/plugins/"
    done < <(printf '%s\n' "${PLUGINS_TO_INSTALL}")
fi

# Copying other servers-base/, per "server group" and per server files
if ([ "${MODE}" = "full" ] || echo "${CHANGED_FILES}" | grep -q "^servers-base/") && \
    [ -d "${GIT_SYNC_REPO_DIR}/servers-base/" ] && [ "${GIT_SYNC_SERVERS_BASE_COPY}" = "true" ]; then
    echo "git-sync: Copying ${GIT_SYNC_REPO_DIR}/servers-base/ ..."
    rsyncCall "${GIT_SYNC_REPO_DIR}/servers-base/" "${DATA_DIR}/"
fi

if ([ "${MODE}" = "full" ] || echo "${CHANGED_FILES}" | grep -q "^servers/${GAMESERVER_SERVER_NAME_WONUM}/data/") && \
    [ -d "${GIT_SYNC_REPO_DIR}/servers/${GAMESERVER_SERVER_NAME_WONUM}/data/" ]; then
    echo "git-sync: Copying ${GAMESERVER_SERVER_NAME_WONUM} server data ..."
    rsyncCall "${GIT_SYNC_REPO_DIR}/servers/${GAMESERVER_SERVER_NAME_WONUM}/data/" "${DATA_DIR}/"
fi

if ([ "${MODE}" = "full" ] || echo "${CHANGED_FILES}" | grep -q "^servers/${GAMESERVER_SERVER_NAME_WONUM}/${POD_HOSTNAME}/") && \
    [ -d "${GIT_SYNC_REPO_DIR}/servers/${GAMESERVER_SERVER_NAME_WONUM}/${POD_HOSTNAME}/" ]; then
    echo "git-sync: Copying ${POD_HOSTNAME} server data ..."
    rsyncCall "${GIT_SYNC_REPO_DIR}/servers/${GAMESERVER_SERVER_NAME_WONUM}/${POD_HOSTNAME}/" "${DATA_DIR}/"
fi

# Envsubst and yq file patching
if [ "${MODE}" = "partial" ]; then
    CHANGED_FILES="$(echo "${CHANGED_FILES//proxy-plugins/plugins}" | sed -r 's/servers-base\///g')"
    while IFS= read -r FILE; do
        # If the file is in the root of the server, add the file directly
        if [ "$(dirname "${FILE}" | cut -d / -f1-2)" = "." ]; then
            CHANGED_DIRS="${DATA_DIR}/${FILE} ${CHANGED_DIRS}"
        else
            CHANGED_DIRS="${DATA_DIR}/$(dirname "${FILE}" | cut -d / -f1-2) ${CHANGED_DIRS}"
        fi
    done <<< "${CHANGED_FILES}"
    export ENVSUBST_DIRS="${CHANGED_DIRS%' '}"
    # If the envsubst dirs is empty, run the envsubst over all files
    if [ "${ENVSUBST_DIRS}" = "" ] || [ "${ENVSUBST_DIRS}" = " " ]; then
        unset ENVSUBST_DIRS
    fi

    if [ "${DEBUG}" = "true" ]; then
        echo "git-sync: Changed files list: ${CHANGED_FILES}"
        echo "git-sync: Changed dirs list: ${CHANGED_DIRS}"
    fi
fi

for POST_SCRIPT in /scripts/git-sync.post.d/*; do
    bash "${POST_SCRIPT}" "${MODE}"
done

"${SCRIPTS_DIR}/envsubst.sh"
"${SCRIPTS_DIR}/yq-file-patching.sh"

# But run the server properties changes only for changed patch files and full mode
if ([ "${MODE}" = "full" ] || echo "${CHANGED_FILES}" | grep -q "server\..*-patch\.properties"); then
    "${SCRIPTS_DIR}/update-server-properties.sh"
fi

echo "${REPO_REVISION}" > "${REVISION_FILE}"
echo "${PLUGINS_LIST_CHECKSUM_NEW}" > "${PLUGINS_LIST_CHECKSUM_FILE}"
rm -f "${RESTART_PAUSE_FILE}"
echo "git-sync: Completed ${MODE} mode run at $(date +"%Y-%m-%d %T")."
