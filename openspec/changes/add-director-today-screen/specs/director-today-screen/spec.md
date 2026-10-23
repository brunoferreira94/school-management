## ADDED Requirements

### Requirement: Prioritized daily action queue

The system SHALL present a "Tela de Hoje" that shows the director a single prioritized queue of concrete actions for the day, aggregated from billing cadence occurrences, delinquency risk, pending AI drafts, and open pedagogical occurrences — not passive charts.

#### Scenario: Director opens the today screen

- **GIVEN** the school has overdue invoices, one student flagged as churn risk, and two pending AI drafts
- **WHEN** the director opens the today screen
- **THEN** the queue lists every actionable item ordered by priority
- **AND** each item cites its data basis (e.g. "3 faturas vencidas há 5 dias")

#### Scenario: Empty queue means the day is resolved

- **GIVEN** no pending actions exist for the school
- **WHEN** the director opens the today screen
- **THEN** the screen shows an explicit "dia resolvido" state with the count of actions resolved that day

### Requirement: One-click suggested action per item

Each queued item SHALL offer a suggested action that executes in one click (open an editable AI draft, send a communication, or open the related record), and the director's resolution (done, deferred, dismissed with reason) SHALL be recorded with an audit trail.

#### Scenario: Director resolves a billing action

- **GIVEN** a delinquency item in the queue
- **WHEN** the director clicks the suggested action and then marks it resolved
- **THEN** the item leaves the queue, the resolution is persisted, and the menu badge count decreases
