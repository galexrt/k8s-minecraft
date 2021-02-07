#!/bin/bash

set -e

POD_HOSTNAME="$(cat /etc/hostname)"
POD_ID="$(echo "${POD_HOSTNAME}" | rev | cut -d'-' -f1 | rev)"
POD_ID_PLUS="$(( POD_ID + 1 ))"
echo "POD_ID is: ${POD_ID} (+1 is ${POD_ID_PLUS})"
# This assumes the databases are named `mc_POD_HOSTNAME`
GAMESERVER_MYSQL_SPECIFIC_DBNAME="${GAMESERVER_MYSQL_SPECIFIC_DBNAME:-mc_${POD_HOSTNAME//-/_}}"
GAMESERVER_POD_HOSTNAME="${GAMESERVER_POD_HOSTNAME:-${POD_HOSTNAME}}"
GAMESERVER_SERVER_TYPE="${GAMESERVER_SERVER_TYPE:-unset}"

echo "envsubst: Running envsubst on config files ..."
for var in "${!GAMESERVER_@}"; do
    echo "Replacing var ${var} in files ..."
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
                \) \
            \) -print0 \
        \) | \
            while IFS= read -r -d '' file; do
                value="${!var}"
                # In value replacements are done here
                value="${value//\%POD_ID\%/${POD_ID}}"
                value="${value//\%POD_ID_PLUS\%/${POD_ID_PLUS}}"

                # Sed replacement
                sed -i 's#${'"${var}"'}#'"${value}"'#g' "${file}"
            done
done
echo "envsubst: Done envsubst on config files."
