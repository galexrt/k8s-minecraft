#!/bin/bash

# shellcheck disable=SC1091
source /custom_scripts/vars.sh

if [ "${CUSTOM_SCRIPT_JARS_REMOVE}" = "true" ]; then
    echo "Removing all /data/plugins/ jar files ..."
    rm -rf /data/plugins/*.jar
    echo "Removed all /data/plugins/ jar files."
else
    echo "Skipping all jar removal from plugins directory."
fi
