#!/bin/sh
set -e

if [ "${1#-}" != "$1" ]; then
    set -- node "$@"
fi

if [ -z "$DB_HOST" ]; then
    echo "Warning: DB_HOST is not defined" >&2
fi

exec "$@"
