# Contrato de Sincronização Offline

## Visão Geral do Contrato

Este documento descreve o contrato de sincronização offline para o sistema de gestão escolar, permitindo que clientes ressincronicem dados quando conectados, com garantias de idempotência e detecção de conflitos.

## Estado da Implementação (POC)

| Recurso | Estado |
|---------|--------|
| `POST /api/offline/sync-batch` (F2) | ✅ Ativo — idempotência, revisão otimista e estados applied/unchanged/conflict/rejected |
| `X-Server-Time` em todas as respostas + `serverTimeUtc` no health check (F3) | ✅ Ativo |
| Cache de idempotência Redis (multi-instância) | ✅ Ativo quando `ConnectionStrings:Redis` configurado; fallback em memória |
| **Idempotência global (F0) nos endpoints individuais** | ✅ **Ativa** — middleware global: POST/PUT/PATCH/DELETE com `Idempotency-Key` (opt-in). Chave inédita → executa; resposta 2xx → chave consumida (reuso → **422**); resposta 4xx/5xx → chave **liberada** (retry com a mesma chave é permitido). Rotas excluídas: `/api/auth`, `/api/webhooks`, `/api/support`, `/api/offline`, `/metrics`, `/swagger` |
| Métricas de adesão (`idempotency_key.missing/provided/reused`, `revision.missing`) | ✅ Ativas — o middleware de idempotência mede **todo** tráfego de mutação (além do sync-batch) com tag `source="http"`; o guard do sync-batch mede com `source="batch"` — **o gate `missing_key < 1%` lê só `source="batch"`** (única superfície em que o `RequireKey` enforça); `revision.missing` é medida no sync-batch (op-level) — para o tráfego HTTP use `revision.adherence` (por rota, ver abaixo) |
| Flags `OfflineSync__Idempotency__RequireKey` / `OfflineSync__Revision__Enforce` | ✅ Lidas pela API (default **false**) — RequireKey: sync-batch sem chave → 400; Enforce: UPDATE sem ETag → outcome `rejected`. O enforcement **global** é deliberadamente opt-in: endpoints individuais só bloqueiam quando o cliente envia a chave |
| Escopo do enforcement `OfflineSync__Revision__EnforcedPaths` | ✅ **Ativo** — lista de padrões `"MÉTODO /path/{id}"` que restringe o 428 (sem `If-Match`) às mutações cobertas pelo cliente; lista vazia = enforcement global. Ex.: `["PUT /api/grades/{id}", "PUT /api/grading-formulas/{id}"]` |
| Adesão de revisão **por rota** (`revision.adherence`) | ✅ **Ativa** — toda mutação em escopo é medida com tags `route` (rota normalizada, ex.: `PUT /api/grades/{id}`) e `state` (`provided` \| `wildcard` \| `missing`). Cardinalidade limitada (50 rotas + bucket `__other__`) — base para decidir, **por recurso**, se o enforcement pode ser ligado |
| Pipeline de exportação das métricas | ✅ **Dois caminhos, mesma nomenclatura** — (1) **produção**: o Prometheus scrapeia `GET /metrics` da API (a API no Render **não tem** collector OTLP); o endpoint serve as gauges de analytics + as métricas do `Meter "SchoolManagement"` (via `SchoolManagementMetricsCollector`) + o registro do prometheus-net. (2) **stack local/self-hosted**: Meter → OTLP (`OTEL_EXPORTER_OTLP_ENDPOINT`) → otel-collector → exporter prometheus (:8889) → Prometheus (job `otel-collector`). Em ambos, o ponto vira underscore **sem** sufixo `_total`: `revision.adherence` → série `revision_adherence`. Smoke test dos dois caminhos: `school-management-api/observability/test-offline-sync-metrics.sh` |
| `If-Match` nos endpoints individuais (F1 HTTP) | ✅ **Ativo** — `OptimisticRevisionMiddleware`: GET em escopo devolve o ETag corrente no header `ETag`; mutação com `If-Match` desatualizada → **412** com `currentRevision` no corpo; sucesso (2xx) devolve o ETag **novo**. A mutação com `If-Match` **reserva** a próxima revisão de forma **atômica** (CAS — Redis: Lua `GET`+`INCR`; memória: `TryUpdate`): dois clientes com o mesmo ETag — só um executa, o outro recebe 412. Falha do endpoint → a reserva é **desfeita** (rollback) e o cliente pode reenviar com o mesmo ETag. Sem `If-Match`: passa com Enforce=false; **428 Precondition Required** com Enforce=true. Revisão por **path** (`tenant:path` no Redis, `etag-revision:r:...`). Rotas excluídas: as mesmas do middleware de idempotência |

