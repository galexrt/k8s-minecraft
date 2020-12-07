FROM fedora:33

ENV HOME="/minecraft" \
    DATA_DIR="/data" \
    LANG="en_US.UTF-8" \
    LANGUAGE="en_US" \
    LC_ALL="en_US.UTF-8"

COPY rootfs /

# libwebp-tools is installed for dynmap / bluemap users
RUN dnf upgrade -y && \
    dnf install -y \
        java-1.8.0-openjdk wget procps net-tools findutils \
        glibc-locale-source glibc-langpack-en libwebp-tools \
        rsync && \
    dnf clean all && \
    localedef --quiet --force -i en_US -f UTF-8 "$LANG" && \
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

ENTRYPOINT ["/scripts/entrypoint.sh"]

CMD ["java"]
