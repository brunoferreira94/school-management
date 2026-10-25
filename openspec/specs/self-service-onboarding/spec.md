# self-service-onboarding Specification

## Purpose
TBD - created by archiving change self-service-school-registration. Update Purpose after archive.

## Requirements

### Requirement: Public school registration form

The system SHALL expose a public, unauthenticated registration form at `/cadastro` so a
visitor can create a school account without contacting support.

#### Scenario: Visitor creates a school account

- **GIVEN** an anonymous visitor on `/cadastro`
- **WHEN** the visitor fills school name, principal name, CPF, e-mail, password and accepts
  the terms
- **THEN** the system creates a tenant, a school unit, the principal user and a Free trial
  subscription in a single transaction
- **AND** the response redirects the visitor to the login page with a "conta criada" indicator

#### Scenario: CPF or e-mail already registered

- **GIVEN** a visitor submits a CPF or e-mail already in use
- **WHEN** the registration is processed
- **THEN** the system returns 409
- **AND** the error message does not reveal which of the two identifiers is duplicated

### Requirement: New tenants start on the Free trial

Every tenant created through self-service SHALL receive an active `Free` plan subscription with
`Status = Trial` and a configurable trial duration (default 14 days).

#### Scenario: New school starts on a Free trial

- **GIVEN** a school account was just created
- **WHEN** the principal logs in
- **THEN** `GET /api/subscriptions/tenant` returns status `Trial` and plan `Free`
- **AND** the dashboard shows the upgrade options and the trial expiration
