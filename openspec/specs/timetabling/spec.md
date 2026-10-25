# timetabling Specification

## Purpose
Esta capacidade leva a disponibilidade dos professores em conta no processo de montagem de horários (timetabling). O staff autorizado registra janelas de disponibilidade semanais por professor, dia da semana, hora inicial e final, com rejeição de sobreposições; o gerador automático de grade e os dados do domínio (histórico de horários, turmas, salas, módulos) residem no `AcademicContext`, escopados por tenant e com assembly de migrations próprio.

## Requirements

### Requirement: Teacher Availability Windows

The system SHALL allow authorized staff to register weekly teacher availability windows per tenant, staff member, weekday, start time, and end time.

#### Scenario: Register teacher availability

- **GIVEN** an authorized staff member opens the teacher availability editor
- **WHEN** they select a teacher, weekday, start time, and end time
- **THEN** the system saves the availability window for that tenant and shows it in the availability list

#### Scenario: Reject overlapping teacher availability

- **GIVEN** a teacher already has Monday 08:00-12:00 availability
- **WHEN** staff tries to register Monday 10:00-14:00
- **THEN** the system rejects the request and explains that the availability overlaps an existing window

### Requirement: Scheduler Uses Teacher Availability

The system SHALL use registered teacher availability when automatically creating timetables, reading availability from the `AcademicContext`.

#### Scenario: Accept available teacher slot

- **GIVEN** a teacher has Monday 08:00-12:00 availability stored in `AcademicContext`
- **WHEN** the scheduler tries to assign that teacher to Monday 09:00-10:00
- **THEN** the assignment is accepted because the requested slot is fully contained in the availability window

#### Scenario: Reject unavailable teacher slot

- **GIVEN** a teacher has Monday 08:00-12:00 availability stored in `AcademicContext`
- **WHEN** the scheduler tries to assign that teacher to Monday 13:00-14:00
- **THEN** the assignment is rejected because the requested slot is outside the availability window

### Requirement: List Teacher Availability

The system SHALL expose teacher availability through API and UI so staff can review and edit the constraints used by timetable generation.

#### Scenario: Review availability list

- **GIVEN** a teacher has saved availability windows
- **WHEN** staff opens the teacher availability list
- **THEN** the system shows each weekday, start time, end time, and deletion/update actions

### Requirement: Academic Data Isolation

The timetabling data (teacher availability, timetables, timetable templates, class schedules, classrooms, class groups, modules, lesson plans, student classes) SHALL be persisted in a dedicated `AcademicContext` that shares the same physical database and table schema as the primary `SchoolContext`, but owns an independent EF Core migration assembly so that schema changes for timetabling do not modify the migration snapshot of unrelated domains.

#### Scenario: Timetable migration does not touch other domains

- **GIVEN** an `AcademicContext` registered with the same connection string as `SchoolContext`
- **WHEN** a new migration is added for the timetabling domain
- **THEN** the migration is produced by the `AcademicContext` migration assembly and does not alter the `SchoolContext` migration snapshot

#### Scenario: Tenant isolation preserved after split

- **GIVEN** teacher availability windows are tenant-scoped in `AcademicContext`
- **WHEN** a query filters by tenant
- **THEN** the `AcademicContext` applies the same tenant query filter as the previous `SchoolContext` configuration

### Requirement: Timetable conflict detection

The system SHALL automatically detect timetable conflicts (the same teacher, classroom, or class group assigned to overlapping slots) when a timetable is created or edited, and SHALL present them as a navigable validation panel instead of requiring manual inspection.

#### Scenario: Overlapping teacher is flagged

- **GIVEN** a teacher is assigned to two class groups in the same time slot
- **WHEN** the timetable is saved or validated
- **THEN** the conflict is detected and listed in the validation panel with both conflicting entries highlighted

### Requirement: One-click conflict resolution suggestions

For each detected conflict, the system SHALL suggest alternative free slots that keep the teacher, classroom, and class group available, applicable in one click.

#### Scenario: Applying a suggestion resolves the conflict

- **GIVEN** a conflict with at least one free alternative slot
- **WHEN** the coordinator applies the suggested slot
- **THEN** the entry moves, the conflict disappears from the panel, and no new conflict is created
