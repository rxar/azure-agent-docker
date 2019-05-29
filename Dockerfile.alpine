FROM alpine:3.9
ARG AGENT_VERSION=2.152.0
ARG AGENT_OS=linux
ARG AGENT_ARCH=x64

RUN \
	wget -O /var/tmp/pkg.tar.gz https://vstsagentpackage.azureedge.net/agent/2.152.0/vsts-agent-${AGENT_OS}-${AGENT_ARCH}-${AGENT_VERSION}.tar.gz && \
	mkdir -p /opt/azr-pipelines-agent/ && \
	tar -xvf /var/tmp/pkg.tar.gz -C /opt/azr-pipelines-agent/ && \
	rm -v /var/tmp/pkg.tar.gz && \
	chown -R nobody:nobody /opt/azr-pipelines-agent/ && \
	true

ARG GROUP_NAME=azrpa
ARG GROUP_ID=29942
ARG USER_NAME=azrpa
ARG USER_ID=29942


#		gcompat \

RUN \
	apk add --no-cache \
		bash \
		libc6-compat \
		libstdc++ \
		libstdc++6 \
	&& true

# https://busybox.net/downloads/BusyBox.html#addgroup
# https://busybox.net/downloads/BusyBox.html#adduser
RUN \
	echo addgroup -g ${GROUP_ID} ${GROUP_NAME} && \
	echo adduser -H -h /var/opt/azr-pipelines-agent/ -s /sbin/nologin -g ${GROUP_NAME} -D -u ${USER_ID} ${USER_NAME} && \
	adduser -H -h /var/opt/azr-pipelines-agent/ -s /sbin/nologin -g ${GROUP_NAME} -D -u ${USER_ID} ${USER_NAME} && \
	echo mkdir -p /var/opt/azr-pipelines-agent/ && \
	echo chown -R ${USER_NAME}:${GROUP_NAME} /opt/azr-pipelines-agent/ && \
	true

USER ${USER_NAME}:${GROUP_NAME}
WORKDIR /var/opt/azr-pipelines-agent/
VOLUME /var/opt/azr-pipelines-agent/

CMD ["/opt/azr-pipelines-agent/"]
