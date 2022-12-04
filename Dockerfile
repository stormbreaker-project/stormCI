FROM ubuntu:20.04
LABEL maintainer="Saalim Quadri <danascape@gmail.com>"

ENV USER=saalim \
    HOSTNAME=StormCI

# Install required dependencies
RUN apt-get update && \
    apt-get install -y build-essential bc python curl \
    git zip ftp gcc-aarch64-linux-gnu gcc-arm-linux-gnueabi \
    libssl-dev lftp zstd wget libfl-dev clang flex bison cpio sudo

# Create separate user
RUN useradd -u 999 --shell /bin/bash --create-home -r -g sudo ${USER}

# Allow sudo without password for build user
RUN echo "${USER} ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/docker-build

USER ${USER}

CMD ["bash"]