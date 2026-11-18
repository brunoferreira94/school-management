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
- `missing_key < 1%`: `idempotency_key_missing / (idempotency_key_missing + idempotency_key_provided)`
- `revision_missing < 1%`: `revision_missing / offline_sync_total`
- Nenhum spike de 5xx

> **Onde as métricas estão** — as métricas do `Meter "SchoolManagement"` (F4 +
> adesão) **não** estão em `/metrics` da API (esse endpoint é do prometheus-net).
> O caminho real é:
>
> ```text
> API (Meter "SchoolManagement")
>   → OTLP (OTEL_EXPORTER_OTLP_ENDPOINT na API)
>     → otel-collector (:4317)
>       → exporter prometheus (:8889)
>         → Prometheus (job "otel-collector")
> ```
>
> O exporter converte o ponto em underscore **sem** sufixo `_total` (collector
> 0.83.0): `revision.adherence` → série `revision_adherence`,
> `idempotency_key.missing` → `idempotency_key_missing`,
> `offline_sync.total` → `offline_sync_total`. O `_total` existe só nas
> métricas do prometheus-net (`http_requests_total`).
>
> **Pré-requisito**: a API precisa de `OTEL_EXPORTER_OTLP_ENDPOINT` (ou
> `OTEL:Endpoint` no `appsettings`) apontando para o collector. Sem isso
> **nenhuma** métrica de adesão sai da API e o rollout fica sem dado — o alerta
> `OfflineSyncRevisionMetricAbsent` dispara exatamente nesse caso.
>
> Smoke test do caminho completo (API → OTLP → collector → Prometheus):
>
> ```bash
> bash school-management-api/observability/test-offline-sync-metrics.sh
> ```

**Antes do Passo 2**: deixar as flags desligadas por ≥ 7 dias em staging e
confirmar adesão < 1% (não ligar flags sem adesão medida).

### Adesão por rota (decidir resource a resource)

O `revision_adherence` mede, **por rota normalizada**, se o cliente enviou
`If-Match` (`state="provided"`, `state="wildcard"` ou `state="missing"`):

```promql
# Taxa de adesão por rota (o que interessa para ligar o enforcement)
sum by (route) (rate(revision_adherence{state="provided"}[1h]))
  / sum by (route) (rate(revision_adherence[1h]))

# Rotas que ainda não aderem (candidatas a NÃO entrar no enforcement)
sum by (route) (rate(revision_adherence{state="missing"}[1h])) > 0
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
idempotency_key_missing
idempotency_key_provided
idempotency_key_reused
revision_missing
revision_conflict
revision_adherence          # tags: route, state

# Taxa de sucesso de sync
sum(increase(offline_sync_success[5m])) / sum(increase(offline_sync_total[5m]))

# Taxa de conflitos
sum(increase(offline_sync_conflicts[5m])) / sum(increase(offline_sync_total[5m]))

# Adesão de chave
sum(increase(idempotency_key_missing[5m])) / sum(increase(idempotency_key_missing[5m]) + increase(idempotency_key_provided[5m]))

# Adesão de If-Match POR ROTA (decide o enforcement por recurso)
sum by (route) (rate(revision_adherence{state="provided"}[1h]))
  / sum by (route) (rate(revision_adherence[1h]))
```

> `http_requests_total` (com `_total`) vem do **prometheus-net** (`/metrics` da
> API) — é outro pipeline e mantém o sufixo. Não misturar os dois.

### Alertas

| Alerta | Condição | Ação |
|--------|----------|------|
| `OfflineSyncHighConflicts` | `offline_sync_conflicts / offline_sync_total > 1%` em 15min | Notificar #alert-offline-sync |
| `OfflineSync5xxErrors` | `sum(rate(http_requests_total{path="/api/offline/*",status=~"5.."}[5m])) > 0` | Notificar on-call |
| `OfflineSyncHighMissingIdempotencyKey` | `idempotency_key_missing / (missing + provided) > 1%` em 30min | Notificar #product |
| `OfflineSyncLowRevisionAdherence` | por rota: `provided / total < 99%` em 1h (só nas rotas com `EnforcedPaths`) | Não ampliar o `EnforcedPaths` nessa rota até a adesão normalizar |
| `OfflineSyncRevisionMetricAbsent` | `absent(revision_adherence) == 1` em 15min | Pipeline de métricas quebrado — sem dado para decidir o rollout |
| `OfflineSyncHighRevisionConflictRate` | `revision_conflict / revision_adherence > 5%` em 15min | Verificar reaplicação do ETag no cliente |

> Arquivo: `school-management-api/observability/prometheus-offline-sync-alerts.yml`
> (registrado em `prometheus.yml` e montado no `docker-compose.yml`).

## Pós-ativação em Produção

Após 7 dias de operação estável:

1. **Verificar adesão** (após implementar métricas de adesão no hardening):
   ```promql
   # Taxa de clientes usando chave (pipeline OTLP: sem sufixo "_total")
   sum(increase(idempotency_key_provided[1d])) / sum(increase(idempotency_key_provided[1d]) + increase(idempotency_key_missing[1d]))
   ```

2. **Documentar lições aprendidas**

3. **Planejar escalabilidade** (se necessário, aumentar cache Redis)