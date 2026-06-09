# classgroup-copy Specification

## Purpose
TBD - created by archiving change implement-copy-classgroups-screen. Update Purpose after archive.
## Requirements
### Requirement: Classgroup duplication UI

The system SHALL expose a UI action that lets authorized staff select a source classgroup, choose duplication options (schedule, teachers, capacity, assignments), and confirm creation of a new classgroup instance.

#### Scenario: Duplicate classgroup with schedule

- **GIVEN** a staff member selects classgroup "9A Morning"
- **WHEN** they choose to copy schedule and teachers
- **THEN** the system creates a new classgroup with identical schedule blocks and teacher assignments but with a unique identifier

### Requirement: Destination selection and naming

The system SHALL allow specifying the destination academic year, term, and optional suffix/prefix for the new classgroup code to avoid collisions.

#### Scenario: Customize new classgroup code

- **GIVEN** the staff chooses destination year 2026
- **WHEN** they set the suffix "-2026"
- **THEN** the resulting classgroup code appends "-2026" and respects uniqueness constraints

### Requirement: Conflict detection

The system SHALL detect conflicts such as overlapping room bookings or duplicate codes during duplication and SHALL present actionable warnings before persisting changes.

#### Scenario: Detect room conflict

- **GIVEN** the destination timetable already uses room A101 at Monday 08:00
- **WHEN** the duplication attempts to copy a block occupying the same slot
- **THEN** the system stops the operation and surfaces a conflict explaining the room overlap with options to adjust

### Requirement: Activity log

The system SHALL append an audit entry for each duplication detailing source classgroup, selected options, user, and timestamp, accessible through the activity log.

#### Scenario: Review duplication audit

- **GIVEN** a duplication completed earlier today
- **WHEN** an administrator checks the activity log
- **THEN** they see an entry describing the source classgroup, destination year, and the user who initiated the duplication

