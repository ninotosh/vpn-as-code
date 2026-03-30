ARG IMAGE=ubuntu:24.04

FROM ${IMAGE} AS jq
ARG JQ_VERSION=1.7

RUN apt update && \
    apt install -y --no-install-recommends curl ca-certificates
RUN ARCH="$(uname -m | sed 's/aarch64/arm64/; s/x86_64/amd64/')" && \
    curl -L -o jq \
      https://github.com/jqlang/jq/releases/download/jq-${JQ_VERSION}/jq-linux-${ARCH} && \
    chmod +x jq && \
    mv jq /usr/local/bin && \
    jq --version

FROM ${IMAGE} AS yq
ARG YQ_VERSION=4.46.1
RUN apt update && \
    apt install -y --no-install-recommends curl ca-certificates
RUN ARCH="$(uname -m | sed 's/aarch64/arm64/; s/x86_64/amd64/')" && \
    curl -L -o yq \
      https://github.com/mikefarah/yq/releases/download/v${YQ_VERSION}/yq_linux_${ARCH} && \
    chmod +x yq && \
    mv yq /usr/local/bin && \
    yq --version

FROM ${IMAGE} AS terraform
ARG TERRAFORM_VERSION=1.14.8
RUN apt update && \
    apt install -y --no-install-recommends curl ca-certificates unzip
RUN ARCH="$(uname -m | sed 's/aarch64/arm64/; s/x86_64/amd64/')" && \
    curl -L -o terraform.zip \
      https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_${ARCH}.zip && \
    unzip terraform.zip && \
    chmod +x terraform && \
    mv terraform /usr/local/bin && \
    terraform --version

FROM ${IMAGE}
COPY --from=jq /usr/local/bin/jq /usr/local/bin
COPY --from=yq /usr/local/bin/yq /usr/local/bin
COPY --from=terraform /usr/local/bin/terraform /usr/local/bin

RUN apt update && \
    apt install -y --no-install-recommends ca-certificates bash-completion && \
    echo 'source /usr/share/bash-completion/bash_completion' >> /etc/bash.bashrc
RUN terraform -install-autocomplete
RUN apt install -y --no-install-recommends make curl
