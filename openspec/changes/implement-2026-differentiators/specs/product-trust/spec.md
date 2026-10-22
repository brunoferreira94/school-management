<!-- markdownlint-disable MD041 -->

## ADDED Requirements

### Requirement: Reliability trust page

The product SHALL present, inside the admin surface: a release changelog (fixes/features) with the mean time to repair of the last 30 days and the current state of each external integration (payment gateways, notification delivery, storage).

#### Scenario: Director checks system health

- **GIVEN** the product had recurring integrations issues in the last 30 days
- **WHEN** the director opens the trust page (confiabilidade & mudanças)
- **THEN** the panel lists the 30-day changelog, the average MTTR, and the current state of each integration

#### Scenario: Integration outage is visible

- **GIVEN** a payment gateway is failing its health checks
- **WHEN** the trust page is opened
- **THEN** that integration is shown as degraded with the last verified timestamp
