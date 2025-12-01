ARG IMAGE=ubuntu:24.04

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

FROM ${IMAGE} AS terraform
ARG TERRAFORM_VERSION=1.14.0
RUN apt update && \
    apt install -y --no-install-recommends curl ca-certificates
RUN apt install -y --no-install-recommends unzip && \
    curl -L -o terraform.zip \
    https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip && \
    unzip terraform.zip -d /usr/local/bin && \
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
