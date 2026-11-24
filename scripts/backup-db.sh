#!/usr/bin/env bash
# Backup do Postgres local (docker compose) — audit (ALTA: sem backup automático).
#
# Uso:
#   scripts/backup-db.sh
#   CONTAINER=... DB=... OUT_DIR=... scripts/backup-db.sh
#
# Gera um dump comprimido em OUT_DIR (default: backups/) com timestamp UTC.
set -euo pipefail

CONTAINER="${CONTAINER:-school-management-api-postgres-1}"
DB="${DB:-SchoolManagementDb}"
PGUSER="${PGUSER:-postgres}"
OUT_DIR="${OUT_DIR:-backups}"

mkdir -p "$OUT_DIR"
STAMP="$(date -u +%Y%m%dT%H%M%SZ)"
OUT="$OUT_DIR/${DB}-${STAMP}.sql.gz"

docker exec -i "$CONTAINER" pg_dump -U "$PGUSER" -d "$DB" | gzip > "$OUT"

echo "$OUT"