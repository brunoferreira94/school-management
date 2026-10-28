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

## 🔩 Como funcionam os deploys

### Front (Vercel)

```bash
cd school-management-ui
git push origin main          # branch `main` → redeploy produção (vercel)
# development gera preview, não produção
```

- Configuração: `vercel.json` (rewrites) fica na raiz e é copiado pro output do build (commit `35b65dc`).
- ⚠️ Se o subdomínio Render mudar, atualizar `vercel.json:5` e dar push.

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
- Últimas env vars via `PUT /v1/services/.../env-vars` (a lista completa precisa ser enviada — a **operação substitui tudo**).
- ⚠️ **Auto-deploy DESLIGADO** (2026-10-28, via API: `PATCH /v1/services/{id}` `{"autoDeploy":"no"}`) em `school-management-api` (main) e `school-management-api-dev` (development). Motivo: 27 builds Docker automáticos em 8 dias (10/21–28) furaram os minutes inclusos do plano Hobby e geraram fatura de overage → 402. **Push no git não constrói mais nada** — deploy é sempre manual (comando acima).
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
- Prometheus local: `monitoring-package-api/observability/` (docker) — o `prometheus.yml` também scrapeia a API cloud.

## 🚦 Incidentes comuns

| Sintoma | Causa | Resolução |
|---------|-------|-----------|
| `x-render-routing: no-server` no `*.onrender.com` | URL de serviço removida/renomeada | conferir slug do serviço no dashboard; atualizar `vercel.json` se necessário |
| Render `server_failed` (`nonZeroExit: 139`) repetidos | banco Supabase pausado | Restaurar projeto no Supabase + redeploy |
| Front 404 sem ACAO/SSO | deployment "congelado" sem file tree | resetar deploy novo (commit vazio ou redeploy na UI) |
| `BLOCKED (COMMIT_AUTHOR_REQUIRED)` | commit author não vinculado à conta Vercel | commit com o e-mail da conta (`brunolpcdz@hotmail.com`) |

## 💾 Backup

```bash
# Supabase (via CLI ou dashboard) — banco produção
supabase db dump --project-id cuiurrqwdugajuyaaaef -f backup.sql
# pg_dump direto também funciona com a connection string do pooler
```

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
