# School Management SaaS — Guia de Deploy

> **Produção (out/2026):** Vercel (front) → Render (API, Docker) → Supabase (PostgreSQL).
> Docker Compose + Cloudflare continuam documentados como alternativa self-hosted no fim deste guia.

---

## 🗺️ Topologia de produção

| Camada | Plataforma | Recurso |
|--------|------------|---------|
| Frontend | Vercel | projeto `school-management-ui` (git `brunoferreira94/school-management-ui`, branch `main`) |
| API | Render | serviço `school-management-api` → `https://school-management-api-sik5.onrender.com` |
| Banco | Supabase | projeto `SchoolManagementDb` (`cuiurrqwdugajuyaaaef`, `ca-central-1`) |
| Auth | Auth0 | domain `rare-softwares` (`us.auth0.com`) |
| Pagamentos | Asaas | sandbox/prod conforme env |

O front roteia `/api/*` direto para a API pelo rewrite do `vercel.json` (proxy same-origin), então o browser **não** executa CORS no fluxo principal. CORS fica configurado na API via `Cors__AllowedOrigins__0/1` para chamadas diretas (ex.: previews, apps nativos, integrações).

## 🔐 Variáveis de ambiente (Render)

O `.env` local (`school-management-api/.env`, gitignored) concentra os segredos.
Para enviar sem apagar o que já existe (o PUT do Render **substitui** a lista):

```bash
scripts/render-env-vars.sh                 # dry-run (mostra o que mudaria)
scripts/render-env-vars.sh --apply         # aplica em prod + staging
scripts/render-env-vars.sh --apply --service prod
```

O script faz GET → merge (as chaves do `.env` vencem) → PUT. `RENDER_API_KEY`
vem do ambiente ou de `~/workspace/secrets.env`.

> ⚠️ Trocar `Jwt__Secret` invalida sessões ativas. Trocar `Metrics__AccessToken`
> exige atualizar o `authorization` no `prometheus.yml` (mesmo valor).

## 🔩 Como funcionam os deploys

### Front (Vercel)

```bash
cd school-management-ui
git push origin main          # branch `main` → redeploy produção (vercel)
# development gera preview, não produção
```

- Configuração: `vercel.json` (rewrites) fica na raiz e é copiado pro output do build (commit `35b65dc`).
- ⚠️ Se um subdomínio Render mudar, atualizar os destinos em `vercel.json` — produção na `main`, staging na `development` — e dar push.
- **Pairing por branch**: `main` → produção (API `school-management-api-sik5`); `development` → preview apontando para a API de **staging** (`school-management-api-dev`). O preview é o cliente da janela de observação do offline-sync (`docs/runbooks/offline-sync-rollout.md`) e um preview nunca escreve em produção.

### API (Render)

- Serviço Git-connected: `push` no branch default do repo `school-management-api` dispara build/deploy.
- Trigger manual/API (necessário pós mudança de env vars via API, quando não auto-disparar):
  ```bash
  RENDER_API_KEY=... # https://dashboard.render.com/account#api-keys
  curl -X POST -H "Authorization: Bearer $RENDER_API_KEY" \
       -H 'Content-Type: application/json' \
       https://api.render.com/v1/services/srv-d82eofrbc2fs73b4jh1g/deploys \
       -d '{"clearCache":"do_not_clear"}'
  ```
- **Script pronto** (deploy + espera + verificação das métricas de rollout):
  ```bash
  # a chave é lida do ambiente ou do .env do repo (gitignored)
  echo 'RENDER_API_KEY=rnd_...' >> .env
  bash scripts/deploy-render-api.sh
  ```
  Ao final ele confere se `revision_adherence`, `idempotency_key_missing`, as séries do prometheus-net e as gauges de analytics estão em `https://school-management-api-sik5.onrender.com/metrics`.
