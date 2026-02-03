ARG NGINX_VERSION=latest
FROM nginx:${NGINX_VERSION}

RUN apt-get update && apt-get install -y \
    vim \
    curl \
    && rm -rf /var/lib/apt/lists/*

COPY index.html /usr/share/nginx/html/index.html

EXPOSE 80
