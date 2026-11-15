# Contrato de Sincronização Offline

## Visão Geral do Contrato

Este documento descreve o contrato de sincronização offline para o sistema de gestão escolar, permitindo que clientes ressincronicem dados quando conectados, com garantias de idempotência e detecção de conflitos.

## Headers Necessários

### Idempotency-Key

```
Idempotency-Key: <uuid-v4>_<hmac-signature>
```

- **Formato**: UUID v4 + HMAC-SHA256(sub, método, path, timestamp)
- **TTL**: 24 horas (cache automaticamente expira)
- **Uso**: Para garantir replay fiel de requisições

### ETag (para Updates)

```
ETag: "<revision>-<version>-<content-hash>"
If-Match: "<revision>-<version>-<content-hash>"
```

- **Revisão**: counter global de modificações no recurso (incremental)
- **Version**: semantic version (ex: 1.0.0)
- **Content-hash**: SHA-256 do corpo da requisição

## Códigos de Status Específicos

### 422 Unprocessable Entity - Chave Reutilizada
```json
{
  "type": "https://school-management.example.com/errors/idempotency-key-reused",
  "title": "Idempotency key already used",
  "status": 422,
  "detail": "Uma operação com a mesma Idempotency-Key já foi processada. Use uma chave única para nova operação."
}
```

### 409 Conflict - Execução em Voo
```json
{
  "type": "https://school-management.example.com/errors/conflict-in-flight",
  "title": "Conflict with in-flight operation",
  "status": 409,
  "detail": "A operação já foi sincronizada por outro cliente. Estado atual: ..."
}
```

### 412 Precondition Failed - Conflito de Revisão
```json
{
  "type": "https://school-management.example.com/errors/revision-conflict",
  "title": "Precondition Failed",
  "status": 412,
  "detail": "A revisão especificada não corresponde ao estado atual do recurso.",
  "currentRevision": 42
}
```

## Endpoints Específicos

### POST /api/offline/sync-batch

Processa múltiplas operações em lote:

```
Request:
POST /api/offline/sync-batch
Idempotency-Key: <uuid>
Content-Type: application/json

{
  "operations": [
    {
      "method": "POST",
      "path": "/api/students",
      "body": { "cpf": "12345678901", "name": "João Silva" },
      "metadata": { "deviceId": "mobile-001", "timestamp": "2026-11-15T10:00:00Z" }
    },
    // ... mais operações
  ]
}

Response:
{
  "batchId": "batch-20261115-100000",
  "outcomes": [
    { "operationId": 0, "result": "applied", "resourceId": "91000000001", "timestamp": "2026-11-15T10:00:01Z" },
    { "operationId": 1, "result": "conflict", "reason": "revision_mismatch", "currentRevision": 5 },
    { "operationId": 2, "result": "rejected", "reason": "validation_failed", "errors": ["CPF must be 11 digits"] }
  ]
}
```

## X-Server-Time

O header `X-Server-Time` é retornado em todas as respostas:

```
HTTP/1.1 200 OK
X-Server-Time: 1763215200
```

Clientes usam isso para:
- Calcular desvio de relógio do dispositivo
- Ajustar TTL da Idempotency-Key
- Sincronizar timestamps de forma consistente

## Política de Retenção

- **Logs de Sync**: Mantidos por 90 dias (LGPD)
- **Cache de Idempotency**: Limpo automaticamente após 24h
- **Dados sensíveis**: Nunca logados (CPF, nomes, etc.)