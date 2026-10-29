# Tasks — fix-cross-tenant-student-access

## 1. Backend — gate por vínculo de tenant na superfície de alunos

- [x] 1.1 `StudentRepository`: método `GetByCpfForTenantAsync(string cpf, Guid tenantId)` — resolve o
      aluno via vínculo canônico (`StudentPlan → SchoolUnit → TenantId`), `AsNoTracking`.
- [x] 1.2 `IStudentService` + `StudentService`: variantes tenant-aware `GetStudentByCpfForTenantAsync`
      e `ListStudentsForTenantAsync` (resolvem o tenant via `ITenantContext` já injetado no service;
      sem tenant resolvido → `null`/lista vazia — nunca caminho global). O método global
      `GetStudentByCpfAsync`/`GetStudentsAsync` permanecem para usos internos não-expostos.
- [x] 1.3 `GetStudentByCpfQuery` handler: trocado para a variante tenant-aware.
- [x] 1.4 Listagem: `GetStudentsQuery` handler usa `ListStudentsForTenantAsync()` →
      `ListByTenantAsync(tenantId)` (o controller já pagina).
- [x] 1.5 `PUT /{cpf}` e `DELETE /{cpf}`: gate no service — `UpdateStudentAsync`/`DeleteStudentAsync`
      exigem vínculo antes de gravar e retornam `Result.Fail(…, ErrorCode.NotFound)`; o controller
      mapeia para 404 (antes ignorava o `Result` e sempre respondia 204).
- [x] 1.6 Migration não é necessária (só query/gate; sem mudança de esquema).

## 2. Testes (ciclo de regressão da correção)

- [x] 2.1 Integração: dois tenants na mesma factory — diretor de A NÃO lê (404) o aluno de B por CPF;
      leitura própria segue 200 (`StudentTenantIsolationIntegrationTests`, seed próprio fora da
      conexão singleton + aceite de ToU para ambos os tenants).
- [x] 2.2 Integração: PUT/DELETE cross-tenant → 404 (integridade do dado de B preservada, verificada
      por leitura do próprio dono) + controle de PUT próprio → 204.
- [x] 2.3 Integração: `GET /api/students` de A não contém nenhum aluno de B (listagem escopada).
- [x] 2.4 Cypress: `tenant-isolation.cy.ts` — monitores "known-issue" elevados a assertivas (404 no
      cross-tenant + listagem de A sem o aluno de B + controle 200 no próprio): 8/8 verde live vs API
      local.
- [x] 2.5 Suíte completa verde antes de commitar (`dotnet test` — integração Testcontainers):
      **781 aprovados, 0 falhas, 5 skips (786 total)**.

## 3. Documentação

- [x] 3.1 Atualizar `api/docs/architecture/multitenancy.md` seções de superfícies globais com o gate
      por vínculo (nota do 404 e do comportamento de alunos só-em-turma).
