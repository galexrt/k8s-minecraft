FROM quay.io/galexrt/k8s-minecraft:base-latest

ARG VERSION

ENV JAVA_JAR="${HOME}/limbo.jar" LIMBO_VERSION="${VERSION}"

RUN wget -q -O "${HOME}/limbo.jar" "https://ci.loohpjames.com/job/Limbo/lastSuccessfulBuild/artifact/target/Limbo-${VERSION}.jar" && \
    wget -q -O "${HOME}/spawn.schem" "https://ci.loohpjames.com/job/Limbo/lastSuccessfulBuild/artifact/spawn.schem"

EXPOSE 25565/tcp

CMD ["--nogui"]
