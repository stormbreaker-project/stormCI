FROM ubuntu:20.04
LABEL maintainer="Saalim Quadri <danascape@gmail.com>"

# Install required dependencies
RUN apt-get update && \
    apt-get install -y build-essential bc python curl \
    git zip ftp gcc-aarch64-linux-gnu gcc-arm-linux-gnueabi \
    libssl-dev lftp zstd wget libfl-dev clang flex bison cpio

CMD ["bash"]
