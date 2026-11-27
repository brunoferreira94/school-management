# Runbook: Ativação da Sincronização Offline

> **Estado atual (2026-11-16)**: contrato POC + hardening implementados —
> sync-batch (F2), X-Server-Time (F3), ETag/revisão via Redis (F1), métricas
> `offline_sync_*` **e** métricas de adesão (`idempotency_key.missing/provided`,
> `revision.missing`). Flags `OfflineSync__Idempotency__RequireKey` /
> `OfflineSync__Revision__Enforce` são lidas pela API (default false — clientes
> sem headers nunca são rejeitados). Fluxo do rollout: medir adesão com flags
> desligadas → ligar → observação 24h → produção.

## Pré-requisitos

- API rodando com `OfflineSync__Idempotency__RequireKey = false` (default)
- API rodando com `OfflineSync__Revision__Enforce = false` (default)
- Todas as migrations aplicadas
- Métricas Prometheus sendo coletadas
- Alertas configurados:
  - `offline_sync_conflicts_rate > 1%` por 5min
  - `offline_sync_errors_5xx > 1%` por 5min

## Ativação em Staging

### Passo 1: Preparar o ambiente

```bash
# Verificar status atual
curl -s http://staging-api:5067/api/support/health | jq '.version'
```

### Passo 2: Ativar as flags

Via variáveis de ambiente no Render/Helm:

```
OfflineSync__Idempotency__RequireKey=true
OfflineSync__Revision__Enforce=true
```

> **Importante — escopo do `Enforce`**: sem `EnforcedPaths`, o `Enforce=true` é
> **global**: toda mutação em escopo sem `If-Match` recebe 428 — inclusive
> criações (`POST`) e upserts de collection, que não têm ETag a enviar. Só
> ligue o enforcement global depois que **todos** os clientes enviarem
> `If-Match` nas mutações que o exigem.
>
> **Rollout incremental (recomendado)**: restrinja o enforcement aos paths
> onde o cliente já envia `If-Match`:
>
> ```
> OfflineSync__Revision__Enforce=true
> OfflineSync__Revision__EnforcedPaths__0=PUT /api/grades/{id}
> OfflineSync__Revision__EnforcedPaths__1=PUT /api/grading-formulas/{id}
> ```
>
> (em `appsettings.json`: `"OfflineSync": { "Revision": { "EnforcedPaths": [...] } }`).
> A UI atual (notas e fórmulas) fica integralmente coberta por esses dois
> padrões: todo `PUT` de recurso com id envia `If-Match`; criação, ativação e
> upserts de collection não são bloqueados.

### Passo 3: Reiniciar os containers

```bash
# Render
curl -X POST "https://api.render.com/v1/services/srv-xxx/redeploy" \
  -H "Authorization: Bearer $RENDER_API_KEY"

# Ou via CLI
render deploy --service school-management-api --clear-cache
```

### Passo 4: Janela de observação (24h)

Monitorar dashboards:

- **Taxa de sucesso**: `sum(increase(offline_sync_success[5m])) / sum(increase(offline_sync_total[5m]))`
- **Taxa de conflitos**: `sum(increase(offline_sync_conflicts[5m])) / sum(increase(offline_sync_total[5m]))`
- **Erros 5xx**: `sum(rate(http_requests_total{status=~"5.."}[5m])) / sum(rate(http_requests_total[5m]))`

Critérios de sucesso:
- `missing_key < 1%` — razão medida **só em `source="batch"`** (sync-batch: é
  a superfície em que o `RequireKey` enforça; tag `source="http"|"batch"`
  adicionada em 2026-11-19). O HTTP individual é opt-in (a UI online não
  envia chave por design) e ficou **fora** do gate — somá-lo lerria ~100%
  missing eterno. **Sem série `source="batch"` o gate é indescisível** (não
  é falha): o smoke test (tasks 5.3) gera o tráfego que o torna decisível.
- `revision_missing < 1%`: `revision_missing / offline_sync_total` (já é
  só-batch: apenas o guard do sync-batch o incrementa)
- Nenhum spike de 5xx

