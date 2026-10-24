# automated-onboarding Specification

## Purpose
Esta capacidade automatiza a configuração inicial de novas escolas na plataforma. Provê um wizard guiado que coleta dados da organização, preferências acadêmicas e módulos a habilitar, além de importação em massa via CSV (alunos, responsáveis, equipe, horários, cursos e turmas) com validação, prévia dos registros, bloqueio de lotes inválidos e relatório de erros por linha.

## Requirements

### Requirement: Guided onboarding wizard

The system SHALL provide a simplified onboarding flow with only 3 critical steps: (1) Welcome modal with video + seed data option, (2) One-click seed application or CSV upload for first class group, (3) First real result visible before any further configuration.

#### Scenario: First-time admin sees welcome modal

- **GIVEN** a new administrator logs in for the first time
- **WHEN** they view the dashboard
- **THEN** the system displays a welcome modal with video and "Use standard school template" option

#### Scenario: Seed data applied automatically

- **GIVEN** the admin selects the standard template
- **WHEN** they confirm the seed
- **THEN** the system provisions sample class groups, calendar, and invites user to import real data

#### Scenario: Complete onboarding steps

- **GIVEN** a new administrator logs in for the first time
- **WHEN** they complete each onboarding step and submit the final confirmation
- **THEN** the tenant is provisioned with the chosen modules enabled and the wizard marks the onboarding as completed

### Requirement: Bulk import with validation

The system SHALL support CSV imports for students, guardians, staff, class schedules, courses, and class groups during onboarding. The system SHALL validate the payload before persisting, provide a preview of valid records, block invalid batches that would create inconsistent data, and produce a downloadable error report referencing row numbers and validation messages.

#### Scenario: Import courses and class groups successfully

- **GIVEN** an administrator opens the setup wizard import step
- **WHEN** they upload a CSV containing valid course and class group rows
- **THEN** the system displays a preview with record counts and validation status
- **AND** after confirmation the system creates the courses and class groups as part of the onboarding setup

#### Scenario: Import with validation errors

- **GIVEN** the administrator uploads a CSV where one class group has capacity below the allowed range
- **WHEN** the import validation runs
- **THEN** the system blocks the import, highlights the affected row, and generates an error report with the row number and validation message

### Requirement: Template library

The system SHALL provide reusable templates for calendars, academic plans, and grading schemes that can be previewed and applied during onboarding or later through the configuration center.

#### Scenario: Apply calendar template

- **GIVEN** the administrator selects the "Standard 200-day Calendar" template
- **WHEN** they apply it to the new school
- **THEN** the system provisions the calendar with predefined terms, holidays, and school days

### Requirement: Automated post-setup tasks

The system SHALL enqueue automated tasks after onboarding completion to create default classgroups, assign welcome communications, and invite staff, and SHALL expose a status dashboard for these background jobs.

#### Scenario: Monitor post-setup jobs

- **GIVEN** the onboarding has been submitted
- **WHEN** the administrator opens the onboarding status page
- **THEN** they can see the progress of background jobs (e.g., classgroup provisioning, welcome emails) with success or failure indicators

### Requirement: Setup wizard CPF/CNPJ inline validation

The system SHALL validate CPF/CNPJ values inline during the school unit data step when a document field is present, and SHALL show a clear message before the administrator can proceed.

#### Scenario: Valid CPF/CNPJ accepted

- **GIVEN** the administrator enters a valid CPF or CNPJ in the school unit document field
- **WHEN** the field loses focus or the step is submitted
- **THEN** the system marks the value as valid and allows the administrator to continue

#### Scenario: Invalid CPF/CNPJ blocked

- **GIVEN** the administrator enters an invalid CPF/CNPJ
- **WHEN** the setup wizard step is submitted
- **THEN** the system prevents navigation to the next step and displays an inline validation message

### Requirement: Setup wizard explanatory tooltips

The system SHALL provide contextual tooltips for setup wizard fields that commonly cause confusion, including school unit document, classroom code, course name, class group name, class group capacity, and batch import controls.

#### Scenario: View tooltip for classroom code

- **GIVEN** the administrator is on the classroom step
- **WHEN** they open the tooltip for classroom code
- **THEN** the system explains examples such as SIGE code, room label, or lab identifier

#### Scenario: View tooltip for class group capacity

- **GIVEN** the administrator is editing a class group
- **WHEN** they open the capacity tooltip
- **THEN** the system explains the accepted capacity range and why it matters for scheduling

### Requirement: Class group capacity bounds

The system SHALL validate class group capacity during setup wizard entry and import, accepting values from 10 to 40 students and rejecting values outside that range with a clear message.

#### Scenario: Valid capacity accepted

- **GIVEN** the administrator enters class group capacity `30`
- **WHEN** the class group form is validated
- **THEN** the system accepts the value and allows submission

#### Scenario: Capacity below minimum rejected

- **GIVEN** the administrator enters class group capacity `5`
- **WHEN** the class group form is validated
- **THEN** the system rejects the value and explains that capacity must be at least 10 students

### Requirement: Downloadable setup import template

The system SHALL provide a downloadable CSV template for setup wizard batch import, including the required columns, example values, and formatting notes for courses and class groups.

#### Scenario: Download import template

- **GIVEN** the administrator opens the setup wizard import step
- **WHEN** they select the template download action
- **THEN** the system downloads a CSV file with the expected columns and sample rows

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
