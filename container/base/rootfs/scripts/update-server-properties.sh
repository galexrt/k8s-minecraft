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

# Iterate over every server properties patch file
for PROPERTIES_FILE in server.*-patch.properties; do
    SERVER_PROPERTIES="$(awk -F= '!a[$1]++' "${PROPERTIES_FILE}" "${SERVER_PROPERTIES_FILE}" | sort)"
    echo "${SERVER_PROPERTIES}" > "${SERVER_PROPERTIES_FILE}"
done

echo "update-server-properties: Done applying patches."