```promql
# Gate missing_key (tasks 5.1/5.4) — só sync-batch (source="batch")
sum(rate(idempotency_key_missing{environment="staging", source="batch"}[1h]))
  / (sum(rate(idempotency_key_missing{environment="staging", source="batch"}[1h]))
     + sum(rate(idempotency_key_provided{environment="staging", source="batch"}[1h])))

# Adesão no caminho HTTP — INFORMATIVA, não é gate (opt-in por design)
sum(rate(idempotency_key_missing{environment="staging", source="http"}[1h]))
  / (sum(rate(idempotency_key_missing{environment="staging", source="http"}[1h]))
     + sum(rate(idempotency_key_provided{environment="staging", source="http"}[1h])))
```

> **Onde as métricas estão** — as métricas do `Meter "SchoolManagement"` (F4 +
> adesão) são exportadas por **dois caminhos**, com a **mesma nomenclatura**:
>
> ```text
> [produção]  API → GET /metrics → Prometheus (job "school-management-prod")
>             (a API no Render não tem collector OTLP — o Prometheus local
>              scrapeia /metrics direto)
>
> [staging]   mesma ponte, job "school-management-staging" (branch development)
>             — é AQUI que a janela de ≥7 dias é contada; o scrape de 60s
>             mantém a instância free-tier acordada (dormindo não há mutação
>             para medir)
>
> [stack local] API → OTLP (OTEL_EXPORTER_OTLP_ENDPOINT) → otel-collector (:4317)
>              → exporter prometheus (:8889) → Prometheus (job "otel-collector")
> ```
>
> O endpoint `/metrics` da API serve as três fontes no mesmo scrape: as gauges
> de analytics (`school_*`), as métricas do Meter (adesão, idempotência, billing,
> ano letivo — via `SchoolManagementMetricsCollector`) e o registro do
> prometheus-net (métricas HTTP do processo). Sem essa ponte, **produção não
> receberia nenhuma métrica de adesão** — o rollout ficaria sem dado.
>
> **Nomes**: o ponto vira underscore **sem** sufixo `_total` (convenção do
> exporter do otel-collector, collector 0.83.0): `revision.adherence` →
> `revision_adherence`, `idempotency_key.missing` → `idempotency_key_missing`,
> `offline_sync.total` → `offline_sync_total`. O `_total` existe só nas métricas
> do prometheus-net (`http_requests_received_total`).
>
> > ⚠️ `OTEL_EXPORTER_OTLP_ENDPOINT` **não é necessário em produção** (e não há
> > collector lá). Ele só importa no stack self-hosted. Os alertas
> > `OfflineSyncRevisionMetricAbsent` (produção) e
> > `OfflineSyncRevisionMetricAbsentStaging` (staging) disparam se a série não
> > aparecer — `absent()` é avaliado **por ambiente** (label `environment`), senão
> > a presença num job mascararia a ausência no outro.
>
> Smoke test dos dois caminhos:
>
> ```bash
> bash school-management-api/observability/test-offline-sync-metrics.sh
> ```

**Antes do Passo 2**: deixar as flags desligadas por ≥ 7 dias em staging e
confirmar adesão < 1% (não ligar flags sem adesão medida). A medição é do job
`school-management-staging` (`environment="staging"`): enquanto o alvo estiver
`up` sem a série, `OfflineSyncRevisionMetricAbsentStaging` sinaliza que os dias
**não** estão contando.

### Cliente de staging (por onde os dias são contados)

O `revision_adherence` do staging só aparece quando **um cliente real** faz
mutação naquela API — e nenhum front apontava para o staging. Há dois caminhos
prontos (pairing `development` ↔ `development`; produção continua na `main`):

```bash
# (a) Local — proxy same-origin p/ a API de staging. O proxy é obrigatório:
#     o CORS do staging (AllowedHeaders) não lista If-Match/Idempotency-Key e
#     bloquearia o preflight de uma chamada cross-origin.
cd school-management-ui && npm run start:staging   # ng serve em 127.0.0.1:4200

# (b) Preview no Vercel — push em `development` gera preview cujo vercel.json
#     roteia /api e /metrics para o staging. A URL muda a cada push; pegue a
#     atual em Vercel → school-management-ui → Deployments (ex. de hoje:
#     https://school-management-a6603y37o-brunoferreira94s-projects.vercel.app)
```

