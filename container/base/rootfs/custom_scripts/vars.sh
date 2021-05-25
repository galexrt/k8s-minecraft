#!/bin/bash

# shellcheck disable=SC2034

RSYNC_FLAGS="${RSYNC_FLAGS:---ignore-times --recursive --quiet}"
POD_HOSTNAME="$(cat /etc/hostname)"
POD_ID="$(echo "${POD_HOSTNAME}" | rev | cut -d'-' -f1 | rev)"
POD_ID_PLUS="$(( POD_ID + 1 ))"
# Assume it is not a first startup unless otherwise set
FIRST_STARTUP="${FIRST_STARTUP:-false}"
RESTART_PAUSE_FILE="${RESTART_PAUSE_FILE:-/data/.pause_restart}"

CUSTOM_SCRIPT_JARS_REMOVE="${CUSTOM_SCRIPT_JARS_REMOVE:-false}"

GAMESERVER_POD_HOSTNAME="${GAMESERVER_POD_HOSTNAME:-${POD_HOSTNAME}}"
GAMESERVER_SERVER_NAME_WONUM="${POD_HOSTNAME%-*}"
SERVER_STATUS_PLUGIN_STATUS_FILE="${SERVER_STATUS_PLUGIN_STATUS_FILE:-/data/plugins/ServerStatus/Status.yml}"

if [ -f "/data/.env" ]; then
    # shellcheck disable=SC1091
    source /data/.env
fi
