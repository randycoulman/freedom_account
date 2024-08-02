#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" &> /dev/null && pwd)"

case "${1-}" in
  install)
    crontab "${SCRIPT_DIR}/backup_db.cron"
    echo "⬆️ crontab installed"
    crontab -l
    exit 0
    ;;

  uninstall)
    crontab -r
    echo "⬇️ crontab uninstalled"
    crontab -l
    exit 0
    ;;
esac

BACKUP_DIR="${HOME}/backups"
SECRETS="${SCRIPT_DIR}/../config/db_secret.env"

set +a
. ${SECRETS}
set -a

BACKUP_FILE="${BACKUP_DIR}/${POSTGRES_DB}_$(date +%Y%m%d).sql"

mkdir -p $BACKUP_DIR

cd ${SCRIPT_DIR}/..
PGPASSWORD="$POSTGRES_PASSWORD" asdf exec pg_dump -h localhost -U "$POSTGRES_USER" "$POSTGRES_DB" > "$BACKUP_FILE"

find "$BACKUP_DIR" -type f -name "*.sql" -mtime +7 -exec rm {} \;
