#!/bin/bash

set -e

# shellcheck disable=SC1091
source /custom_scripts/vars.sh

SERVER_PROPERTIES_FILE="${SERVER_PROPERTIES_FILE:-/data/server.properties}"
SERVER_PROPERTIES_TWEAKS_FILE="${SERVER_PROPERTIES_TWEAKS_FILE:-/data/server-props-tweaks.properties}"

SERVER_HOSTNAME="${SERVER_HOSTNAME:-$(cat /etc/hostname | cut -d'-' -f1)}"

if [ ! -f "${SERVER_PROPERTIES_FILE}" ]; then
    echo "server.properties file not found. Skipping ..."
    exit
fi

# Global settings
echo "server.properties: Applying global fixed tweaks ..."
sed -i \
    -e 's/^view-distance=.*/view-distance=8/g' \
    -e 's/^network-compression-threshold=.*/network-compression-threshold=-1/g' \
    -e 's/^online-mode=.*/online-mode=false/g' \
    -e 's/^spawn-protection=.*/spawn-protection=0/g' \
    -e 's/^debug=.*/debug=false/g' \
    -e 's/^max-players=.*/max-players=100/g' \
    -e 's/^server-name=.*/server-name='"${SERVER_HOSTNAME^}"'/g' \
    -e 's/^enable-command-block=.*/enable-command-block=false/g' \
    "${SERVER_PROPERTIES_FILE}"

# Load per server custom tweak file
if [ -f "${SERVER_PROPERTIES_TWEAKS_FILE}" ]; then
    echo "server.properties: Applying server specific tweaks ..."
    while IFS='=' read -r key value; do
        sed \
            -i \
            -e 's~'"${key}"'=.*~'"${key}"'='"${value}"'~g' \
            "${SERVER_PROPERTIES_FILE}"
    done < "${SERVER_PROPERTIES_TWEAKS_FILE}"
    echo "server.properties: Applied server specific tweaks."
fi

echo "server.properties: Done applying tweaks."