- Últimas env vars via `PUT /v1/services/.../env-vars` (a lista completa precisa ser enviada — a **operação substitui tudo**).
- ⚠️ **Auto-deploy DESLIGADO** (2026-10-28, via API: `PATCH /v1/services/{id}` `{"autoDeploy":"no"}`) em `school-management-api` (main) e `school-management-api-dev` (development). **Push no git não constrói mais nada** — deploy é sempre manual (comando acima).
- 📌 **Diagnóstico do incidente 10/27–28 (corrigido em 10/28):** **não houve fatura nem cobrança** — spend limit do pipeline já está em `US$ 0` (dashboard-only, Billing → Build Pipeline) e a conta nunca gerou invoice. A série de `update_failed` (17 dos últimos 20 deploys até 10/27) coincide com o incidente clássico documentado abaixo (Supabase pausado → API crash-loop → deploy falha) e/ou estado temporário dos limites de uso. Em 10/28 04:00 o deploy da `development` subiu `live` com o código completo (AiDrafts/trust/export). Staging **Healthy** (health 200, DB conectado 53ms, Supabase Dev `ACTIVE_HEALTHY`).
- **Limites de gasto (pós-incidente):**
  - Spend limit do build pipeline é **dashboard-only**: Workspace Settings → **Build Pipeline** → **Set spend limit** → `0`. Com limite 0, os builds param ao esgotar os minutes do mês (sem compra automática). Endereço: https://dashboard.render.com/billing
  - Bandwidth incluso: **5 GB/mês** — estouro cobra $0.15/GB se houver cartão no cadastro; **não há spend limit para bandwidth** (só alertas por e-mail). Tráfego API→Supabase conta como outbound.
  - Itens de fatura não aparecem em API/MCP — **Billing → Invoices** no dashboard é o lugar-of-verdade do que foi cobrado.
- **Deploys manuais comem minutes**: cada build Docker da API ≈ 10–20 min sem cache (`no-cache`) — prefira poucos deploys grandes a vários pequenos. Reativar auto-deploy só se a fábrica de builds for paga consciente (Plano pago / spend limit maior).
- **Variáveis** (atuação cloud): `ASPNETCORE_ENVIRONMENT=Production`, `ConnectionStrings__DefaultConnection` (Supabase pooler), `Jwt__*`, `Auth0__*`(+Management), `Asaas__*`, `Cors__AllowedOrigins__0/1`.

### Banco (Supabase)

- Free tier **pausa** o banco pós ~7 dias sem queries — a API **causa crash-loop (`SIGSEGV/exit 139`) na inicialização** quando o banco está inacessível. Não assustar: restaurar o projeto no dashboard (`Restore`) ou via API:
  ```bash
  SUPABASE_ACCESS_TOKEN=...
  curl -X POST -H "Authorization: Bearer $SUPABASE_ACCESS_TOKEN" \
       https://api.supabase.com/v1/projects/cuiurrqwdugajuyaaaef/restore
  ```

## 🏥 Health & Monitoramento

| Endpoint | Uso |
|----------|-----|
| `/api/support/health` | saúde completa — 200/503 + checks (DB/memória/disco/thread) |
| `/api/support/ready`, `/api/support/live` | k8s/readiness/liveness |
| `/metrics` | Prometheus |

- **Keep-alive:** `.github/workflows/keep-alive.yml` — cron por hora no `main` do repo raiz (custo zero: repo público). Ele acorda o Render e mantém o Supabase ativo; falha depois de 3 pings → a notificação do GitHub chega por e-mail.
- Prometheus (docker): **duas cópias idênticas** de `observability/` — a que roda é `school-management-api/observability/` (montada pelo `docker-compose.yml` da API; jobs locais + `school-management-prod` + `school-management-staging`, ambos com label `environment`); `monitoring-package-api/observability/` é o espelho, p/ subir como stack isolado (as duas usam a porta 9090 — só uma por vez). Após alterar arquivos: `curl -X POST http://127.0.0.1:9090/-/reload`.
- **Métricas da aplicação:** o `GET /metrics` da API serve as três fontes no mesmo scrape — as gauges de analytics (`school_*`), as métricas do `Meter "SchoolManagement"` (adesão de revisão `revision_adherence`, idempotência `idempotency_key_*`, billing, ano letivo) e o registro do prometheus-net (HTTP do processo). Em produção **não há collector OTLP** — o Prometheus local lê esse endpoint (job `school-management-prod`); o pipeline OTLP (`:4317` → `:8889`) é do stack self-hosted. Convenção de nomes: ponto → underscore, **sem** sufixo `_total` (ex.: `revision.adherence` → `revision_adherence`).
  - Smoke test dos dois caminhos: `bash school-management-api/observability/test-offline-sync-metrics.sh`
  - Regras de alerta do rollout: `prometheus-offline-sync-alerts.yml` (nas **duas** pastas — 6 regras, todas filtrando `environment=production|staging`); recarregue com `curl -X POST http://127.0.0.1:9090/-/reload` ou `docker compose restart prometheus` no diretório da API

