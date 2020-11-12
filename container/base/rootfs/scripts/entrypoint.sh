#!/bin/bash

JAVA_JAR="${JAVA_JAR:-}"

if [ "${1}" = "java" ]; then
    echo "Running java jar because first arg ist 'java' ..."
    shift
    if [ -n "${JAVA_JAR}" ]; then
        set -- -jar "${JAVA_JAR}" "$@"
    else
        echo "WARNING! No JAVA_JAR var set in container."
    fi

    exec /usr/bin/java "${@}"
fi

echo "Running arbitrary command ..."

exec "${@}"
