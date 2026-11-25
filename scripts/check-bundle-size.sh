#!/usr/bin/env bash
# Orçamento de bundle (audit — performance): falha se o chunk principal (main)
# passar de 500 KB gzip. Rode após `ng build --configuration production`.
#
# Uso: scripts/check-bundle-size.sh [browser_dir]
set -euo pipefail

DIR="${1:-school-management-ui/dist/school-management-app/browser}"
LIMIT="${BUNDLE_MAIN_LIMIT_KB:-500}"

MAIN=$(ls "$DIR"/main-*.js 2>/dev/null | head -1 || true)
if [[ -z "$MAIN" ]]; then
    echo "main-*.js não encontrado em $DIR (rode o build de produção)" >&2
    exit 2
fi

SIZE=$(gzip -c "$MAIN" | wc -c)
KB=$((SIZE / 1024))

echo "main: ${KB} KB gzip (limite ${LIMIT} KB)"
if (( KB > LIMIT )); then
    echo "ESTOURANDO o orçamento: $KB > $LIMIT KB" >&2
    exit 1
fi
echo "ok"