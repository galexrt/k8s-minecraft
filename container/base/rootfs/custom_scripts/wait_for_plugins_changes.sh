#!/bin/bash

# shellcheck disable=SC1091
source /custom_scripts/vars.sh

SCRIPT_PID="$$"

cleanup() {
    # Remove restart pause file
    rm -f "${RESTART_PAUSE_FILE}"
    kill -s SIGTERM "${SCRIPT_PID}"
    exit 0
}
trap cleanup SIGINT SIGTERM

plugins_install() {
    echo "$(date) Running plugin installation scripts ..."
    if [ -f "${SERVER_STATUS_PLUGIN_STATUS_FILE}" ]; then
        local server_status
        server_status="$(cut -d' ' -f2 "${SERVER_STATUS_PLUGIN_STATUS_FILE}")"
        # When the status is `Starting`, we need to wait till it is `Ready`
        if [ "${server_status}" = "Starting" ]; then
            echo -n "-> Server Status is ${server_status}: Waiting till status changes to other status ..."
            while true; do
                sleep 3
                if [ ! -e "${SERVER_STATUS_PLUGIN_STATUS_FILE}" ]; then
                    echo "$(date) WARNING! Server Status file not found anymore, continuing plugins install ..."
                    break
                fi

                server_status="$(cut -d' ' -f2 "${SERVER_STATUS_PLUGIN_STATUS_FILE}")"
                if [ "${server_status}" != "Starting" ]; then
                    echo "$(date) Server Status is now ${server_status}, continuing plugin install ..."
                    break
                fi
                echo "$(date) Server Status still not changed, waiting 3 seconds ..."
            done
        fi
    fi
    echo "$(date) $0" > "${RESTART_PAUSE_FILE}"
    /custom_scripts/plugins_install.sh
    rm -f "${RESTART_PAUSE_FILE}"
    echo "$(date) Plugins install from list completed."
}

# Unset the list as we rely on the plugin list file to change
export PLUGINS_TO_INSTALL=""
unset PLUGINS_TO_INSTALL

CUSTOM_SCRIPT_PLUGINS_INSTALL_SLEEP_TIME="${CUSTOM_SCRIPT_PLUGINS_INSTALL_SLEEP_TIME:-7}"
CUSTOM_SCRIPT_PLUGINS_INSTALL_RESYNC="${CUSTOM_SCRIPT_PLUGINS_INSTALL_RESYNC:-false}"
# After roughly 900 seconds a full sync is run
CUSTOM_SCRIPT_PLUGINS_INSTALL_RESYNC_WAIT="${CUSTOM_SCRIPT_PLUGINS_INSTALL_RESYNC_WAIT:-900}"
# Must be kept in sync with the `pre/plugins-install.sh` script
CUSTOM_SCRIPT_PLUGINS_INSTALL_FILE_BASE="${CUSTOM_SCRIPT_PLUGINS_INSTALL_FILE_BASE:-/plugins_install_list/base_plugins_install_list.txt}"
CUSTOM_SCRIPT_PLUGINS_INSTALL_FILE="${CUSTOM_SCRIPT_PLUGINS_INSTALL_FILE:-/plugins_install_list/plugins_install_list.txt}"
CUSTOM_SCRIPT_PLUGINS_DIR="${CUSTOM_SCRIPT_PLUGINS_DIR:-/repo/plugins}"

PLUGINS_LIST_CHECKSUM="$(md5sum "${CUSTOM_SCRIPT_PLUGINS_INSTALL_FILE_BASE}" "${CUSTOM_SCRIPT_PLUGINS_INSTALL_FILE}")"
PLUGINS_DIR_REVISION="$(realpath "${CUSTOM_SCRIPT_PLUGINS_DIR}" | md5sum)"
LAST_RESYNC="$(date +%s)"

if [ ! -e "${CUSTOM_SCRIPT_PLUGINS_INSTALL_FILE_BASE}" ]; then
    CUSTOM_SCRIPT_PLUGINS_INSTALL_FILE_BASE="/dev/null"
fi

if [ -f "${SERVER_STATUS_PLUGIN_STATUS_FILE}" ]; then
    echo "ServerStatus plugin Status file found"
fi

echo "$(date) Initial plugins list checksum ${PLUGINS_LIST_CHECKSUM} and plugin dir revision ${PLUGINS_DIR_REVISION}, starting loop with sleep ${CUSTOM_SCRIPT_PLUGINS_INSTALL_SLEEP_TIME} ..."

while true; do
    sleep "${CUSTOM_SCRIPT_PLUGINS_INSTALL_SLEEP_TIME}"

    if [ "${CUSTOM_SCRIPT_PLUGINS_INSTALL_RESYNC}" = "true" ]; then
        # Check if it is time for a resync
        NOW="$(date +%s)"
        if [ "$(( NOW - LAST_RESYNC ))" -ge "${CUSTOM_SCRIPT_PLUGINS_INSTALL_RESYNC_WAIT}" ]; then
            echo "$(date) Plugin resync loop triggered."
            plugins_install
            LAST_RESYNC="$(date +%s)"
            continue
        fi
    fi

    if [ ! -e "${CUSTOM_SCRIPT_PLUGINS_INSTALL_FILE}" ]; then
        echo "$(date) Unable to find plugin install list, sleeping again ..."
        continue
    fi

    PLUGINS_LIST_CHECKSUM_NEW="$(md5sum "${CUSTOM_SCRIPT_PLUGINS_INSTALL_FILE_BASE}" "${CUSTOM_SCRIPT_PLUGINS_INSTALL_FILE}")"
    PLUGINS_DIR_REVISION_NEW="$(realpath "${CUSTOM_SCRIPT_PLUGINS_DIR}" | md5sum)"
    if [ "${PLUGINS_LIST_CHECKSUM}" = "${PLUGINS_LIST_CHECKSUM_NEW}"  ] && [ "${PLUGINS_DIR_REVISION_NEW}" = "${PLUGINS_DIR_REVISION}" ]; then
        continue
    fi

    echo "$(date) Plugins install list has been updated."
    # Update plugins on list file checksum change or when the dir path changed (e.g., git-sync)
    sleep_time="$(shuf -i 0-15 -n 1)"
    echo "$(date) Sleeping ${sleep_time} before running plugins_install scripts ..."
    PLUGINS_LIST_CHECKSUM="$(md5sum "${CUSTOM_SCRIPT_PLUGINS_INSTALL_FILE_BASE}" "${CUSTOM_SCRIPT_PLUGINS_INSTALL_FILE}")"
    PLUGINS_DIR_REVISION="$(realpath "${CUSTOM_SCRIPT_PLUGINS_DIR}" | md5sum)"
    plugins_install
done