## 🚦 Incidentes comuns

| Sintoma | Causa | Resolução |
|---------|-------|-----------|
| `x-render-routing: no-server` no `*.onrender.com` | URL de serviço removida/renomeada | conferir slug do serviço no dashboard; atualizar `vercel.json` se necessário |
| Render `server_failed` (`nonZeroExit: 139`) repetidos | banco Supabase pausado | Restaurar projeto no Supabase + redeploy |
| Front 404 sem ACAO/SSO | deployment "congelado" sem file tree | resetar deploy novo (commit vazio ou redeploy na UI) |
| `BLOCKED (COMMIT_AUTHOR_REQUIRED)` | commit author não vinculado à conta Vercel | commit com o e-mail da conta (`brunolpcdz@hotmail.com`) |

## 💾 Backup

**Local (docker compose)** — script versionado, com timestamp e compressão:

```bash
scripts/backup-db.sh                 # gera backups/SchoolManagementDb-<UTC>.sql.gz
TARGET=SchoolManagementDb_RestoreTest scripts/restore-db.sh backups/<dump>.sql.gz
```

> `backups/` está no `.gitignore` (dump contém dados pessoais).

**Produção (Supabase)** — o dump manual continua válido, mas **não é automático**:

```bash
supabase db dump --project-id cuiurrqwdugajuyaaaef -f backup.sql
# pg_dump direto também funciona com a connection string do pooler
```

> ⚠️ Pendência de infra: ativar backups gerenciados (Supabase Pro) ou agendar
> `pg_dump` diário com retenção de 30 dias.

### Restore testado (25/11)

```bash
# 1) Dump (o pg_dump local é 16; o Supabase é 17 — use um container 17)
URI="postgresql://postgres.<ref>:<senha>@aws-0-<regiao>.pooler.supabase.com:5432/postgres?sslmode=require"
docker run --rm -i postgres:17 pg_dump "$URI" | gzip > backups/prod-$(date -u +%Y%m%dT%H%M%SZ).sql.gz

# 2) Restore em Postgres descartável
docker run -d --name restore-test -e POSTGRES_PASSWORD=postgres postgres:17
docker exec restore-test psql -U postgres -c 'CREATE DATABASE restore'
gunzip -c backups/prod-<dump>.sql.gz | docker exec -i restore-test psql -U postgres -d restore

# 3) Verificar contagens (devem bater com a origem)
docker exec restore-test psql -U postgres -d restore -t -A -c \
  "SELECT (SELECT count(*) FROM \"Tenants\"), (SELECT count(*) FROM \"Achievements\"), (SELECT count(*) FROM \"Permissions\");"

# 4) Remover
docker rm -f restore-test
```

> Em Postgres puro (fora do Supabase) os erros `role "supabase_admin"/"pgbouncer" does not exist`
> e `extension "supabase_vault" is not available` são esperados — não afetam dados/tabelas.
> Em um restore real para o Supabase, roles/extensões já existem.

---

## 🐳 Alternativo: self-hosted com Docker Compose

> `docker-compose.prod.yaml` (guiado no CI) é o compose atual. O antigo `docker-compose.prod.yml` foi **removido** em 2026-10 (divergia de envs/typos: `STRIPE_WEBHOOk_SECRET`, DB e portas).

```bash
cp .env.example .env # preencher com dotnet user-secrets (docs are GITHUB_ACTIONS_SECRETS)
docker compose -f docker-compose.prod.yaml build
docker compose -f docker-compose.prod.yaml up -d
docker compose -f docker-compose.prod.yaml exec api dotnet ef database update
```

Cloudflare Tunnel (opcional, para expor sem porta pública):

```bash
cloudflared tunnel login
cloudflared tunnel create school-management
cloudflared tunnel route dns school-management app.suadominio.com
cloudflared tunnel run school-management
```

Monitoramento local (docker): Grafana http://localhost:3000 · Prometheus http://localhost:9090
