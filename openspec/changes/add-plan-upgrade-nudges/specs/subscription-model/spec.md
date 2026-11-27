# Spec Delta — Capability `subscription-model`

## ADDED Requirements

### Requirement: Upgrade nudge precedes plan enforcement

The UI SHALL offer upgrade nudges for features not included in the tenant's plan **before** any
API enforcement (`403 feature_not_in_plan` or `402 subscription_expired`) occurs. The nudge SHALL
be a soft gate: visual affordances and copy that explain the included value, without preventing
navigation by any other means. This behavior SHALL NOT depend on `FeatureGating:Enforce` or
`Entitlement:Enforce`.

#### Scenario: Locked menu item opens the upgrade offer

- **GIVEN** a tenant on a plan without `financial_module` and `FeatureGating:Enforce = false`
- **WHEN** the user clicks the "Financeiro" menu item
- **THEN** the upgrade modal opens with the `feature_not_in_plan` copy for that feature
- **AND** the user is NOT navigated to a blocked screen and NO API write is attempted

#### Scenario: Nudge respects a seven-day cooldown

- **GIVEN** a user dismissed the nudge for a feature
- **WHEN** the user clicks the same locked item again within 7 days
- **THEN** the upgrade modal may open on explicit click but is NOT shown automatically on boot
- **AND** after 7 days the dismissal is expired

#### Scenario: Expired-trial message uses real usage data

- **GIVEN** a tenant whose trial ended and that has students and classes registered
- **WHEN** the expired-trial upgrade modal is shown
- **THEN** the message includes the real count of students/classes from the usage endpoint
- **AND** if the usage endpoint fails, the count is omitted instead of guessed

### Requirement: Feature nudge copy is specific and honest

Upgrade copy for each gated feature SHALL name a concrete benefit and use only real catalog prices,
real tenant usage data and real deadlines. Fabricated urgency, fake scarcity, invented social proof
and guilt-based language SHALL NOT be used.

#### Scenario: Benefit-specific copy

- **GIVEN** the nudge for `advanced_analytics`
- **WHEN** the locked preview is rendered
- **THEN** it shows the benefit headline and three concrete value bullets for analytics
- **AND** it does not show a generic "access denied" message

#### Scenario: No fabricated urgency or social proof

- **GIVEN** any upgrade nudge
- **WHEN** its copy and visual are inspected
- **THEN** there is no countdown, "last spots" claim or unverified customer count
- **AND** any deadline shown corresponds to a real, documented date
