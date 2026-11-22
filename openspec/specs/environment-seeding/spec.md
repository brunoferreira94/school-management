# environment-seeding Specification

## Purpose

Semeamento do ambiente: garante que todo banco (novo ou já existente) tenha os
dados de plataforma mínimos — permissões, papéis, vínculos e catálogo de
conquistas — de forma idempotente e independente de dados fictícios. O modo demo
(`--seed-demo`) fica restrito a Development e cria apenas dados de demonstração.

## Requirements

### Requirement: Baseline de plataforma no startup

O sistema SHALL aplicar, em todo ambiente não-Testing, um baseline idempotente
de dados de plataforma **após** as migrations e **antes** do primeiro request:
permissões (`Permissions`), papéis (`Roles`), vínculos papel↔permissão
(`RolePermissions`) e o catálogo de conquistas v1.

#### Scenario: Banco novo sobe sem comando manual

- **WHEN** a API inicia contra um banco recém-criado
- **THEN** existem as permissões da plataforma (incluindo `achievements.read` e
  `achievements.manage`)
- **AND** existem os papéis `Director`, `Coordinator`, `Teacher` e `Parent`
- **AND** o `Director` possui `achievements.manage`
- **AND** `Coordinator` e `Teacher` possuem `achievements.read` (e `Teacher`
  **não** possui `achievements.manage`)
- **AND** o catálogo contém as 12 conquistas v1 com keys únicas

#### Scenario: Redeploy não duplica

- **WHEN** a API inicia novamente contra o mesmo banco
- **THEN** a contagem de permissões, papéis, vínculos e conquistas permanece a
  mesma (idempotente)
- **AND** nenhuma permissão/conquista existente é removida ou sobrescrita

#### Scenario: Baseline não cria dados fictícios

- **WHEN** o baseline roda em Produção ou Staging
- **THEN** nenhum tenant, usuário demo ou fórmula fictícia é criado
- **AND** apenas permissões, papéis, vínculos e o catálogo são garantidos

### Requirement: Falha do baseline interrompe o startup

O sistema SHALL tratar falha do baseline como erro de inicialização (fail-closed),
pois uma API sem permissões não é utilizável.

#### Scenario: Banco indisponível no baseline

- **WHEN** o baseline não consegue aplicar (banco fora/transação rejeitada)
- **THEN** o processo encerra com erro e log explícito (`Baseline seeding failed`)
- **AND** a API não começa a aceitar requisições

### Requirement: Modo demo restrito a Development

O sistema SHALL aceitar `--seed-demo` apenas em `Development` e, nesse caso,
aplicar baseline + dados fictícios e encerrar o processo (exit 0) antes de subir
os hosted services.

#### Scenario: Seed demo em Development

- **WHEN** a API inicia com `--seed-demo` em Development
- **THEN** o baseline é aplicado
- **AND** o tenant piloto, as contas demo (`diretor.demo`) e as fórmulas padrão
  são criados
- **AND** o processo encerra com código 0 (sem subir Kestrel/hosted services)

#### Scenario: Seed demo fora de Development

- **WHEN** a API inicia com `--seed-demo` em Staging ou Production
- **THEN** o processo falha com mensagem explícita
- **AND** nenhum dado fictício é criado
