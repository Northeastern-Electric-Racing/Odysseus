FROM ubuntu:latest

RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive TZ="America/New_York" \
    apt-get -y install tzdata


RUN apt-get install -y \
    make \
    binutils \
    build-essential \
    diffutils \
    gcc \
    g++ \
    bash \
    patch \
    gzip \
    bzip2 \
    perl \
    tar \
    cpio \
    unzip \
    rsync \
    file \
    bc \
    findutils \
    wget \
    python3 \
    libncurses5-dev \
    git \
    python3-matplotlib \
    graphviz \
    git-lfs \
    util-linux

# just for calypso require ruamel.yaml
RUN apt-get install -y python3-pip && pip install "ruamel.yaml<0.18.0"

# add all buildroot files there
WORKDIR /home/odysseus/build

RUN  git clone https://gitlab.com/buildroot.org/buildroot.git && cd ./buildroot && git checkout 2024.02

WORKDIR /home/odysseus/outputs/
COPY ./docker_scripts /home/odysseus/scripts
RUN echo "source /home/odysseus/scripts/setup_env.sh" >> ~/.bashrc

ENTRYPOINT "/bin/bash"
