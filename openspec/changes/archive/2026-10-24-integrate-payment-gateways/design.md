# Design — Integrar com Gateways de Pagamento

## Componentes

- Payment Service: cria intents/charges, registra transactions
- Webhook handler: idempotency, retries, security
- Reconciliation engine: regras para matching entre cobranças e pagamentos

## Endpoints

- POST /api/payments/create-intent
- POST /api/payments/webhook

## Notas

- Nunca armazenar full card data; usar tokenization
- Monitorar taxas e disputas (chargebacks)
