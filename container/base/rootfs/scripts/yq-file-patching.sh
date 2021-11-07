#!/bin/bash

export SCRIPTS_DIR="${SCRIPTS_DIR:-/scripts}"

# shellcheck disable=SC1091
source "${SCRIPTS_DIR}/vars.sh"

# Only fail on errors when it is not the first startup
if [ "${FIRST_STARTUP}" = "false" ]; then
    set -e
fi

if [ "${REMOVE_YAML_PATCH_FILES}" = "true" ]; then
    # Delete patch files
    find "${DATA_DIR}" \
        \( \
            \( \
                \( \
                    -iwholename "${DATA_DIR}/plugins/dynmap/web/tiles" \
                    -o -iwholename "${DATA_DIR}/plugins/Essentials/userdata" \
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
fi

echo "yq-file-patching: YAML patching config files ..."
DATA_PATCH_FILES=( "${DATA_DIR}"/*.*-patch.yml)

find "${DATA_DIR}/plugins" "${DATA_PATCH_FILES[@]}" \
    \( \
        \( \
            \( \
                -iwholename "${DATA_DIR}/plugins/dynmap/web/tiles" \
                -o -iwholename "${DATA_DIR}/plugins/Essentials/userdata" \
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

echo "yq-file-patching: Completed YAML patching config files."
