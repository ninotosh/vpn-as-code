# renovate: datasource=github-runners depName=ubuntu
ARG UBUNTU_VERSION=24.04

FROM ubuntu:${UBUNTU_VERSION} AS yq
# renovate: custom-datasource=custom.github-ubuntu-yq depName=yq
ARG YQ_VERSION=4.46.1
RUN apt update && \
    apt install -y --no-install-recommends curl ca-certificates
RUN ARCH="$(uname -m | sed 's/aarch64/arm64/; s/x86_64/amd64/')" && \
    curl -L -o yq \
      https://github.com/mikefarah/yq/releases/download/v${YQ_VERSION}/yq_linux_${ARCH} && \
    chmod +x yq && \
    mv yq /usr/local/bin && \
    yq --version

FROM ubuntu:${UBUNTU_VERSION} AS terraform
# renovate: datasource=github-releases depName=hashicorp/terraform
ARG TERRAFORM_VERSION=1.14.9
RUN apt update && \
    apt install -y --no-install-recommends curl ca-certificates unzip
RUN ARCH="$(uname -m | sed 's/aarch64/arm64/; s/x86_64/amd64/')" && \
    curl -L -o terraform.zip \
      https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_${ARCH}.zip && \
    unzip terraform.zip && \
    chmod +x terraform && \
    mv terraform /usr/local/bin && \
    terraform --version

FROM ubuntu:${UBUNTU_VERSION}
COPY --from=yq /usr/local/bin/yq /usr/local/bin
COPY --from=terraform /usr/local/bin/terraform /usr/local/bin

RUN apt update && \
    apt install -y --no-install-recommends ca-certificates bash-completion && \
    echo 'source /usr/share/bash-completion/bash_completion' >> /etc/bash.bashrc
RUN terraform -install-autocomplete
RUN apt install -y --no-install-recommends jq make curl
