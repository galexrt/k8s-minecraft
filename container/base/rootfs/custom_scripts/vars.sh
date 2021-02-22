#!/bin/bash

# shellcheck disable=SC2034

RSYNC_FLAGS="${RSYNC_FLAGS:---ignore-times --recursive --verbose}"
POD_HOSTNAME="$(cat /etc/hostname)"
POD_ID="$(echo "${POD_HOSTNAME}" | rev | cut -d'-' -f1 | rev)"
POD_ID_PLUS="$(( POD_ID + 1 ))"
