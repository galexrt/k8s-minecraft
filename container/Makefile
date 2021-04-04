.EXPORT_ALL_VARIABLES:

BUILDAH ?= buildah
BUILDAH_LAYERS ?= false

IMAGES ?= base limbo paper velocity waterfall

.PHONY: build
build: $(addprefix build-, $(IMAGES))

build-%:
	$(MAKE) -C $* build

.PHONY: push
push: $(addprefix push-, $(IMAGES))

push-%:
	$(MAKE) -C $* push

.PHONY: clean
clean: $(addprefix clean-, $(IMAGES))

clean-%:
	$(MAKE) -C $* clean

clean-system:
	-$(BUILDAH) \
		rmi --force --all
