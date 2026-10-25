## ADDED Requirements

### Requirement: Pedagogical event automation catalog

The notification rule engine SHALL support pedagogical triggers — recurring absence (configurable threshold), recorded occurrence, grade below average, and report-card publication — firing automatically from domain events without human dispatch.

#### Scenario: Recurring absence triggers one notification

- **GIVEN** a student whose absences reach the configured threshold
- **WHEN** the next absence is recorded
- **THEN** the guardian receives exactly one notification, not one per absence

### Requirement: Anti-noise daily limit with digest

The system SHALL enforce a configurable maximum number of notifications per guardian per day, grouping additional triggers for the same student into a single daily digest.

#### Scenario: Daily limit collapses into a digest

- **GIVEN** a guardian already received the daily maximum and two more triggers fire for the same student
- **WHEN** the engine processes them
- **THEN** both are delivered as one consolidated digest instead of separate notifications
