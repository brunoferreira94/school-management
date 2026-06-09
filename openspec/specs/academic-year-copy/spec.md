# academic-year-copy Specification

## Purpose
TBD - created by archiving change implement-academic-year-copy. Update Purpose after archive.
## Requirements
### Requirement: Academic year duplication wizard

The system SHALL provide a guided flow that allows administrators to duplicate an existing academic year into a target academic year, including selecting the source year, the destination year, and reviewing a summary before execution.

#### Scenario: Launch copy flow

- **GIVEN** an administrator with `MANAGE_ACADEMIC_YEAR` permission
- **WHEN** they open the "Copy Academic Year" action and select a source and destination year
- **THEN** the wizard displays a confirmation step summarizing which items will be copied and requires explicit confirmation before starting the duplication

### Requirement: Selective copy options

The system SHALL allow administrators to choose which configuration blocks (courses, classgroups, schedules, plans, assessments) are included in the copy execution and SHALL persist these choices as part of the request.

#### Scenario: Choose partial copy

- **GIVEN** a source year with courses, classgroups, and plans
- **WHEN** the administrator unchecks "Assessments" and proceeds
- **THEN** the resulting copy job skips assessments while duplicating the selected entities

### Requirement: Dry-run with conflict report

The system SHALL support running the duplication in dry-run mode, producing a report that lists pending inserts, detected conflicts (e.g., overlapping schedules, duplicated identifiers), and required resolutions without mutating data.

#### Scenario: Dry-run highlights conflicts

- **GIVEN** an administrator running a dry-run into a destination year that already contains a classgroup with the same code
- **WHEN** the dry-run completes
- **THEN** the generated report lists the conflicting classgroup identifier and explains the resolution options

### Requirement: Idempotent execution with rollback

The system SHALL execute the copy operation within a transactional boundary, ensuring that either all selected components are copied successfully or the destination state is rolled back, and SHALL allow re-running the copy after conflicts are resolved without duplicating already copied entities.

#### Scenario: Transaction rollback on failure

- **GIVEN** the copy operation starts and fails while creating schedules due to a conflict
- **WHEN** the process aborts
- **THEN** no partial data from the failed copy remains in the destination year and the job status is marked as failed with references to the conflict report

