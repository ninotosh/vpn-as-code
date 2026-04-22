# renovate: datasource=github-runners depName=ubuntu
ARG UBUNTU_VERSION=24.04

FROM ubuntu:${UBUNTU_VERSION} AS jq
ARG JQ_VERSION=1.7

RUN apt update && \
    apt install -y --no-install-recommends curl ca-certificates
RUN ARCH="$(uname -m | sed 's/aarch64/arm64/; s/x86_64/amd64/')" && \
    curl -L -o jq \
      https://github.com/jqlang/jq/releases/download/jq-${JQ_VERSION}/jq-linux-${ARCH} && \
    chmod +x jq && \
    mv jq /usr/local/bin && \
    jq --version

FROM ubuntu:${UBUNTU_VERSION} AS yq
ARG YQ_VERSION=4.46.1
RUN apt update && \
    apt install -y --no-install-recommends curl ca-certificates
RUN ARCH="$(uname -m | sed 's/aarch64/arm64/; s/x86_64/amd64/')" && \
    curl -L -o yq \
      https://github.com/mikefarah/yq/releases/download/v${YQ_VERSION}/yq_linux_${ARCH} && \
    chmod +x yq && \
    mv yq /usr/local/bin && \
    yq --version

FROM ubuntu:${UBUNTU_VERSION} AS docker-ce
COPY --from=jq /usr/local/bin/jq /usr/local/bin
COPY --from=yq /usr/local/bin/yq /usr/local/bin
COPY --from=ansible_roles_openvpn requirements.yml /tmp

RUN apt remove $(dpkg --get-selections docker.io docker-compose docker-compose-v2 docker-doc podman-docker containerd runc | cut -f1)
RUN apt update && \
    apt install -y ca-certificates curl
RUN install -m 0755 -d /etc/apt/keyrings
RUN curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
RUN chmod a+r /etc/apt/keyrings/docker.asc

RUN tee /etc/apt/sources.list.d/docker.sources <<EOF
Types: deb
URIs: https://download.docker.com/linux/ubuntu
Suites: $(. /etc/os-release && echo "${UBUNTU_CODENAME:-$VERSION_CODENAME}")
Components: stable
Architectures: $(dpkg --print-architecture)
Signed-By: /etc/apt/keyrings/docker.asc
EOF

RUN apt update && \
    apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

FROM docker-ce

RUN apt update && \
    apt-get install -y --no-install-recommends \
        # molecule
        python3-pip libssl-dev \
        # venv
        python3-venv python3-dev \
        # ansible
        rsync

ENV HOME=/root
WORKDIR $HOME
RUN python3 -m venv .venv
ENV PATH="$HOME/.venv/bin:$PATH"
RUN . .venv/bin/activate && \
    python3 -m pip install molecule "molecule-plugins[docker]" ansible-lint && \
    ansible --version | head -n 1 | grep --fixed-strings 'core 2.20.'
RUN echo 'PATH="$HOME/.venv/bin:$PATH"' >> $HOME/.bashrc
RUN echo 'eval "$(_MOLECULE_COMPLETE=bash_source molecule)"' >> $HOME/.bashrc
RUN ansible-galaxy collection install -r /tmp/requirements.yml
