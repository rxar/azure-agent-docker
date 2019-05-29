SHELL=bash

OS_NAME=alpine
OS_VERSION=3.9

OS_NAME=fedora
OS_VERSION=29

AGENT_VERSION=2.152.0
AGENT_OS=linux
AGENT_ARCH=x64

docker_file_translate=cat
clean_cache=true

docker_file_translate=sed -E 's|^\s*RUN\s+|RUN --mount=type=cache,id=$(OS_NAME)-$(OS_VERSION)-var-cache,target=/var/cache/ |g'
clean_cache=false

docker_build= \
    DOCKER_BUILDKIT=1 docker image build \
        --progress plain --force-rm --network host \

docker_build_args= \
	--build-arg "CLEAN_CACHE=$(clean_cache)" \
	--build-arg "AGENT_VERSION=$(AGENT_VERSION)" \

build/:
	mkdir $(@)

build/Dockerfile.tr.$(OS_NAME)-$(OS_VERSION): Dockerfile.$(OS_NAME)-$(OS_VERSION)

.PHONY: image
image: build/Dockerfile.tr.$(OS_NAME)-$(OS_VERSION)
	grep -H . <( cat Dockerfile.$(OS_NAME)-$(OS_VERSION) | $(docker_file_translate) )
	cat Dockerfile.$(OS_NAME)-$(OS_VERSION) | $(docker_file_translate) | $(docker_build) $(docker_build_args) \
		--tag docker.io/rxar/vsts-agent:$(OS_NAME)-$(OS_VERSION)-staging \
		--tag docker.io/rxar/vsts-agent:$(OS_NAME)-$(OS_VERSION)-latest \
		--tag docker.io/rxar/vsts-agent:$(OS_NAME)-$(OS_VERSION)-$(AGENT_VERSION)-staging \
		--tag docker.io/rxar/vsts-agent:$(OS_NAME)-$(OS_VERSION)-$(AGENT_VERSION)-latest \
		-f - .

.PHONY: runit-sh
runit-sh: image
	docker container run --rm -it --name rxar_vsts-agent-rm docker.io/rxar/vsts-agent:$(OS_NAME)-$(OS_VERSION)-staging busybox sh

.PHONY: runit
runit: image
	docker container run --rm -it --env-file ~/.config/vsts-agent.env --name rxar_vsts-agent-rm docker.io/rxar/vsts-agent:$(OS_NAME)-$(OS_VERSION)-staging

.PHONY: runit
exec-sh:
	docker container exec -it rxar_vsts-agent-rm sh

.PHONY: push
push: image
	docker push docker.io/rxar/vsts-agent:$(OS_NAME)-$(OS_VERSION)-$(AGENT_VERSION)-latest
	docker push docker.io/rxar/vsts-agent:$(OS_NAME)-$(OS_VERSION)-latest
