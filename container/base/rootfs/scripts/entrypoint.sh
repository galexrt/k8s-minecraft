#!/bin/bash

export SCRIPTS_DIR="${SCRIPTS_DIR:-/scripts}"

# shellcheck disable=SC1091
source "${SCRIPTS_DIR}/vars.sh"

# Remove stale restart pause file
rm -f "${RESTART_PAUSE_FILE}"

# Create first startup tag file
if [ "${FIRST_STARTUP}" = "true" ]; then
    date +%s > "${FIRST_STARTUP_FILE}"
    echo "entrypoint: First start up mode is now disabled for next start ups!"
fi

# Sync data from git
"${SCRIPTS_DIR}/git-sync.sh" full

if [ "${1}" = "java" ]; then
    echo "entrypoint: Running java jar because first arg ist 'java' ..."
    shift

    if [ -n "${JAVA_JAR}" ]; then
        set -- -jar "${JAVA_JAR}" "${@}"
    else
        echo "entrypoint: WARNING! No JAVA_JAR var set in container."
    fi
    if [ -n "${JAVA_FLAGS}" ]; then
        echo "entrypoint: Adding JAVA_FLAGS to args"
        # shellcheck disable=SC2086
        set -- ${JAVA_FLAGS} "${@}"
    fi

    # Set Java PID to the script till the PID is set
    java_pid="$$"
    cleanup() {
        RESTART_JAVA_PROCESS=false
        kill -s SIGTERM "${java_pid}"
        wait "${java_pid}"
        echo "entrypoint: Cleanup trap completed."
        exit 0
    }
    trap cleanup SIGINT SIGTERM

    while true; do
        echo "entrypoint: $(date) Running java command: ${JAVA_CMD} ${*}"
        "${JAVA_CMD}" "${@}" < /dev/stdin &
        java_pid=$!

        wait "${java_pid}"
        rt=$?
        if [ "${RESTART_JAVA_PROCESS}" != "true" ]; then
            echo "entrypoint: $(date) Java program exited with code ${rt}, terminating script."
            exit ${rt}
        fi
        echo "entrypoint: $(date) Java program exited with code ${rt}, restarting ..."

        if [ -f "${SERVER_STATUS_PLUGIN_STATUS_FILE}" ]; then
            # Set Server status to be starting and wait a second
            echo "Status: Starting" > "${SERVER_STATUS_PLUGIN_STATUS_FILE}"
            sleep 1
        fi

        if [ -e "${RESTART_PAUSE_FILE}" ]; then
            echo "entrypoint: $(date) Restart pause file found (contents: '$(cat "${RESTART_PAUSE_FILE}")'), waiting ${RESTART_PAUSE_CHECK_INTERVAL} seconds ..."
            while true; do
                sleep "${RESTART_PAUSE_CHECK_INTERVAL}"
                if [ "${RESTART_JAVA_PROCESS}" != "true" ]; then
                    echo "entrypoint: Signal caught (restart pause file (no more restarts)), DONE."
                    break
                fi

                if [ ! -e "${RESTART_PAUSE_FILE}" ]; then
                    echo "entrypoint: $(date) Restart pause file not found (anymore), continuing restart ..."
                    break
                fi
                echo "entrypoint: $(date) Restart pause file found, waiting ${RESTART_PAUSE_CHECK_INTERVAL} seconds ..."
            done
        fi

        # Sync data from git
        "${SCRIPTS_DIR}/git-sync.sh" full
    done
fi

echo "entrypoint: $(date) Running arbitrary command ..."
set -x
exec "${@}"
