ARG IMAGE=python:3.14-trixie

FROM ${IMAGE} AS jq
ARG JQ_VERSION=1.7

RUN apt update && \
    apt install -y --no-install-recommends curl ca-certificates
RUN curl -L -o /usr/local/bin/jq \
    https://github.com/jqlang/jq/releases/download/jq-${JQ_VERSION}/jq-linux64 && \
    chmod +x /usr/local/bin/jq && \
    jq --version

FROM ${IMAGE} AS yq
ARG YQ_VERSION=4.46.1
RUN apt update && \
    apt install -y --no-install-recommends curl ca-certificates
RUN curl -L -o yq.tar.gz \
    https://github.com/mikefarah/yq/releases/download/v${YQ_VERSION}/yq_linux_amd64.tar.gz && \
    tar zxf yq.tar.gz && \
    mv yq_linux_amd64 /usr/local/bin/yq && \
    yq --version

FROM ${IMAGE}
COPY --from=jq /usr/local/bin/jq /usr/local/bin
COPY --from=yq /usr/local/bin/yq /usr/local/bin

RUN apt-get remove docker docker-engine docker.io containerd runc || true
RUN apt update && \
    apt-get install -y --no-install-recommends \
    ca-certificates curl gnupg lsb-release
RUN curl -fsSL https://download.docker.com/linux/debian/gpg \
    | gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
RUN echo \
    "deb [arch=`dpkg --print-architecture` signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] \
    https://download.docker.com/linux/debian `lsb_release -cs` stable" \
    > /etc/apt/sources.list.d/docker.list
RUN apt-get update && \
    apt-get install -y --no-install-recommends docker-ce-cli

RUN apt-get install -y --no-install-recommends libffi-dev git
RUN python3 -m pip install molecule "molecule-plugins[docker]" ansible-lint
RUN ansible --version | head -n 1 | grep --fixed-strings 'core 2.20.'
RUN echo 'eval "$(_MOLECULE_COMPLETE=bash_source molecule)"' >> /etc/bash.bashrc

# for ansible
RUN apt-get install -y --no-install-recommends rsync
RUN ansible-galaxy collection install ansible.posix