Conferindo que o caminho serve o staging — `process_start_time_seconds` é o
fingerprint do processo (a produção tem outro valor; troque o host para
comparar):

```bash
curl -s https://school-management-a6603y37o-brunoferreira94s-projects.vercel.app/metrics \
  | grep process_start_time_seconds
curl -s https://school-management-api-dev.onrender.com/metrics \
  | grep process_start_time_seconds   # ← tem que ser igual ao do preview
```

> **Login**: mesmo Auth0 (`rare-softwares`); `localhost:4200` já é origem
> permitida no fluxo dev. Se o **preview** recusar o callback, adicione o
> domínio em Auth0 → Applications → Allowed Callback URLs.
>
> **Dia 0 da janela**: a primeira mutação autenticada cria a série
> `revision_adherence{environment="staging"}` e resolve
> `OfflineSyncRevisionMetricAbsentStaging`. Enquanto ninguém usar um dos
> clientes, o alerta (severity **info**) continua sinalizando que os dias
> **não** estão contando — é ele o relógio da janela.
>
> **Registro**: dia 0 = **2026-11-19** (preview `a7ec70a` + API `c632ad5`,
> editor de fórmulas). Os contadores são em memória: um reinício da instância
> zera a série e o alerta volta a `firing` **sem** que a janela tenha parado —
> conte os dias a partir do registro acima, não pelo estado do alerta; uma
> nova mutação reacende a série.

### Adesão por rota (decidir resource a resource)

O `revision_adherence` mede, **por rota normalizada**, se o cliente enviou
`If-Match` (`state="provided"`, `state="wildcard"` ou `state="missing"`):

```promql
# O gate é POR AMBIENTE (label `environment` do job de scrape): sem ele o rate
# soma o stack local (api:5000 / otel-collector) ao de produção/staging.
# Troque environment="staging" por "production" ao julgar produção.

# Taxa de adesão por rota (o que interessa para ligar o enforcement)
sum by (route) (rate(revision_adherence{state="provided", environment="staging"}[1h]))
  / sum by (route) (rate(revision_adherence{environment="staging"}[1h]))

# Rotas que ainda não aderem (candidatas a NÃO entrar no enforcement)
sum by (route) (rate(revision_adherence{state="missing", environment="staging"}[1h])) > 0
```

Fluxo recomendado:

1. Espere ≥ 7 dias com as flags desligadas.
2. Consulte a adesão **por rota** — só ligue o enforcement nas rotas com
   `provided` ≥ 99% (e `wildcard` ≈ 0: wildcard não protege a atualização).
3. Ligue `Enforce=true` **com `EnforcedPaths` restrito a essas rotas**.
4. Acompanhe `revision_conflict` (412) e os 428 por rota durante a janela.

> A métrica tem cardinalidade limitada (50 rotas + bucket `__other__`) — se
> aparecer `__other__`, há paths arbitrários no tráfego (cliente estranho).

> Alertas prontos em `school-management-api/observability/prometheus-offline-sync-alerts.yml`:
> `OfflineSyncRevisionMetricAbsent` (métrica ausente = pipeline quebrado),
> `OfflineSyncLowRevisionAdherence` (adesão < 99% por rota),
> `OfflineSyncHighMissingIdempotencyKey` (> 1%),
> `OfflineSyncHighRevisionConflictRate` (> 5% de 412) e
> `OfflineSyncBatchConflictRateHigh` (> 1% de conflitos no sync-batch).

## Checkpoint de ativação — 26/11 (Bloco 5, tasks 5.1–5.5)

> **Quando rodar**: 2026-11-26 (7 dias completos desde o dia 0 = 2026-11-19).
> É um runbook mecânico: rode as queries, siga a árvore de decisão, aplique as
> flags no **staging** (a produção só recebe depois da aprovação 5.5). Tudo
> abaixo assume o Prometheus local (jobs `school-management-staging` /
> `school-management-prod`, label `environment`).

### 1. Pré-verificação (staging) — todos têm de passar

