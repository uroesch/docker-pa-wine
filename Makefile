DOCKER_USER    := uroesch
DOCKER_TAG     := pa-wine
DOCKER_VERSION := $(shell date +%F)

push-as-latest: push
	docker tag $(DOCKER_USER)/$(DOCKER_TAG):$(DOCKER_VERSION) \
		$(DOCKER_USER)/$(DOCKER_TAG):latest
	docker push $(DOCKER_USER)/$(DOCKER_TAG):latest

push: build
	docker push $(DOCKER_USER)/$(DOCKER_TAG):$(DOCKER_VERSION)

build-no-cache:
	docker build \
		--no-cache \
    --tag $(DOCKER_USER)/$(DOCKER_TAG):$(DOCKER_VERSION) \
		. 

build:
	docker build \
		--pull \
		--tag $(DOCKER_USER)/$(DOCKER_TAG):$(DOCKER_VERSION) \
		. 

.PHONY: build

# vim: shiftwidth=2 tabstop=2 noexpandtab :
