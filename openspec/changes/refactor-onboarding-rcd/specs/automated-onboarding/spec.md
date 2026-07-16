## MODIFIED Requirements

### Requirement: Guided onboarding wizard (REDUZIDO)

The system SHALL provide a simplified onboarding flow with only 3 critical steps: (1) Welcome modal with video + seed data option, (2) One-click seed application or CSV upload for first class group, (3) First real result visible before any further configuration.

#### Scenario: First-time admin sees welcome modal

- **GIVEN** a new administrator logs in for the first time
- **WHEN** they view the dashboard
- **THEN** the system displays a welcome modal with video and "Use standard school template" option

#### Scenario: Seed data applied automatically

- **GIVEN** the admin selects the standard template
- **WHEN** they confirm the seed
- **THEN** the system provisions sample class groups, calendar, and invites user to import real data

## ADDED Requirements

### Requirement: Welcome video onboarding

The system SHALL display a 30-second welcome video in a modal on first admin login, showing the product at a glance and pointing to the fastest value path, not as a tutorial.

#### Scenario: Watch welcome video and proceed

- **WHEN** the admin opens the welcome modal
- **THEN** they can watch the video and select either seed data or custom setup

### Requirement: Activation checklist with progress effect

The system SHALL show an activation checklist starting at 20% progress, tracking: school registered (20%), first class created (40%), 3 teachers invited (60%), first grade book viewed (80%), setup complete (100%).

#### Scenario: Checklist shows progress

- **GIVEN** the admin has created their first class
- **WHEN** they view the checklist
- **THEN** the progress bar shows 40% complete with the next step highlighted

### Requirement: Celebration animation at aha moment

The system SHALL display an animated graph/confetti when the admin completes their first class group, creating an emotional memory tied to achievement.

#### Scenario: Celebrate first class creation

- **GIVEN** the admin has finished importing their first class group
- **WHEN** the import completes successfully
- **THEN** the system shows an animated rising graph with "First class ready!" message