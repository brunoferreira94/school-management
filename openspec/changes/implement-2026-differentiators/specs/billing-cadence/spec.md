<!-- markdownlint-disable MD041 -->

## ADDED Requirements

### Requirement: Cadence engine for invoice events

The system SHALL provide a billing cadence engine that emits a notification per configured rule anchored to invoice events (due-soon, due-today, overdue deltas) at most once per rule occurrence, with safe replay on reprocessing.

#### Scenario: Invoice due in 3 days triggers reminder

- **GIVEN** a school has an unpaid invoice due in 3 business days and the rule `due-soon` is active
- **WHEN** the cadence engine runs
- **THEN** a notification requesting payment with a gateway-generated payment link is queued to the guardian and the rule occurrence is persisted

#### Scenario: Engine replays same occurrence without duplicates

- **GIVEN** the engine processed a `due-soon` occurrence for invoice X and runs again on the same day
- **WHEN** replay is executed
- **THEN** no duplicate notification is queued for the same occurrence and the run log records the skip

#### Scenario: School disables a rule

- **GIVEN** a director disables the `overdue-d5` rule for their school
- **WHEN** the engine processes invoices with new overdue status
- **THEN** no overdue-d5 notification is created and the disabling is auditable

### Requirement: Payment link attaches by billing type

The system SHALL attach the payment link produced by the resolved checkout gateway to every reminder, using the billing type of the invoice (PIX/boleto/carnê link for BRL billing type; hosted checkout for card), never requiring manual assembly.

#### Scenario: Reminder carries PIX link

- **GIVEN** a guardian's invoice is billed in BRL via PIX
- **WHEN** a reminder is queued
- **THEN** the notification contains the direct PIX-capable payment link produced via the gateway resolution for that invoice's billing type

### Requirement: Cadence effectiveness is measurable

The system SHALL expose per-school cadence metrics (notifications per rule, payments completed within 3 days after each rule) so directors can compare the effect of each cadence stage.

#### Scenario: Director opens metrics panel

- **GIVEN** cadence notifications were sent in the last 90 days
- **WHEN** the director opens the billing cadence panel
- **THEN** payments-completed-within-SLA is displayed per rule and channel
