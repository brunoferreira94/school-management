# timetabling Specification (delta — refactor-split-academic-context)

## ADDED Requirements

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

## MODIFIED Requirements

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
