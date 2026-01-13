FROM nginx:latest

# Mise à jour des paquets système
# Installation de vim pour pouvoir éditer la conf en live si nécessaire (debug)
# Installation de curl pour tester les appels vers le backend depuis ce container
RUN apt-get update && apt-get install -y \
    vim \
    curl \
    && rm -rf /var/lib/apt/lists/*

# Copie de notre fichier HTML custom
COPY index.html /usr/share/nginx/html/index.html

EXPOSE 80
