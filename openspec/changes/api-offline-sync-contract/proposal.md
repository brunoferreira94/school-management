# Proposta: Contrato de Sincronização Offline

## Visão Geral

Implementar um contrato robusto de sincronização offline para o sistema de gestão escolar, permitindo que clientes (especialmente dispositivos móveis em ambientes de rede instável) façam upload de dados quando offline e sincronizem quando a conexão é restaurada, garantindo:

- **Idempotência garantida**: múltiplas envios de uma mesma operação resultam em apenas uma execução efeitiva
- **Detecção de conflitos**: quando múltiplos clientes editam os mesmos recursos simultaneamente
- **Consistência de versão**: mecanismo de revisão (ETag) para detectar alterações não propagadas

## Escopo

### F0. Idempotency-Key Globale
- Header `Idempotency-Key`: UUID v4 + HMAC(sub, método, path, TTL=24h)
- Replay fiel: mesma chave = mesmo resultado (status, cabeçalhos, corpo)
- Chave reutilizada → `422 Unprocessable Entity` (retry com nova chave)
- Chave não sincronizada → `409 Conflict` (execução em voo, já sincronizada)

### F1. Revisão Otimista (ETag/If-Match)
- Header `ETag`: hash de conteúdo + revision + version
- Client envia `If-Match: <ETag>` em updates
- Conflito → `412 Precondition Failed` (revision_conflict)
- Revisão separada de Version (fórmulas de notas)
  - `Revision`: counter global de mudanças no recurso
  - `Version`: semantic version (não para detecção de conflitos)

### F2. Sincronização em Lote
- Endpoint `POST /api/offline/sync-batch` aceita array de operações
- Resposta com outcomes: `applied`, `unchanged`, `conflict`, `rejected`
- Processamento em lote com atomicidade parcial (não rollback total)

### F3. X-Server-Time
- Header `X-Server-Time`: timestamp UTC da requisição
- Client calcula desvio de relógio para ajustar `Idempotency-Key` TTL
- Incluso no health check (`GET /api/support/health`)

### F4. Métricas e Alertas
- Métricas Prometheus: `offline_sync_duration_seconds`, `offline_sync_conflicts_total`
- Alertas: Taxa de conflitos > 1% por 5min (possível bug de sync)
- LGPD: Logs de sync mantêm apenas identificador, não conteúdo sensível

## Configurações

- `OfflineSync__Idempotency__RequireKey`: default = false (compatibilidade com clientes legados)
- `OfflineSync__Revision__Enforce`: default = false (ativar em staging 2026-11-16)

## Ativação

1. Ativar flags em staging (observação 24h)
2. Smoke test: 5 clientes, 10k operações/dia cada
3. Monitorar adesão (missing_key < 1%, revision_missing < 1% por 7 dias)
4. Ativar em produção após validação

## Rollback

Se taxas de conflito > 5% ou taxa de erros 5xx > 1%:
1. Desativar flags via config
2. Limpar cache de idempotency (TTL expirado em 24h)
3. Notificar equipe de produto
