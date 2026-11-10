# Proposal: fix-bulk-write-cross-tenant-gates

## Why

A auditoria de superfícies bulk (follow-up do design de `fix-cross-tenant-student-access`)
encontrou **escritas cross-tenant** por falta de gate em superfícies que ancoram em
`ClassGroup` — que **não tem query filter por tenant no AcademicContext**
(`cg.SchoolUnitId != null` é filtro estrutural, não de tenancy):

1. `POST /api/students/bulk-update` — `BulkUpdateStudentsAsync` busca o aluno via
   `FindStudentAsync` (global, `GetByCpf`) e aplica `Update` — principal de B atualiza
   PII de aluno de A (mesma classe do bug corrigido no PUT singular).
2. `POST /api/students/bulk-enroll` — `BulkEnrollStudentsAsync` busca a turma global
   (`GetById`) — principal de B matricula alunos na turma de A (escrita estrutural
   cross-tenant).
3. `POST /api/classgroups/bulk-assign-teacher` — `BulkAssignTeachersAsync` busca cada
   turma global no loop — principal de B reescreve horários (staff) de turmas de A.
4. `POST /api/skills/evaluations[/bulk]` — `EvaluateStudentAsync` grava a avaliação com
   o `ClassGroupId` do request **sem verificar existência/membros/tenant da turma**.

## What Changes

- Gate de tenant na **camada de serviço** (padrão do gate de alunos: vínculo via
  `ITenantContext`, falha igual a "não encontrado", sem vazar existência):
  - bulk-update: busca do aluno via `GetByCpfForTenantAsync(cpf, tenantId)`.
  - bulk-enroll: turma precisa pertencer ao tenant do chamador.
  - bulk-assign-teacher: cada turma da lista precisa pertencer ao tenant do chamador.
  - skill-evaluate: turma do request precisa pertencer ao tenant do chamador.
- Residual documentado: **bulk-enroll** mantém busca global de STUDENT (Student é
  global por design; a tenancy do vínculo vem da turma — o import→enroll de aluno
  recém-importado sem plano continua funcionando; a leitura de dados cruza permanece
  bloqueada pelo gate de leitura).

**BREAKING**: nenhuma para chamadas legítimas (payloads com turmas do próprio tenant).

## Impact

- Specs: `security` (delta ADDED — escrevass em lote ancoradas em ClassGroup).
- Código: `StudentService` (2 métodos), `ClassGroupService` (+`ITenantContext` opcional),
  `SkillAssessmentService` (+`ITenantContext` opcional, em Infrastructure).
- Testes: unit (StudentService/ClassGroupService cross-tenant) + integração (bulk
  eliminar cross) + cypress (probes de bulk no spec de isolamento) + multitenancy.md.
