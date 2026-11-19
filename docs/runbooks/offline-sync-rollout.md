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