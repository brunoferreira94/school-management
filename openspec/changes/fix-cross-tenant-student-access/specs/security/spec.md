## ADDED Requirements

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
