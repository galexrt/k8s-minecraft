#!/bin/bash

DATA_DIR="${DATA_DIR:-/data}"
RSYNC_FLAGS="${RSYNC_FLAGS:---ignore-times --recursive --quiet}"
JAVA_CMD="${JAVA_CMD:-/usr/bin/java}"
JAVA_JAR="${JAVA_JAR:-}"
JAVA_FLAGS="${JAVA_FLAGS:-}"

RESTART_JAVA_PROCESS="${RESTART_JAVA_PROCESS:-true}"
RESTART_PAUSE_FILE="${RESTART_PAUSE_FILE:-${DATA_DIR}/.pause_restart}"
RESTART_PAUSE_CHECK_INTERVAL="${RESTART_PAUSE_CHECK_INTERVAL:-3}"
SERVER_STATUS_PLUGIN_STATUS_FILE="${SERVER_STATUS_PLUGIN_STATUS_FILE:-${DATA_DIR}/plugins/ServerStatus/Status.yml}"
FIRST_STARTUP_FILE="${DATA_DIR}/.first_startup_complete"
# shellcheck disable=SC2034
REVISION_FILE="${DATA_DIR}/.last_revision"
GIT_SYNC_REPO_DIR="${GIT_SYNC_REPO_DIR:-/repo/servers}"
GIT_SYNC_PLUGINS_DIR="${GIT_SYNC_PLUGINS_DIR:-plugins/}"
GIT_SYNC_WATCH_SLEEP_INTERVAL="${GIT_SYNC_WATCH_SLEEP_INTERVAL:-15}"
GIT_SYNC_IGNORED_CHANGED_FILES="${GIT_SYNC_IGNORED_CHANGED_FILES:-(proxy-plugins)\/}"
GIT_SYNC_PLUGINS_INSTALL_FILE_BASE="${GIT_SYNC_PLUGINS_INSTALL_FILE_BASE:-/plugins_install_list/base_plugins_install_list.txt}"
GIT_SYNC_PLUGINS_INSTALL_FILE="${GIT_SYNC_PLUGINS_INSTALL_FILE:-/plugins_install_list/plugins_install_list.txt}"
GIT_SYNC_SERVERS_BASE_COPY="${GIT_SYNC_SERVERS_BASE_COPY:-true}"

REMOVE_YAML_PATCH_FILES="${REMOVE_YAML_PATCH_FILES:-false}"

POD_HOSTNAME="$(cat /etc/hostname)"
POD_ID="$(echo "${POD_HOSTNAME}" | rev | cut -d'-' -f1 | rev)"
# shellcheck disable=SC2034
POD_ID_PLUS="$(( POD_ID + 1 ))"

GAMESERVER_POD_HOSTNAME="${GAMESERVER_POD_HOSTNAME:-${POD_HOSTNAME}}"
# shellcheck disable=SC2034
GAMESERVER_SERVER_NAME_WONUM="${POD_HOSTNAME%-*}"
# This assumes the databases are named `mc_POD_HOSTNAME`
GAMESERVER_MYSQL_SPECIFIC_DBNAME="${GAMESERVER_MYSQL_SPECIFIC_DBNAME:-mc_${POD_HOSTNAME//-/_}}"
GAMESERVER_SERVER_TYPE="${GAMESERVER_SERVER_TYPE:-unset}"

export FIRST_STARTUP="${FIRST_STARTUP:-false}"

# First startup check
if [ ! -f "${FIRST_STARTUP_FILE}" ]; then
    export FIRST_STARTUP="true"
fi

if [ -f "${DATA_DIR}/.env" ]; then
    # shellcheck disable=SC1091
    source "${DATA_DIR}/.env"
fi
