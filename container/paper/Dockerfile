FROM quay.io/galexrt/k8s-minecraft:base-latest

ARG PAPER_DL_URL="https://papermc.io/api/v1/paper/1.16.4/274/download"

RUN wget -q -O "$HOME/paper.jar" "$PAPER_DL_URL"

ENTRYPOINT ["/usr/bin/java", "-jar", "paper.jar"]

EXPOSE 25565/tcp
