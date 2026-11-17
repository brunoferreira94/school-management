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

- **Taxa de sucesso**: `sum(increase(offline_sync_success_total[5m])) / sum(increase(offline_sync_total[5m]))`
- **Taxa de conflitos**: `sum(increase(offline_sync_conflicts_total[5m])) / sum(increase(offline_sync_total[5m]))`
- **Erros 5xx**: `sum(rate(http_requests_total{status=~"5.."}[5m])) / sum(rate(http_requests_total[5m]))`

Critérios de sucesso:
- `missing_key < 1%`: `idempotency_key.missing / (idempotency_key.missing + idempotency_key.provided)`
- `revision_missing < 1%`: `revision.missing / offline_sync.total`
- Nenhum spike de 5xx

> Métricas disponíveis: `offline_sync_total`, `offline_sync_success_total`,
> `offline_sync_conflicts_total` (F4) + adesão `idempotency_key.missing`,
> `idempotency_key.provided`, `revision.missing` (medidas sempre, flags
> ligadas ou não). Métricas de adesão ficam registradas em memória (Meter do
> System.Diagnostics) — coletadas pelo exporter Prometheus da API.

**Antes do Passo 2**: deixar as flags desligadas por ≥ 7 dias em staging e
confirmar adesão < 1% (não ligar flags sem adesão medida).

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
# Métricas implementadas (F4 + adesão):
offline_sync_total
offline_sync_success_total
offline_sync_conflicts_total
idempotency_key_missing_total   # exported as idempotency_key.missing
idempotency_key_provided_total  # exported as idempotency_key.provided
revision_missing_total          # exported as revision.missing

# Taxa de sucesso de sync
sum(increase(offline_sync_success_total[5m])) / sum(increase(offline_sync_total[5m]))

# Taxa de conflitos
sum(increase(offline_sync_conflicts_total[5m])) / sum(increase(offline_sync_total[5m]))

# Adesão de chave
sum(increase(idempotency_key_missing_total[5m])) / sum(increase(idempotency_key_missing_total[5m]) + increase(idempotency_key_provided_total[5m]))
```

### Alertas

| Alerta | Condição | Ação |
|--------|----------|------|
| `OfflineSyncHighConflicts` | `offline_sync_conflicts_total / offline_sync_total > 1%` em 5min | Notificar #alert-offline-sync |
| `OfflineSync5xxErrors` | `sum(rate(http_requests_total{path="/api/offline/*",status=~"5.."}[5m])) > 0` | Notificar on-call |
| `OfflineSyncMissingKey` | `idempotency_key_missing_total / total de sync > 1%` em 10min | Notificar #product |

## Pós-ativação em Produção

Após 7 dias de operação estável:

1. **Verificar adesão** (após implementar métricas de adesão no hardening):
   ```bash
   # Taxa de clientes usando chave
   sum(increase(idempotency_key_provided_total[1d])) / sum(increase(http_requests_total[1d]))
   ```

2. **Documentar lições aprendidas**

3. **Planejar escalabilidade** (se necessário, aumentar cache Redis)