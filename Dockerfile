FROM ubuntu:latest

RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive TZ="America/New_York" \
    apt-get -y install tzdata


RUN apt-get update && apt-get install -y \
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
    util-linux \ 
    wpasupplicant \
    curl

# add all buildroot files there
WORKDIR /home/odysseus/build

RUN  git clone https://gitlab.com/buildroot.org/buildroot.git && cd ./buildroot && git checkout 4cca0f30f2b263acf97c6d0abd8d31e2417542e2 && curl https://patchwork.ozlabs.org/bundle/Jack1221/qt6-6.9/mbox/ | git apply


WORKDIR /home/odysseus/outputs/
COPY ./docker_scripts /home/odysseus/scripts
RUN echo "source /home/odysseus/scripts/setup_env.sh" >> ~/.bashrc

# install password using wildcard so failures arent deadly
COPY ./SECRETS.env.* /home/odysseus/

ENTRYPOINT "/bin/bash"
