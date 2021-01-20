FROM quay.io/galexrt/k8s-minecraft:base-latest

ARG VERSION

ENV JAVA_JAR="${HOME}/velocity.jar" VELOCITY_VERSION="${VERSION}"

RUN wget -q -O "${HOME}/velocity.jar" "https://versions.velocitypowered.com/download/${VELOCITY_VERSION}.jar"

EXPOSE 25577/tcp
