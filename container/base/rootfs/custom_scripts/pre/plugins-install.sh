#!/bin/bash

set -e

CUSTOM_SCRIPT_PLUGINS_INSTALL="${CUSTOM_SCRIPT_PLUGINS_INSTALL:-false}"
CUSTOM_SCRIPT_PLUGINS_INSTALL_FILE="${CUSTOM_SCRIPT_PLUGINS_INSTALL_FILE:-/plugins_install_list/plugins_install_list.txt}"
CUSTOM_SCRIPT_PLUGINS_DIR="${CUSTOM_SCRIPT_PLUGINS_DIR:-/repo/plugins}"
RSYNC_FLAGS="${RSYNC_FLAGS:--aurv}"

if [ "${CUSTOM_SCRIPT_PLUGINS_INSTALL}" != "true" ]; then
    echo "Skipping plugins install from plugins directory."
    exit
fi

if [ ! -e "${CUSTOM_SCRIPT_PLUGINS_INSTALL_FILE}" ] && [ -z "${PLUGINS_TO_INSTALL}" ]; then
    echo "No ${CUSTOM_SCRIPT_PLUGINS_INSTALL_FILE} file found and empty PLUGINS_TO_INSTALL env var, skipping plugins install ..."
    exit
fi

# When the env var is empty, read the plugins list file
if [ -z "${PLUGINS_TO_INSTALL}" ]; then
    PLUGINS_TO_INSTALL="$(sed -r -e '/^(|#.*)$/d' "${CUSTOM_SCRIPT_PLUGINS_INSTALL_FILE}")"
fi

while IFS= read -r plugin; do
    n=1
    until [ "$n" -gt 3 ]; do
        if [ -d "${CUSTOM_SCRIPT_PLUGINS_DIR}/${plugin}" ]; then
            echo "Copying plugin data ${plugin} to server (try $n/3) ..."
            # shellcheck disable=SC2145,SC2086
            rsync ${RSYNC_FLAGS} "${CUSTOM_SCRIPT_PLUGINS_DIR}/${plugin}/" /data/plugins/ && break
        else
            n=$((n+1))
            echo "ERROR: Failed to find ${plugin} dir in ${CUSTOM_SCRIPT_PLUGINS_DIR} (try $n/3). Sleeping 30 seconds ..."
            sleep 30
        fi
    done
    if [ "$n" -ge 3 ]; then
        echo "ERROR: Failed to install ${plugin} (no dir found). Exiting 1 ..."
        exit 1
    fi
done < <(printf '%s\n' "${PLUGINS_TO_INSTALL}")
