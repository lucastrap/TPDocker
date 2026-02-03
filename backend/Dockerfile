ARG NODE_VERSION=18-slim
FROM node:${NODE_VERSION}

WORKDIR /app

# Mise à jour des listes de paquets pour avoir les dernières versions disponibles
# Installation de curl pour les healthchecks (vérifier si le serveur répond)
# Installation de iputils-ping pour tester la connectivité réseau interne vers la DB
RUN apt-get update && apt-get install -y \
    curl \
    iputils-ping \
    && rm -rf /var/lib/apt/lists/*

# Copie des fichiers de dépendances
COPY package.json .

# Installation des dépendances Node
RUN npm install

# Copie du reste du code source
COPY . .

# Documentation du port utilisé
EXPOSE 3000

# Démarrage de l'application
CMD ["node", "server.js"]
