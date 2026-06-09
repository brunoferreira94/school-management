<!-- markdownlint-disable MD041 -->

## ADDED Requirements

### Requirement: Pricing tier configuration

The system SHALL support the canonical subscription tiers `Free`, `Premium`, and `Enterprise`, with explicit limits on active students, staff users, school units, storage, and included modules, and SHALL enforce these limits through feature gating and usage monitoring.

#### Scenario: Enforce student limit

- **GIVEN** a school is on the `Premium` tier with a 500 student limit
- **WHEN** they attempt to enroll the 501st student
- **THEN** the system blocks the enrollment and prompts the administrator to upgrade the tier

#### Scenario: Free tier remains low-friction

- **GIVEN** a school is on the `Free` tier
- **WHEN** the public plans are listed
- **THEN** the system shows a zero-cost plan with limited capacity and without premium-only modules

### Requirement: Premium value package for MVP

The system SHALL treat `Premium` as the primary monetized offer in the MVP, bundling Portal do Responsável, advanced notifications, financial module, and operational analytics without requiring paid add-ons in phase 1.

#### Scenario: Premium unlocks core commercial value

- **GIVEN** a tenant upgrades from `Free` to `Premium`
- **WHEN** the subscription becomes active
- **THEN** Portal do Responsável, advanced notifications, financial module, and analytics features become available immediately

### Requirement: Premium onboarding value validation

The system SHALL provide a product validation path that allows the team to verify whether a `Premium` tenant reaches first value through the Portal do Responsável quickly enough to sustain the MVP pricing narrative.

#### Scenario: Premium tenant reaches first value

- **GIVEN** a tenant is on the `Premium` plan
- **WHEN** an administrator or responsible user follows the guided onboarding path for the portal
- **THEN** the team can verify login completion, dashboard access, and real responsible data access as concrete value milestones
- **AND** the first value moment is measured from the start of the guided flow until the first real portal data becomes visible

#### Scenario: Premium validation uses explicit milestones

- **GIVEN** the team is validating the commercial value of the `Premium` plan
- **WHEN** the validation session starts
- **THEN** the session records at least three observable milestones: successful login, dashboard load, and display of real responsible data
- **AND** the result is classified as `validated`, `partial`, or `failed`

#### Scenario: Value proposition requires adjustment

- **GIVEN** the onboarding validation shows that first value is slow, blocked, or unclear
- **WHEN** product and marketing review the outcome
- **THEN** the monetization work records whether to adjust pricing copy, improve onboarding, or postpone stronger commercial push

### Requirement: Phased billing rollout

The system SHALL support a phased billing rollout, where phase 1 records subscription lifecycle and pricing metadata and phase 2 integrates an external billing gateway only after the charging contract and webhook flow are validated.

#### Scenario: Capture billing metadata before production charging

- **GIVEN** a tenant starts an annual `Premium` subscription
- **WHEN** the subscription is created
- **THEN** the system stores billing cycle, plan price, and external billing identifiers needed for later gateway integration

#### Scenario: Billing gateway remains blocked until validated

- **GIVEN** the gateway contract has not been validated with sandbox credentials and webhook proof
- **WHEN** the team reviews production readiness
- **THEN** charging in production remains disabled and the monetization change records the gateway as a follow-up dependency

### Requirement: Monetization KPIs

The system SHALL provide dashboards or reports tracking MRR, churn, ARPU, upgrade/downgrade events, and lead conversion, with enough segmentation to evaluate the performance of `Free`, `Premium`, and `Enterprise`.

#### Scenario: Export KPI report

- **GIVEN** the finance team filters KPIs for the `Enterprise` segment
- **WHEN** they export the report
- **THEN** the system produces a CSV containing the filtered KPI values and the reporting period metadata
