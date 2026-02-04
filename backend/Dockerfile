# Image Node.js Slim (securite) enrichie avec 'ping' pour verifier la connexion reseau vers la BDD.
ARG NODE_VERSION=18-slim
FROM node:${NODE_VERSION}

WORKDIR /app

RUN apt-get update && apt-get install -y \
    curl \
    iputils-ping \
    && rm -rf /var/lib/apt/lists/*

COPY package.json .

RUN npm install

COPY . .

COPY entrypoint.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/entrypoint.sh

EXPOSE 3000

ENTRYPOINT ["entrypoint.sh"]

CMD ["node", "server.js"]
