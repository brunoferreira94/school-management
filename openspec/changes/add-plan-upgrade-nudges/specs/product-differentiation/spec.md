# Spec Delta — Capability `product-differentiation`

## ADDED Requirements

### Requirement: Locked features communicate value, not denial

Features outside the tenant's plan SHALL be presented with an upgrade affordance (lock icon,
"Premium" badge or locked preview) that explains what is included and how to unlock it. The
affordance SHALL NOT hide the feature's existence, block unrelated navigation or degrade trust
through deceptive urgency.

#### Scenario: Locked affordance in the sidebar

- **GIVEN** a tenant whose plan does not include the feature
- **WHEN** the sidebar is rendered
- **THEN** the item shows a lock icon and a "Premium" badge
- **AND** clicking it opens the upgrade offer instead of navigating away

#### Scenario: Direct URL still works during soft gate

- **GIVEN** enforcement is disabled
- **WHEN** the user opens the feature's URL directly
- **THEN** the feature screen opens normally
- **AND** no upgrade modal is forced on every visit

### Requirement: Upgrade nudges are measured per feature

The system SHALL record when a nudge is shown, dismissed and converted into an upgrade click,
with the feature identifier and the source surface, so the copy can be improved with real data.

#### Scenario: Nudge events carry the feature and source

- **GIVEN** a nudge shown from the sidebar
- **WHEN** the user dismisses it or clicks "Desbloquear"
- **THEN** the recorded event identifies the feature and the source `menu`
- **AND** no personal student data is included in the event
