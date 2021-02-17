#!/bin/bash

RSYNC_FLAGS="${RSYNC_FLAGS:---ignore-times --recursive --verbose}"

JAVA_JAR="${JAVA_JAR:-}"
JAVA_FLAGS="${JAVA_FLAGS:-}"

if [ -d /custom_scripts/pre/ ]; then
    for f in /custom_scripts/pre/*.sh; do
        echo "Running pre custom_script ${f} ..."
        bash "${f}" || { echo "pre custom_script ${f} failed. Exiting ..."; exit 1; }
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
        bash "${f}" || { echo "post custom_script ${f} failed. Exiting ..."; exit 1; }
        echo "Done. Ran post custom_script ${f}."
    done
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

    echo "Running java command:"
    set -x
    exec /usr/bin/java "${@}"
fi

echo "Running arbitrary command ..."
set -x
exec "${@}"