```bash
# 1) Gate missing_key (batch) < 1%
curl -s "http://127.0.0.1:9090/api/v1/query" --data-urlencode 'query=sum(rate(idempotency_key_missing{environment="staging", source="batch"}[1h])) / (sum(rate(idempotency_key_missing{environment="staging", source="batch"}[1h])) + sum(rate(idempotency_key_provided{environment="staging", source="batch"}[1h])))'

# 2) revision_missing < 1% (batch)
curl -s "http://127.0.0.1:9090/api/v1/query" --data-urlencode 'query=sum(rate(revision_missing{environment="staging"}[1h])) / sum(rate(offline_sync_total{environment="staging"}[1h]))'

# 3) Adesão por rota — provided ≥ 99% e wildcard ≈ 0
curl -s "http://127.0.0.1:9090/api/v1/query" --data-urlencode 'query=sum by (route) (rate(revision_adherence{state="provided", environment="staging"}[1h])) / sum by (route) (rate(revision_adherence{environment="staging"}[1h]))'

# 4) Alertas sustained (devem estar todos inactive/pending, nunca firing)
curl -s "http://127.0.0.1:9090/api/v1/query" --data-urlencode 'query=ALERTS{alertstate="firing", environment="staging"}'
```

| Verificação | Passa se | Se falhar |
|---|---|---|
| `missing_key` (batch) | < 1% | **Não ligar `RequireKey`** — achar o cliente batch sem chave (grep nos logs do guard) |
| `revision_missing` | < 1% | Não ligar `Enforce` — UPDATE/DELETE sem ETag no batch |
| `revision_adherence` por rota | `provided ≥ 99%`, `wildcard ≈ 0` | `EnforcedPaths` só nas rotas aprovadas (nunca global) |
| Alertas staging | nenhum `firing` sustentado | investigar antes |

> A série `idempotency_key_missing{source="batch"}` **ausente** = 0 missing
> (passa). Se `provided{batch}` não cresce, o soak (5.3) morreu — reinicie
> antes de decidir qualquer coisa.

### 2. Árvore de decisão

```text
missing_key < 1%  ──não──▶ NÃO ligar RequireKey (investigar cliente)
        │sim
revision_missing < 1% ──não──▶ NÃO ligar Enforce
        │sim
aderência por rota ≥ 99% ──▶ EnforcedPaths = [rotas aprovadas]
        │                        (nunca lista vazia/global no 1º dia)
nenhum alerta sustained ──▶ prosseguir para 3
```

### 3. Aplicar no staging (Render)

Variáveis (service `school-management-api-dev`, `srv-d9r4shvqj5pc73ap72k0`):

| Variável | Valor |
|---|---|
| `OfflineSync__Idempotency__RequireKey` | `true` (escopo: sync-batch, onde o guard enforça) |
| `OfflineSync__Revision__Enforce` | `true` |
| `OfflineSync__Revision__EnforcedPaths__0` | `PUT /api/grading-formulas/{id}` (exemplo — só rotas com `provided ≥ 99%`; repita `__1`, `__2`… para as demais) |

```bash
# API Render (alternativa ao dashboard): variável + deploy manual
#   POST /v1/services/srv-d9r4shvqj5pc73ap72k0/env-vars  {"name":"...","value":"..."}
#   POST /v1/services/srv-d9r4shvqj5pc73ap72k0/deploys   (autoDeploy: no)
# Dashboard: Environment → adicionar → Manual Deploy (clear cache "do_not_clear")
```

> `EnforcedPaths` é lista de padrões `"MÉTODO /path/{id}"` (`{id}` = 1
> segmento). Lista vazia = enforcement global — **não** usar no 1º dia.

### 4. Verificação pós-ligação (24h, staging)

- `idempotency_key_missing{source="batch"}` continua **0** (RequireKey ligado + clientes compliant)
- `offline_sync_conflicts / offline_sync_total` < 1%
- `revision_conflict` (412) ~0 nas rotas do `EnforcedPaths`; 428 por rota = clientes que não enviavam `If-Match` (esperado nas rotas recém-incluídas — acompanhar, não é erro)
- 5.2: janela 24h; 5.4: monitoramento; 5.3: soak ≥24h (log diário)

