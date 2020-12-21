FROM quay.io/galexrt/k8s-minecraft:base-latest

ARG PAPER_DL_URL="https://papermc.io/api/v1/paper/1.16.4/338/download"

ENV JAVA_JAR="$HOME/paper.jar"

RUN wget -q -O "$HOME/paper.jar" "$PAPER_DL_URL"

EXPOSE 25565/tcp
