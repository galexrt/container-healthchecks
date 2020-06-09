RELEASE_TAG := $(shell grep -P -o 'HEALTHCHECKS_VERSION="([a-z0-9.-]+)"' Dockerfile | cut -d'"' -f 2)-$(shell date +%Y%m%d-%H%M%S-%3N)

build:
	docker build -t galexrt/healthchecks:latest .

release:
	git tag $(RELEASE_TAG)
	git push origin $(RELEASE_TAG)

release-and-build: build
	git tag $(RELEASE_TAG)
	docker tag galexrt/healthchecks:latest galexrt/healthchecks:$(RELEASE_TAG)
	git push origin $(RELEASE_TAG)
	docker push galexrt/healthchecks:$(RELEASE_TAG)
	docker push galexrt/healthchecks:latest
