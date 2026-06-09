<!-- markdownlint-disable MD041 -->

## ADDED Requirements

### Requirement: Course duplication selection

The system SHALL allow administrators to select an existing course as a template and configure duplication options for curriculum content, assessments, workloads, and pricing.

#### Scenario: Duplicate without assessments

- **GIVEN** the administrator chooses an existing course
- **WHEN** they unselect the "Assessments" option before confirming
- **THEN** the new course is created with curriculum and workload data but without assessment templates

### Requirement: Relationship preservation

The system SHALL copy linked entities (modules, disciplines, prerequisites) while ensuring new identifiers are generated and relationships remain valid in the duplicated course.

#### Scenario: Preserve module links

- **GIVEN** the source course contains modules referencing prerequisites
- **WHEN** the course is duplicated
- **THEN** the resulting course maintains equivalent module relationships using the new identifiers

### Requirement: Conflict handling

The system SHALL detect naming collisions or code conflicts in the destination context and SHALL prompt the administrator to adjust the course code or title before finalizing duplication.

#### Scenario: Prevent duplicate code

- **GIVEN** the destination already contains a course with code `MATH101`
- **WHEN** the duplication would create another `MATH101`
- **THEN** the system blocks the action until the administrator provides a unique course code

### Requirement: Version history

The system SHALL keep a record of course duplications, capturing source course, user, timestamp, and selected options, and SHALL expose this information in the course history view.

#### Scenario: Inspect duplication history

- **GIVEN** a course was duplicated last week
- **WHEN** an administrator opens the course history
- **THEN** they see an entry referencing the original course, date, and which components were included in the copy
