## ADDED Requirements

### Requirement: Boleto payment via portal

The system SHALL allow guardians to pay outstanding boletos directly from the portal using PIX or credit card, integrating with the existing payment gateway, and SHALL display real-time payment status updates.

#### Scenario: Pay boleto via PIX

- **GIVEN** a guardian has an outstanding boleto
- **WHEN** they select the PIX payment option and confirm
- **THEN** the system generates a PIX QR code, shows the payment status as "Pending", and updates to "Paid" when the gateway confirms the transaction

#### Scenario: Payment failure handling

- **GIVEN** a guardian attempts to pay a boleto
- **WHEN** the payment gateway returns a failure
- **THEN** the system displays the error message and allows the guardian to retry

### Requirement: Document download

The system SHALL allow guardians and students to download official documents (report cards, certificates, declarations) in PDF format from the portal, with documents generated on-demand or fetched from cached storage.

#### Scenario: Download report card PDF

- **GIVEN** a student has completed assessments for a term
- **WHEN** the guardian requests the report card PDF
- **THEN** the system generates or retrieves the PDF and initiates a download with the student name and term in the filename

### Requirement: Student timetable view

The system SHALL display the student's class timetable (weekly schedule) in the academic section, showing subject, teacher, classroom, and time slot for each class.

#### Scenario: View weekly timetable

- **GIVEN** a student is enrolled in class groups with defined schedules
- **WHEN** they open the timetable tab in the academic section
- **THEN** the system displays a weekly grid with all scheduled classes, highlighting the current day

### Requirement: School messaging channel

The system SHALL provide a messaging channel between guardians/students and school coordination, supporting sending and receiving messages with read receipts and message history.

#### Scenario: Send message to coordination

- **WHEN** the guardian composes and sends a message to school coordination
- **THEN** the system stores the message, marks it as sent, and shows it in the conversation thread with a timestamp

#### Scenario: View message history

- **WHEN** the guardian opens the messaging section
- **THEN** the system displays the conversation history with sent and received messages, ordered chronologically

### Requirement: Student notifications inbox

The system SHALL provide a per-student notifications inbox showing notifications addressed to the student, with read/unread status and the ability to mark notifications as read.

#### Scenario: View student notifications

- **GIVEN** a student has received notifications (grades posted, schedule changes, etc.)
- **WHEN** the guardian opens the notifications tab
- **THEN** the system displays notifications sorted by date with read/unread indicators

#### Scenario: Mark notification as read

- **GIVEN** a notification is unread
- **WHEN** the guardian clicks on it
- **THEN** the system marks it as read and updates the unread count