#### Resultado da execução — 26/11 (staging)

| Verificação | Resultado |
|---|---|
| Gate 1 — `missing_key` (batch) | **0%** (série `missing{source="batch"}` ausente; `provided` crescendo) |
| Gate 2 — `revision_missing` | **0%** (série ausente; `offline_sync_total` = `offline_sync_success`) |
| Gate 3 — adesão por rota | `PUT /api/grading-formulas/{id}` = **100% `provided`** (UI real em browser: `If-Match: "0-1.0.0-…"` → 200) |
| Gate 4 — alertas | nenhum `firing` |
| Pós-ligação | lote sem chave → **400**; lote com chave → 200 `applied`; PUT sem `If-Match` na rota aprovada → **428** `revision-required`; PUT com `If-Match` → 200 + ETag novo; POST (fora da rota) → 200 |

Flags ativas no staging (`srv-d9r4shvqj5pc73ap72k0`, deploy
`dep-dc3s4it9el5s739fq2kg` live em 26/11 05:24 UTC):

```
OfflineSync__Idempotency__RequireKey=true
OfflineSync__Revision__Enforce=true
OfflineSync__Revision__EnforcedPaths__0=PUT /api/grading-formulas/{id}
```

Base dos contadores cumulativos no momento da ligação (medir **delta** a
partir daqui — as sondas do próprio gate entram como `missing`):
`idempotency_key_missing{batch}=1` · `revision_adherence{PUT /api/grading-formulas/{id}} missing=3` /
`provided=2` · `offline_sync_total=0` (reset do deploy).

**Fechamento da janela (24h)** — quando a janela fechar (27/11 ~05:30 UTC):

```bash
# 1) delta da janela contra a base gravada no início
scripts/check-offline-sync-gate.py --env staging \
  --baseline docs/runbooks/offline-sync-gate-base-2026-11-26.json

# 2) leitura absoluta da janela (com as sondas do gate já dentro)
scripts/check-offline-sync-gate.py --env staging --window 24h
```

O modo `--baseline` julga os **deltas** desde a base — é ele que isola as
sondas do próprio gate (400/428, gravadas como `missing`). A base está
versionada em `docs/runbooks/offline-sync-gate-base-2026-11-26.json`
(2023 lotes batch, 20021/20021 applied, 0 conflitos, 0 alertas).

> **Executado em 27/11 07:13 UTC**: janela fechada limpa — Δmissing=0, Δrevision=0,
> Δconflitos=0 em 33.570 ops, 100% de adesão, 0 alertas. Veredito em
> `docs/runbooks/offline-sync-gate-closure-2026-11-27.md`. Em seguida foi ativado o
> `Entitlement:Enforce` no staging (deploy `dep-dc4irc61egvs738jggjg`), que **zerou os
> contadores**: a nova base é `docs/runbooks/offline-sync-gate-base-2026-11-27.json` e
> a janela de ≥7 dias recomeça a partir desse deploy.

**Regras de conducto durante a janela**: **não deployar no staging** (o deploy
zera os contadores em memória e a janela recomeça) e manter a máquina com
Prometheus + soak no ar (o `soak` tem supervisor: `scripts/run-offline-sync-soak.sh`).

**Pegadinhas da execução (26/11)** — valem para os próximos deploys:1. **Render: `PUT /env-vars` SUBSTITUI o conjunto e o `GET` pagina em 20.**
   Listar sem `?limit=100` devolve só as 20 mais recentes: enviar esse recorte
   no `PUT` **apaga** a 21ª variável (no caso, `Metrics__AccessToken` → o
   scrape do Prometheus cai e o gate fica sem dado). Sempre: `GET
   .../env-vars?limit=100` → mesclar → `PUT` com **todas** as variáveis.
   E: a API **não** tem POST em `/env-vars` (405) — é `PUT` com
   `[{"key":…,"value":…}]`.
2. **`EnforcedPaths` casa o path interno, não o cru.** O
   `ApiVersioningMiddleware` remove `/api/v1` **antes** do
   `OptimisticRevisionMiddleware`, então `PUT /api/grading-formulas/{id}`
   cobre o cliente canônico (`/api/v1/...`) e o alias (`/api/...`) — e é
   também o label da métrica `revision_adherence`.
