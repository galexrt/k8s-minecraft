#!/bin/bash

set -e

CUSTOM_SCRIPT_PLUGINS_INSTALL="${CUSTOM_SCRIPT_PLUGINS_INSTALL:-true}"
CUSTOM_SCRIPT_PLUGINS_DIR="${CUSTOM_SCRIPT_PLUGINS_DIR:-/repo/plugins}"
RSYNC_FLAGS="${RSYNC_FLAGS:--aurv}"

if [ "${CUSTOM_SCRIPT_PLUGINS_INSTALL}" != "true" ]; then
    echo "Skipping plugins install from plugins directory."
    exit
fi

if [ ! -f "/data/.plugins_install_list.txt" ]; then
    echo "Creating empty .plugins_install_list.txt for server and exiting ..."
    echo "" > .plugins_install_list.txt
    exit
fi

while IFS= read -r plugin; do
    echo "Copying plugin data ${plugin} to server ..."
    if [ ! -d "${CUSTOM_SCRIPT_PLUGINS_DIR}/${plugin}" ]; then
        echo "ERROR: Failed to find ${plugin} dir in ${CUSTOM_SCRIPT_PLUGINS_DIR}. Exiting ..."
        exit 1
    fi

    # shellcheck disable=SC2145,SC2086
    rsync ${RSYNC_FLAGS} "${CUSTOM_SCRIPT_PLUGINS_DIR}/${plugin}" /data/plugins
done < "/data/.plugins_install_list.txt"
