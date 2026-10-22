<!-- markdownlint-disable MD041 -->

## ADDED Requirements

### Requirement: WhatsApp deep-link handoff

The system SHALL offer WhatsApp deep-link sharing (wa.me with masked registered guardian phone and prefilled, school-approved message template) as a delivery handoff for guardian-facing notices and billing reminders, without requiring an external WhatsApp API in the first release and without exposing other guardians' data.

#### Scenario: Billing reminder via WhatsApp handoff

- **GIVEN** a queued billing reminder notification for an unpaid invoice
- **WHEN** the staff member initiates the WhatsApp handoff for that guardian
- **THEN** the deep link opens a WhatsApp conversation with a prefilled message generated from the school-approved template and only that guardian's data

#### Scenario: Template content is school-controlled

- **GIVEN** a director edits the message template for a billing event
- **WHEN** any handoff is generated afterwards
- **THEN** the prefilled WhatsApp message matches the school-approved template

#### Scenario: Handoff never auto-sends from the platform

- **GIVEN** any queued notification with WhatsApp handoff available
- **WHEN** the reminder is processed
- **THEN** the system only presents the handoff link; the human confirms sending from the school's WhatsApp client
