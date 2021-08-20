HEALTHCHECKS_VERSION := $(shell grep -P -o 'HEALTHCHECKS_VERSION="([a-z0-9.-]+)"' Dockerfile | cut -d'"' -f 2)
RELEASE_TAG := $(HEALTHCHECKS_VERSION)-$(shell date +%Y%m%d-%H%M%S-%3N)

# Default is the main branch as that is where the "latest" tag should be
VERSION ?= main
VERSION_SHORT ?= $(shell cut -d '-' -f 1 <<< "$(VERSION)")

# CI Helper Variables
REGISTRY_GHCRIO_USERNAME ?= $(shell cut -d '/' -f 1 <<< "$(GITHUB_REPOSITORY)")

## Create and push a newly generated git tag to trigger a new automated CI run
release-tag:
	git tag $(RELEASE_TAG)
	git push origin $(RELEASE_TAG)

## Build the container image
container-build:
	docker build \
		--build-arg BUILD_DATE="$(shell date -u +'%Y-%m-%dT%H:%M:%SZ')" \
		--build-arg VCS_REF="$(shell git rev-parse HEAD)" \
		-t ghcr.io/galexrt/healthchecks:$(VERSION) \
		.
	docker tag ghcr.io/galexrt/healthchecks:$(VERSION) quay.io/galexrt/healthchecks:$(VERSION)

	if [ "$(VERSION)" != "$(VERSION_SHORT)" ]; then \
		docker tag ghcr.io/galexrt/healthchecks:$(VERSION) ghcr.io/galexrt/healthchecks:$(VERSION_SHORT); \
		docker tag ghcr.io/galexrt/healthchecks:$(VERSION) quay.io/galexrt/healthchecks:$(VERSION_SHORT); \
	fi

container-push:
	docker push ghcr.io/galexrt/healthchecks:$(VERSION)
	docker push quay.io/galexrt/healthchecks:$(VERSION)

	if [ "$(VERSION)" != "$(VERSION_SHORT)" ]; then \
		docker push ghcr.io/galexrt/healthchecks:$(VERSION_SHORT); \
		docker push quay.io/galexrt/healthchecks:$(VERSION_SHORT); \
	fi

## Build and push the versioned images
container-release:
	$(MAKE) container-build container-push

## CI ONLY: This is used to login to the container image registries
container-registrylogin:
	echo $(GITHUB_TOKEN) | docker login ghcr.io -u $(REGISTRY_GHCRIO_USERNAME) --password-stdin
	echo $(REGISTRY_QUAYIO_PASSWORD) | docker login quay.io -u $(REGISTRY_QUAYIO_USERNAME) --password-stdin
