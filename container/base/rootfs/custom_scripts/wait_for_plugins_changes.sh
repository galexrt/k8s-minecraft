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
    echo "$(date) Plugins install list has been updated (checksum: ${PLUGINS_LIST_CHECKSUM_NEW}). Triggering plugin installation scripts ..."
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
CUSTOM_SCRIPT_PLUGINS_INSTALL_FILE="${CUSTOM_SCRIPT_PLUGINS_INSTALL_FILE:-/plugins_install_list/plugins_install_list.txt}"
CUSTOM_SCRIPT_PLUGINS_DIR="${CUSTOM_SCRIPT_PLUGINS_DIR:-/repo/plugins}"

PLUGINS_LIST_CHECKSUM="$(md5sum "${CUSTOM_SCRIPT_PLUGINS_INSTALL_FILE}")"
PLUGINS_DIR_REVISION="$(realpath "${CUSTOM_SCRIPT_PLUGINS_DIR}" | md5sum)"
LAST_RESYNC="$(date +%s)"

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

    PLUGINS_LIST_CHECKSUM_NEW="$(md5sum "${CUSTOM_SCRIPT_PLUGINS_INSTALL_FILE}")"
    PLUGINS_DIR_REVISION_NEW="$(realpath "${CUSTOM_SCRIPT_PLUGINS_DIR}" | md5sum)"
    if [ "${PLUGINS_LIST_CHECKSUM}" = "${PLUGINS_LIST_CHECKSUM_NEW}"  ] && [ "${PLUGINS_DIR_REVISION_NEW}" = "${PLUGINS_DIR_REVISION}" ]; then
        continue
    fi

    # Update plugins on list file checksum change or when the dir path changed (e.g., git-sync)
    sleep_time="$(shuf -i 0-12 -n 1)"
    echo "$(date) Sleeping ${sleep_time} before running plugins_install scripts ..."
    PLUGINS_LIST_CHECKSUM="$(md5sum "${CUSTOM_SCRIPT_PLUGINS_INSTALL_FILE}")"
    PLUGINS_DIR_REVISION="$(realpath "${CUSTOM_SCRIPT_PLUGINS_DIR}" | md5sum)"
    plugins_install
done
