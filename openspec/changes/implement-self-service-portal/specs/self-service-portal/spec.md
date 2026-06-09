<!-- markdownlint-disable MD041 -->

## ADDED Requirements

### Requirement: Portal authentication and roles

The system SHALL provide a dedicated portal for guardians and students with secure authentication supporting MFA and role-based access that limits guardians to dependents they are linked to.

#### Scenario: Guardian access scope

- **GIVEN** a guardian associated with two students
- **WHEN** they sign in to the portal
- **THEN** they can view data for those students only and cannot access other students' information

### Requirement: Financial document access

The system SHALL allow guardians and students (where permitted) to view, download, and pay invoices/boletos from the portal with real-time status updates.

#### Scenario: Download boleto

- **GIVEN** an outstanding boleto is available
- **WHEN** the guardian accesses the financial section
- **THEN** they can download the boleto PDF and see the current payment status

### Requirement: Academic performance visibility

The system SHALL display grades, attendance summaries, and upcoming events tailored to the authenticated role, with filters by term or course.

#### Scenario: View attendance summary

- **GIVEN** a student has recorded absences this term
- **WHEN** they open the attendance tab
- **THEN** they see a summary of total absences, justified vs unjustified counts, and links to detailed records

### Requirement: Profile management and audit

The system SHALL let users update personal contact information subject to validation rules and SHALL record an audit trail of changes requiring administrator approval when required by policy.

#### Scenario: Update phone number

- **GIVEN** a guardian edits their phone number
- **WHEN** they submit the change
- **THEN** the system validates the format, stores the new value pending approval if configured, and logs the change with timestamp
