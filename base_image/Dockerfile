# Image de base Debian avec outils de debug (vim/curl) et nettoyage des fichiers temporaires pour optimiser la taille.
ARG DEBIAN_VERSION=bullseye-slim
FROM debian:${DEBIAN_VERSION}

RUN apt-get update && apt-get install -y \
    vim \
    curl \
    tar \
    && rm -rf /var/lib/apt/lists/*
