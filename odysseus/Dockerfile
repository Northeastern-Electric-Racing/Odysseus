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


# add all buildroot files there
WORKDIR /home/odysseus/build

RUN  git clone https://gitlab.com/buildroot.org/buildroot.git && cd ./buildroot && git checkout 2024.02

ADD ./docker_out_of_tree.sh /home/odysseus/

RUN echo 'alias make-current="time make -j`nproc` --output-sync=target 2>&1 | tee output.log"' >> ~/.bashrc && \
echo "/home/odysseus/docker_out_of_tree.sh" >> ~/.bashrc && \
echo 'echo \
" .d88888b.       888\n\                                              
d88P  Y88b       888\n\                                             
888     888      888\n\                         
888     888  .d88888 888  888 .d8888b  .d8888b   .d88b.  888  888\n\
888     888 d88  888 888  888 88K      88K      d8P  Y8b 888  888\n\ 
888     888 888  888 888  888  Y8888b.  Y8888b. 88888888 888  888\n\ 
Y88b. .d88P Y88b 888 Y88b 888      X88      X88 Y8b.     Y88b 888\n\ 
  Y88888P     Y88888   Y88888  88888P   88888P    Y8888    Y88888\n\ 
                          888                                 888\n\ 
                     Y8b d88P                            Y8b d88P\n\
                       Y88P                                Y88P"' >> ~/.bashrc
ENTRYPOINT "/bin/bash"
WORKDIR /home/odysseus/outputs/
