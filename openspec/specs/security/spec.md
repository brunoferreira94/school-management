# security Specification

## Purpose
TBD - created by archiving change add-owner-client-management-dashboard. Update Purpose after archive.

## Requirements

### Requirement: Owner Access Control

O sistema MUST restringir o acesso ao dashboard e às ferramentas de gestão de clientes ao usuário com perfil Owner.

#### Scenario: Usuário sem Owner acessa dashboard

- **WHEN** um usuário sem perfil Owner tenta acessar `/owner/dashboard`
- **THEN** o sistema bloqueia o acesso e exibe erro de permissão

#### Scenario: Owner acessa dashboard

- **WHEN** um usuário Owner acessa `/owner/dashboard`
- **THEN** o sistema exibe o dashboard sem erro de permissão

### Requirement: Audit Log

O sistema MUST registrar ações sensíveis executadas pelo Owner em clientes/tenants e relatórios cross-tenant.

#### Scenario: Atualizar status de tenant

- **WHEN** o Owner altera o status de um tenant
- **THEN** o sistema registra quem executou, quando, o tenant afetado e o valor anterior/novo

#### Scenario: Exportar relatório cross-tenant

- **WHEN** o Owner exporta um relatório com dados de múltiplos tenants
- **THEN** o sistema registra auditoria da exportação

### Requirement: Isolamento cross-tenant da superfície de alunos

O sistema SHALL restringir as operações de aluno por CPF (leitura, atualização, deleção e listagem
em `/api/students`) ao escopo do tenant do chamador, resolvendo o vínculo canônico
`StudentPlan → SchoolUnit → TenantId`; na ausência de vínculo o recurso SHALL responder 404.

#### Scenario: Diretor de outra escola não lê aluno por CPF

- **WHEN** um usuário autenticado do tenant A solicita `GET /api/students/{cpf}` de um aluno vinculado
  apenas ao tenant B
- **THEN** a API responde 404 e não retorna nenhum dado pessoal do aluno de B

#### Scenario: Diretor lê o próprio aluno

- **WHEN** um usuário autenticado do tenant A solicita `GET /api/students/{cpf}` de um aluno vinculado
  (via plano) a uma unidade do tenant A
- **THEN** a API responde 200 com os dados do aluno

#### Scenario: Listagem de alunos é escopada por tenant

- **WHEN** um usuário autenticado do tenant A lista dois alunos em `GET /api/students`
- **THEN** a resposta contém apenas alunos com vínculo (plano) a unidades do tenant A

#### Scenario: Escrita cross-tenant é bloqueada

- **WHEN** um usuário do tenant A envia `PUT` ou `DELETE` em `/api/students/{cpf}` de um aluno do tenant B
- **THEN** a API responde 404 e os dados de B permanecem inalterados
