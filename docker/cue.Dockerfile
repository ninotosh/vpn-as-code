FROM golang:1.25-bookworm
ARG CUE_VERSION=0.15.0

RUN apt update && \
    apt install -y --no-install-recommends bash-completion && \
    echo 'source /usr/share/bash-completion/bash_completion' >> /etc/bash.bashrc
RUN go install cuelang.org/go/cmd/cue@v${CUE_VERSION} && \
    cue completion bash > /etc/bash_completion.d/cue
ENTRYPOINT cue