3. **Cliente de staging**: o `vercel.json` do branch `development` aponta
   `/api` para **produção** (o merge do Termo v2026.2 restaurou o de
   produção) — para medir em staging use o cliente local
   (`npm run start:staging`, proxy same-origin) ou um preview com
   `vercel.json` de staging.
4. **Soak**: precisa do token do `/metrics` (protegido fora de Development) —
   `SMOKE_METRICS_TOKEN` ou `observability/metrics_token` (gitignored). O
   harness também tinha um bug de padding do JWT que o fazia trafegar no
   tenant default (corrigido em 26/11).

### 5. Rollback

Qualquer regressão: `OfflineSync__Idempotency__RequireKey=false` +
`OfflineSync__Revision__Enforce=false` + redeploy (mesmo fluxo). O 412/428
some imediatamente; filas offline pendentes seguem válidas (a chave é
liberada em 4xx/5xx).

### 6. Produção (após 5.5)

Repetir 3–4 no service de produção (`srv-d82eofrbc2fs73b4jh1g`) **só depois**
da aprovação do fundador (5.5). Produção ainda não tem cliente real com
If-Match (a UI só passou a enviar em 4.6/M2 nas telas de nota/fórmula) —
a decisão por rota sai do mesmo dado (`environment="production"`).

## Smoke Test

### Cenário 1: Sincronização bem-sucedida

```bash
# Simular cliente mobile
UUID=$(uuidgen)
TIMESTAMP=$(date -u +%s)
HMAC=$(echo -n "sub001POST/api/students$TENANT$TIMESTAMP" | sha256sum | cut -d' ' -f1)

curl -X POST "https://staging-api:5067/api/students" \
  -H "Idempotency-Key: ${UUID}_${HMAC}" \
  -H "Content-Type: application/json" \
  -H "X-Server-Time: ${TIMESTAMP}" \
  -d '{"cpf":"12345678901","name":"Teste Offline"}'

# Segunda chamada com mesma chave → 422
curl -X POST "https://staging-api:5067/api/students" \
  -H "Idempotency-Key: ${UUID}_${HMAC}" \
  -H "Content-Type: application/json" \
  -H "X-Server-Time: ${TIMESTAMP}" \
  -d '{"cpf":"12345678901","name":"Teste Offline"}'
# Esperado: 422 Unprocessable Entity
```

### Cenário 2: Conflito de revisão

```bash
# GET recurso → obter ETag
RESPONSE=$(curl -s "https://staging-api:5067/api/students/91000000001")
Etag=$(echo "$RESPONSE" | jq -r '."@etag"')
Revision=$(echo "$RESPONSE" | jq -r '.revision')

# Tentar update com ETag antigo
curl -X PUT "https://staging-api:5067/api/students/91000000001" \
  -H "If-Match: ${Etag}" \
  -H "Content-Type: application/json" \
  -d '{"cpf":"91000000001","name":"Nome Atualizado"}'
# Esperado: 412 Precondition Failed
```

### Cenário 3: Sync em lote

> O `POST /api/offline/sync-batch` exige `clientId` em formato **Guid** (body) e
> `idempotencyKey` no **corpo** — o guard lê o corpo, não o header (o header é
> opcional para simular cliente real).

```bash
curl -X POST "https://staging-api:5067/api/offline/sync-batch" \
  -H "Idempotency-Key: $(uuidgen)" \
  -H "Content-Type: application/json" \
  -d '{
    "tenantId": "00000000-0000-0000-0000-000000000001",
    "clientId": "device-mobile-001",
    "idempotencyKey": "$(uuidgen)",
    "operations": [
      {"entityType": "Student", "operationType": "CREATE", "payload": {"name": "New Student", "cpf": "99999999999"}},
      {"entityType": "Student", "operationType": "UPDATE", "entityId": "91000000-0000-0000-0000-000000000001",
       "etag": "4-1.0.0-a1B2c3D4", "payload": {"name": "Updated"}}
    ]
  }'

# Esperado: 200 OK com batchId, contagens e outcomes por operação:
# { "batchId": "...", "processedCount": 2, "unchangedCount": 0, "conflictCount": 0,
#   "unprocessedCount": 0,
#   "outcomes": [ {"status": "applied", "newETag": "5-1.0.0-..."}, ... ] }
# Reenvio com MESMA Idempotency-Key → 422 Unprocessable Entity
```

