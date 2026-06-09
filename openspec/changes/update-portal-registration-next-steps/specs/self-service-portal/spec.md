<!-- markdownlint-disable MD041 -->

## MODIFIED Requirements

### Requirement: Portal authentication and roles

The system SHALL provide a dedicated portal for guardians and students with secure authentication supporting MFA and role-based access that limits guardians to dependents they are linked to. The registration flow SHALL enforce e-mail verification before first full access and SHALL keep a fail-closed posture for identity linkage.

#### Scenario: Guardian must verify email before full access

- **GIVEN** a guardian has completed registration with valid data
- **WHEN** they attempt to authenticate before e-mail verification
- **THEN** the system denies full portal access, guides the user to verification, and records an audit event

### Requirement: Profile management and audit

The system SHALL let users update personal contact information subject to validation rules and SHALL record an audit trail of changes requiring administrator approval when required by policy. Registration, verification resend, rate-limit blocks, and first-login events SHALL also be auditable.

#### Scenario: Audit registration abuse protection

- **GIVEN** repeated registration attempts from the same IP exceed policy threshold
- **WHEN** the limit is reached
- **THEN** the system returns HTTP 429, logs the blocking event with minimal sensitive data, and exposes the signal to observability dashboards

## ADDED Requirements

### Requirement: Registration verification experience

The system SHALL provide an e-mail verification experience at route /portal/email-verification with clear status messaging, a controlled resend action, and safe cleanup of transient client-side state after completion.

#### Scenario: Resend verification e-mail

- **GIVEN** a guardian is on the e-mail verification page
- **WHEN** they request resend within allowed policy limits
- **THEN** the system issues a new verification notification, returns user-friendly status feedback, and appends an audit record

### Requirement: Portal registration hardening and accessibility

The system SHALL enforce registration endpoint rate limiting (5 attempts per minute per IP), and the login screen SHALL include an accessible path to registration for new users.

#### Scenario: Navigate from login to registration

- **GIVEN** a visitor without account opens the portal login page
- **WHEN** they activate the register link using keyboard or screen reader
- **THEN** navigation reaches /portal/register successfully and the interaction is accessible and test-covered
