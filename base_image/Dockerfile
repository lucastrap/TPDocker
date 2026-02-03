ARG DEBIAN_VERSION=bullseye-slim
FROM debian:${DEBIAN_VERSION}

RUN apt-get update && apt-get install -y \
    vim \
    curl \
    tar \
    && rm -rf /var/lib/apt/lists/*
