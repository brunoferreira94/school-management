# Tasks — Ativar gateways em produção/staging

> Runbook detalhado (contas Stripe/Asaas/Render, variáveis, validação ponta-a-ponta, rollback):
> [`docs/runbooks/activate-gateways.md`](../../../docs/runbooks/activate-gateways.md)

- [ ] Promover development → main nos submódulos (API `5b5a7dc+`, UI) e confirmar com founder antes do deploy (Render CLI: POST `/v1/services/srv-d82eofrbc2fs73b4jh1g/deploys` com `{"clearCache":"do_not_clear"}`; Vercel deploy de produção dispara no push em main).
- [ ] Definir URLs de success/cancel do hosted Stripe (UI) e configurar `STRIPE_SUCCESS_URL`/`STRIPE_CANCEL_URL` no Render.
- [ ] Criar conta/produto Stripe (test → live), gerar webhook secret e configurar `STRIPE_SECRET_KEY`/`STRIPE_WEBHOOK_SECRET` no Render (POST env vars; PUT substitui tudo).
- [ ] Validar webhook sandbox end-to-end: preferir **validação local via túnel** (Seção 0.1 do runbook — sem cartão, sem staging). Alternativa em staging só se/quando houver capacidade no free tier (o 402 é verificação de conta, não gargalo de capacidade): checkout Asaas sandbox → webhook → assinatura ACTIVE → flag `ok` na reconciliação; repetir evento (idempotência); repetir no Stripe test mode.
- [x] UI: página de planos/checkout lendo `provider` do `CheckoutIntentResponse` (BRL pix/boleto/carnê via Asaas; CARD USD via Stripe redirect); banner "modo sandbox/staging" quando ambiente ≠ produção — implementado em `school-management-ui` (`checkout-page.component.ts/html`: `provider()` + banner `data-cy="sandbox-banner"` quando `MockPayment`).
- [ ] Reexecutar suíte portal E2E após deploy de produção (regressão de deploy) + `premium-portal-activation.cy.ts` ao vivo no staging.
- [ ] Atualizar CLAUDE/AGENTS memory: URL + env vars dos gateways ativos (asg rot de chaves documentada no README da API).

## Status de código já entregue (pré-requisitos)

- [x] `GatewayCheckoutRouter` degrada para mock só em Development/Testing; Production/Staging sem credenciais → `UnavailableGateway` (falha explícita).
- [x] `Tenant:FailClosed=true` e `Entitlement:Enforce=true` em `appsettings.Production/Staging`.
- [x] Webhooks Asaas (token) e Stripe (HMAC) já validam origem e são idempotentes.