ARG IMAGE=ubuntu:24.04

FROM ${IMAGE} AS cue
ARG CUE_VERSION=0.16.0
ARG ARCH=arm64

RUN apt update && \
    apt install -y --no-install-recommends curl ca-certificates
RUN curl -L -o cue.tar.gz \
      https://github.com/cue-lang/cue/releases/download/v${CUE_VERSION}/cue_v${CUE_VERSION}_linux_${ARCH}.tar.gz && \
    tar zxf cue.tar.gz && \
    cp cue /usr/local/bin && \
    cue version

FROM ${IMAGE}
COPY --from=cue /usr/local/bin/cue /usr/local/bin

RUN apt update && \
    apt install -y --no-install-recommends bash-completion && \
    echo 'source /usr/share/bash-completion/bash_completion' >> /etc/bash.bashrc && \
    cue completion bash > /usr/share/bash-completion/completions/cue
