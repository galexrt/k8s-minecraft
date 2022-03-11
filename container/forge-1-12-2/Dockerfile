FROM quay.io/galexrt/k8s-minecraft:base-v0.1.7

ARG VERSION

ENV JAVA_JAR="${HOME}/forge-${VERSION}.jar" \
    JAVA_HOME=""

USER 0

COPY rootfs /

# We need Java 8 for a Minecraft 1.12.2 server
RUN rm -rf /opt/* /usr/local/bin/* && \
    dnf install -y adoptopenjdk-8-hotspot

USER 1337

RUN wget -q -O "${HOME}/forge-installer.jar" "https://maven.minecraftforge.net/net/minecraftforge/forge/${VERSION}/forge-${VERSION}-installer.jar" && \
    cd "${HOME}" && \
    java -jar "${HOME}/forge-installer.jar" --installServer && \
    rm -f "${HOME}/forge-installer.jar"

EXPOSE 25565/tcp