### Cenário 4: Soak contínuo 5×10k ops/dia (tasks 5.3)

Harness: `school-management-api/observability/smoke-offline-sync.mjs` (Node,
sem dependências). Simula 5 clientes × 10k operações/dia em lotes de 10 ops
contra `POST /api/offline/sync-batch` no staging — gera a série
`idempotency_key_*{source="batch"}` que o gate `missing_key < 1%` (§Passo 4)
lê. Desenho:

- **Só sync-batch** — o tráfego é batch-only de propósito: não toca em
  `revision_adherence` (medição de cliente real por rota), então não
  "gamela" o gate de EnforcedPaths.
- UPDATE/DELETE **sempre com ETag** do estado local → `revision_missing` 0.
- Chave nova (UUID) por lote + **replay deliberado** a cada 100 lotes
  (esperado 422 — prova de F0 sob carga).
- **Detecção de restart** via `process_start_time_seconds` (GET /metrics,
  público) antes de cada lote: reinício da API zera o estado POC do ETag
  manager → pools recriados antes de mandar ETag velho (0 conflitos
  pós-deploy; sem isso, um lote que aterrissa entre o restart e a detecção
  conflita — `currentRevision=0 ≠ N` — e encosta no limiar de 1% do
  `OfflineSyncBatchConflictRateHigh`).
- Fallback: outcome conflict/rejected derruba a entidade do pool (recria com
  id novo), nunca reenvia ETag vencido.

```bash
# Iniciar (background) — defaults: 5 clientes × 10k ops/dia, 1 lote/86,4s
NODE=$(source ~/.nvm/nvm.sh && nvm use 24 >/dev/null && which node)
nohup "$NODE" observability/smoke-offline-sync.mjs >> /tmp/smoke-offline-sync.log 2>&1 &

# Monitorar: log do processo (relatório a cada 5 min)
tail -f /tmp/smoke-offline-sync.log

# PromQL (gate §Passo 4, staging):
#   missing_key (batch):  sum(rate(idempotency_key_missing{source="batch"}[1h]))
#     / (sum(rate(idempotency_key_missing{source="batch"}[1h]))
#        + sum(rate(idempotency_key_provided{source="batch"}[1h])))   # < 1%
#   conflicts (batch):    sum(rate(offline_sync_conflicts[15m]))
#     / sum(rate(offline_sync_total[15m]))                           # < 1%
```

Parar: `kill <pid>` (SIGTERM → relatório final no log). Reiniciar após
reboot da máquina: repetir o comando de iniciar (o harness recria os pools;
estado POC antigo fica órfão, inofensivo).

## Rollback

Se os critérios de erro forem excedidos:

1. **Desativar flags**:
   ```
   OfflineSync__Idempotency__RequireKey=false
   OfflineSync__Revision__Enforce=false
   ```

   Rollback parcial (manter o resto): basta remover os padrões de
   `OfflineSync__Revision__EnforcedPaths` (ou esvaziá-los → enforcement global)
   e reiniciar — o `Enforce=false` já impede qualquer 428.

2. **Cache de idempotency**: expira naturalmente em 24h (TTL nativo do Redis e
   do serviço em memória). Não há endpoint de flush — para limpeza imediata,
   usar o console do provedor Redis (ex.: Upstash → Flush Database). Entradas
   em memória desaparecem no restart da instância.

3. **Reportar incidente**: #alert-offline-sync no Slack

## Monitoramento Contínuo

### Dashboard Prometheus

