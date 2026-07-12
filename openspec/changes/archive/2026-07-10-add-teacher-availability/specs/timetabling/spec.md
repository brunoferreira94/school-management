# timetabling Specification

## Purpose

Gerar horários escolares e validar restrições essenciais de alocação, incluindo disponibilidade de professores.

## ADDED Requirements

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

The system SHALL use registered teacher availability when automatically creating timetables.

#### Scenario: Accept available teacher slot

- **GIVEN** a teacher has Monday 08:00-12:00 availability
- **WHEN** the scheduler tries to assign that teacher to Monday 09:00-10:00
- **THEN** the assignment is accepted because the requested slot is fully contained in the availability window

#### Scenario: Reject unavailable teacher slot

- **GIVEN** a teacher has Monday 08:00-12:00 availability
- **WHEN** the scheduler tries to assign that teacher to Monday 13:00-14:00
- **THEN** the assignment is rejected because the requested slot is outside the availability window

### Requirement: List Teacher Availability

The system SHALL expose teacher availability through API and UI so staff can review and edit the constraints used by timetable generation.

#### Scenario: Review availability list

- **GIVEN** a teacher has saved availability windows
- **WHEN** staff opens the teacher availability list
- **THEN** the system shows each weekday, start time, end time, and deletion/update actions
