# Vincular checkout ao webhook da assinatura

Autor: Bruno Ferreira (assistente)
Data: 2026-11-24
Status: draft

## Motivação

A validação end-to-end do webhook Asaas sandbox (task 4 de `activate-dual-gateway-rollout`, via
túnel local, 10/10 checks em 2026-11-24) provou que o webhook funciona **quando a assinatura já
está vinculada**, mas o fluxo real de compra nunca cria esse vínculo. A lacuna tem duas faces:

1. **Vínculo inexistente.** `POST /api/subscriptions/checkout-intents` é `[AllowAnonymous]`, gera
   a referência externa `premium-{ciclo}-{timestamp}` dentro dos serviços de gateway
   (`AsaasCheckoutService.cs:110`, `StripeCheckoutService.cs:93`) e **não persiste nada
   localmente** — o `CheckoutIntentResponse` sequer expõe a referência. O webhook
   (`POST /api/subscriptions/webhooks/asaas`) casa a assinatura **exclusivamente** por
   `GetByExternalSubscriptionIdAsync(referência)`, sem fallback: pagamento real → webhook órfão →
   `processed:false`. O Stripe tem o mesmo problema (`FindSubscriptionByAnyReferenceAsync` só
   encontra valores pré-gravados).
2. **Plano nunca aplicado.** Mesmo com o vínculo criado à mão (ponte admin usada na E2E), o
   webhook só grava `Status`, `ExternalCustomerId`, `ExternalSubscriptionId` e `Notes` — **nunca
   altera `SubscriptionPlanId`**. O tenant paga Premium e segue no plano Free (ativo no plano
   errado).

Os E2E de UI não pegaram a lacuna porque `checkout-gateway.cy.ts` e `asaas-sandbox.cy.ts` stubam
`checkout-intents` via `cy.intercept`. A E2E do funil (`school-funnel.cy.ts`) documenta a
limitação como "dev-mock não cria subscription (404)".

## Escopo

- `POST /api/subscriptions/checkout-intents` passa a exigir tenant autenticado
  (`[Authorize(Policy = "Permission:subscriptions.write")]`, mesmo gate de
  `POST /subscriptions/tenant` / `DELETE /subscriptions/tenant`), consistente com o cenário
  existente "Anonymous user is not redirected".
- No intent: resolver a assinatura vigente (`GetActiveByTenantIdAsync`), provisionar trial
  idempotente (`ITrialSubscriptionProvisioner.EnsureTrialAsync`) quando não houver nenhuma, gerar
  a referência **centralmente no controller** e **persistir `ExternalSubscriptionId` antes** de
  chamar o gateway.
- Webhook (Asaas e Stripe): ao mapear o status para `Active`, aplicar o plano comprado +
  `BillingCycle` derivados da própria referência (`premium-{ciclo}-{timestamp}`), com fallback
  gracioso — referência não parseável mantém o plano atual e não falha o webhook. Nada é aplicado
  em pagamentos `pending`/`overdue`.
- Expor `externalSubscriptionId` em `GET /api/subscriptions/tenant` para verificação ponta-a-ponta.
- Atualizar o E2E do funil (`school-funnel.cy.ts`) para o novo comportamento em dev-mock
  (200 + `Trial`, em vez de 404).

## Fora de escopo

- Renovação/período (`CurrentPeriodEndsAtUtc`) na ativação — segue o mecanismo de billing-cadence
  existente; registrar como follow-up se a reconciliação apontar divergência.
- Stripe em test mode ao vivo (tasks 3–4 de `activate-dual-gateway-rollout`); aqui entra só a
  paridade de aplicação de plano no `StripeWebhookProcessor`.

## Critérios de aceitação

- Checkout autenticado (Asaas sandbox) → `GET /api/subscriptions/tenant` já retorna
  `externalSubscriptionId` **antes** do pagamento.
- Webhook `PAYMENT_CONFIRMED` do pagamento real (sem ponte admin) → `GET /api/subscriptions/tenant`
  retorna `status=Active`, `subscriptionPlanName=Premium` e `billingCycle=Monthly` (ou `Annual`).
- Referência não mapeada continua `processed:false`; evento repetido continua idempotente
  ("Evento já processado anteriormente").
- `POST /checkout-intents` sem token → 401/403, sem criar assinatura nem cobrança.
- Suíte da API verde (build + `dotnet test`) e E2E do funil ajustado.
