## ADDED Requirements

### Requirement: Segment-specific seed templates

The onboarding wizard SHALL offer segment-specific seed templates (early childhood, elementary, high school, language school, technical) whose structure — subjects, grade levels, and class-group model — matches the chosen segment, replacing the single all-purpose template.

#### Scenario: Language school template

- **GIVEN** a new school selects the "idiomas" segment in the wizard
- **WHEN** they apply the seed template
- **THEN** the created structure contains language levels (A1–C1) and subject names typical of a language school

#### Scenario: Default behavior preserved

- **GIVEN** a school does not choose a segment
- **WHEN** the standard seed is applied
- **THEN** the current default template behavior is preserved

#### Scenario: Segment preview before applying

- **GIVEN** the wizard shows available segments
- **WHEN** the school selects one
- **THEN** a preview of the structure to be created (subjects, years, class-group model) is displayed before confirmation
