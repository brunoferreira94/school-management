# Conectar o checkout da UI ao gateway de pagamento (checkout-intents)

## Why

O funil ao vivo (school-funnel.cy.ts) mostra que a página de checkout **não usa o
gateway** (`POST /api/subscriptions/checkout-intents` existe no backend mas não é chamado):
ela chama `POST /subscriptions/tenant` direto, simulando pagamento com `setTimeout`, de modo
que **nenhum link de pagamento real é gerado e nenhum webhook é reconciliado**. A assinatura
criada assim sai `Active`, mas sem checkout nem faturamento — o plano Premium "grátis" de
desenvolvimento não reflete a realidade.

## What Changes

- A página de checkout chamará `POST /api/subscriptions/checkout-intents` com plano, ciclo,
  método de pagamento, nome, e-mail e CPF.
- O backend `GatewayCheckoutRouter` entrega a URL de pagamento (Asaas sandbox, Stripe, ou
  mock local quando `Asaas:ApiKey`/`Stripe:SecretKey` estão vazios).
- A UI redireciona o visitante para a `checkoutUrl` retornada.
- Após o pagamento, o visitante volta para uma rota de retorno que **consulta a assinatura**
  (`GET /subscriptions/tenant`) para refletir o status real (`Active`/`Trial`).
- Webhook (`POST /api/subscriptions/webhooks/asaas|stripe`) reconcilia a assinatura no banco
  — já implementado no backend; só precisa ser exposto em staging.

**BREAKING**: o antigo `POST /subscriptions/tenant` (criação direta de assinatura) é substituído
pelo fluxo gateway. Mantido só como fallback de teste local.

## Impact

- Specs afetadas: `checkout-gateway` (nova, abaixo)
- Código UI: `features/checkout/ui/checkout-page.component.ts`, `services/subscription.service.ts`
  (a raiz de `src/app/services/subscription.service.ts` com `createCheckoutIntent`)
- Backend: nenhuma alteração obrigatória (os endpoints já existem); apenas expor
  `WebhookSuccessUrl`/`WebhookCancelUrl` no mock local e apontar para o `GatewayReconciliation`
