# renovate: datasource=github-runners depName=ubuntu
ARG UBUNTU_VERSION=24.04

FROM ubuntu:${UBUNTU_VERSION} AS cue
# renovate: datasource=github-releases depName=cue-lang/cue
ARG CUE_VERSION=0.16.1

RUN apt update && \
    apt install -y --no-install-recommends curl ca-certificates
RUN ARCH="$(uname -m | sed 's/aarch64/arm64/; s/x86_64/amd64/')" && \
    curl -L -o cue.tar.gz \
      https://github.com/cue-lang/cue/releases/download/v${CUE_VERSION}/cue_v${CUE_VERSION}_linux_${ARCH}.tar.gz && \
    tar zxf cue.tar.gz && \
    cp cue /usr/local/bin && \
    cue version

FROM ubuntu:${UBUNTU_VERSION}
COPY --from=cue /usr/local/bin/cue /usr/local/bin

RUN apt update && \
    apt install -y --no-install-recommends bash-completion && \
    echo 'source /usr/share/bash-completion/bash_completion' >> /etc/bash.bashrc && \
    cue completion bash > /usr/share/bash-completion/completions/cue
