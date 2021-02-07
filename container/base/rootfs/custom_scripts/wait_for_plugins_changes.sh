#!/bin/bash

cleanup() {
    kill -s SIGTERM $!
    exit 0
}
trap cleanup SIGINT SIGTERM

plugins_install() {
    echo "$(date) Plugins install list has been updated (checksum: ${PLUGINS_LIST_CHECKSUM_NEW}). Triggering plugin installation scripts ..."
    /custom_scripts/pre/jars-removal.sh
    /custom_scripts/pre/plugins-install.sh
    echo "$(date) Plugins install from list completed."
}

# Unset the list as we rely on the plugin list file to change
export PLUGINS_TO_INSTALL=""
unset PLUGINS_TO_INSTALL

PLUGINS_INSTALL_SLEEP_TIME="${PLUGINS_INSTALL_SLEEP_TIME:-10}"

# Must be kept in sync with the `pre/plugins-install.sh` script
CUSTOM_SCRIPT_PLUGINS_INSTALL_FILE="${CUSTOM_SCRIPT_PLUGINS_INSTALL_FILE:-/plugins_install_list/plugins_install_list.txt}"

PLUGINS_LIST_CHECKSUM="$(md5sum "${CUSTOM_SCRIPT_PLUGINS_INSTALL_FILE}")"

echo "Initial plugins list checksum ${PLUGINS_LIST_CHECKSUM}, starting loop with sleep ${PLUGINS_INSTALL_SLEEP_TIME} ..."

# Loop times after which a "resync" will be done
resync_loop_count=1

while true; do
    sleep "${PLUGINS_INSTALL_SLEEP_TIME}"

    # Every 7.5 minutes (45 loops * 10 seconds sleep)
    if [ "${resync_loop_count}" -ge 45 ]; then
        echo "$(date) Plugin resync loop triggered."
        plugins_install
        resync_loop_count=1
        continue
    fi

    resync_loop_count=$(( resync_loop_count + 1 ))
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