```
# Métricas implementadas (F4 + adesão) — nomes REAIS no Prometheus
# (pipeline OTLP: ponto → underscore, SEM "_total"):
offline_sync_total
offline_sync_success
offline_sync_conflicts
idempotency_key_missing    # tags: source (http | batch)
idempotency_key_provided   # tags: source (http | batch)
idempotency_key_reused
revision_missing
revision_conflict
revision_adherence          # tags: route, state

# Taxa de sucesso de sync
sum(increase(offline_sync_success[5m])) / sum(increase(offline_sync_total[5m]))

# Taxa de conflitos
sum(increase(offline_sync_conflicts[5m])) / sum(increase(offline_sync_total[5m]))

# Adesão de chave — GATE: só sync-batch (source="batch"); sem o filtro de
# ambiente o número soma o stack local
sum(rate(idempotency_key_missing{environment="staging", source="batch"}[5m]))
  / (sum(rate(idempotency_key_missing{environment="staging", source="batch"}[5m]))
     + sum(rate(idempotency_key_provided{environment="staging", source="batch"}[5m])))

# Adesão de chave no caminho HTTP — informativa (opt-in; a UI online não
# envia chave por design; NÃO é gate)
sum(rate(idempotency_key_missing{environment="staging", source="http"}[5m]))
  / (sum(rate(idempotency_key_missing{environment="staging", source="http"}[5m]))
     + sum(rate(idempotency_key_provided{environment="staging", source="http"}[5m])))

# Adesão de If-Match POR ROTA (decide o enforcement por recurso)
# filtrando por ambiente — senão o rate soma o stack local ao gate
sum by (route) (rate(revision_adherence{state="provided", environment="staging"}[1h]))
  / sum by (route) (rate(revision_adherence{environment="staging"}[1h]))
```

> `http_requests_total` (com `_total`) vem do **prometheus-net** (`/metrics` da
> API) — é outro pipeline e mantém o sufixo. Não misturar os dois.

### Alertas

| Alerta | Condição | Ação |
|--------|----------|------|
| `OfflineSyncBatchConflictRateHigh` | `offline_sync_conflicts / offline_sync_total > 1%` em 15min (por ambiente) | Notificar #alert-offline-sync |
| `OfflineSyncHighMissingIdempotencyKey` | só `source="batch"` (sync-batch — superfície em que o `RequireKey` enforça): `missing / (missing + provided) > 1%` em 30min (por ambiente); sem tráfego de batch a razão é NaN e **não dispara** (gate indescisível, não falha) | Notificar #product |
| `OfflineSyncLowRevisionAdherence` | por rota **PUT** (`route=~"PUT .*"` — POST/DELETE nunca enviam `If-Match` por contrato) + `environment=~"production\|staging"`: `provided / total < 99%` em 1h | Não ampliar o `EnforcedPaths` nessa rota até a adesão normalizar |
| `OfflineSyncRevisionMetricAbsent` | `absent(revision_adherence{environment="production"}) == 1` em 15min | Sem dado em produção p/ decidir o rollout (build sem a ponte, scraping ou sem mutações) |
| `OfflineSyncRevisionMetricAbsentStaging` | `absent(revision_adherence{environment="staging"}) == 1` em 15min (severity **info**) | Janela de ≥7 dias não está contando (staging dormindo, build antigo ou sem mutações) |
| `OfflineSyncHighRevisionConflictRate` | `revision_conflict / revision_adherence` (denominador só rotas PUT) > 5% em 15min (por ambiente) | Verificar reaplicação do ETag no cliente |

> Arquivo: `school-management-api/observability/prometheus-offline-sync-alerts.yml`
> (registrado em `prometheus.yml` e montado no `docker-compose.yml`).

## Pós-ativação em Produção

Após 7 dias de operação estável:

1. **Verificar adesão** (após implementar métricas de adesão no hardening):
   ```promql
   # Taxa de clientes usando chave no sync-batch (pipeline OTLP: sem sufixo
   # "_total") — gate do RequireKey; troque environment por "production"
   sum(rate(idempotency_key_provided{environment="production", source="batch"}[1h]))
     / (sum(rate(idempotency_key_provided{environment="production", source="batch"}[1h]))
        + sum(rate(idempotency_key_missing{environment="production", source="batch"}[1h])))
   ```

2. **Documentar lições aprendidas**

3. **Planejar escalabilidade** (se necessário, aumentar cache Redis)