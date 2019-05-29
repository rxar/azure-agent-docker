
.PHONY: image
image:
	docker image build --tag docker.io/rxar/vsts-agent:staging --tag docker.io/rxar/vsts-agent:latest .

.PHONY: runit-sh
runit-sh: image
	docker container run --rm -it --name rxar_vsts-agent-rm docker.io/rxar/vsts-agent:staging busybox sh

.PHONY: push
push: image
	docker push docker.io/rxar/vsts-agent:latest