## Headers Necessários

### Idempotency-Key

```
Idempotency-Key: <uuid-v4>
```

- **Formato**: UUID v4 por operação de negócio (a assinatura HMAC não é exigida)
- **TTL**: 24 horas (cache automaticamente expira)
- **Escopo**: endpoints individuais de mutação (POST/PUT/PATCH/DELETE) e `sync-batch`
- **Comportamento (middleware global, opt-in por header)**:
  - Chave inédita → operação executa; resposta 2xx **consome** a chave
  - Reuso de chave consumida → **422** (a operação já foi aplicada — nunca retry)
  - Resposta 4xx/5xx → chave **liberada**: retente com a **mesma** chave
  - Sem header → requisição normal (adesão medida, nunca rejeitada)

### ETag (para Updates)

```
ETag: "{revision}-1.0.0-{hash8}"
If-Match: "{revision}-1.0.0-{hash8}"
```

- **Revisão**: contador incremental de escritas no recurso. No `sync-batch`, por
  entidade (`Revision` na tabela, `etag-revision:{entityId}` no Redis); nos
  endpoints individuais, por **path** (`etag-revision:r:{tenant}:{path}` no
  Redis, emitido/validado pelo `OptimisticRevisionMiddleware`)
- **Ciclo individual**: `GET` → resposta traz `ETag` corrente → cliente edita →
  `PUT`/`POST` com `If-Match` → conferindo: executa e devolve o ETag **novo**;
  desatualizado: **412** (abaixo); ausente: passa (Enforce=false) ou **428** (Enforce=true)
- **Reserva atômica (CAS)**: a mutação com `If-Match` **reserva** a próxima revisão
  *antes* de executar o endpoint (Redis: script Lua `GET`+`INCR` numa execução;
  memória: `TryUpdate` em laço). Dois clientes que editaram a mesma versão
  (mesmo ETag) — **só um executa**; o outro recebe **412**. Sem o CAS, a janela
  entre "verificar" e "incrementar" permitiria que ambos passassem (último a
  escrever sobrescreve o outro — perda silenciosa de atualização).
- **Rollback**: se o endpoint falhar (4xx/5xx) depois da reserva, a reserva é
  **desfeita** e a revisão volta à anterior — o cliente pode reenviar com o
  **mesmo ETag** (essencial para o retry da fila offline). A reserva só é
  desfeita se a revisão corrente ainda for a reservada (ninguém escreveu por cima).
- **Version**: `1.0.0` (evolução do formato do ETag)
- **hash8**: 8 caracteres Base64 do SHA-256 do conteúdo — informativo; a detecção de
  conflito compara a **revisão** (simplificação POC, ver `MemoryETagManager.Validate`)
- **ETag ausente = sem precondition** — a requisição sempre passa (compatibilidade com
  clientes sem headers enquanto as flags estiverem desligadas)
- **Granularidade por path**: a revisão é do **path** (`/api/grades/{id}`), então o
  ETag do GET de um recurso não vale para outro. Mutações de *collection* (upserts
  sem id na URL) não enviam `If-Match` — a revisão seria granular demais.

## Códigos de Status Específicos

### 422 Unprocessable Entity - Chave Reutilizada
```json
{
  "message": "Uma operação com a mesma Idempotency-Key já foi processada com sucesso. Gere uma chave nova (UUID v4) para uma operação nova.",
  "code": "idempotency-key-reused"
}
```

> **Regra de cliente: 422 NUNCA é retry automático.** Chave reutilizada significa
> que a tentativa anterior **foi bem-sucedida** (resposta 2xx consome a chave;
> 4xx/5xx a liberam). Vale para o `sync-batch` e para endpoints individuais
> de mutação que enviarem o header.

