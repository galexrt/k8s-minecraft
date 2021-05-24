#!/bin/bash

set -e

# shellcheck disable=SC1091
source /custom_scripts/vars.sh

CUSTOM_SCRIPT_PLUGINS_INSTALL="${CUSTOM_SCRIPT_PLUGINS_INSTALL:-false}"
CUSTOM_SCRIPT_PLUGINS_INSTALL_FILE_BASE="${CUSTOM_SCRIPT_PLUGINS_INSTALL_FILE_BASE:-/plugins_install_list/base_plugins_install_list.txt}"
CUSTOM_SCRIPT_PLUGINS_INSTALL_FILE="${CUSTOM_SCRIPT_PLUGINS_INSTALL_FILE:-/plugins_install_list/plugins_install_list.txt}"
CUSTOM_SCRIPT_PLUGINS_DIR="${CUSTOM_SCRIPT_PLUGINS_DIR:-/repo/plugins}"

if [ "${CUSTOM_SCRIPT_PLUGINS_INSTALL}" != "true" ]; then
    echo "Skipping plugins install from plugins directory."
    exit
fi

if [ ! -e "${CUSTOM_SCRIPT_PLUGINS_INSTALL_FILE}" ]; then
    echo "No ${CUSTOM_SCRIPT_PLUGINS_INSTALL_FILE} file found, skipping plugins install ..."
    exit
fi
if [ ! -e "${CUSTOM_SCRIPT_PLUGINS_INSTALL_FILE_BASE}" ]; then
    CUSTOM_SCRIPT_PLUGINS_INSTALL_FILE_BASE="/dev/null"
fi

PLUGINS_TO_INSTALL="$(sed -r -e '/^(|#.*)$/d' "${CUSTOM_SCRIPT_PLUGINS_INSTALL_FILE_BASE}" "${CUSTOM_SCRIPT_PLUGINS_INSTALL_FILE}" | sort | uniq)"

while IFS= read -r plugin; do
    n=1
    until [ "$n" -gt 3 ]; do
        if [ -d "${CUSTOM_SCRIPT_PLUGINS_DIR}/${plugin}" ]; then
            echo "Copying plugin data ${plugin} to server (try $n/3) ..."
            if [ "${PLUGINS_INSTALL_REMOVE_JARS}" == "true" ]; then
                # shellcheck disable=SC2145,SC2086
                rsync ${RSYNC_FLAGS} "${CUSTOM_SCRIPT_PLUGINS_DIR}/${plugin}/" /data/plugins/ && break
            else
                # shellcheck disable=SC2145,SC2086
                rsync ${RSYNC_FLAGS} --exclude='*.jar' "${CUSTOM_SCRIPT_PLUGINS_DIR}/${plugin}/" /data/plugins/ && break
            fi
            echo "ERROR: Failed to copy ${plugin} data to server (try $n/3). Sleeping 5 seconds ..."
            sleep 5
        else
            echo "ERROR: Failed to find ${plugin} dir in ${CUSTOM_SCRIPT_PLUGINS_DIR} (try $n/3). Sleeping 20 seconds ..."
            sleep 20
        fi
        n=$(( n + 1 ))
    done
    if [ "$n" -ge 3 ]; then
        echo "ERROR: Failed to install ${plugin} (no dir found). Exiting 1 ..."
        exit 1
    fi
done < <(printf '%s\n' "${PLUGINS_TO_INSTALL}")
