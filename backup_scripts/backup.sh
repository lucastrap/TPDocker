#!/bin/bash
echo "Starting Backup..."
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
# Backup du volume partagé ou dump de la base
pg_dump -h db -U $POSTGRES_USER -d $POSTGRES_DB > /backup_data/db_backup_$TIMESTAMP.sql
echo "Backup created: db_backup_$TIMESTAMP.sql"
