#!/bin/bash

set -e

POD_HOSTNAME="$(cat /etc/hostname)"
POD_ID="$(echo "${POD_HOSTNAME}" | rev | cut -d'-' -f1 | rev)"
echo "POD_ID is: ${POD_ID}"
# This assumes the databases are named `mc_POD_HOSTNAME`
GAMESERVER_MYSQL_SPECIFIC_DBNAME="${GAMESERVER_MYSQL_SPECIFIC_DBNAME:-mc_${POD_HOSTNAME//-/_}}"
GAMESERVER_POD_HOSTNAME="${GAMESERVER_POD_HOSTNAME:-${POD_HOSTNAME}}"
GAMESERVER_SERVER_TYPE="${GAMESERVER_SERVER_TYPE:-unset}"

echo "envsubst: Running envsubst on config files ..."
for var in "${!GAMESERVER_@}"; do
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
                echo "Updating file: $file"
                value="${!var}"
                value="${value//\%POD_ID\%/${POD_ID}}"
                sed -i 's#${'"${var}"'}#'"${value}"'#g' "${file}"
            done
done
echo "envsubst: Done envsubst on config files."
