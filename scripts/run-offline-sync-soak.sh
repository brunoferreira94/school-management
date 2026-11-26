#!/usr/bin/env bash
# Supervisor do soak do contrato offline-sync (task 5.3 / janela 5.2).
#
# O soak precisa trafficar durante a janela de 24h do Bloco 5: se o processo
# node cair (ou a máquina reiniciar), o `provided{batch}` para de crescer e o
# gate `missing_key` fica indecidível. Este wrapper reinicia o harness.
#
# Uso: setsid nohup scripts/run-offline-sync-soak.sh > /dev/null 2>&1 &
set -uo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
API_DIR="$ROOT/school-management-api"
LOG="$API_DIR/observability/soak.log"

export SMOKE_BASE_URL="${SMOKE_BASE_URL:-https://school-management-api-dev.onrender.com}"
export SMOKE_USERNAME="${SMOKE_USERNAME:-diretor.validacao.1795581595@escola.test}"
export SMOKE_PASSWORD="${SMOKE_PASSWORD:-Senha123!}"
export SMOKE_CLIENTS="${SMOKE_CLIENTS:-5}"
export SMOKE_OPS_PER_DAY="${SMOKE_OPS_PER_DAY:-10000}"

echo "[$(date -u +%H:%M:%S)] supervisor do soak iniciado (pid $$)" >> "$LOG"

# Node vem do nvm (fora do shell do agente o PATH não tem node).
NODE_BIN="$(command -v node || true)"
if [[ -z "$NODE_BIN" && -s "$HOME/.nvm/nvm.sh" ]]; then
  # shellcheck disable=SC1090
  . "$HOME/.nvm/nvm.sh" >/dev/null 2>&1 || true
  nvm use 24 >/dev/null 2>&1 || true
  NODE_BIN="$(command -v node || true)"
fi
if [[ -z "$NODE_BIN" ]]; then
  echo "[$(date -u +%H:%M:%S)] node não encontrado — supervisor abortado" >> "$LOG"
  exit 1
fi
echo "[$(date -u +%H:%M:%S)] node: $NODE_BIN ($("$NODE_BIN" --version))" >> "$LOG"

while true; do
  echo "[$(date -u +%H:%M:%S)] iniciando harness" >> "$LOG"
  "$NODE_BIN" "$API_DIR/observability/smoke-offline-sync.mjs" >> "$LOG" 2>&1
  echo "[$(date -u +%H:%M:%S)] harness saiu (code $?) — reiniciando em 15s" >> "$LOG"
  sleep 15
done
