#!/bin/bash

# Unset the list as we rely on the plugin list file to change
export PLUGINS_TO_INSTALL=""
unset PLUGINS_TO_INSTALL

# Must be kept in sync with the `pre/plugins-install.sh` script
CUSTOM_SCRIPT_PLUGINS_INSTALL_FILE="${CUSTOM_SCRIPT_PLUGINS_INSTALL_FILE:-/plugins_install_list/plugins_install_list.txt}"

PLUGINS_LIST_CHECKSUM="$(md5sum "${CUSTOM_SCRIPT_PLUGINS_INSTALL_FILE}")"

while true; do
    sleep 10
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

    echo "$(date) Plugins install list has been updated. Triggering plugin installation scripts ..."
    /custom_scripts/pre/jars-removal.sh
    /custom_scripts/pre/plugins-install.sh
    echo "$(date) Plugins install from list completed."
done
