FROM quay.io/galexrt/k8s-minecraft:base-v0.0.1

ARG VERSION

ENV JAVA_JAR="${HOME}/paper.jar" PAPER_VERSION="${VERSION}"

RUN wget -q -O "${HOME}/paper.jar" "https://papermc.io/api/v1/paper/${PAPER_VERSION}/download"

EXPOSE 25565/tcp
