FROM quay.io/galexrt/k8s-minecraft:base-v0.1.6

ARG VERSION

ENV JAVA_JAR="${HOME}/limbo.jar" LIMBO_VERSION="${VERSION}"

RUN wget -q -O "${JAVA_JAR}" "${LIMBO_VERSION}"

EXPOSE 30000/tcp
