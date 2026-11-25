# Tasks — Vincular checkout ao webhook da assinatura

> Estado: implementada e com suíte verde. Evidência por item entre parênteses.

## 1. Observabilidade do vínculo

- [x] 1.1 Expor `ExternalSubscriptionId` em `TenantSubscriptionDto` e no `MapToDto` de
      `SubscriptionService` (`GET /api/subscriptions/tenant`), sem quebrar contrato de UI.
      (`TenantSubscriptionDto.ExternalSubscriptionId` + `MapToDto` — commit da API)
- [x] 1.2 Adicionar assert de não-regressão no teste de `GET /tenant` (campo presente quando há
      vínculo, `null` quando não há).
      (`CheckoutLinkageIntegrationTests`: `externalSubscriptionId` preenchido após o checkout e
      `null`/ausente na assinatura sem checkout)

## 2. Referência centralizada

- [x] 2.1 Criar helper único de referência (`{planSlug}-{ciclo}-{yyyyMMddHHmmss}`) na camada
      Application — ex.: `Subscriptions/Services/CheckoutReference.cs` — e usá-lo em
      `AsaasCheckoutService` (`:110`), `StripeCheckoutService` (`:93`) e no controller.
      (`CheckoutReference.Create/NormalizeCycle/TryParse/ToBillingCycle`)
- [x] 2.2 `AsaasCheckoutService`/`StripeCheckoutService`: usar `request.ExternalReference` quando
      fornecido e cair no helper quando `null` (mantém os testes unitários atuais intactos).
      (fallback preservado nos dois gateways)
- [x] 2.3 `CreateCheckoutIntentRequest`: adicionar `ExternalReference` (preenchido **sempre** pelo
      controller; valor enviado pelo cliente é ignorado/sobrescrito).
      (`[JsonIgnore]` no DTO + sobrescrita pelo servidor no `CheckoutIntentService`)

## 3. Vínculo no intent

- [x] 3.1 `CreateCheckoutIntent`: trocar `[AllowAnonymous]` por
      `[Authorize(Policy = "Permission:subscriptions.write")]`; resolver `tenantId` via
      `ITenantProvider`.
      (controller fino: delega ao `ICheckoutIntentService`, que usa o tenant do provider)
- [x] 3.2 Resolver assinatura alvo: `GetActiveByTenantIdAsync` → senão
      `ITrialSubscriptionProvisioner.EnsureTrialAsync(tenantId)` (idempotente; cobre o caso de
      assinatura só-cancelada) → recarregar a assinatura ativa.
      (`EnsureTrialAsync` antes do `GetActiveByTenantIdAsync`; caso só-cancelado coberto por teste)
- [x] 3.3 Persistir `ExternalSubscriptionId = "{referência}"` na assinatura **antes** da chamada ao
      gateway; em caso de falha do gateway, **desfazer** o vínculo (não deixar referência órfã;
      próximo checkout sobrescreve de qualquer forma).
      (`CheckoutIntentService`: grava → chama gateway → reverte em falha — unit test dedicado)
- [x] 3.4 Injetar `ITrialSubscriptionProvisioner` onde a orquestração acontece.
      (na camada Application: `CheckoutIntentService`; o controller não carrega regra de negócio)

## 4. Aplicação do plano no webhook

- [x] 4.1 Criar parser da referência (slug + ciclo, split a partir da direita para tolerar slugs com
      hífen) com fallback `null` quando não reconhecer.
      (`CheckoutReference.TryParse` — parse da direita; referência irreconhecível → plano mantido)
- [x] 4.2 No handler do webhook Asaas, quando `MapProviderStatus(...) == Active`, resolver o plano
      por slug e aplicar `SubscriptionPlanId` + `BillingCycle` (parse falhou/plano inexistente →
      mantém plano atual e loga warning, sem falhar o webhook).
      (regra centralizada em `PurchasedPlanApplier`/`IPurchasedPlanApplier`, injetado no controller
      e no `StripeWebhookProcessor`; nunca lança)
- [x] 4.3 `StripeWebhookProcessor`: mesma aplicação de plano quando `MapEventStatus` → `Active`,
      usando o `client_reference_id` do evento (paridade entre gateways).
      (`client_reference_id` → `metadata.external_reference` como fallback)
- [x] 4.4 Garantir que eventos `pending`/`awaiting_payment`/`overdue` **não** alterem o plano.
      (aplicação só na transição para `Active`; coberto por teste de integração)

## 5. Testes

