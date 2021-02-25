#!/bin/bash

RSYNC_FLAGS="${RSYNC_FLAGS:---ignore-times --recursive --verbose}"
JAVA_JAR="${JAVA_JAR:-}"
JAVA_FLAGS="${JAVA_FLAGS:-}"
RESTART_JAVA_PROCESS="${RESTART_JAVA_PROCESS:-true}"

export FIRST_STARTUP="${FIRST_STARTUP:-false}"

if [ ! -f "/data/.first_startup_complete" ]; then
    echo "First start detected! Setting FIRST_STARTUP=true ..."
    export FIRST_STARTUP="true"
fi

if [ -d /custom_scripts/pre/ ]; then
    for f in /custom_scripts/pre/*.sh; do
        echo "Running pre custom_script ${f} ..."
        bash "${f}" || {
            if [ "${FIRST_STARTUP}" = "true" ]; then
                echo "Ignoring pre custom_script ${f} failure."; return;
            fi;
            echo "pre custom_script ${f} failed. Exiting ...";
            exit 1;
        }
        echo "Done. Ran pre custom_script ${f}."
    done
fi

if [ -d /custom_data/ ]; then
    echo "Copying /custom_data dir to /data"
    # shellcheck disable=SC2145,SC2086
    rsync ${RSYNC_FLAGS} /custom_data/ /data/
    echo "Done. Copying /custom_data dir"
fi

if [ -d /custom_scripts/post/ ]; then
    for f in /custom_scripts/post/*.sh; do
        echo "Running post custom_script ${f} ..."
        bash "${f}" || {
            if [ "${FIRST_STARTUP}" = "true" ]; then
                echo "Ignoring post custom_script ${f} failure."; return;
            fi;
            echo "post custom_script ${f} failed. Exiting ...";
            exit 1;
        }
        echo "Done. Ran post custom_script ${f}."
    done
fi

# Add first startup tag file
if [ "${FIRST_STARTUP}" = "true" ]; then
    date +%s > /data/.first_startup_complete
    echo "First start complete!"
fi

if [ "${1}" = "java" ]; then
    echo "Running java jar because first arg ist 'java' ..."
    shift

    if [ -n "${JAVA_JAR}" ]; then
        set -- -jar "${JAVA_JAR}" "$@"
    else
        echo "WARNING! No JAVA_JAR var set in container."
    fi
    if [ -n "${JAVA_FLAGS}" ]; then
        echo "Adding JAVA_FLAGS to args: ${JAVA_FLAGS}"
        # shellcheck disable=SC2086
        set -- ${JAVA_FLAGS} "$@"
    fi

    # Set Java PID to the script till the PID is set
    java_pid="$$"
    cleanup() {
        kill -s SIGTERM "${java_pid}"
        wait "${java_pid}"
    }
    trap cleanup SIGINT SIGTERM

    set -x
    while true; do
        echo "$(date) Running java command:"
        /usr/bin/java "${@}" < /dev/stdin &
        java_pid=$!

        wait "${java_pid}"
        rt=$?
        if [ "${RESTART_JAVA_PROCESS}" != "true" ]; then
            echo "$(date) Java program exited with code ${rt}, terminating script."
            exit ${rt}
        fi
        echo "$(date) Java program exited with code ${rt}, restarting ..."
    done
fi

echo "Running arbitrary command ..."
set -x
exec "${@}"
