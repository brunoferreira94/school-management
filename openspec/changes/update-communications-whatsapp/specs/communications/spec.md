## ADDED Requirements

### Requirement: WhatsApp as an official communication channel

The system SHALL support WhatsApp as a first-class communication channel through the same template, segmentation, and delivery-tracking infrastructure used for e-mail and SMS, with every message traceable inside the system.

#### Scenario: Segmented WhatsApp send with tracking

- **GIVEN** a coordinator sends a notice to a class group selecting WhatsApp as channel
- **WHEN** the send is processed
- **THEN** each recipient's delivery and read status is recorded in the existing communication history

### Requirement: Channel consent with fallback

The system SHALL only send WhatsApp messages to guardians who opted in to the channel, and SHALL fall back to e-mail (recording the reason) when consent is absent.

#### Scenario: No consent falls back to e-mail

- **GIVEN** a guardian has no WhatsApp opt-in recorded
- **WHEN** a billing reminder is dispatched via WhatsApp
- **THEN** the reminder is sent by e-mail instead and the fallback reason is recorded in the delivery log

### Requirement: WhatsApp templates with actionable variables

WhatsApp templates SHALL support student and invoice variables, including a one-tap PIX second-copy link, so billing reminders are actionable inside the message.

#### Scenario: Billing reminder with PIX link

- **GIVEN** an overdue invoice for a student
- **WHEN** the billing cadence triggers the WhatsApp reminder
- **THEN** the message includes the amount, due date, and a working second-copy link
