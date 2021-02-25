#!/bin/bash

# shellcheck disable=SC2034

RSYNC_FLAGS="${RSYNC_FLAGS:---ignore-times --recursive --verbose}"
POD_HOSTNAME="$(cat /etc/hostname)"
SERVER_NAME_WITHOUT_NUMBER="${POD_HOSTNAME%-*}"
POD_ID="$(echo "${POD_HOSTNAME}" | rev | cut -d'-' -f1 | rev)"
POD_ID_PLUS="$(( POD_ID + 1 ))"
# Assume it is not a first startup unless otherwise set
FIRST_STARTUP="${FIRST_STARTUP:-false}"