### 409 Conflict — não utilizado

O contrato original previa 409 para "execução em voo". Na implementação atual,
conflitos de revisão são mapeados para **412** (abaixo) e replays de chave para
**422** — 409 não é emitido pelo sync offline.

### 412 Precondition Failed - Conflito de Revisão

Emitido pelo `sync-batch` (op-level) e pelo `OptimisticRevisionMiddleware`
(endpoints individuais — formato `{message, code, currentRevision}`):

```json
{
  "message": "Recurso modificado por outro usuário. Reenvie (re-fetch) e reaplique sua alteração. Current: 41",
  "code": "revision-conflict",
  "currentRevision": 41
}
```

> **Regra de cliente: 412 NUNCA é retry automático.** Re-fetch do recurso
> (o GET devolve o ETag corrente), rebase da alteração e reenvio com o ETag novo.
>
> Na UI, 412 no caminho online mostra a mensagem de conflito e recarrega a
> lista; na fila offline o rascunho é marcado como `conflict` (preservado para
> o usuário decidir). **Nunca** reenviar o mesmo `If-Match` depois de um 412 —
> a revisão já avançou (por isso o rollback só acontece em falha do endpoint,
> não em conflito).

### 428 Precondition Required — só com `OfflineSync:Revision:Enforce=true`

Mutações **sem** `If-Match` em endpoints individuais (opt-in do dono do produto
via flag — default **false**):

```json
{
  "message": "Envie o header If-Match com o ETag obtido no GET do recurso antes de editar.",
  "code": "revision-required"
}
```

> **Escopo do enforcement (importante)**: com `Enforce=true`, a exigência é
> **global** — **toda** mutação em escopo sem `If-Match` recebe 428, inclusive
> **criações** (`POST /api/grades`) e **upserts de collection** (diário,
> chamada). Como o ETag só existe para recursos já lidos (revisão por path),
> criações não têm ETag a enviar — por isso a flag só pode ser ligada depois
> que **todos** os clientes enviarem `If-Match` nas mutações que o exigem
> (ou quando o enforcement passar a ser escopado por path). Enquanto isso,
> `Enforce=false` (default) preserva a compatibilidade.

#### Enforcement escopado por path (`OfflineSync:Revision:EnforcedPaths`)

Para o rollout incremental — exigir `If-Match` **só** onde o cliente já o
envia — o enforcement pode ser restrito a padrões de método+path:

```json
{
  "OfflineSync": {
    "Revision": {
      "Enforce": true,
      "EnforcedPaths": [
        "PUT /api/grades/{id}",
        "PUT /api/grading-formulas/{id}"
      ]
    }
  }
}
```

- **`{id}`** casa exatamente **um** segmento do path (o identificador):
  `PUT /api/grades/{id}` casa `/api/grades/42` e **não** casa
  `/api/grades/42/observacoes` nem `/api/grades`.
- **O método faz parte do padrão**: `POST /api/grades` (criação) e
  `POST /api/grading-formulas/{id}/activate` (ativação) ficam de fora mesmo
  com o padrão de `PUT` da mesma coleção.
- **Demais segmentos são literais** (sem distinção de maiúsculas/minúsculas).
- **Lista vazia = enforcement global** (comportamento anterior, preservado).
- Quem **envia** `If-Match` continua sujeito à validação de revisão (412) em
  qualquer path — o escopo restringe apenas quem é **bloqueado** por falta do
  header.
- O escopo vale para os **endpoints individuais** (middleware). O `sync-batch`
  tem enforcement próprio, por operação (ETag da entidade), não por path.

Com essa configuração, a UI atual (notas e fórmulas) fica **integralmente
coberta**: todo `PUT` de recurso com id envia `If-Match`, e as demais
mutações (criação, ativação, upserts de collection) não são bloqueadas.

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

| Métrica (nome no `Meter`) | Série no Prometheus | Incremento |
|---------------------------|----------------------|-----------|
| `offline_sync.total` | `offline_sync_total` | Por operação processada |
| `offline_sync.success` | `offline_sync_success` | Por operação applied/unchanged |
| `offline_sync.conflicts` | `offline_sync_conflicts` | Por operação em conflict |

