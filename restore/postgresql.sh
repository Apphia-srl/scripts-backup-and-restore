# Apphia s.r.l.
# Restore script for PostgreSQL database using Docker Compose
#
# To update this script run
# curl -fsOL https://raw.githubusercontent.com/Apphia-srl/scripts-backup-and-restore/refs/heads/main/restore/postgresql.sh

#!/bin/bash

set -e

log()   {
    if [ "$#" -eq 2 ]; then
        echo -e "$(date '+%Y-%m-%dT%H:%M:%SZ') \033[34m[$1] \033[0m  $2";
    else
        echo -e "$(date '+%Y-%m-%dT%H:%M:%SZ') \033[34m[INFO]\033[0m  $1";
    fi
}

# Usage help message
if [ "$#" -lt 1 ] || [ "$#" -gt 3 ]; then
    echo "Usage: $0 <input-file-path.sql.gz> [<compose-file-path>] [<service-name>]"
    exit -1
fi

log "INFO" "Starting restore of PostgreSQL..."

FILENAME=$1
COMPOSE=${2:-"docker-compose.yml"}
SERVICE=${3:-"postgres"}

# Ensure the input file has a .sql.gz extension
if [[ ! $FILENAME == *.sql.gz ]]; then
    log "ERROR" "Input file must have a .sql.gz extension"
    exit -1
fi

COMMAND="gzip -cd /tmp/postgres.sql.gz | psql -U \$POSTGRES_USER \$POSTGRES_DB"

SECONDS=0

docker compose -f $COMPOSE cp $FILENAME $SERVICE:/tmp/postgres.sql.gz
docker compose -f $COMPOSE exec $SERVICE sh -c "$COMMAND"

FILESIZE=$(stat -c%s "$FILENAME")
log "INFO" "Restored database from $FILENAME ($FILESIZE bytes) in $SECONDS s"
