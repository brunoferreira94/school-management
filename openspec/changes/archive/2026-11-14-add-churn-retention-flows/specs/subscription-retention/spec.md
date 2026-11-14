## ADDED Requirements

### Requirement: Designed cancellation flow (win-back)

The system SHALL present a designed cancellation flow instead of a plain confirmation dialog, applying loss aversion, offering a retention alternative before termination, and collecting the cancellation reason via an open question.

#### Scenario: Show concrete loss before cancelling

- **GIVEN** an admin with an active subscription for a school with recorded students, classes, and usage history
- **WHEN** they start the cancellation flow
- **THEN** the system displays the concrete loss (e.g. "Você perderá acesso a 476 alunos, 18 turmas e 8 meses de histórico") before any confirmation

#### Scenario: Offer a retention alternative

- **GIVEN** an admin is in the cancellation flow
- **WHEN** the loss step is shown
- **THEN** the system offers at least one alternative to cancelling (pause for 30 days or one free month) before the final cancel action

#### Scenario: Collect cancellation reason with an open question

- **GIVEN** an admin proceeds past the alternative step
- **WHEN** they confirm cancellation
- **THEN** the system asks an open question ("O que faltou para você continuar?") and persists the free-text reason with a timestamp for later analysis

#### Scenario: Cancel remains accessible and honest

- **GIVEN** an admin wants to cancel
- **WHEN** they navigate the flow
- **THEN** the cancel action stays reachable at each step without deceptive obstruction

### Requirement: Account churn-risk health score

The system SHALL compute a per-account churn-risk health score from usage signals over 14- and 30-day windows and expose it read-only to the school owner.

#### Scenario: Flag an at-risk account

- **GIVEN** an account whose logins and key actions dropped below the configured threshold over the last 14 days
- **WHEN** the owner opens the management dashboard
- **THEN** the account is flagged as at-risk with the contributing signals shown

#### Scenario: Conservative thresholds avoid false alarms

- **GIVEN** an account with normal but low activity within expected bounds
- **WHEN** the health score is computed
- **THEN** the account is not flagged, respecting conservative thresholds

### Requirement: Usage-based expansion prompt

The system SHALL surface a non-blocking expansion prompt when an account approaches its plan limit, never interrupting the user's current task.

#### Scenario: Prompt near the plan limit

- **GIVEN** an account on a plan capped at 100 students that reaches 90% of the cap
- **WHEN** the admin views the students area
- **THEN** a contextual non-blocking banner suggests upgrading, and the user can continue their task without forced interruption

### Requirement: Recurring-event re-engagement anchor

The system SHALL trigger re-engagement communications anchored to recurring school-calendar events, with a fallback cadence when no calendar is configured.

#### Scenario: Re-engage at start of term

- **GIVEN** a school with a configured academic calendar and an at-risk account
- **WHEN** a recurring event occurs (start of term, enrollment window, or grade closing)
- **THEN** the system sends a re-engagement notification anchored to that event via the notifications module

#### Scenario: Fallback cadence without a calendar

- **GIVEN** a school with no configured calendar
- **WHEN** the re-engagement job runs
- **THEN** the system uses a simple fallback cadence instead of event anchoring
