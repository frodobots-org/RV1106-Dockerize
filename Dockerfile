# Use Ubuntu 22.04 as the base image
FROM ubuntu:22.04

# Set environment variables
ENV SDK_PATH=/opt/rv1106_firmware

# Install necessary dependencies
RUN apt-get update && apt-get install -y \
    build-essential \
    git \
    wget \
    python3 \
    python3-pip \
    python-is-python3 \
    libncurses5-dev \
    flex \
    bison \
    libssl-dev \
    bc \
    cpio \
    unzip \
    device-tree-compiler \
    jq \
    pkg-config \
    vim \
    net-tools \
    && rm -rf /var/lib/apt/lists/*

RUN sed -i 's/archive.ubuntu.com/mirrors.aliyun.com/g' /etc/apt/sources.list \
    && apt update \
    && apt install texinfo -y

RUN apt-get install gperf -y

RUN apt-get install cmake -y

RUN git config --global --add safe.directory /opt/rv1106_firmware

# Create SDK directory (mount point)
RUN mkdir -p ${SDK_PATH}

# Set working directory
WORKDIR ${SDK_PATH}

# Define default command
CMD ["/bin/bash"]
