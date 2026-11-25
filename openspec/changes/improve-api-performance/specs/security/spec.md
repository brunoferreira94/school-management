# Spec Delta — Capability `security`

## ADDED Requirements

### Requirement: Orçamento de consultas no login

O login SHALL resolver usuário, papéis/permissões e unidade escolar em **no máximo
3 consultas** (usuário; claims agregadas em 1 join; unidade), sem N+1. Auditoria,
refresh token e atualização de `LastLoginAt` permanecem como escritas.

#### Scenario: Login resolve claims sem N+1

- **WHEN** um usuário faz login
- **THEN** o provedor de claims executa no máximo 3 leituras (usuário, claims, unidade)
- **AND** as permissões retornadas são idênticas às do modelo atual (por papel)

#### Scenario: Login tolerante a falha de telemetria

- **WHEN** a auditoria de login falha
- **THEN** o login continua (a telemetria não derruba a autenticação)

### Requirement: Auditoria assíncrona e não bloqueante

O sistema SHALL persistir a trilha de auditoria de requisições mutantes em um
canal assíncrono (background writer), de modo que a requisição **não** espere o
`SaveChanges` do log. Falhas do writer SHALL ser logadas e nunca derrubar a
operação de negócio (fail-open).

#### Scenario: Mutação não espera a auditoria

- **WHEN** uma mutação autenticada é processada
- **THEN** a requisição enfileira o evento de auditoria e responde sem aguardar o save
- **AND** o evento é persistido eventualmente (ordem preservada)

#### Scenario: Falha do writer de auditoria

- **WHEN** o writer não consegue persistir (banco fora)
- **THEN** a falha é logada
- **AND** a operação de negócio retorna sucesso