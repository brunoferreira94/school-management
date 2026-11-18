#!/usr/bin/env bash
# ================================================================
# Deploy da API no Render + verificação das métricas
# ================================================================
# O serviço `school-management-api` (Render) tem **auto-deploy DESLIGADO**
# (2026-10-28) — deploy é sempre manual.
#
# Este script:
#   1. lê RENDER_API_KEY do ambiente ou do .env do repo (gitignored)
#   2. dispara o deploy da API
#   3. aguarda o deploy ficar "live"
#   4. verifica se as métricas de rollout chegaram em produção
#      (GET /metrics → revision_adherence / idempotency_key_*)
#
# Uso: bash scripts/deploy-render-api.sh [--service <id>] [--no-wait]
#
# Chave: https://dashboard.render.com/account#api-keys
# Para usar o MCP Render (inspeção de serviços/env vars), a mesma chave vai
# em ~/.config/opencode/opencode.json → mcp.render.headers.Authorization
# (requer reiniciar o MCP para pegar a chave nova).
# ================================================================

set -uo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
ENV_FILE="${ENV_FILE:-$REPO_ROOT/.env}"
SERVICE_ID="${RENDER_SERVICE_ID:-srv-d82eofrbc2fs73b4jh1g}"
PROD_URL="${PROD_URL:-https://school-management-api-sik5.onrender.com}"
WAIT=true

while [ $# -gt 0 ]; do
    case "$1" in
        --service) SERVICE_ID="$2"; shift 2 ;;
        --no-wait) WAIT=false; shift ;;
        *) echo "opção desconhecida: $1"; exit 2 ;;
    esac
done

RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'; BLUE='\033[0;34m'; NC='\033[0m'
log_info() { echo -e "${BLUE}[INFO]${NC} $1"; }
log_ok()   { echo -e "${GREEN}[OK]${NC} $1"; }
log_warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }
log_error(){ echo -e "${RED}[FAIL]${NC} $1"; }

# ── 1. Chave ─────────────────────────────────────────────────────
if [ -z "${RENDER_API_KEY:-}" ] && [ -f "${ENV_FILE}" ]; then
    RENDER_API_KEY="$(grep -E '^RENDER_API_KEY=' "${ENV_FILE}" | head -1 | cut -d= -f2- | tr -d "\"' " )"
    [ -n "${RENDER_API_KEY}" ] && log_info "Chave lida de ${ENV_FILE}"
fi

if [ -z "${RENDER_API_KEY:-}" ]; then
    log_error "RENDER_API_KEY não encontrada (nem no ambiente, nem em ${ENV_FILE})"
    echo "        Gere em https://dashboard.render.com/account#api-keys e:"
    echo "        echo 'RENDER_API_KEY=rnd_...' >> ${ENV_FILE}"
    exit 1
fi

api() {
    curl -s -H "Authorization: Bearer ${RENDER_API_KEY}" \
         -H "Accept: application/json" \
         -H "Content-Type: application/json" \
         "$@"
}

# Valida a chave antes de qualquer ação
if ! api "https://api.render.com/v1/owners" | grep -q '"id"'; then
    log_error "RENDER_API_KEY inválida/ expirada (401). Gere uma nova:"
    echo "        https://dashboard.render.com/account#api-keys"
    echo "        echo 'RENDER_API_KEY=rnd_...' >> ${ENV_FILE}"
    exit 1
fi
log_ok "Chave válida"

# ── 2. Estado do serviço ─────────────────────────────────────────
log_info "Consultando o serviço ${SERVICE_ID}..."
service_json="$(api "https://api.render.com/v1/services/${SERVICE_ID}")"
service_name="$(echo "${service_json}" | python3 -c "import sys,json; print(json.load(sys.stdin).get('name','?'))" 2>/dev/null || echo "?")"
auto_deploy="$(echo "${service_json}" | python3 -c "import sys,json; print(json.load(sys.stdin).get('autoDeploy','?'))" 2>/dev/null || echo "?")"
log_ok "serviço '${service_name}' (autoDeploy=${auto_deploy})"

# Env vars relevantes (o rollout não deve depender de OTLP em produção)
env_json="$(api "https://api.render.com/v1/services/${SERVICE_ID}/env-vars")"
if echo "${env_json}" | grep -qi "OTEL_EXPORTER_OTLP_ENDPOINT"; then
    log_warn "OTEL_EXPORTER_OTLP_ENDPOINT está configurado — em produção não há collector OTLP; aponte para um collector real ou remova (as métricas chegam via GET /metrics)"
else
    log_ok "sem OTEL_EXPORTER_OTLP_ENDPOINT (correto: produção usa o endpoint /metrics)"
fi

# ── 3. Deploy ────────────────────────────────────────────────────
log_info "Disparando deploy..."
deploy_json="$(api -X POST "https://api.render.com/v1/services/${SERVICE_ID}/deploys" \
    -d '{"clearCache":"do_not_clear"}')"
deploy_id="$(echo "${deploy_json}" | python3 -c "import sys,json; d=json.load(sys.stdin); print(d.get('id') or d.get('message',''))" 2>/dev/null || echo "")"

if [ -z "${deploy_id}" ]; then
    log_error "deploy não disparado: $(echo "${deploy_json}" | head -c 200)"
    exit 1
fi
log_ok "deploy ${deploy_id} disparado"

if [ "${WAIT}" != "true" ]; then
    exit 0
fi

# ── 4. Aguarda o deploy ──────────────────────────────────────────
log_info "Aguardando o deploy ficar live (até ~8min)..."
for i in $(seq 1 48); do
    status="$(api "https://api.render.com/v1/services/${SERVICE_ID}/deploys/${deploy_id}" \
        | python3 -c "import sys,json; print(json.load(sys.stdin).get('status','?'))" 2>/dev/null || echo "?")"
    if [ "${status}" = "live" ]; then
        log_ok "deploy live"
        break
    fi
    if [ "${status}" = "build_failed" ] || [ "${status}" = "update_failed" ] || [ "${status}" = "deactivated" ]; then
        log_error "deploy falhou (${status}) — veja os logs no dashboard"
        exit 1
    fi
    sleep 10
done

[ "${status}" = "live" ] || log_warn "deploy ainda em '${status}' — confira no dashboard"

# ── 5. Verificação das métricas ──────────────────────────────────
log_info "Verificando as métricas de rollout em ${PROD_URL}/metrics..."
metrics="$(curl -s --max-time 45 "${PROD_URL}/metrics")"

check() {
    if grep -qE "$1" <<< "${metrics}"; then
        log_ok "$2"
    else
        log_error "$2 — AUSENTE em /metrics"
    fi
}

check '^revision_adherence\{' 'revision_adherence presente (adesão por rota)'
check '^idempotency_key_missing' 'idempotency_key_missing presente'
check '^http_requests_received_total' 'métricas do prometheus-net presentes'
check '^school_retention_rate\{' 'gauges de analytics preservadas'

if grep -qE "^revision_adherence" <<< "${metrics}"; then
    echo
    log_ok "Métricas de rollout disponíveis em produção — o gate do enforcement tem dado."
    echo "    curl -s ${PROD_URL}/metrics | grep revision_adherence"
fi
