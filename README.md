# azure-agent-docker

```
https://github.com/Microsoft/azure-pipelines-agent/releases

https://vstsagentpackage.azureedge.net/agent/2.152.0/vsts-agent-linux-x64-2.152.0.tar.gz

docker container run --rm -it --name azure-agent mcr.microsoft.com/azure-pipelines/vsts-agent:ubuntu-16.04 cat start.sh
docker container run --rm -it --name azure-agent mcr.microsoft.com/azure-pipelines/vsts-agent:ubuntu-16.04 id
docker container run --rm -it --name azure-agent mcr.microsoft.com/azure-pipelines/vsts-agent:ubuntu-16.04 id
docker image inspect mcr.microsoft.com/azure-pipelines/vsts-agent:ubuntu-16.04

docker image build --force-rm --tag docker.io/rxar/azr-pipelines-agent:staging .
docker container run --rm --name azr-pipelines-agent-rm -it docker.io/rxar/azr-pipelines-agent:staging sh

docker container run --rm --name alpine-rm -it alpine sh
```
