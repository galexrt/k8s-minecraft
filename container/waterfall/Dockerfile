FROM quay.io/galexrt/k8s-minecraft:base-v0.0.9

ARG VERSION

ENV JAVA_JAR="${HOME}/waterfall.jar" WATERFALL_VERSION="${VERSION}"

RUN MC_VERSION="$(echo ${WATERFALL_VERSION} | cut -d'/' -f1)" && \
    BUILD_NUMBER="$(echo ${WATERFALL_VERSION} | cut -d'/' -f2)" && \
    wget -q -O "${JAVA_JAR}" "https://papermc.io/api/v2/projects/waterfall/versions/${MC_VERSION}/builds/${BUILD_NUMBER}/downloads/waterfall-${MC_VERSION}-${BUILD_NUMBER}.jar"

EXPOSE 25577/tcp
