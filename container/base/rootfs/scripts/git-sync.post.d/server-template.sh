#!/bin/bash

export SCRIPTS_DIR="${SCRIPTS_DIR:-/scripts}"

# shellcheck disable=SC1091
source "${SCRIPTS_DIR}/vars.sh"

export DEBUG="${DEBUG:-false}"

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
# TODO implement logic for ordered mode
#ordered)
#    echo "server-template: Ordered Mode"
#    SELECTED_FOLDER=""
#    ;;
*)
    echo "server-template: Random Mode"
    SELECTED_FOLDER="$(find "${SERVER_TEMPLATE_PATH}" -maxdepth 1 -type d -print0 | shuf -zn1)"
    ;;
esac

if [ -z "${SELECTED_FOLDER}" ]; then
    ecoh "server-template: No folder has been selected."
    exit 0
fi

echo "server-template: Copying ${SELECTED_FOLDER}/ to ${DATA_DIR}/ ..."
# shellcheck disable=SC2086
rsync -i ${RSYNC_FLAGS} "${SELECTED_FOLDER}/" "${DATA_DIR}/"

echo "server-template: Template copy completed."
