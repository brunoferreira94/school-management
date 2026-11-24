## Context

Evidência coletada na validação do webhook Asaas sandbox (2026-11-24) e na leitura do código:

- `SubscriptionsController.CreateCheckoutIntent` (`:114`) apenas repassa ao
  `_subscriptionGateway.CreateCheckoutIntentAsync`; o controller **não** persiste nada e a resposta
  (`CheckoutIntentResponse`) não carrega a referência externa.
- A referência é gerada **dentro** de cada gateway, idêntica: `premium-{ciclo}-{timestamp}`
  (`AsaasCheckoutService.cs:110`, `StripeCheckoutService.cs:93`); o Stripe a envia como
  `client_reference_id` + `metadata[external_reference]`.
- O webhook Asaas casa só por `GetByExternalSubscriptionIdAsync` (`:147`) e depois grava
  `Status`/`ExternalCustomerId`/`ExternalSubscriptionId`/`Notes` (`:168-184`) — nenhuma escrita de
  `SubscriptionPlanId`.
- `MapProviderStatus` (`:691`): `received|confirmed|received_in_cash → Active`, `pending|awaiting_payment → Trial`,
  `overdue → PastDue`, `refunded|canceled|cancelled → Cancelled`.
- `GetTenantSubscriptionAsync` filtra por `GetActiveByTenantIdAsync` (Active/Trial) → 404 quando só
  existe linha cancelada.
- `TrialSubscriptionProvisioner.EnsureTrialAsync` só cria quando não há Active/Trial (idempotente);
  portanto cria uma nova linha trial mesmo quando existe apenas linha cancelada.
- `CancelTenantSubscriptionAsync` marca `Status=Cancelled` (não apaga), então o histórico é
  preservado e um novo trial pode coexistir.
- Gateways mock: `MockPaymentCheckoutService` não gera referência nem dispara webhook (dev sem
  credenciais) — o vínculo persistido nele é inerte.

Restrições:
- Não expor/derivar plano sem pagamento confirmado: aplicar plano no intent entregaria Premium
  durante o trial sem cobrança.
- `SubscriptionStatus` não tem `Pending`; a transição `pending → Trial` do webhook precisa continuar
  não aplicando plano.
- Compatibilidade com os E2E existentes: `checkout-gateway.cy.ts` e `asaas-sandbox.cy.ts` stubam
  `checkout-intents` (não quebram com auth); `school-funnel.cy.ts` exercita o endpoint real em
  dev-mock e precisa ser atualizado.

## Goals / Non-Goals

- Goals:
  - Todo checkout autenticado grava o vínculo local **antes** de criar a cobrança no provedor.
  - Pagamento confirmado ativa a assinatura **no plano comprado** e no ciclo comprado.
  - Webhook continua idempotente e tolerante a referências desconhecidas.
  - Verificação ponta-a-ponta possível via `GET /api/subscriptions/tenant`.
- Non-Goals:
  - Renovação/`CurrentPeriodEndsAtUtc` na ativação (billing-cadence existente; follow-up se a
    reconciliação apontar divergência).
  - Stripe test mode ao vivo (rollout separado).
  - Tabela dedicada de checkout-intents.

## Decisions

- **Decisão: persistir o vínculo no intent, antes de chamar o gateway.** O controller gera a
  referência e grava `ExternalSubscriptionId` na assinatura alvo; só depois chama o gateway.
  - Motivo: elimina a corrida com o webhook `PAYMENT_CREATED`, que o Asaas dispara imediatamente
    após criar a cobrança. Persistir depois da resposta deixaria uma janela em que o evento chegaria
    órfão.
  - Falha do gateway depois da gravação é inofensiva: a referência fica sem cobrança correspondente
    e o próximo checkout a sobrescreve.
