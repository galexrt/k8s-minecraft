#!/bin/bash

# shellcheck disable=SC1091
source /custom_scripts/vars.sh

export CUSTOM_SCRIPT_JARS_REMOVE="true"

/custom_scripts/plugins-install.sh
