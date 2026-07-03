## ADDED Requirements

### Requirement: Tenant Management

O sistema MUST permitir que o usuário Owner gerencie clientes/tenants de forma centralizada.

#### Scenario: Listar tenants

- **WHEN** o Owner acessa a tela de clientes
- **THEN** o sistema exibe uma lista paginada de tenants com nome, slug, status, plano, assinatura, uso e últimas atualizações

#### Scenario: Buscar tenant por nome ou slug

- **WHEN** o Owner informa um termo de busca
- **THEN** a lista é filtrada por nome ou slug correspondente

#### Scenario: Filtrar por status

- **WHEN** o Owner seleciona um status de tenant
- **THEN** a lista exibe apenas tenants naquele status

## ADDED Requirements

### Requirement: Tenant Detail

O sistema MUST apresentar uma tela de detalhe para cada tenant com informações relevantes para gestão do cliente.

#### Scenario: Abrir detalhe do tenant

- **WHEN** o Owner clica em um tenant da lista
- **THEN** o sistema exibe detalhes de assinatura, uso, unidades, alunos, staff, eventos recentes e alertas

#### Scenario: Ver uso atualizado

- **WHEN** o Owner abre o detalhe do tenant
- **THEN** o sistema mostra uso atual de alunos, staff, unidades e armazenamento em relação aos limites do plano

## ADDED Requirements

### Requirement: Tenant Actions

O sistema MUST oferecer ações administrativas para o Owner, com confirmação e auditoria.

#### Scenario: Atualizar status do tenant

- **WHEN** o Owner altera o status de um tenant
- **THEN** o sistema persiste a mudança e registra auditoria

#### Scenario: Atualizar plano do tenant

- **WHEN** o Owner altera o plano de assinatura de um tenant
- **THEN** o sistema atualiza o plano e recalcula limites e alertas

#### Scenario: Adicionar observação ao tenant

- **WHEN** o Owner adiciona uma observação ao tenant
- **THEN** o sistema salva a observação e a exibe na tela de detalhe
