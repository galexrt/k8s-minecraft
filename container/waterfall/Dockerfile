FROM quay.io/galexrt/k8s-minecraft:base-latest

ARG WATERFALL_DL_URL="https://papermc.io/api/v1/waterfall/1.16/384/download"

RUN wget -q -O "$HOME/waterfall.jar" "$WATERFALL_DL_URL"

ENTRYPOINT ["/usr/bin/java", "-jar", "waterfall.jar"]

EXPOSE 25577/tcp
