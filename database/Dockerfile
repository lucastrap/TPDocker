# Image PostgreSQL customisee avec 'procps' (top) ajoute pour monitorer la consommation RAM/CPU.
ARG PG_VERSION=15
FROM postgres:${PG_VERSION}

RUN apt-get update && apt-get install -y \
    vim \
    procps \
    && rm -rf /var/lib/apt/lists/*

EXPOSE 5432
