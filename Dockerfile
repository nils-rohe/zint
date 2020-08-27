FROM ubuntu:20.04

RUN export DEBIAN_FRONTEND=noninteractive && \
    apt-get update && apt-get install -y --no-install-recommends \
    # git pull script dependencies
    ca-certificates \
    git \
    # zint dependencies
    build-essential \
    cmake\
    libpng-dev \
 && rm -rf /var/lib/apt/lists/*
