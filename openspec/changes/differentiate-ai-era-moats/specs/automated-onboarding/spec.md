## MODIFIED Requirements

### Requirement: Activation checklist as director path

The system SHALL present an activation checklist after onboarding that evolves from a static list into a repeatable "director path" — a sequence of micro-loops (grade entry → report card → announcement → payment) that the user internalizes through repetition. Each completed loop SHALL persist backend state (`LastGradeEntryAt`, `LastReportCardViewedAt`, `LastAnnouncementAt`, `LastPaymentAt` in `SetupProgress`) and SHALL drive the next suggested step from the backend, not a static list.

#### Scenario: Checklist suggests next step from backend state

- **GIVEN** a school completed onboarding and has `LastGradeEntryAt` set but `LastReportCardViewedAt` null
- **WHEN** the administrator opens the dashboard
- **THEN** the activation checklist shows "View report card" as the primary next step
- **AND** the suggestion is derived from `SetupProgress` backend state, not client-side logic

#### Scenario: Micro-loop completion celebrates and advances

- **GIVEN** the administrator views the report card
- **WHEN** the view is recorded
- **THEN** the system shows a 200ms confirmation micro-interaction
- **AND** the checklist advances to the next loop (announcement) as primary

## ADDED Requirements

### Requirement: Teacher invitation with magic link

The system SHALL allow the administrator to invite teachers via a signed magic-link (no password) from the activation checklist. The invitation SHALL be recorded in `SetupProgress.TeachersInvited` and SHALL mark `TeachersActivated` when the invited teacher accepts and becomes active in the tenant.

#### Scenario: Invite teacher from checklist

- **GIVEN** the administrator is on the activation checklist step "Invite 3 teachers"
- **WHEN** they enter a teacher email and click invite
- **THEN** the system generates a signed magic-link token (7-day expiry)
- **AND** records the invitation count in `SetupProgress.TeachersInvited`
- **AND** returns a shareable link

#### Scenario: Teacher accepts invite and becomes active

- **GIVEN** a teacher opens the magic-link `/invite/:token`
- **WHEN** they confirm their name and accept
- **THEN** the system creates/activates the teacher in the tenant
- **AND** increments `SetupProgress.TeachersActivated`
- **AND** the checklist shows the teacher as "active"

### Requirement: Today screen (attention-first dashboard)

The system SHALL provide a "today screen" as the default dashboard view showing exactly one primary action (the most urgent item: delinquency > absences > event). The legacy 5-widget grid SHALL remain available via a "view full dashboard" toggle but SHALL NOT compete for attention by default.

#### Scenario: Today screen shows single primary action

- **GIVEN** a school has 1 overdue payment, 2 absences today, and 1 upcoming event
- **WHEN** the administrator loads the dashboard
- **THEN** the today screen shows "1 overdue payment" as the primary action
- **AND** the 5-widget grid is hidden by default

#### Scenario: Toggle to full dashboard

- **GIVEN** the administrator is on the today screen
- **WHEN** they click "view full dashboard"
- **THEN** the 5-widget grid becomes visible
- **AND** the toggle state persists in localStorage

### Requirement: Gentle error recovery

The system SHALL present errors with a human tone and a recoverable action instead of raw error codes. A 404 SHALL return the user to a relevant route with suggestions.

#### Scenario: Duplicate classroom error recovers

- **GIVEN** the administrator creates a classroom that already exists
- **WHEN** the API returns a conflict
- **THEN** the UI shows "Ops, this classroom already exists — want to use the model classroom?" with a recovery button
- **AND** no raw "409 Conflict" is shown

#### Scenario: 404 returns user

- **GIVEN** the user navigates to a non-existent route
- **WHEN** the 404 renders
- **THEN** it shows suggested routes (dashboard, students, classrooms)
- **AND** a button to return to dashboard

### Requirement: Proprietary brand tokens

The system SHALL apply proprietary design tokens (ESCOLA+ color, 12px radius, confirmation shadow, brand typography) to RCD components (onboarding-welcome, activation-checklist, activation-celebration, empty-state) to signal visual authority and consistency distinct from default Material themes.

#### Scenario: RCD components use brand tokens

- **GIVEN** the onboarding welcome modal renders
- **WHEN** the user inspects the computed styles
- **THEN** the primary color matches the ESCOLA+ token (not Material default)
- **AND** the border-radius is 12px per token
