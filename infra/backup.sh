#!/usr/bin/env sh
# Nightly backup of the database and uploaded files, 30 days kept (docs/03-conception/07-NON_FUNCTIONAL.md).
# Cron on the server, from infra/:  0 2 * * * /path/to/infra/backup.sh >> /var/log/ngclass-backup.log 2>&1
# Copy BACKUP_DIR to a second location (another server or storage) as well.
set -eu
cd "$(dirname "$0")"
BACKUP_DIR="${BACKUP_DIR:-/var/backups/ngclass}"
STAMP="$(date +%Y-%m-%d_%H%M)"
mkdir -p "$BACKUP_DIR"

docker compose -f docker-compose.prod.yml exec -T db pg_dump -U ngclass -d ngclass --format=custom \
	> "$BACKUP_DIR/db_$STAMP.dump"
docker compose -f docker-compose.prod.yml run --rm --no-deps -v "$BACKUP_DIR:/backup" --entrypoint sh api \
	-c "tar -czf /backup/files_$STAMP.tar.gz -C /data files"

find "$BACKUP_DIR" -type f -mtime +30 -delete
echo "$(date) backup $STAMP done"
