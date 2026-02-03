ARG PG_VERSION=15
FROM postgres:${PG_VERSION}

# Mise à jour de la liste des paquets pour récupérer les dernières versions
# Installation de 'vim' : Utile pour éditer les fichiers de configuration de PostgreSQL (pg_hba.conf, postgresql.conf) directement dans le conteneur pour le debugging.
# Installation de 'procps' : Fournit la commande 'ps' et 'top' pour surveiller les processus de la base de données en temps réel.
RUN apt-get update && apt-get install -y \
    vim \
    procps \
    && rm -rf /var/lib/apt/lists/*

# On conserve le port standard
EXPOSE 5432
