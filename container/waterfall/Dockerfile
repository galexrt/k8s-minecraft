FROM quay.io/galexrt/k8s-minecraft:base-latest

ARG VERSION

ENV JAVA_JAR="${HOME}/waterfall.jar" WATERFALL_VERSION="${VERSION}"

RUN wget -q -O "${HOME}/waterfall.jar" "https://papermc.io/api/v1/waterfall/${WATERFALL_VERSION}/download"

EXPOSE 25577/tcp
