# Tasks — Conectar checkout ao gateway (checkout-intents)

## 1. API (mock local)
- [x] 1.1 `GET /api/dev/checkout/return/{id}` devolve o status mockado (só em Development) — existente, verificado
- [x] 1.2 `GatewayCheckoutRouter` degrada para `MockPaymentCheckoutService` com chaves vazias (PIX/BOLETO/CARNE→Asaas|mock; CREDIT/DEBIT→Stripe|mock; default→Asaas|mock) — existente
- [x] 1.3 `CheckoutIntentResponse` expõe `CheckoutUrl` + `Amount`/`Currency` (BRL) no mock — verificado via E2E local (200 com `checkoutUrl` demo-payments.local)

## 2. UI — subscription.service
- [x] 2.1 `createCheckoutIntent(payload)` exportado e usado pela checkout-page
- [x] 2.2 `getTenantSubscription()` existe (`features/subscriptions/data/subscription.service.ts`); aceite de termos é fluxo próprio do ToU (`/privacy/terms-of-use/accept`), não do checkout

## 3. UI — checkout-page
- [x] 3.1 `setTimeout`/`createSubscription` já substituídos pelo `createCheckoutIntent`
- [x] 3.2 Payload envia `Plan`, `BillingCycle`, `BillingType` (PIX/BOLETO/CREDIT via seletor), `Name`, `Email`, `Document`, `TotalPrice` — **fix de bug real (2026-10-24)**: o submit antigo lia `cardForm.value.name/email` inexistentes → payload sem nome/e-mail → 400 do backend; form agora tem name/email/cpf próprios
- [x] 3.3 Redirect para `checkoutUrl` real via `window.open(url, '_self')`; checkoutUrl do mock (demo-payments.local) segue **retorno interno** em vez de sair do app para um domínio inexistente
- [x] 3.4 Retorno do mock consulta `GET /subscriptions/tenant` antes de navegar para success (nota honesta: sem gateway real não há webhook — assinatura permanece Trial; Active pende de webhook em staging/produção)
- [x] 3.5 Campos de cartão apenas para CREDIT (validators condicionais em `setBillingType`); PIX/BOLETO pedem só nome/e-mail/CPF

## 4. Mock local (sem credenciais reais)
- [x] 4.1 `MockPaymentCheckoutService` devolve `https://demo-payments.local/checkout/{id}` (parcial: response stateless — persistência in-memory desnecessária no fluxo dev atual, o status vem do dev-route 1.1)
- [ ] 4.2 Dev return aplicar a assinatura como `Active` — pende de simulação de webhook (o dev-route só ecoa `COMPLETED`); fluxo real Active depende de credenciais Asaas/Stripe no staging

## 5. Testes
- [x] 5.1 E2E `checkout-gateway.cy.ts` (2026-10-25, cypress): intent criado com payload completo, redirect `window.open(url,'_self')` ao gateway real, retorno interno do mock dev consulta a assinatura e conclui em success; `Active` real ao voltar pende do webhook do provedor (staging/chaves). Complementado pelos 4 testes unitários de `checkout-page.component.spec.ts` (payload PIX, redirect real, retorno interno do mock, validators condicionais) e E2E curl local
- [x] 5.2 E2E `checkout-gateway.cy.ts` (2026-10-25): nenhuma chamada a POST /subscriptions/tenant no fluxo de pagamento (verificado por flag no intercept) — assinatura só via webhook; cartão exigido apenas em CREDIT — onda de E2E local (Cypress)
- [x] 5.3 `GatewayCheckoutRouterTests` cobre roteamento (BRL→Asaas, Card→Stripe, chaves vazias→Mock)

## Ordem de implementação
Gateway → UI checkout → dev return → E2E