- [x] 5.1 Unit: parser da referência (`premium-monthly-*`, `premium-annual-*`, slug composto,
      lixo → `null`).
      (`CheckoutReferenceTests` — 15 casos; `PurchasedPlanApplierTests` — 4 casos;
      `CheckoutIntentServiceTests` — 5 casos)
- [x] 5.2 Integração (API): intent autenticado persiste `ExternalSubscriptionId`; intent anônimo →
      401; tenant só-cancelado → trial provisionado + referência; webhook `confirmed` aplica
      Premium + ciclo; webhook `pending` não altera plano; webhook de referência desconhecida segue
      `processed:false`; repetição de evento segue idempotente.
      (`CheckoutLinkageIntegrationTests` — 3 testes, todos verdes)
- [x] 5.3 E2E: atualizar `school-funnel.cy.ts` (dev-mock → `GET /tenant` 200 com `Trial` e
      `externalSubscriptionId`, comentário de limitação atualizado) e `checkout-gateway.cy.ts` se o
      intercept precisar refletir o novo contrato.
      (`school-funnel.cy.ts` atualizado; `checkout-gateway.cy.ts` não precisa de ajuste — os
      intercepts de `checkout-intents` seguem válidos)
- [~] 5.4 Validar ao vivo com Asaas sandbox (runbook §0.1): checkout → pagamento → webhook →
      `GET /tenant` com `Active` + `Premium` + `externalSubscriptionId`, sem ponte admin;
      `gateway-reconciliation` com flag `ok`.
      **Parcial** (ver "Evidência da validação ao vivo" abaixo): o sandbox não permite confirmar um
      PIX sem pagador (nem o checkout de cartão headless fecha), então a transição
      `Active` + `Premium` foi validada por teste de integração determinístico, não por sandbox.
- [x] 5.5 Build + `dotnet test` verdes; `npx ng build --configuration development` verde.
      (`dotnet build src/SchoolManagement` → 0 erros; `dotnet test` → 1204 aprovados / 0 falhas /
      5 ignorados; `npx ng build --configuration development` → OK)

## 6. Fechamento

- [x] 6.1 Registrar no runbook `docs/runbooks/activate-gateways.md` §0.1 a ordem
      checkout → vínculo → webhook → plano.
      (seção 0.1 com a ordem explícita e a nota da validação)
- [x] 6.2 Commits: submódulos (`development`) + bump de ponteiro na raiz; mensagens no padrão do
      histórico.
      (API `351d70b`, UI `813fbe2`, raiz: bump de ponteiros + este tasks.md)

## Evidência da validação ao vivo (Asaas sandbox, 2026-11-24/25)

Executada em ambiente local isolado (API em `127.0.0.1:5077`, Postgres local, túnel público,
chave do sandbox lida de `~/.config/opencode/asaas.env` — nunca exposta).

- [x] `POST /api/subscriptions/checkout-intents` autenticado (`diretor.demo`, permissão
      `subscriptions.write`) → cobrança **real** no sandbox Asaas (`pay_0_kh99ax2h2bhdg9`,
      R$ 299,90, PIX) e referência gerada pelo servidor.
- [x] A assinatura do tenant ficou com `externalSubscriptionId = premium-monthly-20261125013724`
      **antes** da cobrança (Trial/Free nesse instante).
- [x] A cobrança lida de volta na API do Asaas (`GET /v3/payments/{id}`) traz
      `externalReference` **idêntico** ao valor persistido localmente — é o elo que faltava.
- [x] Um evento **real** do Asaas (`PAYMENT_CREATED`, `id evt_05b708f9…&25927121`,
      `User-Agent: Asaas_Hmlg/3.0`, header `asaas-access-token` correto) chegou ao endpoint
      público via túnel e respondeu `200`; o replay do payload capturado gravou o marcador real
      `asaas-event:evt_05b708f9…&25927121` na assinatura (evento `pending` → plano **não** muda).
- [x] Token inválido → `401` (fail-closed) no mesmo endpoint público.
- [ ] Pagamento **confirmado** no sandbox → `Active` + `Premium`: não reproduzível — o sandbox não
      simula o pagador de PIX e o checkout de cartão do sandbox não fecha em navegador headless
      (captcha). O caminho `confirmed → Active + Premium` fica coberto pelo teste de integração
      `CheckoutLinkageIntegrationTests.CheckoutVinculaReferencia_EWebhookConfirmadoAplicaPlanoComprado`.
- [x] Webhook do sandbox desabilitado ao final (`enabled=false`) e pagamentos de teste apagados.
