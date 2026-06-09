<!-- markdownlint-disable MD041 -->

## ADDED Requirements

### Requirement: Hosted checkout and charges

The system SHALL integrate with Stripe and Pagar.me to create charges via hosted checkout, supporting one-time and recurring payments, and SHALL return redirect URLs and status updates to the application.

#### Scenario: Initiate hosted checkout

- **GIVEN** a responsible party chooses to pay an invoice online
- **WHEN** the backend creates a checkout session
- **THEN** it receives a redirect URL from the provider and the invoice status remains pending until the webhook confirms the payment

### Requirement: Tokenization and stored payment methods

The system SHALL allow guardians to store card tokens securely via the provider for future payments and SHALL manage consent and revocation of stored methods.

#### Scenario: Save payment method

- **GIVEN** a guardian opts to save their card during checkout
- **WHEN** the provider returns a token
- **THEN** the system stores the token metadata, associates it to the guardian, and masks the card details in the UI

### Requirement: Webhook processing and idempotency

The system SHALL consume provider webhooks (e.g., `payment_intent.succeeded`, `charge.failed`) idempotently, verifying signatures, recording events, and updating financial records exactly once.

#### Scenario: Handle repeated webhook

- **GIVEN** Stripe retries a `payment_intent.succeeded` webhook
- **WHEN** the system receives the duplicate event
- **THEN** it recognizes the event ID, avoids duplicate processing, and responds 200 OK

### Requirement: Reconciliation dashboard

The system SHALL provide a reconciliation view that matches gateway transactions against internal invoices, highlighting mismatches, partial payments, and fees, and SHALL allow exporting reconciliation results.

#### Scenario: Identify unmatched transaction

- **GIVEN** a payment exists in the gateway without a corresponding invoice
- **WHEN** the reconciliation job runs
- **THEN** the dashboard flags the transaction as unmatched with guidance to link or refund
