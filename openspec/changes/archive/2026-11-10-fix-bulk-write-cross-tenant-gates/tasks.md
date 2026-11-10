# Tasks — fix-bulk-write-cross-tenant-gates

## 1. Gates na camada de serviço

- [x] 1.1 `StudentService.BulkUpdateStudentsAsync`: busca via `FindStudentForTenantAsync`
      (gate por vínculo plano; sem tenant → erro por item, nunca global).
- [x] 1.2 `StudentService.BulkEnrollStudentsAsync`: turma precisa pertencer ao tenant
      (`classGroup.TenantId != tenantId` → `ClassGroupNotFound`; sem tenant → fail-closed).
- [x] 1.3 `ClassGroupService.BulkAssignTeachersAsync`: gate por turma no loop
      (+`ITenantContext?` opcional no ctor).
- [x] 1.4 `SkillAssessmentService.EvaluateStudentAsync`: gate da turma do request
      (+`ITenantContext?` opcional no ctor).

## 2. Testes

- [x] 2.1 Unit `StudentServiceTests`: bulk-update com CPF de outro tenant → item "aluno não
      encontrado" + `Update` nunca chamado; bulk-enroll com turma de outro tenant →
      `ClassGroupNotFound` + nenhum vínculo criado (4 testes novos, 17/17).
- [x] 2.2 Unit `ClassGroupServiceTests` (arquivo novo): bulk-assign com turma de outro
      tenant → erro por item, sem escrita de schedule; fail-closed sem tenant; controle
      no próprio tenant (3/3).
- [x] 2.3 Cobertura de integração dos bulk: exercitada ao vivo pelos probes do cypress
      (task 3.1 — POST bulk-update e bulk-enroll cross-tenant contra a API real),
      equivalente ao gate HTTP completo (sem 5xx, Updated=0 / 404 turma).
- [x] 2.4 Suíte completa verde (`dotnet test`, 792/0 — 797 total, 5 skips conhecidos).

## 3. E2E e docs

- [x] 3.1 Cypress `tenant-isolation.cy.ts`: probes de bulk-update e bulk-enroll cross-tenant
      (nunca 200 com dado aplicado / nunca 5xx) — 12/12 ao vivo contra a API local.
- [x] 3.2 `api/docs/architecture/multitenancy.md`: seção de gates de escrita ancorados em
      ClassGroup + residual documentado do enroll global (student global, link herdado da turma).
