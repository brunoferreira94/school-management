## ADDED Requirements

### Requirement: Automated guardian request resolution with real data

The portal SHALL resolve the most common guardian requests (second copy of invoice, enrollment statement, payment receipt, due-date inquiry) automatically using the student's real registration and financial data, without human secretariat intervention, and the secretariat SHALL see only the requests that could not be auto-resolved.

#### Scenario: Guardian gets a second copy instantly

- **GIVEN** a guardian with an open invoice
- **WHEN** they request "2ª via" in the portal
- **THEN** the invoice copy is generated instantly from the student's real financial data
- **AND** no secretariat action is required

#### Scenario: Unresolvable request becomes a human ticket

- **GIVEN** a request that cannot be auto-resolved (e.g. installment renegotiation)
- **WHEN** the guardian submits it
- **THEN** it appears in the secretariat queue as a human ticket with its queue position visible to the guardian

#### Scenario: Secretariat sees only exceptions and the automation gain

- **GIVEN** 50 requests were auto-resolved and 3 required humans this week
- **WHEN** the secretariat opens the requests panel
- **THEN** only the 3 human tickets are listed
- **AND** the panel shows the auto-resolved volume (50) for the period
