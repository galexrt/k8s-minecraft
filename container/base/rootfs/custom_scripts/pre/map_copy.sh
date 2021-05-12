#!/bin/bash

# shellcheck disable=SC1091
source /custom_scripts/vars.sh

CUSTOM_SCRIPT_MAP_COPY="${CUSTOM_SCRIPT_MAP_COPY:-false}"

if [ "${CUSTOM_SCRIPT_MAP_COPY}" = "true" ]; then
    if [ ! -d "/data/.maps" ]; then
        echo "No /data/.maps/ dir found."
        exit 0;
    fi
    echo "Found maps for copy directory ..."
    for map in /data/.maps/*/; do
        mapName="$(basename "${map}")"
        echo "Removing map ${mapName} ..."
        rm -rf "/data/${mapName}/"
        echo "Removed and copying map ${mapName} ."
        cp -r "${map}" "/data/${mapName}/"
        echo "Copied map ${mapName} to server."
    done
    echo "Completed map copy process."
fi
