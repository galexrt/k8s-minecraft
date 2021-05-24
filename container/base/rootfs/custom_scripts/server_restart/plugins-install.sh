#!/bin/bash

# shellcheck disable=SC1091
source /custom_scripts/vars.sh

export PLUGINS_INSTALL_REMOVE_JARS="true"

/custom_scripts/plugins_install.sh
