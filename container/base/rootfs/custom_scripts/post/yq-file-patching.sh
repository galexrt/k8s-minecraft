#!/bin/bash

# Only fail on errors when it is not the first startup
if [ "${FIRST_STARTUP}" = "false" ]; then
    set -e
fi

# shellcheck disable=SC1091
source /custom_scripts/vars.sh

echo "yq-file-patching: Running envsubst on config files ..."
DATA_PATCH_FILES=(/data/*.merge-patch.yml)

find /data/plugins "${DATA_PATCH_FILES[@]}" \
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
                \( -iname '*.merge-patch.yml' \) \
                -o \( -iname '*.merge-patch.yaml' \) \
            \) \
        \) -print0 \
    \) | \
        while IFS= read -r -d '' file; do
            echo "yq-file-patching: Patching ${file} file ..."
            # shellcheck disable=SC2016
            yq \
                -i \
                eval-all \
                '. as $item ireduce ({}; . * $item )' "${file/.merge-patch/}" "${file}"
        done

echo "yq-file-patching: Done yq-file-patching on config files ..."
