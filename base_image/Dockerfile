# Image de base partagée "Ops"
# Elle contient les outils communs d'administration (Vim, Curl, Tar)
# Cette image servira de socle pour l'image de backup
FROM debian:bullseye-slim

# Explication des apt-get : 
# - vim : pour éditer des fichiers directement dans n'importe quel conteneur qui hérite de celui-ci
# - curl : pour faire des requêtes HTTP de diagnostic
# - tar : pour la compression de fichiers (utilisé plus tard dans le backup)
RUN apt-get update && apt-get install -y \
    vim \
    curl \
    tar \
    && rm -rf /var/lib/apt/lists/*
