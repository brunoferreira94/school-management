#!/usr/bin/env bash
# Verifica o gate de adesão do contrato de sincronização offline (Bloco 5).
#
# Uso:
#   scripts/check-offline-sync-gate.sh                    # staging
#   scripts/check-offline-sync-gate.sh --env production
#   scripts/check-offline-sync-gate.sh --env staging --window 24h
#
# Regras (docs/runbooks/offline-sync-rollout.md §Checkpoint):
#   1) missing_key (batch) < 1%   — série ausente = 0 missing (passa)
#   2) revision_missing < 1%       — série ausente = 0 missing (passa)
#   3) adesão por rota ≥ 99%       — "provided" sobre o total da rota
#   4) nenhum alerta "firing"
#
# Variáveis:
#   PROMETHEUS_URL (default: http://127.0.0.1:9090)
set -euo pipefail

ENVIRONMENT="staging"
WINDOW="1h"

while [[ $# -gt 0 ]]; do
  case "$1" in
    --env) ENVIRONMENT="${2:?--env exige staging|production}"; shift ;;
    --window) WINDOW="${2:?--window exige ex.: 1h|24h}"; shift ;;
    -h|--help) sed -n '2,16p' "$0"; exit 0 ;;
    *) echo "argumento desconhecido: $1" >&2; exit 2 ;;
  esac
  shift
done

PROMETHEUS_URL="${PROMETHEUS_URL:-http://127.0.0.1:9090}"

query() {
  curl -s --max-time 20 "$PROMETHEUS_URL/api/v1/query" --data-urlencode "query=$1"
}

# Retorna "SEM DADO" quando a série não existe (ausente = 0 eventos).
value() {
  python3 -c "
import sys, json
d = json.load(sys.stdin)
r = d.get('data', {}).get('result', [])
print(r[0]['value'][1] if r else 'SEM DADO')
"
}

echo "== gate offline-sync | environment=$ENVIRONMENT | janela=$WINDOW"
echo

MISSING_RATIO=$(query "sum(rate(idempotency_key_missing{environment=\"$ENVIRONMENT\", source=\"batch\"}[$WINDOW])) / (sum(rate(idempotency_key_missing{environment=\"$ENVIRONMENT\", source=\"batch\"}[$WINDOW])) + sum(rate(idempotency_key_provided{environment=\"$ENVIRONMENT\", source=\"batch\"}[$WINDOW])))" | value)
REVISION_RATIO=$(query "sum(rate(revision_missing{environment=\"$ENVIRONMENT\"}[$WINDOW])) / sum(rate(offline_sync_total{environment=\"$ENVIRONMENT\"}[$WINDOW]))" | value)
FIRING=$(query "ALERTS{alertstate=\"firing\", environment=\"$ENVIRONMENT\"}" | python3 -c "
import sys, json
d = json.load(sys.stdin)
r = d.get('data', {}).get('result', [])
print(len(r))
")

echo "1) missing_key (batch):     $MISSING_RATIO   (passa se < 0.01 ou ausente)"
echo "2) revision_missing:        $REVISION_RATIO   (passa se < 0.01 ou ausente)"
echo "3) adesão por rota:"
query "sum by (route) (rate(revision_adherence{state=\"provided\", environment=\"$ENVIRONMENT\"}[$WINDOW])) / sum by (route) (rate(revision_adherence{environment=\"$ENVIRONMENT\"}[$WINDOW]))" |
  python3 -c "
import sys, json
d = json.load(sys.stdin)
r = d.get('data', {}).get('result', [])
if not r:
    print('   (sem tráfego medido na janela)')
for x in r:
    route = x['metric'].get('route', '?')
    ratio = x['value'][1]
    try:
        pct = float(ratio) * 100
    except ValueError:
        pct = None
    if pct is None or pct != pct:  # None ou NaN
        # NaN = 0/0: sem tráfego medido na janela (a série existe, mas não variou).
        print(f'   - {route}: sem tráfego na janela')
        continue
    marca = '✓' if pct >= 99 else '✗'
    print(f'   {marca} {route}: {pct:.2f}% provided')
"
echo "4) alertas firing:          $FIRING   (passa se 0)"
echo
echo "Nota: os contadores são cumulativos — as sondas do próprio gate (400/428)"
echo "ficam gravadas como 'missing'. Meça por DELTA a partir da base registrada"
echo "no runbook (resultado da execução de 26/11) ou use uma janela que as exclua."
