# Architecture Technique

## 1. Vue d'ensemble

L'infrastructure simule un environnement de production complet sur une stack Docker Compose.

## 2. Stratégie de Construction (Build)

Les images ne proviennent pas directement du Hub Docker ("FROM node" direct) mais sont construites via des `Dockerfile` locaux pour garantir la maîtrise de la chaine logicielle et des outils embarqués.

### Arguments de Build (ARG)
Standardisation des versions via variables de build :

| Service | Argument | Valeur | Rôle |
| :--- | :--- | :--- | :--- |
| **System** | `DEBIAN_VERSION` | `bullseye-slim` | OS minimal (Base security) |
| **Backend** | `NODE_VERSION` | `18-slim` | Runtime application |
| **Frontend** | `NGINX_VERSION` | `latest` | Serveur Web / Proxy |
| **Data** | `PG_VERSION` | `15` | Moteur BDD |

### Outillage & Maintenance (Ops)
Ajout d'outils spécifiques pour le débogage en conteneur ("exec") et la maintenance :

*   **Socle Commun** : `vim`, `curl`, `tar` (héritage partiel).
*   **Backend** : `iputils-ping` pour valider la résolution DNS interne (`ping db`).
*   **Backup** : `postgresql-client` requis pour l'extraction des données (`pg_dump`).
*   **Database** : `procps` pour le monitoring des processus (`top`, `ps`).

## 3. Configuration & Runtime

L'injection de configuration se fait exclusivement via variables d'environnement au démarrage du conteneur.

| Service | Variable | Description |
| :--- | :--- | :--- |
| **DB / Backup** | `POSTGRES_USER/DB` | Identifiants et nom de base |
| **Backend** | `DB_HOST` | Cible de connexion (DNS Docker) |
| **Global** | `TZ` | Fuseau horaire (si applicable) |

## 4. Orchestration & Ressources

### Dimensionnement (Quotas)
Application de limites strictes (`deploy.resources.limits`) pour garantir la stabilité du noeud hôte et éviter les effets de "voisin bruyant".

*   **Database (1.0 CPU / 512MB)** : Priorité haute. Mémoire requise pour le cache et les connexions concurrentes.
*   **Backend (0.5 CPU / 256MB)** : Dimensionné pour un usage standard Node.js.
*   **Frontend (0.2 CPU / 128MB)** : Nginx est très peu gourmand en ressources pour du contenu statique/proxy.
*   **Backup (0.2 CPU / 64MB)** : Processus background ponctuel.

### Cycle de vie
Utilisation de `depends_on` couplé aux `healthcheck` pour un démarrage séquentiel fiable :
1.  **DB** : Attente disponibilité socket + réponse `pg_isready`.
2.  **Backend** : Attente statut "Healthy" de la DB.
3.  **Frontend** : Attente statut "Healthy" du Backend.

**Gestion des signaux** : Le backend écoute `SIGTERM` pour fermer proprement le serveur HTTP avant l'arrêt du conteneur (Graceful Shutdown).


