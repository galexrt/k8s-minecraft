#!/bin/bash

# shellcheck disable=SC1091
source /custom_scripts/vars.sh

# Delete patch files
find /data \
    \( \
        \( \
            \( \
                -iwholename '/data/plugins/dynmap/web/tiles' \
                -o -iwholename '/data/plugins/Essentials/userdata' \
            \) \
            -prune -false \
        \) \
       -o \( \
            -type f \
            -a \( \
                \( -iname '*.*-patch.yml' \) \
                -o \( -iname '*.*-patch.yaml' \) \
            \) \
        \) -exec rm {} + \
    \)

if [ "${PLUGINS_INSTALL_REMOVE_JARS}" == "true" ]; then
    /custom_scripts/pre/jars-removal.sh
fi
/custom_scripts/pre/plugins-install.sh
/custom_scripts/pre/server-base-install.sh
/custom_scripts/pre/server-configs-install.sh

/custom_scripts/post/envsubst.sh
/custom_scripts/post/yq-file-patching.sh
