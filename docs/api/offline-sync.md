# Contrato de Sincronização Offline

## Visão Geral do Contrato

Este documento descreve o contrato de sincronização offline para o sistema de gestão escolar, permitindo que clientes ressincronicem dados quando conectados, com garantias de idempotência e detecção de conflitos.

## Estado da Implementação (POC)

| Recurso | Estado |
|---------|--------|
| `POST /api/offline/sync-batch` (F2) | ✅ Ativo — idempotência, revisão otimista e estados applied/unchanged/conflict/rejected |
| `X-Server-Time` em todas as respostas + `serverTimeUtc` no health check (F3) | ✅ Ativo |
| Métricas `offline_sync.total/success/conflicts` (F4) | ✅ Ativas |
| Cache de idempotência Redis (multi-instância) | ✅ Ativo quando `ConnectionStrings:Redis` configurado; fallback em memória |
| Enforcement de flags (`RequireKey`, `Enforce`) | ⏳ Pendente (hardening) — clientes **sem** headers nunca são rejeitados |
| `If-Match` nos endpoints individuais (F1 HTTP) | ⏳ Pendente (hardening) — hoje a revisão otimista atua no sync-batch |

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
ETag: "{revision}-1.0.0-{hash8}"
If-Match: "{revision}-1.0.0-{hash8}"
```

- **Revisão**: contador incremental de escritas no recurso (`Revision` na tabela, `etag-revision:{entityId}` no Redis)
- **Version**: `1.0.0` (evolução do formato do ETag)
- **hash8**: 8 caracteres Base64 do SHA-256 do conteúdo — informativo; a detecção de
  conflito compara a **revisão** (simplificação POC, ver `MemoryETagManager.Validate`)
- **ETag ausente = sem precondition** — a requisição sempre passa (compatibilidade com
  clientes sem headers enquanto as flags estiverem desligadas)

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

> **Regra de cliente: 422 NUNCA é retry automático.** Chave reutilizada significa
> replay — o cliente deve gerar uma Idempotency-Key nova (UUID v4) para cada
> operação de negócio diferente.

### 409 Conflict — não utilizado

O contrato original previa 409 para "execução em voo". Na implementação atual,
conflitos de revisão são mapeados para **412** (abaixo) e replays de chave para
**422** — 409 não é emitido pelo sync offline.

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
  "tenantId": "00000000-0000-0000-0000-000000000001",
  "clientId": "device-mobile-001",
  "idempotencyKey": "e1f5c2a3-8b4d-4c6e-9f0a-1b2c3d4e5f60",
  "operations": [
    {
      "entityType": "Student",
      "operationType": "UPDATE",
      "entityId": "91000000-0000-0000-0000-000000000001",
      "etag": "4-1.0.0-a1B2c3D4",
      "payload": { "name": "João Silva", "cpf": "12345678901" }
    }
    // ... mais operações
  ]
}

Response (200 OK):
{
  "batchId": "7f3e9a2b-1c4d-4e5f-8a9b-0c1d2e3f4a5b",
  "processedCount": 2,
  "unchangedCount": 1,
  "conflictCount": 1,
  "unprocessedCount": 2,
  "outcomes": [
    { "entityId": "91000000-...", "entityType": "Student", "operationType": "UPDATE",
      "status": "applied", "success": true, "newETag": "5-1.0.0-f6E5d4C3" },
    { "entityId": "...", "operationType": "UPDATE",
      "status": "unchanged", "success": true, "newETag": "5-1.0.0-f6E5d4C3" },
    { "entityId": "...", "operationType": "UPDATE",
      "status": "conflict", "success": false,
      "error": "Revision conflict. Your revision is outdated. Current: 5" },
    { "entityId": null, "operationType": "CREATE",
      "status": "rejected", "success": false, "error": "Invalid ETag format" }
  ]
}

Estados por operação:
- `applied` — operação aplicada; nova revisão emitida (`newETag`).
- `unchanged` — payload idêntico ao já armazenado (replay offline); nenhum efeito, ETag corrente retornado.
- `conflict` — revisão do cliente desatualizada; mapear para 412 no cliente (nunca retry automático).
- `rejected` — payload/ETag/tipo de operação inválido; corrigir antes de reenviar.
```

## Métricas (F4 — LGPD)

Contadores Prometheus agregados, sem nenhum dado do payload (LGPD):

| Métrica | Incremento |
|---------|-----------|
| `offline_sync.total` | Por operação processada |
| `offline_sync.success` | Por operação applied/unchanged |
| `offline_sync.conflicts` | Por operação em conflict |

Log de batch contém **apenas** `batchId`, `tenantId` e contagens por status —
CPF, nomes, payloads e EntityIds nunca são logados.

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
- **Cache de Idempotency**: Limpo automaticamente após 24h (TTL nativo do Redis)
- **Dados sensíveis**: Nunca logados (CPF, nomes, etc.)

## Configuração do Backend (Redis)

O cache de idempotência suporta dois modos, escolhido automaticamente no DI:

| Modo | Quando | Implementação |
|------|--------|---------------|
| **Redis (distribuído)** | `ConnectionStrings:Redis` configurada | `RedisIdempotencyService` — multi-instância, TTL nativo de 24h |
| **Memória (POC/dev)** | Chave ausente ou vazia | `MemoryIdempotencyService` — instância única, sem persistência |

### Como configurar

```bash
# Variável de ambiente (produção/staging)
export ConnectionStrings__Redis="rediss://default:<token>@<host>:<port>"

# appsettings.<env>.json (equivalente)
"ConnectionStrings": { "Redis": "rediss://..." }
```

- A URL no formato `rediss://` (Upstash e demais provedores) é aceita diretamente por `StackExchange.Redis`.
- `AbortOnConnectFail=false`: a API sobe mesmo se o Redis estiver indisponível (a chamada falha apenas quando usada).
- Sem `ConnectionStrings:Redis` → cache em memória (comportamento atual de dev/testes).

### Comportamento no Testing

A suíte de testes não define `ConnectionStrings:Redis` (unitários exercitam o
`MemoryIdempotencyService`, determinístico e sem rede). Além disso, a suíte tem
**testes de integração contra Redis real** via Testcontainers (`redis:7-alpine`):
idempotência (F0), ETag/revisão (F1), lote batch (F2) e flag `IsProcessed` —
ver `tests/SchoolManagement.Tests/OfflineSync/`.

## Migração de Revisões Existentes (3.3)

A migration `OfflineSyncRevisionColumns` (SchoolContext, 2026-11-16) adiciona
as colunas em `Students` com defaults que preenchem as linhas existentes:

```sql
Revision  INTEGER NOT NULL DEFAULT 1,
Version   VARCHAR(20) NOT NULL DEFAULT '1.0.0',
ETag      VARCHAR(64) NULL
```

Consequências para dados pré-existentes:

- **Clientes legados sem `If-Match`**: sempre passam (sem precondition) — sem mudança de comportamento.
- **Clientes offline com ETag emitido antes da migration**: nenhum existe (o ETag
  HTTP individual ainda não é emitido); no sync-batch, a revisão corrente parte de 1.
- **Após a migration**, as primeiras escritas incrementam `Revision` (1 → 2 → ...).
  Emissão e leitura do ETag persistido (`Students.ETag`) serão ativadas no
  hardening, quando os endpoints individuais passarem a devolver/validar If-Match.