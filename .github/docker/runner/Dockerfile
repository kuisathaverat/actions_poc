FROM ubuntu:20.04

RUN apt-get update -qq && apt-get install -y -qq \
    ca-certificates \
    curl \
    sudo

ARG RUNNER_VERSION=2.294.0
ARG RUNNER_SHA=a19a09f4eda5716e5d48ba86b6b78fc014880c5619b9dba4a059eaf65e131780
RUN useradd -m -s /bin/bash -u 1000 -G sudo runner
# run sudo with no passsword
RUN echo "runner ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

USER runner
WORKDIR /home/runner
RUN curl -sS -o "actions-runner-linux-x64-${RUNNER_VERSION}.tar.gz" \
    -L "https://github.com/actions/runner/releases/download/v${RUNNER_VERSION}/actions-runner-linux-x64-${RUNNER_VERSION}.tar.gz" \
    && echo "${RUNNER_SHA} actions-runner-linux-x64-${RUNNER_VERSION}.tar.gz" | sha256sum -c \
    && tar xzf "./actions-runner-linux-x64-${RUNNER_VERSION}.tar.gz" \
    && rm "./actions-runner-linux-x64-${RUNNER_VERSION}.tar.gz" \
    && sudo ./bin/installdependencies.sh

COPY entrypoint.sh /home/runner
COPY uninstall.sh /home/runner
ENTRYPOINT ["/home/runner/entrypoint.sh"]