# Image heritant de ma base custom, avec client Postgres pour effectuer les dumps (sauvegardes).
FROM my-base-image:latest

WORKDIR /backup

RUN apt-get update && apt-get install -y \
    postgresql-client \
    && rm -rf /var/lib/apt/lists/*

COPY entrypoint.sh /usr/local/bin/
COPY backup.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/entrypoint.sh /usr/local/bin/backup.sh

ENTRYPOINT ["entrypoint.sh"]
CMD ["sh", "-c", "while true; do backup.sh; sleep 60; done"]