- **Decisão: referência gerada centralmente (helper único) e repassada ao gateway.** Evita divergir
  o formato entre Asaas/Stripe/controller e permite que o webhook faça o parse com garantia de
  formato. Gateways mantêm a geração própria como fallback quando o campo vem `null` (chamadas
  diretas em testes unitários).
- **Decisão: `checkout-intents` exige tenant autenticado com `Permission:subscriptions.write`.**
  - Motivo: sem tenant não há assinatura para vincular; a operação escreve estado de cobrança do
    tenant. É o mesmo gate de `POST/DELETE /subscriptions/tenant`, e o cenário de spec
    "Anonymous user is not redirected" já determina que anônimo não cria intent.
  - O valor de `ExternalReference` vindo do cliente é **sempre sobrescrito** pelo servidor, o que
    também fecha a possibilidade de um tenant gravar referência arbitrária (o match do webhook é
    global, por referência).
- **Decisão: `EnsureTrialAsync` quando não houver assinatura ativa.** Garante o invariante "todo
  tenant tem assinatura" e cobre o fluxo de recompra após cancelamento.
  - Efeito aceito e explícito: recompra após cancelar provisiona um novo trial **no plano Free**
    (mesmas regras do cadastro); Premium só é aplicado quando o pagamento é confirmado pelo webhook.
- **Decisão: aplicar plano + ciclo no webhook, só na transição para `Active`.** O plano é derivado
  da própria referência (`{slug}-{ciclo}-{timestamp}`, parse a partir da direita para tolerar slugs
  com hífen). Referência não parseável ou slug inexistente → mantém o plano atual e loga warning,
  sem falhar o webhook (assinatura ainda ativa pelo status).
  - Motivo: o webhook é a única fonte confiável de "pagamento confirmado" e já é idempotente por
    marcador em `Notes`.
- **Decisão: paridade no Stripe.** `StripeWebhookProcessor` aplica o mesmo plano ao mapear
  `checkout.session.completed`/equivalente para `Active`, usando `client_reference_id` do evento
  (disponível mesmo depois de `ExternalSubscriptionId` migrar para `sub_*`).

## Alternatives considered

- **Aplicar plano no intent (plan-at-checkout).** Entregaria Premium/Enterprise no trial antes de
  qualquer pagamento — vazamento de receita. Recusado.
- **Criar a assinatura já no plano comprado com `Status=Pending`.** O enum `SubscriptionStatus` não
  tem `Pending`; `Trial`/`PastDue` concedem ou bloqueiam de forma diferente e distorceriam
  entitlements e a reconciliação. Recusado.
- **Fallback do webhook por e-mail do cliente (`ExternalCustomerId`/e-mail).** Frágil: o
  `ExternalCustomerId` só é gravado pelo próprio webhook; e-mail não é chave única confiável.
  Recusado.
- **Tabela nova de checkout-intents (intent → referência → assinatura).** Resolveria múltiplos
  checkouts simultâneos, mas exige migration e não é necessária: a referência pertence à assinatura
  do tenant e o último checkout vale. Recusado (pode voltar se houver pagamentos paralelos).
- **Persistir o vínculo depois da chamada ao gateway (usando a referência devolvida na resposta).**
  Abre janela de corrida com `PAYMENT_CREATED`. Recusado.

## Risks / Trade-offs

- **Recompra após cancelamento cria novo trial Free.** Aceito: mesma semântica do cadastro e sem
  concessão de plano pago.
- **`school-funnel.cy.ts` muda de 404 para 200 (`Trial`).** É consequência direta de a assinatura
  passar a existir no intent; o comentário de limitação documentada é atualizado na mesma task.
- **`CurrentPeriodEndsAtUtc` não é ajustado na ativação.** Mantém o comportamento atual; a renovação
  continua regida pela cadência existente. Se a reconciliação apontar cobrança fora de janela, vira
  change próprio.
- **Parse da referência acopla webhook ao formato.** Mitigado pelo helper único + fallback
  gracioso + testes dedicados.
