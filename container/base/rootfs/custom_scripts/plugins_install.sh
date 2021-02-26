#!/bin/bash

# shellcheck disable=SC1091
source /custom_scripts/vars.sh

/custom_scripts/pre/jars-removal.sh
/custom_scripts/pre/plugins-install.sh
/custom_scripts/pre/server-base-install.sh
/custom_scripts/pre/server-configs-install.sh

/custom_scripts/post/envsubst.sh
/custom_scripts/post/yq-file-patching.sh
