#!/usr/bin/env bash
# Restore de um dump (scripts/backup-db.sh) para um banco de destino.
#
# Uso:
#   scripts/restore-db.sh backups/SchoolManagementDb-20261124T120000Z.sql.gz
#   TARGET=SchoolManagementDb_RestoreTest scripts/restore-db.sh <dump>
#
# O banco de destino é criado (CREATE DATABASE) se não existir. NUNCA aponta
# para o banco de produção sem intenção explícita.
set -euo pipefail

DUMP="${1:?informe o caminho do dump (.sql.gz)}"
CONTAINER="${CONTAINER:-school-management-api-postgres-1}"
PGUSER="${PGUSER:-postgres}"
TARGET="${TARGET:-SchoolManagementDb_RestoreTest}"

if [[ ! -f "$DUMP" ]]; then
    echo "dump não encontrado: $DUMP" >&2
    exit 1
fi

docker exec -i "$CONTAINER" psql -U "$PGUSER" -d postgres -v ON_ERROR_STOP=1 \
    -c "CREATE DATABASE \"$TARGET\"" 2>/dev/null || true

gunzip -c "$DUMP" | docker exec -i "$CONTAINER" psql -U "$PGUSER" -d "$TARGET" -v ON_ERROR_STOP=1

echo "restore concluído em $TARGET"