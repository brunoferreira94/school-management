# notifications Specification

## Purpose
TBD - created by archiving change implement-notifications-reminders. Update Purpose after archive.
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

