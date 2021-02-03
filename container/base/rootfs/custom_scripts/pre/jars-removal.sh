#!/bin/bash

CUSTOM_SCRIPT_JARS_REMOVE="${CUSTOM_SCRIPT_JARS_REMOVE:-false}"

if [ "${CUSTOM_SCRIPT_JARS_REMOVE}" = "true" ]; then
    echo "Removing all /data/plugins/ jar files ..."
    rm -rf /data/plugins/*.jar
    echo "Removed all /data/plugins/ jar files."
else
    echo "Skipping all jar removal from plugins directory."
fi
