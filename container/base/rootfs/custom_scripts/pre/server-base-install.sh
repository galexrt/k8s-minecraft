#!/bin/bash

set -e

# shellcheck disable=SC1091
source /custom_scripts/vars.sh

CUSTOM_SCRIPT_SERVER_BASE_INSTALL="${CUSTOM_SCRIPT_SERVER_BASE_INSTALL:-false}"
CUSTOM_SCRIPT_SERVER_BASE_DIR="${CUSTOM_SCRIPT_SERVER_BASE_DIR:-/repo/servers-base}"

if [ "${CUSTOM_SCRIPT_SERVER_BASE_INSTALL}" != "true" ]; then
    echo "Skipping server base install."
    exit
fi

if [ -d "${CUSTOM_SCRIPT_SERVER_BASE_DIR}" ]; then
    echo "Copying ${CUSTOM_SCRIPT_SERVER_BASE_DIR}/ server base to server ..."
    # shellcheck disable=SC2145,SC2086
    rsync ${RSYNC_FLAGS} "${CUSTOM_SCRIPT_SERVER_BASE_DIR}/" /data/
else
    echo "Skipping ${CUSTOM_SCRIPT_SERVER_BASE_DIR}/ server base install, no dir found in ${CUSTOM_SCRIPT_SERVER_BASE_DIR}/ ..."
fi
