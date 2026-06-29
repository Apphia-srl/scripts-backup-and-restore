# Apphia s.r.l.
# Backup script for PostgreSQL database using Docker Compose
#
# To update this script run
# curl -fsOL https://raw.githubusercontent.com/Apphia-srl/scripts-backup-and-restore/refs/heads/main/backup/postgresql.sh

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
    echo "Usage: $0 <output-file-path.sql.gz> [<compose-file-path>] [<service-name>]"
    exit -1
fi

log "INFO" "Starting backup of PostgreSQL..."

FILENAME=$1
COMPOSE=${2:-"docker-compose.yml"}
SERVICE=${3:-"postgres"}

# Ensure the output file has a .sql.gz extension
if [[ ! $FILENAME == *.sql.gz ]]; then
    FILENAME="${FILENAME}.sql.gz"
fi

# Create the output directory if it doesn't exist
OUTPUT_DIR=$(dirname "$FILENAME")
mkdir -p "$OUTPUT_DIR"

COMMAND="pg_dump -U \$POSTGRES_USER \$POSTGRES_DB --clean --if-exists | gzip"

SECONDS=0

docker compose -f $COMPOSE exec $SERVICE sh -c "$COMMAND" > $FILENAME

FILESIZE=$(stat -c%s "$FILENAME")
log "INFO" "Backup of PostgreSQL to $FILENAME ($FILESIZE bytes) in $SECONDS s"
