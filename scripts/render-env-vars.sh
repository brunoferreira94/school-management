#!/usr/bin/env bash
# Injeta/atualiza variáveis de ambiente do Render (API) sem apagar as existentes.
#
# Uso:
#   scripts/render-env-vars.sh                 # dry-run: mostra o que mudaria
#   scripts/render-env-vars.sh --apply         # aplica (prod + staging)
#   scripts/render-env-vars.sh --apply --service prod
#
# Variáveis:
#   RENDER_API_KEY   (ou lido de /home/bruno/workspace/secrets.env)
#   ENV_FILE         (default: school-management-api/.env, gitignored)
#
# O PUT /env-vars do Render SUBSTITUI a lista inteira — por isso o script faz
# GET, mescla (as chaves do .env vencem) e só então envia.
set -euo pipefail

MODE="dry-run"
SERVICE_FILTER="both"

while [[ $# -gt 0 ]]; do
  case "$1" in
    --apply) MODE="apply" ;;
    --service) SERVICE_FILTER="${2:?--service exige prod|staging|both}"; shift ;;
    -h|--help) sed -n '2,14p' "$0"; exit 0 ;;
    *) echo "argumento desconhecido: $1" >&2; exit 2 ;;
  esac
  shift
done

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
ENV_FILE="${ENV_FILE:-$ROOT/school-management-api/.env}"

API_KEY="${RENDER_API_KEY:-}"
if [[ -z "$API_KEY" && -f /home/bruno/workspace/secrets.env ]]; then
  API_KEY="$(grep -oP '(?<=^RENDER_API_KEY=).*' /home/bruno/workspace/secrets.env | head -1)"
fi
[[ -n "$API_KEY" ]] || { echo "RENDER_API_KEY ausente (env ou ~/workspace/secrets.env)" >&2; exit 2; }
[[ -f "$ENV_FILE" ]] || { echo "arquivo de env ausente: $ENV_FILE" >&2; exit 2; }

SERVICES=()
[[ "$SERVICE_FILTER" == "both" || "$SERVICE_FILTER" == "prod" ]] && SERVICES+=("srv-d82eofrbc2fs73b4jh1g:prod")
[[ "$SERVICE_FILTER" == "both" || "$SERVICE_FILTER" == "staging" ]] && SERVICES+=("srv-d9r4shvqj5pc73ap72k0:staging")
[[ ${#SERVICES[@]} -gt 0 ]] || { echo "--service inválido (use prod|staging|both)" >&2; exit 2; }

echo "modo: $MODE | arquivo: $ENV_FILE"
echo

for entry in "${SERVICES[@]}"; do
  SERVICE_ID="${entry%%:*}"
  SERVICE_NAME="${entry##*:}"

  python3 - "$API_KEY" "$SERVICE_ID" "$SERVICE_NAME" "$ENV_FILE" "$MODE" <<'PY'
import json
import sys
import urllib.request
import urllib.error

api_key, service_id, name, env_file, mode = sys.argv[1:6]
BASE = "https://api.render.com/v1"

def req(method, path, payload=None):
    data = json.dumps(payload).encode() if payload is not None else None
    r = urllib.request.Request(BASE + path, data=data, method=method)
    r.add_header("Authorization", f"Bearer {api_key}")
    r.add_header("Content-Type", "application/json")
    try:
        with urllib.request.urlopen(r, timeout=30) as resp:
            body = resp.read().decode()
            return json.loads(body) if body else None
    except urllib.error.HTTPError as e:
        raise SystemExit(f"  erro HTTP {e.code} em {method} {path}: {e.read().decode()[:300]}")

# 1) .env atual (só linhas KEY=VALUE)
new_vars = {}
with open(env_file, encoding="utf-8") as fh:
    for line in fh:
        line = line.strip()
        if not line or line.startswith("#") or "=" not in line:
            continue
        key, value = line.split("=", 1)
        new_vars[key.strip()] = value

# 2) variáveis atuais no Render (a API devolve uma LISTA de {key,value})
existing = {}
page = req("GET", f"/services/{service_id}/env-vars?limit=100") or []
items = page.get("envVars", []) if isinstance(page, dict) else page
for ev in items:
    if isinstance(ev, dict) and "envVar" in ev:
        ev = ev["envVar"]
    if isinstance(ev, dict) and ev.get("key"):
        existing[ev["key"]] = ev.get("value", "")

merged = dict(existing)
merged.update(new_vars)

changed = sorted(k for k in new_vars if existing.get(k) != new_vars[k])
print(f"== {name} ({service_id})")
print(f"   existentes: {len(existing)} | no .env: {len(new_vars)} | alteradas: {len(changed)}")
for key in changed:
    print(f"   ~ {key} (valor mascarado)")
if not changed:
    print("   nada a fazer")
    sys.exit(0)
if mode != "apply":
    print("   (dry-run — use --apply para enviar)")
    sys.exit(0)

payload = {"envVars": [{"key": k, "value": v} for k, v in merged.items()]}
req("PUT", f"/services/{service_id}/env-vars", payload)
print(f"   ✓ aplicado ({len(payload['envVars'])} variáveis)")
PY
done

echo
echo "concluído. Reinicie o serviço no Render para aplicar (ou aguarde o próximo deploy)."