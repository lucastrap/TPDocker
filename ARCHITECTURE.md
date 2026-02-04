# Architecture du Projet Docker Cloud

Ce document detaille l'architecture containerisee mise en place pour le projet Docker Cloud. Il explique les choix techniques, les configurations, et l'orchestration des services.

## 1. Schema d'Architecture (Flux de Donnees)

```mermaid
graph TD
    subgraph Host_Windows ["Machine Hote (Windows)"]
        User((Utilisateur))
        HostVol["Dossier: ./backups_on_host"]
    end

    subgraph Docker_Stack ["Docker Compose Stack (internal_net)"]
        direction TB
        
        Front["<b>Frontend (Nginx)</b><br/>Port: 80<br/>RAM: 128M"]
        Back["<b>Backend (Express API)</b><br/>Port: 3000<br/>RAM: 256M"]
        DB[("<b>Database (PostgreSQL)</b><br/>Port: 5432<br/>RAM: 512M")]
        Backup["<b>Backup Service (Debian Custom)</b><br/>No Port<br/>RAM: 64M"]
        
        %% Inheritance
        BaseImage["<b>Base Image Ops</b><br/>(Debian + Tools)"] -.->|extends| Backup
    end

    %% Connections
    User -- "HTTP :8080" --> Front
    Front -- "Reverse Proxy" --> Back
    Back -- "SQL Protocol" --> DB
    Backup -- "pg_dump" --> DB
    Backup -- "Volume Bind" --> HostVol
```

## 2. Choix de Build et Personnalisation des Images

Toutes les images utilisees sont **construites localement** (directive `build` dans docker-compose) et n'utilisent pas directement des images brutes du Docker Hub sans modification.

### A. Arguments de Build (ARG)
Pour flexibiliser la construction, des arguments `ARG` ont ete introduits dans chaque Dockerfile. Cela permet de changer la version des bases sans modifier le code.

| Service | Build Arg | Valeur par defaut | Description |
| :--- | :--- | :--- | :--- |
| **Base** | `DEBIAN_VERSION` | `bullseye-slim` | Version de l'OS Debian minimal |
| **Backend** | `NODE_VERSION` | `18-slim` | Version du runtime Node.js |
| **Frontend** | `NGINX_VERSION` | `latest` | Version du serveur Web Nginx |
| **Database** | `PG_VERSION` | `15` | Version du moteur PostgreSQL |

### B. Dependances et Operations Systeme

Chaque image a ete enrichie avec des outils specifiques pour l'administration et le debug, justifiant la necessite de creer nos propres images.

#### 1. Base Image & Backup Service
*   **Base (Debian)** : 
    *   `vim` : Essentiel pour editer des fichiers de configuration *in situ* lors de debugs d'urgence en production.
    *   `curl` : Permet de tester les endpoints HTTP internes et la connectivite sortante.
    *   `tar` : Utilise pour compresser/decompresser les archives de logs ou de backups.
*   **Backup** : Utilise `postgresql-client` specifiquement pour la commande `pg_dump`, standard industriel pour les exports PostgreSQL.
*   **Nettoyage OS** : La commande `rm -rf /var/lib/apt/lists/*` est cruciale pour alleger l'image finale. Elle supprime les index de paquets telecharges qui ne sont plus necessaires apres l'installation, reduisant l'empreinte disque sur le registre et l'orchestrateur.

#### 2. Backend (Node.js)
*   **Outils ajoutes** :
    *   `iputils-ping` : Indispensable pour diagnostiquer les problemes de resolution DNS (`ping db`) ou de routage reseau interne entre les conteneurs.
    *   `curl` : Utilise par le *Healthcheck* Docker pour valider que l'API repond (200 OK) avant d'envoyer du trafic.
*   **Securite** : Le choix de l'image `slim` evite d'embarquer des centaines de vulnerabilites potentielles presentes dans une image complete.

#### 3. Frontend (Nginx) & Database
*   **Outils ajoutes** : 
    *   `procps` (sur la DB) : Fournit `ps` et `top`. Sans cela, il est impossible de surveiller la consommation memoire reelle d'un processus PostgreSQL qui s'emballerait.
    *   `vim` : Permet de modifier la configuration Nginx (`nginx.conf`) ou Postgres (`postgresql.conf`) pour tester des optimisations sans devoir reconstruire l'image a chaque essai (hot-debugging).

## 3. Configuration et Arguments au Run (ENV)

L'orchestration injecte des variables d'environnement pour configurer le comportement des conteneurs au demarrage.

| Service | Variable | Valeur (Exemple) | Role |
| :--- | :--- | :--- | :--- |
| **Database** | `POSTGRES_USER` | `luca` | Definit le super-admin de la DB |
| | `POSTGRES_PASSWORD`| `password` | Definit le mot de passe admin |
| | `POSTGRES_DB` | `tp_docker` | Cree une DB initiale par defaut |
| **Backend** | `PORT` | `3000` | Port d'ecoute de l'application Node |
| | `DB_HOST` | `db` | Hostname du service DB (resolution DNS interne Docker) |

## 4. Gestion des Ressources et Orchestration

Le fichier `docker-compose.yml` definit des contraintes strictes pour simuler un environnement Cloud realiste.

### Allocation des Ressources (Limits)
Dans un contexte Cloud/Mutualise, il est imperatif d'isoler les performances pour eviter qu'un service ne sature la machine ("Voisin bruyant").

*   **Database (512M RAM / 1.0 CPU)** : 
    *   *Pourquoi ?* Une BDD necessite de charger ses index en RAM pour etre performante. C'est le goulot d'etranglement principal de l'architecture.
*   **Backend (256M RAM / 0.5 CPU)** : 
    *   *Pourquoi ?* Node.js est efficace mais gourmand en RAM (V8 Engine). Une limite trop basse provoquerait des crashs (OOM Killed). 0.5 CPU suffit car Node est asynchrone single-threaded.
*   **Frontend (128M RAM / 0.2 CPU)** : 
    *   *Pourquoi ?* Nginx sert des fichiers statiques ; c'est une operation I/O bound tres peu couteuse en CPU/RAM.
*   **Backup (64M RAM / 0.2 CPU)** : 
    *   *Pourquoi ?* Processus ephemere et sequentiel, pas besoin de priorite.

### Ordre de Demarrage et Healthchecks
Le systeme respecte un ordre strict grace a `depends_on` conditionne par des *Healthchecks* :
1.  **Database** demarre. Docker attend que `pg_isready` renvoie OK (Service Healthy).
2.  **Backend** demarre seulement quand la DB est Healthy.
3.  **Frontend** demarre seulement quand le Backend est Healthy.

### Gestion du SIGTERM (Graceful Shutdown)
Le code du Backend (`server.js`) intercepte le signal `SIGTERM` envoye par Docker lors d'un arret (`docker compose stop`). Cela permet de fermer proprement le serveur HTTP avant de tuer le processus, evitant de corrompre des requetes en cours.

## 5. Entrypoints
Nous avons mis en place des scripts `entrypoint.sh` pour initialiser l'environnement avant de lancer l'application principale.

*   **Backend** :
    *   **Script** : Initialise le conteneur, affiche la version de Node.js et verifie la presence de la variable `DB_HOST` pour le debug.
    *   **CMD** : `["node", "server.js"]` (passe en argument a l'entrypoint).
*   **Backup** :
    *   **Script** : Verifie que le volume `/backup_data` est bien monte et accessible en ecriture avant de demarrer, evitant des erreurs silencieuses lors des sauvegardes.
    *   **CMD** : `["sleep", "infinity"]` (garde le conteneur en vie).


