#!/bin/bash

export SCRIPTS_DIR="${SCRIPTS_DIR:-/scripts}"

# shellcheck disable=SC1091
source "${SCRIPTS_DIR}/vars.sh"

export DEBUG="${DEBUG:-false}"
export SERVER_TEMPLATE_PATH="${SERVER_TEMPLATE_PATH:-${SERVER_TEMPLATE_BASE_DIR}/${GAMESERVER_SERVER_NAME_WONUM}}"
export SERVER_TEMPLATE_MODE="${SERVER_TEMPLATE_MODE:-random}" # `random` or `ordered` mode

if [ "${SERVER_TEMPLATE_ENABLED}" != "true" ]; then
    echo "server-template: Server Template System is disabled."
    exit
fi

if [ ! -d "${SERVER_TEMPLATE_BASE_DIR}" ]; then
    echo "server-template: Server Template base dir (${SERVER_TEMPLATE_BASE_DIR}) does not exist. Exiting 1 ..."
    exit 1
fi
if [ ! -d "${SERVER_TEMPLATE_PATH}" ]; then
    echo "server-template: Server Template path (${SERVER_TEMPLATE_PATH}) does not exist, skipping ..."
    exit 0
fi

SELECTED_FOLDER=""

case "${SERVER_TEMPLATE_MODE}" in
*)
    echo "server-template: Random Mode"
    SELECTED_FOLDER="$(find "${SERVER_TEMPLATE_PATH}" -maxdepth 1 -type d -print0 | shuf -zn1 | tr -d '\0')"
    ;;
esac

if [ -z "${SELECTED_FOLDER}" ]; then
    ecoh "server-template: No folder has been selected."
    exit 0
fi

SELECTED_FOLDER_CLEANUP_SCRIPT="${SERVER_TEMPLATE_PATH}/$(basename "${SELECTED_FOLDER}".sh)"
if [ -x "${SELECTED_FOLDER_CLEANUP_SCRIPT}" ]; then
    echo "server-template: Running ${SELECTED_FOLDER_CLEANUP_SCRIPT} script ..."
    bash "${SELECTED_FOLDER_CLEANUP_SCRIPT}"
fi
SERVER_CLEANUP_SCRIPT="${SERVER_TEMPLATE_PATH}/cleanup.sh"
if [ -x "${SERVER_CLEANUP_SCRIPT}" ]; then
    echo "server-template: Running ${SERVER_CLEANUP_SCRIPT} script ..."
    bash "${SERVER_CLEANUP_SCRIPT}"
fi

echo "server-template: Copying ${SELECTED_FOLDER}/ to ${DATA_DIR}/ ..."
# shellcheck disable=SC2086
rsync ${RSYNC_FLAGS} "${SELECTED_FOLDER}/" "${DATA_DIR}/"

echo "server-template: Template copy completed."
