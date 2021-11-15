#!/bin/bash

set -e

export SCRIPTS_DIR="${SCRIPTS_DIR:-/scripts}"

# shellcheck disable=SC1091
source "${SCRIPTS_DIR}/vars.sh"

SERVER_PROPERTIES_FILE="${DATA_DIR}/server.properties"

if [ ! -f "${SERVER_PROPERTIES_FILE}" ]; then
    echo "update-server-properties: server.properties not found. Skipping ..."
    exit 0
fi

# Load patch / tweak files
SERVER_PROPERTIES="$(awk -F= '!a[$1]++' "${SERVER_PROPERTIES_FILE}" $(find "${DATA_DIR}" -maxdepth 1 -iname 'server.*-patch.properties'))"
echo "${SERVER_PROPERTIES}" > "${SERVER_PROPERTIES_FILE}"

echo "update-server-properties: Done applying patches."
