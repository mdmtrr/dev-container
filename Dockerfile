ARG UBUNTU_VERSION="22.04"

FROM ubuntu:${UBUNTU_VERSION} AS builder

ARG TERRAFORM_VERSION="1.11.4"
ARG CHERRYCTL_VERSION="v0.5.0"

WORKDIR /tmp
RUN mkdir ./bin
RUN apt update && apt install -y unzip
ADD https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_arm64.zip .
RUN unzip terraform_${TERRAFORM_VERSION}_linux_arm64.zip "terraform" -d ./bin
ADD https://github.com/cherryservers/cherryctl/releases/download/${CHERRYCTL_VERSION}/cherryctl-linux-arm64 ./bin/cherryctl
RUN chmod +x ./bin/cherryctl

RUN ls -lah

FROM ubuntu:${UBUNTU_VERSION} AS dev-container
RUN apt update && apt install -y\
    python3\
    python3-pip\
    ca-certificates\
    mc\
    curl\
    wget\
    sudo\
    vim\
  &&\
    apt-get clean

COPY --from=builder /tmp/bin/* /usr/local/bin/
RUN useradd -rm -d /home/dev -s /bin/bash -g root -G sudo -u 1001 dev
USER dev
WORKDIR /home/dev
RUN python3 -m pip install --user\
    ansible
ENV PATH=".local/bin/:$PATH"
