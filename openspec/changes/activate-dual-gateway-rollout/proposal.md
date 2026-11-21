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
3. Staging no Render pode não ser viável no free tier (o 402 é **verificação de conta**, não gargalo
   de capacidade — colocar cartão não muda nada enquanto o spend limit for US$ 0 e a cota esgotar).
   Por isso a validação de webhook é feita **localmente via túnel** com os sandboxes gratuitos de
   Asaas e Stripe (ver `docs/runbooks/activate-gateways.md` §0.1), sem depender do staging.

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
