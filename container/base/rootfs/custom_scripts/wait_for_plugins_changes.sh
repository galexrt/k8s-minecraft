#!/bin/bash

# shellcheck disable=SC1091
source /custom_scripts/vars.sh

cleanup() {
    kill -s SIGTERM $!
    exit 0
}
trap cleanup SIGINT SIGTERM

plugins_install() {
    echo "$(date) Plugins install list has been updated (checksum: ${PLUGINS_LIST_CHECKSUM_NEW}). Triggering plugin installation scripts ..."
    /custom_scripts/pre/jars-removal.sh
    /custom_scripts/pre/plugins-install.sh
    /custom_scripts/pre/server-base-install.sh
    /custom_scripts/pre/server-configs-install.sh

    /custom_scripts/post/envsubst.sh
    echo "$(date) Plugins install from list completed."
}

# Unset the list as we rely on the plugin list file to change
export PLUGINS_TO_INSTALL=""
unset PLUGINS_TO_INSTALL

CUSTOM_SCRIPT_PLUGINS_INSTALL_SLEEP_TIME="${CUSTOM_SCRIPT_PLUGINS_INSTALL_SLEEP_TIME:-10}"
CUSTOM_SCRIPT_PLUGINS_INSTALL_RESYNC="${CUSTOM_SCRIPT_PLUGINS_INSTALL_RESYNC:-false}"
# Every 7.5 minutes (45 loops * 10 seconds sleep)
CUSTOM_SCRIPT_PLUGINS_INSTALL_RESYNC_WAIT_COUNT="${CUSTOM_SCRIPT_PLUGINS_INSTALL_RESYNC_WAIT_COUNT:-45}"
# Must be kept in sync with the `pre/plugins-install.sh` script
CUSTOM_SCRIPT_PLUGINS_INSTALL_FILE="${CUSTOM_SCRIPT_PLUGINS_INSTALL_FILE:-/plugins_install_list/plugins_install_list.txt}"

PLUGINS_LIST_CHECKSUM="$(md5sum "${CUSTOM_SCRIPT_PLUGINS_INSTALL_FILE}")"

echo "Initial plugins list checksum ${PLUGINS_LIST_CHECKSUM}, starting loop with sleep ${CUSTOM_SCRIPT_PLUGINS_INSTALL_SLEEP_TIME} ..."

# Loop times after which a "resync" will be done
resync_loop_count=1

while true; do
    sleep "${CUSTOM_SCRIPT_PLUGINS_INSTALL_SLEEP_TIME}"

    if [ "${CUSTOM_SCRIPT_PLUGINS_INSTALL_RESYNC}" = "true" ]; then
        if [ "${resync_loop_count}" -ge "${CUSTOM_SCRIPT_PLUGINS_INSTALL_RESYNC_WAIT_COUNT}" ]; then
            echo "$(date) Plugin resync loop triggered."
            plugins_install
            resync_loop_count=1
            continue
        fi
        resync_loop_count=$(( resync_loop_count + 1 ))
    fi

    if [ ! -e "${CUSTOM_SCRIPT_PLUGINS_INSTALL_FILE}" ]; then
        echo "$(date) Unable to find plugin install list, sleeping again ..."
        continue
    fi

    PLUGINS_LIST_CHECKSUM_NEW="$(md5sum "${CUSTOM_SCRIPT_PLUGINS_INSTALL_FILE}")"
    if [ "${PLUGINS_LIST_CHECKSUM}" = "${PLUGINS_LIST_CHECKSUM_NEW}"  ]; then
        continue
    fi
    # Update plugins list checksum on change
    PLUGINS_LIST_CHECKSUM="${PLUGINS_LIST_CHECKSUM_NEW}"

    plugins_install
done
