
.PHONY: image
image:
	docker image build --tag rxar/vsts-agent:staging .

.PHONY: runit-sh
runit-sh: image
	docker container run --rm -it --name rxar_vsts-agent-rm rxar/vsts-agent:staging busybox sh

