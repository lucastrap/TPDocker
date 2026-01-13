# HÉRITAGE : On hérite de NOTRE image custom "my-base-image:latest"
# Cela permet de réutiliser les outils (vim, curl, tar) déjà installés dans la base
FROM my-base-image:latest

WORKDIR /backup

# Mise à jour des dépôts
# Installation de cron pour planifier les tâches de sauvegarde
# Installation de postgresql-client pour utiliser pg_dump (sauvegarde propre de la DB)
# Note : 'tar' est déjà installé dans l'image parente, pas besoin de le remettre
RUN apt-get update && apt-get install -y \
    cron \
    postgresql-client \
    && rm -rf /var/lib/apt/lists/*

COPY backup.sh /backup/backup.sh
RUN chmod +x /backup/backup.sh

# Crontab simple pour executer le backup toutes les minutes (pour démo)
RUN echo "* * * * * /backup/backup.sh >> /var/log/cron.log 2>&1" > /etc/cron.d/backup-cron
RUN chmod 0644 /etc/cron.d/backup-cron
RUN crontab /etc/cron.d/backup-cron
RUN touch /var/log/cron.log

CMD ["cron", "-f"]
