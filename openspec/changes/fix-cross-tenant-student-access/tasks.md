# Tasks — fix-cross-tenant-student-access

## 1. Backend — gate por vínculo de tenant na superfície de alunos

- [ ] 1.1 `StudentRepository`: método `GetByCpfForTenantAsync(string cpf, Guid tenantId)` — resolve o
      aluno via vínculo canônico (`StudentPlan → SchoolUnit → TenantId`), `AsNoTracking`.
- [ ] 1.2 `IStudentService` + `StudentService.GetStudentByCpfAsync`: adicionar variante tenant-aware
      usando `ITenantProvider` (o handler atual `GetStudentByCpfAsync` global permanece para
      usos internos explicitamente não-expostos, vide design).
- [ ] 1.3 `GetStudentByCpfQuery` handler: trocar para a variante tenant-aware.
- [ ] 1.4 Sua listagem: `GetStudentsQuery` handler usa `ListByTenantAsync(tenantId)` (o controller já pagina).
- [ ] 1.5 `PUT /{cpf}` e `DELETE /{cpf}`: resolução via vínculo tenancy antes de gravar (404 sem vínculo).
- [ ] 1.6 Migration não é necessária (só query/gate; sem mudança de esquema).

## 2. Testes (ciclo de regressão da correção)

- [ ] 2.1 Integração: dois tenants na mesma factory — diretor de A NÃO lê (404) o aluno de B por CPF;
      leitura própria segue 200.
- [ ] 2.2 Integração: PUT/DELETE cross-tenant → 404 (integridade do dado de B preservada).
- [ ] 2.3 Integração: `GET /api/students` de A não contém nenhum aluno de B (listagem escopada).
- [ ] 2.4 Cypress: `tenant-isolation.cy.ts` — elevar os monitores "known-issue" para assertivas de 404
      (e listagem sem aluno de B).
- [ ] 2.5 Suíte completa verde antes de commitar (`dotnet test` — integração Testcontainers).

## 3. Documentação

- [ ] 3.1 Atualizar `api/docs/architecture/multitenancy.md` seções de superfícies globais com o gate
      por vínculo (nota do 404 e do comportamento de alunos só-em-turma).
