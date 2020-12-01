include ../Makefile.common

.PHONY: build
build:
	BUILDAH_LAYERS=$(BUILDAH_LAYERS) buildah bud -t quay.io/galexrt/k8s-minecraft:paper-latest .

.PHONY: push
push:
	buildah push quay.io/galexrt/k8s-minecraft:paper-latest
