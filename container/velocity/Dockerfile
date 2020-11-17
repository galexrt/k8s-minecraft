FROM quay.io/galexrt/k8s-minecraft:base-latest

ARG VELOCITY_DL_URL="https://versions.velocitypowered.com/download/1.1.0.jar"

ENV JAVA_JAR="$HOME/velocity.jar"

RUN wget -q -O "$HOME/velocity.jar" "$VELOCITY_DL_URL"

EXPOSE 25577/tcp
