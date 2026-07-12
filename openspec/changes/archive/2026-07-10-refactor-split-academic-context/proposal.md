# refactor-split-academic-context

## Why

O `SchoolContext` é um God Object: o grafo de conhecimento do repo mostra que ele conecta ~90 comunidades distintas (betweenness centrality 0.191) e todo `BaseRepository<T>` e `UnitOfWork` operam sobre a mesma instância `SchoolContext`. Isso significa que **qualquer migração de schema** — inclusive as da feature de horário automático (`TeacherAvailability`, `Timetable`, `TimetableTemplate`) — locka o modelo inteiro, tornando migrações lentas e arriscadas, e impede isolar testes de timetable.

A geração automática de horários (capability `timetabling`) precisa de um contexto de dados estável e isolado para evoluir sem arrastar billing/people. O split do `AcademicContext` destrava essa evolução.

## What Changes

- Criar `AcademicContext : DbContext` em `SchoolManagement.Infrastructure` contendo as entidades acadêmicas/timetable: `ClassSchedule`, `Timetable`, `TimetableTemplate`, `TimetableTemplateEntry`, `TeacherAvailability`, `Classroom`, `ClassGroup`, `Module`, `LessonPlan`, `StudentClass`, `TimeSlot`, `TeacherAssignment`.
- Mover a configuração de modelo (Fluent API + query filters de tenant) dessas entidades do `SchoolContext` para o `AcademicContext`.
- Registrar o `AcademicContext` no container de DI com a **mesma connection string** do `SchoolContext`, mas com **assembly de migração próprio** (`AcademicContext` recebe `[MigrationAssembly("SchoolManagement.Infrastructure.Academic")]` ou migration factory dedicada), mantendo o mesmo banco físico (schema atual, sem breaking change de dados).
- Tornar `UnitOfWork` capaz de receber múltiplos contextos: expor os repositórios acadêmicos a partir do `AcademicContext`, mantendo os demais no `SchoolContext`.
- `BaseRepository<T>` passa a aceitar o contexto por parâmetro (já faz hoje) — nenhuma mudança de assinatura necessária para repositórios existentes.

## Impact

- Affected specs: `timetabling` (isolamento de dados da feature de horário)
- Affected code:
  - `src/SchoolManagement.Infrastructure/SchoolContext.cs` (remoção dos DbSets/academic config)
  - `src/SchoolManagement.Infrastructure/AcademicContext.cs` (NOVO)
  - `src/SchoolManagement.Infrastructure/UnitOfWork.cs` (injeção do AcademicContext)
  - `src/SchoolManagement/Infrastructure/DependencyInjection/*` (registro do novo contexto)
  - Migrations: novo assembly de migração para `AcademicContext` (snapshot inicial a partir do modelo academic atual)
- Non-breaking: mesmo banco, mesmo schema de tabelas, mesma connection string. Rollout faseado por repositório.
