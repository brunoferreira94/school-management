# self-service-portal Specification

## Purpose
Esta capacidade provê o portal de autoatendimento para responsáveis e alunos, com autenticação segura (MFA) e acesso baseado em papéis que limita o responsável aos dependentes a ele vinculados. Pelo portal, o usuário consulta e baixa documentos financeiros (boletos/faturas), visualiza o status de pagamento em tempo real e acompanha as informações acadêmicas permitidas.

## Requirements

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
