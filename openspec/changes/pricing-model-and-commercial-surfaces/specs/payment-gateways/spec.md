# Spec Delta — Capability `payment-gateways`

## ADDED Requirements

### Requirement: Production runs against the production gateway

The production environment SHALL use the provider's production base URL and credentials. Sandbox
endpoints SHALL be restricted to Development and staging, and the configuration SHALL make the
active environment explicit (no silent sandbox fallback in production).

#### Scenario: Production configuration points to the production API

- **GIVEN** the production service environment variables
- **WHEN** the checkout configuration is read
- **THEN** `Asaas__ApiBaseUrl` is `https://api.asaas.com/v3`
- **AND** the configured API key is a production key

#### Scenario: Staging keeps the sandbox

- **GIVEN** the staging service environment variables
- **WHEN** a checkout intent is created
- **THEN** the sandbox base URL and sandbox key are used
- **AND** the UI shows a sandbox banner

#### Scenario: Missing production credentials fail loudly

- **GIVEN** the production environment without a configured provider key
- **WHEN** a checkout intent is created
- **THEN** the request fails with a configuration error
- **AND** the system does not fall back to the mock payment service