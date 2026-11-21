## MODIFIED Requirements

### Requirement: Local development runs without real gateway credentials

In Development/E2E the gateway SHALL degrade to the mock payment service so the checkout
flow can be exercised end-to-end without Asaas or Stripe keys. In Production/Staging the
gateway SHALL NOT degrade to the mock: missing credentials SHALL fail fast at startup.

#### Scenario: Missing credentials degrade to mock in development

- **GIVEN** `Asaas:ApiKey` and `Stripe:SecretKey` are empty
- **AND** the environment is Development or Testing
- **WHEN** a checkout intent is created for a Boleto/PIX payment
- **THEN** the `MockPaymentCheckoutService` returns a `checkoutUrl` with provider `MockPayment`
- **AND** the local return route simulates a `COMPLETED` payment

#### Scenario: Missing credentials degrade to mock

- **GIVEN** `Asaas:ApiKey` and `Stripe:SecretKey` are empty
- **WHEN** a checkout intent is created for a Boleto/PIX payment
- **THEN** the `MockPaymentCheckoutService` returns a `checkoutUrl` with provider `MockPayment`

#### Scenario: Missing credentials fail fast in production

- **GIVEN** `Asaas:ApiKey` and `Stripe:SecretKey` are empty
- **AND** the environment is Production or Staging
- **WHEN** the application starts
- **THEN** startup fails with an explicit configuration error
- **AND** no checkout is served by the mock