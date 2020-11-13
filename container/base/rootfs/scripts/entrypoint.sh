#!/bin/bash

JAVA_JAR="${JAVA_JAR:-}"
JAVA_FLAGS="${JAVA_FLAGS:-}"

if [ -d /custom_data/ ]; then
    echo "Copying /custom_data dir to /data"
    cp -ar /custom_data/ /data/
fi

if [ "${1}" = "java" ]; then
    echo "Running java jar because first arg ist 'java' ..."
    shift

    if [ -n "${JAVA_FLAGS}" ]; then
        echo "Adding JAVA_FLAGS to args: ${JAVA_FLAGS}"
        set -- "${JAVA_FLAGS}" "$@"
    fi
    if [ -n "${JAVA_JAR}" ]; then
        set -- -jar "${JAVA_JAR}" "$@"
    else
        echo "WARNING! No JAVA_JAR var set in container."
    fi

    exec /usr/bin/java "${@}"
fi

echo "Running arbitrary command ..."
exec "${@}"
