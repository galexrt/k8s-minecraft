.EXPORT_ALL_VARIABLES:

IMAGES ?= base paper velocity waterfall
BUILDAH_LAYERS ?= true

.PHONY: build
build:
	for image in $(IMAGES); do \
		$(MAKE) -C $$image build; \
	done

.PHONY: push
push:
	for image in $(IMAGES); do \
		$(MAKE) -C $$image push; \
	done
