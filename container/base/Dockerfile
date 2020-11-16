FROM fedora:33

ENV HOME="/minecraft" DATA_DIR="/data"

COPY rootfs /

RUN dnf upgrade -y && \
    dnf install -y java-latest-openjdk wget procps net-tools && \
    dnf clean all && \
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
    chmod -R 770 "$HOME" "$DATA_DIR" && \
    chown -R 1337:1337 "$HOME" "$DATA_DIR" /custom_data /custom_scripts && \
    chmod -R 770 /custom_data /custom_scripts && \
    chmod 755 /scripts/*

WORKDIR "$DATA_DIR"

USER 1337

ENTRYPOINT ["/scripts/entrypoint.sh"]

CMD ["java"]
