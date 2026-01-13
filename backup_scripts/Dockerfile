# HÉRITAGE : On hérite de NOTRE image custom "my-base-image:latest"
# Cela permet de réutiliser les outils (vim, curl, tar) déjà installés dans la base
FROM my-base-image:latest

WORKDIR /backup

# Mise à jour des dépôts
# Installation de cron pour planifier les tâches de sauvegarde
# Installation de postgresql-client pour utiliser pg_dump (sauvegarde propre de la DB)
# Note : 'tar' est déjà installé dans l'image parente, pas besoin de le remettre
RUN apt-get update && apt-get install -y \
    postgresql-client \
    && rm -rf /var/lib/apt/lists/*

# On garde le conteneur en vie indéfiniment pour pouvoir lancer des backups manuellement
# ou via un script externe avant l'extinction. Plus de cron automatique.
CMD ["sleep", "infinity"]
