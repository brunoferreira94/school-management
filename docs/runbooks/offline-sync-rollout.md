# Runbook: Ativação da Sincronização Offline

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

- **Taxa de idempotência**: `sum(increase(sync_idempotency_2xx_total[5m])) by (status)`
- **Taxa de conflitos**: `rate(offline_sync_conflicts_total[5m])`
- **Erros 5xx**: `sum(rate(http_requests_total{status=~"5.."}[5m])) / sum(rate(http_requests_total[5m]))`

Critérios de sucesso:
- `missing_key < 1%` (clientes sem chave)
- `revision_missing < 1%` (clientes sem revision)
- Nenhum spike de 5xx

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
  -H "Idempotency-Key: $(uuidgen)_$(date +%s)" \
  -H "Content-Type: application/json" \
  -d '{
    "operations": [
      {"method": "GET", "path": "/api/students/91000000001"},
      {"method": "POST", "path": "/api/students", "body": {"cpf":"99999999999","name":"New Student"}},
      {"method": "PUT", "path": "/api/students/99999999999", "body": {"cpf":"99999999999","name":"Updated"}}
    ]
  }'

# Verificar outcome
# 400 Bad Request → {"outcomes": [{"result": "applied"}, {"result": "applied"}, {"result": "applied"}]}
```

## Rollback

Se os critérios de erro forem excedidos:

1. **Desativar flags**:
   ```
   OfflineSync__Idempotency__RequireKey=false
   OfflineSync__Revision__Enforce=false
   ```

2. **Limpar cache de idempotency** (TTL expira naturalmente em 24h):
   ```bash
   # Se necessário imediatamente
   curl -X DELETE "https://staging-api:5067/api/support/idempotency-cache"
   ```

3. **Reportar incidente**: #alert-offline-sync no Slack

## Monitoramento Contínuo

### Dashboard Prometheus

```
# Taxa de sucesso de sync
sum(increase(offline_sync_success_total[5m])) / sum(increase(offline_sync_total[5m]))

# Taxa de conflitos
rate(offline_sync_conflicts_total[5m])

# Erros por tipo
rate(offline_sync_errors_total{error_type="idempotency"}[5m])
rate(offline_sync_errors_total{error_type="conflict"}[5m])
```

### Alertas

| Alerta | Condição | Ação |
|--------|----------|------|
| `OfflineSyncHighConflicts` | `rate(offline_sync_conflicts_total[5m]) > 0.01` | Notificar #alert-offline-sync |
| `OfflineSync5xxErrors` | `sum(rate(http_requests_total{path="/api/offline/*",status=~"5.."}[5m])) > 0` | Notificar on-call |
| `OfflineSyncMissingKey` | `rate(idempotency_key_missing_total[5m]) > 10` | Notificar #product |

## Pós-ativação em Produção

Após 7 dias de operação estável:

1. **Verificar adesão**:
   ```bash
   # Taxa de clientes usando chave
   sum(increase(idempotency_key_provided_total[1d])) / sum(increase(http_requests_total[1d]))
   ```

2. **Documentar lições aprendidas**

3. **Planejar escalabilidade** (se necessário, aumentar cache Redis)