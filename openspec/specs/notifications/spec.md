# notifications Specification

## Purpose
Esta capacidade centraliza as notificações e lembretes da escola. Administradores configuram regras que combinam gatilhos (vencimento de faturas, limiar de presença, lembrete de eventos) com offsets de agendamento e audiências-alvo. O envio é multicanal (e-mail, push, SMS) respeitando as preferências de cada usuário, com retentativas em backoff exponencial para falhas transitórias.

## Requirements

### Requirement: Notification rule engine

The system SHALL allow administrators to configure notification rules combining triggers (invoice due date, attendance threshold, event reminder) with scheduling offsets and target audiences.

#### Scenario: Configure due date reminder

- **GIVEN** an administrator creates a rule for invoices due in three days
- **WHEN** the scheduler processes the rule
- **THEN** the system enqueues notifications for all matching responsible parties exactly three days before the due date

### Requirement: Multi-channel delivery

The system SHALL support sending notifications through email, push, and SMS, choosing channels based on user preferences and rule configuration, and SHALL handle retries with exponential backoff on transient failures.

#### Scenario: Respect user channel preferences

- **GIVEN** a guardian opts out of SMS but allows email
- **WHEN** a rule fires that includes SMS and email
- **THEN** the system sends only the email notification and records that SMS was skipped due to preferences

### Requirement: Opt-out and quiet hours

The system SHALL respect per-user opt-out settings and quiet-hour windows, postponing or suppressing notifications according to configured policies.

#### Scenario: Quiet hours enforcement

- **GIVEN** quiet hours are configured for 22:00-07:00 local time
- **WHEN** a critical absence rule triggers at 23:00
- **THEN** the system delays the notification until 07:00 and logs the adjusted send time

### Requirement: Monitoring dashboard

The system SHALL expose a dashboard summarizing notification throughput, failure rates, and pending queues, with drill-down into individual notification history.

#### Scenario: Inspect failed notification

- **GIVEN** a notification failed due to provider timeout
- **WHEN** an operator views the dashboard and opens the failure details
- **THEN** they see the provider error message, retry attempts, and next retry schedule

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
