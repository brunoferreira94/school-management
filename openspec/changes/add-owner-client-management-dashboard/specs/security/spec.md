## ADDED Requirements

### Requirement: Owner Access Control

O sistema MUST restringir o acesso ao dashboard e às ferramentas de gestão de clientes ao usuário com perfil Owner.

#### Scenario: Usuário sem Owner acessa dashboard

- **WHEN** um usuário sem perfil Owner tenta acessar `/owner/dashboard`
- **THEN** o sistema bloqueia o acesso e exibe erro de permissão

#### Scenario: Owner acessa dashboard

- **WHEN** um usuário Owner acessa `/owner/dashboard`
- **THEN** o sistema exibe o dashboard sem erro de permissão

## ADDED Requirements

### Requirement: Audit Log

O sistema MUST registrar ações sensíveis executadas pelo Owner em clientes/tenants e relatórios cross-tenant.

#### Scenario: Atualizar status de tenant

- **WHEN** o Owner altera o status de um tenant
- **THEN** o sistema registra quem executou, quando, o tenant afetado e o valor anterior/novo

#### Scenario: Exportar relatório cross-tenant

- **WHEN** o Owner exporta um relatório com dados de múltiplos tenants
- **THEN** o sistema registra auditoria da exportação
