# refactor-split-academic-context — Design

## Context

O `SchoolContext` é o único `DbContext` do sistema e concentra ~60 entidades. `BaseRepository<T>` (`SchoolManagement.Infrastructure/BaseRepository.cs:9`) recebe `SchoolContext` no construtor e opera via `_context.Set<T>()`. `UnitOfWork` (`UnitOfWork.cs:12`) também guarda um `SchoolContext` e instancia 9 repositórios lazy a partir dele. O grafo de conhecimento do repo (graphify, 10.407 nós / 661 comunidades) confirma: `SchoolContext` é o hub de maior betweenness (0.191) e `SchoolManagement.Domain` o namespace de maior grau (729).

A feature de horário automático (`timetabling`) vive no mesmo contexto. Cada nova coluna/migração de timetable força um `dotnet ef migrations add` sobre o modelo completo, e a migration resultante mexe no snapshot de tudo.

## Goals / Non-Goals

- Goals:
  - Isolar as entidades de timetable/academic em `AcademicContext`.
  - Permitir migrações de timetable isoladas (assembly próprio).
  - Manter `UnitOfWork`/`BaseRepository` funcionando sem reescrever repositórios.
  - Não quebrar o banco existente (mesmo DB, mesmo schema de tabelas).
- Non-Goals:
  - Não dividir billing/people/tenancy nesta change (são changes futuras, mesma técnica).
  - Não mudar a connection string nem o provedor de banco.
  - Não alterar a API pública de timetable/teacher-availability.

## Decisions

- **Mesmo banco, schema atual, assembly de migração separado.** `AcademicContext` é registrado com a mesma connection string do `SchoolContext`, mas aponta para um migration assembly dedicado. Assim as tabelas acadêmicas ficam no mesmo banco físico, sem `ALTER`/movimentação de dados, e as migrações de timetable deixam de tocar o snapshot do `SchoolContext`.
- **Entidades movidas (comprovadas no `SchoolContext.cs`):**
  `ClassSchedule` (L70), `TimetableTemplate` (L71), `TimetableTemplateEntry` (L72), `Timetable` (L75), `TeacherAvailability` (L120, com `HasQueryFilter` tenant L150 e config Fluent L695), `Classroom` (L59), `ClassGroup` (L68), `Module` (L108), `LessonPlan` (L54), `StudentClass` (L69). `TimeSlot`/`TeacherAssignment` (se existirem) entram no mesmo pacote.
- **`UnitOfWork` multi-contexto:** recebe `SchoolContext` + `AcademicContext`; os repositórios `AcademicYears`, `ClassGroups`, `Courses`, `LessonPlans`, `StudentClasses` e o novo agregado de timetable passam a usar `AcademicContext`. O `SaveChangesAsync`/transação do UoW decide a estratégia: por enquanto chama `SaveChangesAsync` em ambos (ou apenas no contexto dono da operação). Decisão de transação distribuída fica para a task 3.3.
- **Query filter de tenant:** recriado no `AcademicContext` (`_tenantFilterEnabled` + `_tenantId`), idêntico ao do `SchoolContext`, para manter o isolation por tenant nas entidades movidas.

## Risks / Trade-offs

- Risco: migração inicial do `AcademicContext` pode gerar `Up`/`Down` vazios (snapshot idêntico ao atual) — é o comportamento esperado, não um erro.
- Risco: repositórios que hoje recebem `SchoolContext` e tocam entidades movidas precisam receber `AcademicContext`. Mitigação: mapear todos os `new XRepository(_context)` no `UnitOfWork` e injeções diretas (task 2.2).
- Trade-off: dois contextos sobre o mesmo DB significa que uma transação que cruza academic + people não é atômica via `IDbContextTransaction` simples. Mitigação documentada em Non-Goals de transação distribuída; por ora as operações de timetable são autocontidas no `AcademicContext`.

## Migration Plan

1. Criar `AcademicContext` com as entidades academic + config Fluent + tenant filter.
2. Gerar migration inicial do `AcademicContext` (snapshot = estado atual das tabelas academic). `Up`/`Down` vazios intencionalmente.
3. Registrar `AcademicContext` no DI com a mesma connection string + migration assembly dedicado.
4. Redirecionar repositórios academic no `UnitOfWork` para `AcademicContext`.
5. Remover os DbSets/academic do `SchoolContext` e daí sua config Fluent.
6. Testes: `UnitOfWorkIntegrationTests` e `CustomWebApplicationFactory` devem instanciar ambos os contextos; suíte de timetable deve passar sem tocar `SchoolContext`.
