FROM quay.io/galexrt/k8s-minecraft:base-v0.1.5

ARG VERSION

ENV JAVA_JAR="${HOME}/limbo.jar" LIMBO_VERSION="${VERSION}"

RUN wget -q -O "${JAVA_JAR}" "https://ci.loohpjames.com/job/Limbo/lastSuccessfulBuild/artifact/target/Limbo-${LIMBO_VERSION}.jar"

EXPOSE 25565/tcp
