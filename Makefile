DOCKER_USER    := uroesch
DOCKER_TAG     := pa-wine
DOCKER_VERSION ?= $(shell date +%F)

to-latest:
	docker tag $(DOCKER_USER)/$(DOCKER_TAG):$(DOCKER_VERSION) \
		$(DOCKER_USER)/$(DOCKER_TAG):latest

push-as-latest: to-latest push
	docker push $(DOCKER_USER)/$(DOCKER_TAG):latest

push-only:
	docker push $(DOCKER_USER)/$(DOCKER_TAG):$(DOCKER_VERSION)

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
