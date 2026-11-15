# Especificação: Contrato de Sincronização Offline

## Purpose

Este contrato defina um mecanismo robusto de sincronização offline para o sistema de gestão escolar, permitindo que clientes (especialmente dispositivos móveis em ambientes de rede instável) façam upload de dados quando offline e sincronizem quando a conexão é restaurada, com garantias de idempotência, detecção de conflitos e consistência de versão.

## Requirements

### Requirement: Idempotency-Globale (F0)

#### Scenario: Cliente repete mesma operação via Idempotency-Key
Dado que um cliente está offline e acaba de concluir uma operação
E o cliente sincroniza com `Idempotency-Key: abc123`
Quando o mesmo cliente tenta sincronizar novamente com `Idempotency-Key: abc123`
Então o servidor responde `422 Unprocessable Entity`
E o corpo contém `type: "https://school-management.example.com/errors/idempotency-key-reused"`
E não há alteração adicional no banco de dados

#### Scenario: Cada nova operação gera chave única
Dado que o cliente gera uma nova operação
Quando o cliente inclui `Idempotency-Key` com UUID único
Então o servidor processa a operação normalmente
E armazena o resultado no cache por 24 horas

### Requirement: Revisão Otimista com ETag (F1)

#### Scenario: Update bem-sucedido com ETag válido
Dado que um recurso existe com `ETag: "3-1.0.0-abc123"`
Quando o cliente envia `If-Match: "4-1.0.0-def456"` (revision atualizada)
Então o servidor aceita o update
E retorna `200 OK` com novo `ETag`

#### Scenario: Conflito de revisão detectado
Dado que o recurso foi modificado por outro cliente
E meu ETag está desatualizado (`revision 3`)
Quando envio `If-Match` com ETag antigo (`revision 3`)
Então o servidor responde `412 Precondition Failed`
E o corpo contém `"currentRevision": 4`

### Requirement: Sync em Lote (F2)

#### Scenario: Lote com operações mistas
Dado que o cliente tem 5 operações pendentes
Quando envio `POST /api/offline/sync-batch` com todas
Então o servidor responde `200 OK`
E o corpo contém `batchId` único
E o array `outcomes` contém 5 elementos
Pelo menos 3 são `applied` (operações processadas)
Pelo menos 1 é `unchanged` (não precisou alterar nada)

#### Scenario: Operação rejeitada em lote
Dado que uma operação no lote viola validação
Quando processo o lote
Então o outcome é `rejected`
E o corpo contém `errors: ["CPF inválido"]`

### Requirement: X-Server-Time (F3)

#### Scenario: Cliente sincroniza relógio
Dado que o cliente faz qualquer requisição
Quando recebo resposta com `X-Server-Time: 1763215200`
Então o cliente calcula seu desvio de relógio
E ajusta TTL da Idempotency-Key se necessário

#### Scenario: Health check inclui servidor tempo
Quando cliente chama `GET /api/support/health`
Então a resposta contém campo `serverTimeUtc: 1763215200`

### Requirement: Métricas e LGPD (F4)

#### Scenario: Métricas de sync são exportadas
Dado que operações de sync estão acontecendo
Quando o Prometheus coleta métricas
Então `offline_sync_total` incrementa
E `offline_sync_success_total` incrementa apenas para successos
E `offline_sync_conflicts_total` incrementa para conflitos

#### Scenario: Logs não continham PII
Dado que sync ocorreu com sucesso
Quando o log é criado
Então o log contém apenas `tenantId`, `batchId`, `operationType`
Não contém CPF, nomes, ou dados sensíveis

## Configuration

| Config | Default | Descrição |
|--------|---------|-----------|
| `OfflineSync__Idempotency__RequireKey` | `false` | Requer header Idempotency-Key |
| `OfflineSync__Revision__Enforce` | `false` | Requer ETag/If-Match em updates |
| `OfflineSync__Redis__TTL` | `86400` | TTL do cache em segundos (24h) |

## Design Reference

Ver `design.md` para detalhas de arquitetura, fluxos e schema.