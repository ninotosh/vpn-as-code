# renovate: datasource=github-runners depName=ubuntu
ARG UBUNTU_VERSION=24.04

FROM ubuntu:${UBUNTU_VERSION} AS conftest
# renovate: datasource=github-releases depName=open-policy-agent/conftest
ARG CONFTEST_VERSION=0.68.2

RUN apt update && \
    apt install -y --no-install-recommends curl ca-certificates
RUN ARCH="$(uname -m | sed 's/aarch64/arm64/')" && \
    curl -L -o conftest.tar.gz \
      https://github.com/open-policy-agent/conftest/releases/download/v${CONFTEST_VERSION}/conftest_${CONFTEST_VERSION}_Linux_${ARCH}.tar.gz && \
    tar zxf conftest.tar.gz && \
    cp conftest /usr/local/bin && \
    conftest --version

FROM ubuntu:${UBUNTU_VERSION}
COPY --from=conftest /usr/local/bin/conftest /usr/local/bin

RUN apt update && \
    apt install -y --no-install-recommends bash-completion && \
    echo 'source /usr/share/bash-completion/bash_completion' >> /etc/bash.bashrc && \
    conftest completion bash > /usr/share/bash-completion/completions/conftest
