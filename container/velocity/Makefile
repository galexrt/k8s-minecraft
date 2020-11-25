.PHONY: build
build:
	BUILDAH_LAYERS=true buildah bud -t quay.io/galexrt/k8s-minecraft:velocity-latest .

.PHONY: push
push:
	buildah push quay.io/galexrt/k8s-minecraft:velocity-latest
