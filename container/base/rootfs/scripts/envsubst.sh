#!/bin/bash

set -e

export SCRIPTS_DIR="${SCRIPTS_DIR:-/scripts}"

# shellcheck disable=SC1091
source "${SCRIPTS_DIR}/vars.sh"

ENVSUBST_DIRS="${ENVSUBST_DIRS:-${DATA_DIR}/*.yml ${DATA_DIR}/plugins}"

echo "envsubst: Running envsubst on config files ..."
# shellcheck disable=SC2086
find ${ENVSUBST_DIRS} \
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
                \( -iname '*.yml' \) \
                -o \( -iname '*.yaml' \) \
                -o \( -iname '*.txt' \) \
                -o \( -iname '*.properties' \) \
                -o \( -iname '*.conf' \) \
                -o \( -iname '*.json' \) \
                -o \( -iname '*.cm2' \) \
                -o \( -iname '*.hocon' \) \
                -o \( -iname '*.cfg' \) \
            \) \
        \) -print0 \
    \) | \
        while IFS= read -r -d '' file; do
            # If file doesn't contain any `GAMESERVER_*` vars, skip it early
            # shellcheck disable=SC2016
            if ! grep --quiet --perl-regexp '\${GAMESERVER_.+}' "${file}" > /dev/null 2>&1; then
                continue
            fi
            echo "envsubst: Replacing vars in ${file} ..."
            for var in "${!GAMESERVER_@}"; do
                value="${!var}"
                # In value replacements are done here
                value="${value//\%POD_ID\%/${POD_ID}}"
                value="${value//\%POD_ID_PLUS\%/${POD_ID_PLUS}}"

                sed -i 's~${'"${var}"'}~'"${value}"'~g' "${file}"
            done
        done

echo "envsubst: Done envsubst on config files."
