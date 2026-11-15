# Design: Contrato de Sincronização Offline

## Arquitetura

### Componentes

1. **Cliente Offline**
   - Gera `Idempotency-Key` baseado em UUID + HMAC
   - Armazena operações pendentes em local storage
   - Calcula desvio de relógio via `X-Server-Time`

2. **Middleware de Idempotência**
   - Cache distribuído (Redis) com TTL de 24h
   - Chave de cache: `idempotency:{tenant}:{key_hash}`
   - Valor: `{status_code, headers, body_hash}`

3. **Gerenciador de Revisão**
   - Coluna `Revision` em todas as entidades expostíveis
   - Update: `SET revision = revision + 1`
   - ETag gerado como: `SHA256(content + revision + version)`

4. **Processador de Lote**
   - Endpoint `/api/offline/sync-batch`
   - Processa operações sequencialmente
   - Acumula erros sem abortar
   - Resposta com outcomes detalhados

## Fluxos

### Fluxo 1: Operação Idempotente

```mermaid
sequenceDiagram
    participant C as Cliente
    participant S as Servidor
    participant R as Redis (Idempotency Cache)

    C->>S: POST /recursos (Idempotency-Key: xxx)
    S->>R: GET idempotency:tenant:xxx
    alt Chave não existe
        R-->>S: null
        S->>S: Processar operação
        S->>R: SET idempotency:tenant:xxx = {201, body}
        S-->>C: 201 Created
    else Chave existe
        R-->>S: {status, body}
        S-->>C: 422 Unprocessable Entity (replay)
    end
```

### Fluxo 2: Conflito de Revisão

```mermaid
sequenceDiagram
    participant C as Cliente
    participant S as Servidor

    C->>S: PUT /students/123 (If-Match: "old-etag")
    S->>S: Obter recurso atual + ETag
    alt ETag confere
        S->>S: Processar update
        S->>S: Incrementar revision
        S-->>C: 200 OK (novo-etag)
    else ETag não confere
        S-->>C: 412 Precondition Failed
    end
```

### Fluxo 3: Sync em Lote

```mermaid
sequenceDiagram
    participant C as Cliente
    participant S as Servidor
    participant W as Worker

    C->>S: POST /offline/sync-batch (operations: [...])
    S->>W: Enfileirar lote
    loop Para cada operação
        W->>S: Processar
        W->>W: Acumular outcome
    end
    S-->>C: 200 {batchId, outcomes: [...]}
```

## Schema de Dados

### Tabela de Cache de Idempotência

```sql
CREATE TABLE IdempotencyCache (
    key_hash TEXT PRIMARY KEY,
    tenant_id UUID NOT NULL,
    status_code INTEGER NOT NULL,
    headers JSONB,
    body_hash TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    expires_at TIMESTAMP WITH TIME ZONE
);

CREATE INDEX idx_idempotency_tenant ON IdempotencyCache(tenant_id);
CREATE INDEX idx_idempotency_expires ON IdempotencyCache(expires_at);
```

### Coluna de Revisão (exemplo para Student)

```sql
ALTER TABLE Students ADD COLUMN IF NOT EXISTS revision INTEGER NOT NULL DEFAULT 1;
ALTER TABLE Students ADD COLUMN IF NOT EXISTS version TEXT NOT NULL DEFAULT '1.0.0';
```

## Segurança LGPD

- Não armazenar corpo completo da requisição no cache
- Hash SHA-256 do corpo para verificação de replay
- Logs de sincronização apontam para `operations_metadata` (não PII)
- Retention policy de 24h no cache de idempotência

## Performance

- Cache Redis com LRU eviction
- Timeout de operação: 10s (batch) / 2s (individual)
- Rate limit: 100 req/min por tenant (sync batch)