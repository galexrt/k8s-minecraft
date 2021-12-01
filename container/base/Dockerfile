FROM fedora:34

ENV HOME="/minecraft" \
    DATA_DIR="/data" \
    LANG="en_US.UTF-8" \
    LANGUAGE="en_US" \
    LC_ALL="en_US.UTF-8" \
    YQ_VERSION="v4.15.1" \
    YQ_BINARY="yq_linux_amd64"

COPY rootfs /

# libwebp-tools is installed for dynmap / bluemap users
RUN dnf upgrade -y && \
    dnf install -y \
        adoptopenjdk-16-hotspot wget procps net-tools findutils \
        glibc-locale-source glibc-langpack-en libwebp-tools \
        rsync inotify-tools tar git bind-utils tini && \
    dnf clean all && \
    localedef --quiet --force -i en_US -f UTF-8 "$LANG" && \
    wget -q "https://github.com/mikefarah/yq/releases/download/${YQ_VERSION}/${YQ_BINARY}.tar.gz" -O - | tar xz && \
    mv "${YQ_BINARY}" /usr/bin/yq && \
    chmod 755 /usr/bin/yq && \
    mkdir -p "$DATA_DIR" /custom_data /custom_scripts && \
    groupadd \
        --gid 1337 \
        minecraft && \
    useradd \
        --uid 1337 \
        --gid 1337 \
        --create-home \
        --home-dir "$HOME" \
        minecraft && \
    chmod -R 770 "$HOME" "$DATA_DIR" /custom_data /custom_scripts && \
    chown -R 1337:1337 "$HOME" "$DATA_DIR" /custom_data /custom_scripts && \
    chmod 755 /scripts/*

WORKDIR "$DATA_DIR"

USER 1337

ENTRYPOINT ["/usr/bin/tini", "--", "/scripts/entrypoint.sh"]

CMD ["java"]
