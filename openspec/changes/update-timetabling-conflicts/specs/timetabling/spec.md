## ADDED Requirements

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
