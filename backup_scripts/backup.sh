#!/bin/bash
# cronjob qui lance un pg_dump et sauvegarde le fichier sur l'hôte
echo "Starting Backup..."
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
pg_dump -h db -U $POSTGRES_USER -d $POSTGRES_DB > /backup_data/db_backup_$TIMESTAMP.sql
if [ $? -eq 0 ]; then
    echo "Backup created: db_backup_$TIMESTAMP.sql"
    
    ls -tp /backup_data/db_backup_*.sql | grep -v '/$' | tail -n +6 | xargs -I {} rm -- "{}" || true
else
    echo "Error: Backup failed!"
fi
