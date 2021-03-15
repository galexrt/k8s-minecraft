#!/bin/bash

set -e

# shellcheck disable=SC1091
source /custom_scripts/vars.sh

echo "POD_ID is: ${POD_ID} (+1 is ${POD_ID_PLUS})"
# This assumes the databases are named `mc_POD_HOSTNAME`
GAMESERVER_MYSQL_SPECIFIC_DBNAME="${GAMESERVER_MYSQL_SPECIFIC_DBNAME:-mc_${POD_HOSTNAME//-/_}}"
GAMESERVER_SERVER_TYPE="${GAMESERVER_SERVER_TYPE:-unset}"

echo "envsubst: Running envsubst on config files ..."
find /data/*.yml /data/plugins \
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
                \( -iname '*.yml' \) \
                -o \( -iname '*.yaml' \) \
                -o \( -iname '*.txt' \) \
                -o \( -iname '*.properties' \) \
                -o \( -iname '*.conf' \) \
                -o \( -iname '*.json' \) \
                -o \( -iname '*.cm2' \) \
            \) \
        \) -print0 \
    \) | \
        while IFS= read -r -d '' file; do
            # If file doesn't contain any `GAMESERVER_*` vars, skip it early
            # shellcheck disable=SC2016
            if ! grep --quiet --perl-regexp '\${GAMESERVER_.+}' "${file}" > /dev/null 2>&1; then
                continue
            fi
            echo "Replacing vars in ${file} ..."
            for var in "${!GAMESERVER_@}"; do
                value="${!var}"
                # In value replacements are done here
                value="${value//\%POD_ID\%/${POD_ID}}"
                value="${value//\%POD_ID_PLUS\%/${POD_ID_PLUS}}"

                sed -i 's~${'"${var}"'}~'"${value}"'~g' "${file}"
            done
        done

echo "envsubst: Done envsubst on config files."
