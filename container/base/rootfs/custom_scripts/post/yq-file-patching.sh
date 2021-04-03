#!/bin/bash

# Only fail on errors when it is not the first startup
if [ "${FIRST_STARTUP}" = "false" ]; then
    set -e
fi

# shellcheck disable=SC1091
source /custom_scripts/vars.sh

echo "yq-file-patching: Running envsubst on config files ..."
DATA_PATCH_FILES=(/data/*.*-patch.yml)

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
                \( -iname '*.*-patch.yml' \) \
                -o \( -iname '*.*-patch.yaml' \) \
            \) \
        \) -print0 \
    \) | sort -z | \
        while IFS= read -r -d '' file; do
            echo "yq-file-patching: Patching ${file} file ..."
            if [ ! -f "${file/.*-patch/}" ]; then
                echo "yq-file-patching: File to patch doesn't exist (patch: ${file}), skipping ..."
                continue
            fi
            # shellcheck disable=SC2016
            yq \
                -i \
                eval-all \
                '. as $item ireduce ({}; . * $item )' "${file/.*-patch/}" "${file}"
        done

echo "yq-file-patching: Done yq-file-patching on config files ..."