### Adesão de rollout

| Métrica (nome no `Meter`) | Série no Prometheus | Tags | Incremento |
|---------------------------|----------------------|------|-----------|
| `idempotency_key.missing` | `idempotency_key_missing` | `source` (`http` \| `batch`) | Mutação em escopo sem `Idempotency-Key` — **o gate `missing_key < 1%` lê só `source="batch"`** (sync-batch, superfície do `RequireKey`); `source="http"` é adesão informativa (opt-in por design) |
| `idempotency_key.provided` | `idempotency_key_provided` | `source` (`http` \| `batch`) | Mutação em escopo com `Idempotency-Key` |
| `idempotency_key.reused` | `idempotency_key_reused` | — | Requisição rejeitada com 422 |
| `revision.missing` | `revision_missing` | — | Operação do sync-batch sem ETag (op-level) |
| `revision.conflict` | `revision_conflict` | — | 412 (stale `If-Match`) |
| **`revision.adherence`** | **`revision_adherence`** | `route`, `state` | **Toda mutação HTTP em escopo** — `state`: `provided` (enviou ETag), `wildcard` (`If-Match: *`) ou `missing` (sem header) |

> **Nomes no Prometheus**: o exporter do otel-collector converte o ponto em
> underscore e **não** acrescenta sufixo `_total` (versão pinada 0.83.0). Logo
> a série é `revision_adherence`, **não** `revision_adherence_total`. O sufixo
> `_total` existe só nas métricas do prometheus-net
> (`http_requests_received_total`), que são outro conjunto dentro do mesmo
> endpoint. Um nome errado na query/regra devolve vazio em silêncio — use
> sempre o nome da tabela acima e o smoke test
> `observability/test-offline-sync-metrics.sh` para validar.

> **Onde o Prometheus lê**: as séries acima estão disponíveis em **dois
> pipelines** (mesmos nomes): (1) **produção** — `GET /metrics` da API, que o
> Prometheus local scrapeia (job `school-management-prod`); o endpoint agrega
> as gauges de analytics, as métricas do `Meter "SchoolManagement"` (via
> `SchoolManagementMetricsCollector`) e o registro do prometheus-net; (2)
> **stack self-hosted** — OTLP → otel-collector → exporter prometheus (:8889).
> Em produção **não** há collector OTLP, então o caminho (1) é o que alimenta o
> rollout.

A **`revision_adherence`** é a métrica que permite decidir o rollout **por
recurso**: ela mede a adesão do cliente em cada rota, normalizada
(`PUT /api/grades/42` → `PUT /api/grades/{id}` — o path cru viraria uma série
nova por id). A cardinalidade é limitada a **50 rotas distintas**; acima disso,
as rotas novas caem no bucket `__other__`.

Taxa de adesão por rota (PromQL). O label `environment` vem do job de scrape
(`production` = `school-management-prod`, `staging` = `school-management-staging`);
sem ele o rate somaria o stack local (`api:5000` / `otel-collector`) ao gate:

```promql
sum by (route) (rate(revision_adherence{state="provided", environment="staging"}[5m]))
  / sum by (route) (rate(revision_adherence{environment="staging"}[5m]))
```

> `state="wildcard"` **não** protege a atualização (equivale a "qualquer
> revisão") — conte-o como não aderência ao decidir se liga o enforcement.

Alertas prontos: `observability/prometheus-offline-sync-alerts.yml`
(adesão baixa por rota, métrica ausente **por ambiente** — produção e staging —,
chave ausente > 1%, taxa de 412, conflitos do sync-batch; todos filtram por
`environment=production|staging`).

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
- **Clientes offline com ETag emitido antes da migration**: nenhum existe; no
  sync-batch, a revisão corrente parte de 1. No middleware individual, a revisão
  por path parte de 0 (recurso nunca escrito) e é **independente** da coluna
  `Students.Revision` (chave `tenant:path`, não entidade).
- **Após a migration**, as primeiras escritas incrementam `Revision` (1 → 2 → ...).
  A emissão/validação individual via middleware já está ativa (ETag derivado da
  revisão do path); a coluna `Students.ETag` persistida segue reservada para o
  acoplamento por entidade futuro.