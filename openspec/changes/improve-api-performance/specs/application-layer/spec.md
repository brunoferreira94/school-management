# Spec Delta — Capability `application-layer`

## ADDED Requirements

### Requirement: Paginação no banco para listagens

O sistema SHALL paginar listagens **no banco** (com `Skip`/`Take` e `CountAsync`),
nunca carregando a coleção inteira em memória para paginar depois. A resposta
SHALL manter o contrato atual (`items` + `total` + headers `X-Total-Count`,
`X-Page`, `X-Page-Size`, `X-Total-Pages`).

#### Scenario: Lista paginada sem carregar tudo

- **WHEN** um cliente pede `GET /api/students?page=2&pageSize=20`
- **THEN** a consulta executa no banco com `OFFSET/LIMIT` e um `COUNT` para o total
- **AND** a resposta traz no máximo 20 itens e o total correto
- **AND** nenhuma query carrega a tabela inteira em memória

#### Scenario: Busca com paginação

- **WHEN** o cliente informa `q` e `page`/`pageSize`
- **THEN** o filtro (nome/CPF) é aplicado no banco
- **AND** o total considera o filtro (não a tabela inteira)

### Requirement: Índices de suporte às consultas

O sistema SHALL ter índices nas colunas usadas para filtrar/ordenar em listagens
tenant-scoped (ex.: `Students.TenantId`), criados por migration idempotente.

#### Scenario: Índice de tenant em Students

- **WHEN** a migration `StudentsTenantIdIndex` é aplicada
- **THEN** existe o índice `IX_Students_TenantId`
- **AND** `ListByTenantAsync` usa o índice (sem seq scan)