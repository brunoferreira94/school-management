# Tasks — Vincular checkout ao webhook da assinatura

## 1. Observabilidade do vínculo

- [ ] 1.1 Expor `ExternalSubscriptionId` em `TenantSubscriptionDto` e no `MapToDto` de
      `SubscriptionService` (`GET /api/subscriptions/tenant`), sem quebrar contrato de UI.
- [ ] 1.2 Adicionar assert de não-regressão no teste de `GET /tenant` (campo presente quando há
      vínculo, `null` quando não há).

## 2. Referência centralizada

- [ ] 2.1 Criar helper único de referência (`{planSlug}-{ciclo}-{yyyyMMddHHmmss}`) na camada
      Application — ex.: `Subscriptions/Services/CheckoutReference.cs` — e usá-lo em
      `AsaasCheckoutService` (`:110`), `StripeCheckoutService` (`:93`) e no controller.
- [ ] 2.2 `AsaasCheckoutService`/`StripeCheckoutService`: usar `request.ExternalReference` quando
      fornecido e cair no helper quando `null` (mantém os testes unitários atuais intactos).
- [ ] 2.3 `CreateCheckoutIntentRequest`: adicionar `ExternalReference` (preenchido **sempre** pelo
      controller; valor enviado pelo cliente é ignorado/sobrescrito).

## 3. Vínculo no intent

- [ ] 3.1 `CreateCheckoutIntent`: trocar `[AllowAnonymous]` por
      `[Authorize(Policy = "Permission:subscriptions.write")]`; resolver `tenantId` via
      `ITenantProvider`.
- [ ] 3.2 Resolver assinatura alvo: `GetActiveByTenantIdAsync` → senão
      `ITrialSubscriptionProvisioner.EnsureTrialAsync(tenantId)` (idempotente; cobre o caso de
      assinatura só-cancelada) → recarregar a assinatura ativa.
- [ ] 3.3 Persistir `ExternalSubscriptionId = "{referência}"` na assinatura **antes** da chamada ao
      gateway; em caso de falha do gateway, manter a referência (próximo checkout sobrescreve).
- [ ] 3.4 Injetar `ITrialSubscriptionProvisioner` no `SubscriptionsController` (DI já registrada).

## 4. Aplicação do plano no webhook

- [ ] 4.1 Criar parser da referência (slug + ciclo, split a partir da direita para tolerar slugs com
      hífen) com fallback `null` quando não reconhecer.
- [ ] 4.2 Injetar `ISubscriptionPlanRepository` no `SubscriptionsController`; no handler do webhook
      Asaas, quando `MapProviderStatus(...) == Active`, resolver o plano por slug e aplicar
      `SubscriptionPlanId` + `BillingCycle` (parse falhou/plano inexistente → mantém plano atual e
      loga warning, sem falhar o webhook).
- [ ] 4.3 `StripeWebhookProcessor`: mesma aplicação de plano quando `MapEventStatus` → `Active`,
      usando o `client_reference_id` do evento (paridade entre gateways).
- [ ] 4.4 Garantir que eventos `pending`/`awaiting_payment`/`overdue` **não** alterem o plano.

## 5. Testes

- [ ] 5.1 Unit: parser da referência (`premium-monthly-*`, `premium-annual-*`, slug composto,
      lixo → `null`).
- [ ] 5.2 Integração (API): intent autenticado persiste `ExternalSubscriptionId`; intent anônimo →
      401; tenant só-cancelado → trial provisionado + referência; webhook `confirmed` aplica
      Premium + ciclo; webhook `pending` não altera plano; webhook de referência desconhecida segue
      `processed:false`; repetição de evento segue idempotente.
- [ ] 5.3 E2E: atualizar `school-funnel.cy.ts` (dev-mock → `GET /tenant` 200 com `Trial` e
      `externalSubscriptionId`, comentário de limitação atualizado) e `checkout-gateway.cy.ts` se o
      intercept precisar refletir o novo contrato.
- [ ] 5.4 Validar ao vivo com Asaas sandbox (runbook §0.1): checkout → pagamento → webhook →
      `GET /tenant` com `Active` + `Premium` + `externalSubscriptionId`, sem ponte admin;
      `gateway-reconciliation` com flag `ok`.
- [ ] 5.5 Build + `dotnet test` verdes; `npx ng build --configuration development` verde.

## 6. Fechamento

- [ ] 6.1 Registrar no runbook `docs/runbooks/activate-gateways.md` §0.1 a ordem
      checkout → vínculo → webhook → plano.
- [ ] 6.2 Commits: submódulos (`development`) + bump de ponteiro na raiz; mensagens no padrão do
      histórico.
