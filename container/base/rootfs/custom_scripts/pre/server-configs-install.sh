#!/bin/bash

set -e

# shellcheck disable=SC1091
source /custom_scripts/vars.sh

CUSTOM_SCRIPT_SERVER_CONFIGS_INSTALL="${CUSTOM_SCRIPT_SERVER_CONFIGS_INSTALL:-false}"
CUSTOM_SCRIPT_SERVER_CONFIGS_DIR="${CUSTOM_SCRIPT_SERVER_CONFIGS_DIR:-/repo/servers}"

if [ "${CUSTOM_SCRIPT_SERVER_CONFIGS_INSTALL}" != "true" ]; then
    echo "Skipping server config data install."
    exit
fi

if [ -d "${CUSTOM_SCRIPT_SERVER_CONFIGS_DIR}/${SERVER_NAME_WITHOUT_NUMBER}/data" ]; then
    echo "Copying ${SERVER_NAME_WITHOUT_NUMBER}/data server config data to server ..."
    # shellcheck disable=SC2145,SC2086
    rsync ${RSYNC_FLAGS} "${CUSTOM_SCRIPT_SERVER_CONFIGS_DIR}/${SERVER_NAME_WITHOUT_NUMBER}/data/" /data/
else
    echo "Skipping ${SERVER_NAME_WITHOUT_NUMBER}/data server config data install, no dir found in ${CUSTOM_SCRIPT_SERVER_CONFIGS_DIR}/${SERVER_NAME_WITHOUT_NUMBER}/data/ ..."
fi

if [ -d "${CUSTOM_SCRIPT_SERVER_CONFIGS_DIR}/${SERVER_NAME_WITHOUT_NUMBER}/${POD_HOSTNAME}" ]; then
    echo "Copying ${POD_HOSTNAME} server config data to server ..."
    # shellcheck disable=SC2145,SC2086
    rsync ${RSYNC_FLAGS} "${CUSTOM_SCRIPT_SERVER_CONFIGS_DIR}/${SERVER_NAME_WITHOUT_NUMBER}/${POD_HOSTNAME}/" /data/
    sleep 5
else
    echo "Skipping ${POD_HOSTNAME} server config data install, no dir found in ${CUSTOM_SCRIPT_SERVER_CONFIGS_DIR}/${SERVER_NAME_WITHOUT_NUMBER}/${POD_HOSTNAME}/ ..."
fi
