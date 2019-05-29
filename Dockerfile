FROM registry.fedoraproject.org/fedora:29
ARG AGENT_VERSION=2.152.0
ARG AGENT_OS=linux
ARG AGENT_ARCH=x64

RUN \
	sed -E -i 's/^\s*metadata_expire\s*=.*$/metadata_expire=never/g' /etc/yum.repos.d/* && \
	echo 'metadata_expire=never' >> /etc/dnf/dnf.conf && \
	dnf install -y \
		busybox \
	&& \
	true

RUN \
	dnf install -y \
		icu \
	&& \
	true

ARG GROUP_NAME=azrpa
ARG GROUP_ID=29942
ARG USER_NAME=azrpa
ARG USER_ID=29942

RUN \
	echo groupadd -g ${GROUP_ID} ${GROUP_NAME} && \
	groupadd -g ${GROUP_ID} ${GROUP_NAME} && \
	echo useradd -M -d /var/opt/vsts-agent/ -s /sbin/nologin -g ${GROUP_NAME} -u ${USER_ID} ${USER_NAME} && \
	useradd -M -d /var/opt/vsts-agent/ -s /sbin/nologin -g ${GROUP_NAME} -u ${USER_ID} ${USER_NAME} && \
	mkdir -p /var/opt/vsts-agent/ /opt/vsts-agent/ && \
	chown -R ${USER_NAME}:${GROUP_NAME} /var/opt/vsts-agent/ /opt/vsts-agent/ && \
	true

RUN \
	busybox wget -O /var/tmp/pkg.tar.gz https://vstsagentpackage.azureedge.net/agent/2.152.0/vsts-agent-${AGENT_OS}-${AGENT_ARCH}-${AGENT_VERSION}.tar.gz && \
	busybox tar -xvf /var/tmp/pkg.tar.gz -C /opt/vsts-agent/ && \
	rm -v /var/tmp/pkg.tar.gz && \
	chown -R ${USER_NAME}:${GROUP_NAME} /opt/vsts-agent/ && \
	true

RUN \
	dnf install -y \
		compat-openssl10 \
	&& \
	true

COPY common-files/profile-vsts-agent.sh /etc/profile.d/vsts-agent.sh
COPY common-files/vsts-script.sh /opt/vsts-agent/bin/
RUN ln -s vsts-script.sh /opt/vsts-agent/bin/vsts-start.sh
ENV PATH /opt/vsts-agent/bin:$PATH

USER ${USER_NAME}:${GROUP_NAME}
WORKDIR /var/opt/vsts-agent/
VOLUME /var/opt/vsts-agent/

#ENTRYPOINT ["/opt/vsts-agent/bin/vsts-entrypoint.sh"]

CMD ["vsts-script.sh", "start"]
