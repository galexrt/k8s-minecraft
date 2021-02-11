#!/bin/bash

set -e

POD_HOSTNAME="$(cat /etc/hostname)"
SERVER_NAME="${POD_HOSTNAME%-*}"
CUSTOM_SCRIPT_SERVER_CONFIGS_INSTALL="${CUSTOM_SCRIPT_SERVER_CONFIGS_INSTALL:-false}"
CUSTOM_SCRIPT_SERVER_CONFIGS_DIR="${CUSTOM_SCRIPT_SERVER_CONFIGS_DIR:-/repo/servers}"
RSYNC_FLAGS="${RSYNC_FLAGS:--aurv}"

if [ "${CUSTOM_SCRIPT_SERVER_CONFIGS_INSTALL}" != "true" ]; then
    echo "Skipping server config data install."
    exit
fi

if [ -d "${CUSTOM_SCRIPT_SERVER_CONFIGS_DIR}/${SERVER_NAME}/${POD_HOSTNAME}" ]; then
    echo "Copying ${POD_HOSTNAME} server config data to server ..."
    # shellcheck disable=SC2145,SC2086
    rsync --dry-run ${RSYNC_FLAGS} "${CUSTOM_SCRIPT_SERVER_CONFIGS_DIR}/${SERVER_NAME}/${POD_HOSTNAME}/" /data/
    echo "ERROR: Failed to copy ${POD_HOSTNAME} server config data to server. Sleeping 5 seconds ..."
    sleep 5
else
    echo "Skipping ${POD_HOSTNAME} server config data install, no dir found in ${CUSTOM_SCRIPT_SERVER_CONFIGS_DIR}/${SERVER_NAME}/${POD_HOSTNAME}/ ..."
fi
