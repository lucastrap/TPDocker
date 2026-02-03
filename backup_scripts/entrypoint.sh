#!/bin/bash
set -e

if [ -d "/backup_data" ]; then
    if ! touch /backup_data/.writable_check 2>/dev/null; then
        echo "Warning: /backup_data is not writable" >&2
    else
        rm /backup_data/.writable_check
    fi
else
    echo "Warning: /backup_data directory does not exist" >&2
fi

exec "$@"
