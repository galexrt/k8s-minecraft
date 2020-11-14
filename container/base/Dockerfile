FROM fedora:33

ENV HOME="/minecraft" DATA_DIR="/data"

COPY rootfs /

RUN dnf upgrade -y && \
    dnf install -y java-latest-openjdk wget screen procps net-tools && \
    dnf clean all && \
    mkdir -p "$DATA_DIR" && \
    groupadd \
        --gid 1337 \
        minecraft && \
    useradd \
        --uid 1337 \
        --gid 1337 \
        --home-dir "$HOME" \
        minecraft && \
    chmod 770 -R "$HOME" "$DATA_DIR" && \
    chown 1337:1337 -R "$HOME" "$DATA_DIR" && \
    chmod 755 /scripts/*

WORKDIR "$DATA_DIR"

USER 1337

ENTRYPOINT ["/scripts/entrypoint.sh"]

CMD ["java"]
