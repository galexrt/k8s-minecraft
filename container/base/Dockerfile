FROM fedora:34

ENV HOME="/minecraft" \
    DATA_DIR="/data" \
    LANG="en_US.UTF-8" \
    LANGUAGE="en_US" \
    LC_ALL="en_US.UTF-8" \
    YQ_VERSION="v4.15.1" \
    YQ_BINARY="yq_linux_amd64" \
    JAVA_DL_URL="https://github.com/adoptium/temurin18-binaries/releases/download/jdk-18.0.1%2B10/OpenJDK18U-jdk_x64_linux_hotspot_18.0.1_10.tar.gz" \
    JAVA_HOME="/opt/jdk-18"

COPY rootfs /

# libwebp-tools is installed for dynmap / bluemap users
RUN dnf upgrade -y && \
    dnf install -y \
        tini wget procps net-tools findutils \
        glibc-locale-source glibc-langpack-en libwebp-tools \
        rsync inotify-tools tar git bind-utils && \
    dnf clean all && \
    localedef --quiet --force -i en_US -f UTF-8 "$LANG" && \
    echo "YQ download and install" && \
    wget -O- -q -T 5 -t 3 "https://github.com/mikefarah/yq/releases/download/${YQ_VERSION}/${YQ_BINARY}.tar.gz" | tar xz && \
    mv "${YQ_BINARY}" /usr/bin/yq && \
    chmod 755 /usr/bin/yq && \
    mkdir -p "$JAVA_HOME" "$DATA_DIR" /custom_data /custom_scripts && \
    groupadd \
        --gid 1337 \
        minecraft && \
    useradd \
        --uid 1337 \
        --gid 1337 \
        --create-home \
        --home-dir "$HOME" \
        minecraft && \
    echo "Java Install" && \
    cd /opt && \
    JAVA_TAR="$(basename "$JAVA_DL_URL")" && \
    wget -O "/opt/$JAVA_TAR" -q -T 5 -t 3 "$JAVA_DL_URL" && \
    wget -O- -q -T 5 -t 3 "$JAVA_DL_URL.sha256.txt" | sha256sum -c && \
    cd "$JAVA_HOME" && \
    tar xfz "/opt/$JAVA_TAR" --strip-components=1 && \
    rm -f "/opt/$JAVA_TAR" && \
    ln -sfn "$JAVA_HOME/bin/"* /usr/local/bin && \
    echo "Java Install Completed" && \
    chmod -R 770 "$HOME" "$DATA_DIR" /custom_data /custom_scripts && \
    chown -R 1337:1337 "$HOME" "$DATA_DIR" /custom_data /custom_scripts && \
    chmod 755 /scripts/*

WORKDIR "$DATA_DIR"

USER 1337

ENTRYPOINT ["/usr/bin/tini", "--", "/scripts/entrypoint.sh"]

CMD ["java"]
