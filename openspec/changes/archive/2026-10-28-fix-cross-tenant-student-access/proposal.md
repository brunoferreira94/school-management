## Why

O E2E adversarial de isolamento cross-tenant (`tenant-isolation.cy.ts`, 2026-10-28, API local real)
provou vazamentos na superfície de alunos: `Student` é entidade global (sem `TenantId`, sem query
filter) e as rotas `GET/PUT/DELETE /api/students/{cpf}` + `GET /api/students` consultam a tabela
global sem conferir vínculo com o tenant do chamador. Um diretor com `students.read`/`students.write`
acessou — e pode alterar/apagar — alunos de **outra escola** pelo CPF (LGPD/PII: nome, endereço,
contato do responsável).

Evidência executada (diretor do tenant A atacando dado do tenant B):
- `GET /api/students` → 200 listando os **7 alunos de todos os tenants** (deveria listar só os de A);
- `GET /api/students/91000001911` (aluno de B) → **200 com PII completa**;
- `PUT`/`DELETE` por `{cpf}` → globais (mesma família, mutação cross-tenant possível);
- Controles que JÁ estão corretos: `GET /api/subscriptions/tenants/{id}` → 403, `/account-summary` → 403,
  `ai-drafts/generate` com aluno de B → 400.

O design documentado (`api/docs/architecture/multitenancy.md:16`) prescreve o caminho de vínculo
canônico — `StudentPlan → SchoolUnit → TenantId` (`ListByTenantAsync`) — mas só a listagem de planos
o usa; o resto da superfície de alunos ignora o vínculo.

## What Changes

- **Leitura/escrita de aluno por CPF passam a exigir vínculo com o tenant do chamador**
  (`StudentPlan` com `SchoolUnit.TenantId == tenant do token`) → sem vínculo = 404 (não 403,
  para não vazar existência).
- **A listagem `GET /api/students` passa a usar o caminho de vínculo canônico**
  (`ListByTenantAsync`) em vez do `GetAll()` global — traz também OFERTAS de tenant (a página
  de alunos deixa de listar outras escolas).
- `Update`/`Delete` por CPF resolvem o aluno **via vínculo** antes de escrever (404 cross-tenant;
  404 também para aluno sem vínculo, consistente com a listagem atual).
- Junções famílias relacionadas (ex. `GET /api/students/{cpf}/plans`) permanecem como estão
  (already-safe por query filter de `StudentPlan`).
- **BREAKING (comportamental)**: alunos *só em turmas* (sem plano) deixam de ser visíveis por CPF —
  alinhado ao comportamento já documentado da listagem por tenant; registrado em decisões.

## Impact

- Affected specs: `security` (requirement novo de isolamento da superfície de alunos).
- Affected code: `People/StudentsController.cs` (rota `{cpf}` list/get/put/delete),
  `Application/Students/**` (handler/queries), `Application/Students/Services/StudentService.cs`,
  `Infrastructure/StudentRepository.cs`.
- Affected tests: `tests/SchoolManagement.Tests/Integration/**` (casos cross-tenant de isolamento),
  `cypress/e2e/tenant-isolation.cy.ts` (expectativas de 404substituindo os monitores "known-issue").
- Riscos portais: fluxos de responsável usam rotas de portal próprias — fora do escopo.
