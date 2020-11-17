IMAGES ?= base paper velocity waterfall

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
