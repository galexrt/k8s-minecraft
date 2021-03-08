#!/bin/bash

# shellcheck disable=SC2034

RSYNC_FLAGS="${RSYNC_FLAGS:---ignore-times --recursive --verbose}"
POD_HOSTNAME="$(cat /etc/hostname)"
POD_ID="$(echo "${POD_HOSTNAME}" | rev | cut -d'-' -f1 | rev)"
POD_ID_PLUS="$(( POD_ID + 1 ))"
# Assume it is not a first startup unless otherwise set
FIRST_STARTUP="${FIRST_STARTUP:-false}"
RESTART_PAUSE_FILE="${RESTART_PAUSE_FILE:-/data/.pause_restart}"

GAMESERVER_POD_HOSTNAME="${GAMESERVER_POD_HOSTNAME:-${POD_HOSTNAME}}"
GAMESERVER_SERVER_NAME_WONUM="${POD_HOSTNAME%-*}"
