# public-launch-readiness Specification

## Purpose

Define the minimum conditions required for the School Management SaaS to move from internal prototype to closed pilot, controlled beta, and public launch.

## ADDED Requirements

### Requirement: Release readiness gates

The system SHALL expose a release readiness model with three stages: `closed_pilot`, `controlled_beta`, and `public_launch`, and SHALL require explicit go/no-go evidence before advancing to the next stage.

#### Scenario: Block public launch when P0 blockers remain open

- **GIVEN** one or more P0 release blockers remain open
- **WHEN** the team reviews launch readiness
- **THEN** the system records the launch stage as not eligible for public launch
- **AND** the release checklist identifies the remaining P0 blockers

### Requirement: Backend stability gate

The system SHALL keep critical API services stable under normal production-like operation, including migrations, background jobs, audit cleanup, tenant management, reports, and teacher availability scheduling.

#### Scenario: Background service failure does not stop the API host

- **GIVEN** a background cleanup or scheduler task encounters a transient cancellation or provider timeout
- **WHEN** the task runs
- **THEN** the system logs the failure and retries according to policy
- **AND** the API host remains available for user requests

### Requirement: Automated test gate

The system SHALL provide automated tests for critical release paths, including authentication, permissions, terms of use, billing checkout, owner dashboard, reports, and teacher availability.

#### Scenario: Release cannot proceed with failing critical tests

- **GIVEN** a critical automated test fails in the release candidate
- **WHEN** the CI pipeline evaluates the release
- **THEN** the pipeline fails
- **AND** the release checklist prevents public launch until the failure is resolved

### Requirement: Billing readiness gate

The system SHALL validate payment provider integration before public launch, including sandbox checkout creation, webhook processing, idempotency, status reconciliation, and environment separation for sandbox and production credentials.

#### Scenario: Asaas checkout becomes production-ready

- **GIVEN** a Premium tenant starts checkout in sandbox
- **WHEN** the payment provider creates a charge and sends a webhook
- **THEN** the system processes the webhook idempotently
- **AND** the local subscription or invoice status is reconciled with the provider status

### Requirement: Self-service portal readiness gate

The system SHALL provide a self-service portal for guardians and students that allows authenticated users to access only their own linked school data, including financial documents, grades, attendance, and communications.

#### Scenario: Guardian reaches first value quickly

- **GIVEN** a guardian completes onboarding for a closed pilot school
- **WHEN** the guardian signs in to the portal
- **THEN** the system displays relevant linked student data
- **AND** the time to first value is measured and recorded for launch readiness review

### Requirement: Legal and privacy readiness gate

The system SHALL require completed legal and privacy readiness evidence before public launch, including Terms of Use, Privacy Policy, cookie consent, tenant-level B2B documentation, data subject rights handling, and auditability.

#### Scenario: Tenant cannot launch publicly without legal documentation

- **GIVEN** a tenant lacks accepted Terms of Use or required B2B documentation
- **WHEN** the release checklist is evaluated for public launch
- **THEN** the tenant is blocked from public launch
- **AND** the checklist shows which legal or privacy artifact is missing

### Requirement: Deployment and operations gate

The system SHALL provide production deployment readiness evidence before public launch, including environment-specific secrets, TLS, database backups, migration procedure, rollback plan, health checks, and incident runbooks.

#### Scenario: Production deployment is reversible

- **GIVEN** a production release introduces a critical regression
- **WHEN** the operator follows the rollback runbook
- **THEN** the system can restore the previous known-good version
- **AND** the rollback action is recorded in the incident log

### Requirement: Product launch gate

The system SHALL provide product launch readiness evidence before public launch, including pricing copy, FAQ, onboarding materials, support process, and success metrics such as activation, retention, MRR, and support volume.

#### Scenario: Closed pilot graduates to controlled beta

- **GIVEN** a closed pilot school completes onboarding and reaches first value
- **WHEN** the team reviews activation, support, billing, and stability evidence
- **THEN** the system records whether the pilot meets the controlled beta criteria
- **AND** the next launch stage is approved only when all required evidence is present
