ARG IMAGE=ubuntu:24.04

FROM ${IMAGE} AS conftest
ARG CONFTEST_VERSION=0.49.0
RUN apt update && \
    apt install -y --no-install-recommends curl ca-certificates
RUN curl -L -o conftest.tar.gz \
    https://github.com/open-policy-agent/conftest/releases/download/v${CONFTEST_VERSION}/conftest_${CONFTEST_VERSION}_Linux_x86_64.tar.gz && \
    tar zxf conftest.tar.gz && \
    cp conftest /usr/local/bin && \
    conftest --version

FROM ${IMAGE}
COPY --from=conftest /usr/local/bin/conftest /usr/local/bin
RUN apt update && \
    apt install -y --no-install-recommends bash-completion && \
    echo 'source /usr/share/bash-completion/bash_completion' >> /etc/bash.bashrc && \
    conftest completion bash > /usr/share/bash-completion/completions/conftest
ENTRYPOINT [ "conftest" ]
