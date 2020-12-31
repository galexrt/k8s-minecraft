FROM quay.io/galexrt/k8s-minecraft:base-latest

ARG WATERFALL_DL_URL="https://papermc.io/api/v1/waterfall/1.16/389/download"

ENV JAVA_JAR="$HOME/waterfall.jar"

RUN wget -q -O "$HOME/waterfall.jar" "$WATERFALL_DL_URL"

EXPOSE 25577/tcp
