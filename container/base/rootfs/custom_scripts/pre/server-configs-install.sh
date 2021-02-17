#!/bin/bash

set -e

POD_HOSTNAME="$(cat /etc/hostname)"
SERVER_NAME="${POD_HOSTNAME%-*}"
CUSTOM_SCRIPT_SERVER_CONFIGS_INSTALL="${CUSTOM_SCRIPT_SERVER_CONFIGS_INSTALL:-false}"
CUSTOM_SCRIPT_SERVER_CONFIGS_DIR="${CUSTOM_SCRIPT_SERVER_CONFIGS_DIR:-/repo/servers}"
RSYNC_FLAGS="${RSYNC_FLAGS:---ignore-times --recursive --verbose}"

if [ "${CUSTOM_SCRIPT_SERVER_CONFIGS_INSTALL}" != "true" ]; then
    echo "Skipping server config data install."
    exit
fi

if [ -d "${CUSTOM_SCRIPT_SERVER_CONFIGS_DIR}/${SERVER_NAME}/data" ]; then
    echo "Copying ${SERVER_NAME}/data server config data to server ..."
    # shellcheck disable=SC2145,SC2086
    rsync ${RSYNC_FLAGS} "${CUSTOM_SCRIPT_SERVER_CONFIGS_DIR}/${SERVER_NAME}/data/" /data/
else
    echo "Skipping ${SERVER_NAME}/data server config data install, no dir found in ${CUSTOM_SCRIPT_SERVER_CONFIGS_DIR}/${SERVER_NAME}/data/ ..."
fi

if [ -d "${CUSTOM_SCRIPT_SERVER_CONFIGS_DIR}/${SERVER_NAME}/${POD_HOSTNAME}" ]; then
    echo "Copying ${POD_HOSTNAME} server config data to server ..."
    # shellcheck disable=SC2145,SC2086
    rsync ${RSYNC_FLAGS} "${CUSTOM_SCRIPT_SERVER_CONFIGS_DIR}/${SERVER_NAME}/${POD_HOSTNAME}/" /data/
    sleep 5
else
    echo "Skipping ${POD_HOSTNAME} server config data install, no dir found in ${CUSTOM_SCRIPT_SERVER_CONFIGS_DIR}/${SERVER_NAME}/${POD_HOSTNAME}/ ..."
fi
