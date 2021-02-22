#!/bin/bash

set -e

# shellcheck disable=SC1091
source /custom_scripts/vars.sh

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
                \( -iname '*.merge-patch.yml' \) \
                -o \( -iname '*.merge-patch.yaml' \) \
            \) \
        \) -print0 \
    \) | \
        while IFS= read -r -d '' file; do
            yq \
                -i \
                eval-all \
                '. as $item ireduce ({}; . * $item )' "${file/.merge-patch/}" "${file}"
        done
