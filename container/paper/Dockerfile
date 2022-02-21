FROM quay.io/galexrt/k8s-minecraft:base-v0.1.5

ARG VERSION

ENV JAVA_JAR="${HOME}/paper.jar" PAPER_VERSION="${VERSION}"

RUN MC_VERSION="$(echo ${PAPER_VERSION} | cut -d'/' -f1)" && \
    BUILD_NUMBER="$(echo ${PAPER_VERSION} | cut -d'/' -f2)" && \
    wget -q -O "${JAVA_JAR}" "https://papermc.io/api/v2/projects/paper/versions/${MC_VERSION}/builds/${BUILD_NUMBER}/downloads/paper-${MC_VERSION}-${BUILD_NUMBER}.jar"

EXPOSE 25565/tcp
