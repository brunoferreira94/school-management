# Ativar gateways de pagamento em produção/staging

Autor: Bruno Ferreira (assistente)
Data: 2026-10-22
Status: draft

## Motivação

O change `integrate-payment-gateways` (5/5 tasks, commit `5b5a7dc` no repo da API) entregou a
abstração `ISubscriptionGateway` (Asaas BRL + Stripe USD/intl), webhooks idempotentes com
verificação de assinatura e reconciliação. Porém **nada disso roda em produção ou staging ainda**:

1. O código novo está apenas na branch `development` — produção (Render: `main`, Vercel: `main`)
   ainda não recebeu também 429-observabilidade, churn endpoints/widget e cancel-flow contracts.
2. Não há credenciais reais de Stripe (`STRIPE_SECRET_KEY`, `STRIPE_WEBHOOK_SECRET`,
   `STRIPE_SUCCESS_URL`, `STRIPE_CANCEL_URL`) nem UI consumindo o `provider` retornado no
   checkout.
3. Staging no Render está bloqueado por cartão de crédito (402 do workspace `tea-d82eakm7r5hc73bp8gg0`),
   o que impede validar webhook sandbox end-to-end (premium-portal-activation.cy.ts exige
   credenciais/ambiente reais).

## Escopo

- Promover development → main nos submódulos (API + UI) e disparar deploys com confirmação
  do founder.
- Wire-up da UI: página de planos/checkout lendo `provider` do `CheckoutIntentResponse`,
  success/cancel URLs para o Stripe, banner de "modo sandbox" em staging.
- Validação end-to-end de webhooks no staging (Asaas sandbox + Stripe test mode), incluindo
  eventos repetidos (idempotência) e reconciliação.
- Configuração de env vars no Render (POST `/deploys` com `do_not_clear`, nunca PUT).

## Critérios de aceitação

- Assinatura premium ativável end-to-end em staging: checkout → webhook → status ACTIVE
  → reconciliação com flag `ok`.
- Produção comporta ambos os provedores com keys de rotação documentadas (README da API).
- Suíte E2E do portal continua verde após o deploy (intercepts) + smoke com sandbox.
