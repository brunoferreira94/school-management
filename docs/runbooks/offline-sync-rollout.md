# Runbook: Ativação da Sincronização Offline

> **Estado atual (2026-11-16)**: contrato POC ativo — sync-batch (F2),
> X-Server-Time (F3), métricas `offline_sync_*` e ETag/revisão via Redis (F1)
> implementados e testados (suíte 977/0). As flags `RequireKey`/`Enforce`
> **ainda não são lidas pela API** — ligá-las sem implementar enforcement e
> métricas de adesão não tem efeito. Este runbook vale para o momento do
> hardening, quando o enforcement for ativado.

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
- `missing_key < 1%` (clientes sem chave) — **requer métrica de adesão, ainda não implementada (hardening)**
- `revision_missing < 1%` (clientes sem revision) — idem
- Nenhum spike de 5xx

> Métricas hoje disponíveis: `offline_sync_total`, `offline_sync_success_total`,
> `offline_sync_conflicts_total` (F4). Métricas de adesão (`missing_key`,
> `revision_missing`) são pré-requisito para ligar as flags em staging —
> implementar no Bloco de hardening antes do Passo 2.

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

2. **Cache de idempotency**: expira naturalmente em 24h (TTL nativo do Redis e
   do serviço em memória). Não há endpoint de flush — para limpeza imediata,
   usar o console do provedor Redis (ex.: Upstash → Flush Database). Entradas
   em memória desaparecem no restart da instância.

3. **Reportar incidente**: #alert-offline-sync no Slack

## Monitoramento Contínuo

### Dashboard Prometheus

```
# Métricas implementadas (F4):
offline_sync_total
offline_sync_success_total
offline_sync_conflicts_total

# Taxa de sucesso de sync
sum(increase(offline_sync_success_total[5m])) / sum(increase(offline_sync_total[5m]))

# Taxa de conflitos
sum(increase(offline_sync_conflicts_total[5m])) / sum(increase(offline_sync_total[5m]))
```

> `offline_sync_errors_total` e as métricas de adesão (`idempotency_key_missing_total`,
> `idempotency_key_provided_total`) ainda não existem — implementar no Bloco de
> hardening antes de ativar flags.

### Alertas

| Alerta | Condição | Ação |
|--------|----------|------|
| `OfflineSyncHighConflicts` | `offline_sync_conflicts_total / offline_sync_total > 1%` em 5min | Notificar #alert-offline-sync |
| `OfflineSync5xxErrors` | `sum(rate(http_requests_total{path="/api/offline/*",status=~"5.."}[5m])) > 0` | Notificar on-call |

## Pós-ativação em Produção

Após 7 dias de operação estável:

1. **Verificar adesão** (após implementar métricas de adesão no hardening):
   ```bash
   # Taxa de clientes usando chave
   sum(increase(idempotency_key_provided_total[1d])) / sum(increase(http_requests_total[1d]))
   ```

2. **Documentar lições aprendidas**

3. **Planejar escalabilidade** (se necessário, aumentar cache Redis)