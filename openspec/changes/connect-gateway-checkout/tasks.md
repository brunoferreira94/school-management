# Tasks — Conectar checkout ao gateway (checkout-intents)

## 1. API (mock local)
- [ ] 1.1 Em `Environment/development` (e2e), registrar uma rota controller `GET /api/dev/checkout/return/{id}` que devolve o status do *intent* mockado (simula o retorno do provedor após pagamento)
- [ ] 1.2 Garantir que `GatewayCheckoutRouter` degrade para `MockPaymentCheckoutService` quando `Asaas:ApiKey` e `Stripe:SecretKey` estão vazios (já implementado — validar com teste de roteamento)
- [ ] 1.3 `CheckoutIntentResponse` já expõe `CheckoutUrl`; confirmar shape `Amount`/`Currency` no mock

## 2. UI — subscription.service (raiz)
- [ ] 2.1 Exportar `createCheckoutIntent(payload)` (existe em `src/app/services/subscription.service.ts`) no serviço de checkout
- [ ] 2.2 Adicionar helpers: `getTenantSubscription()`, `acceptTerms()` (se não exportados)

## 3. UI — checkout-page
- [ ] 3.1 Substituir o `setTimeout` + `createSubscription` pelo `createCheckoutIntent`
- [ ] 3.2 Enviar `Plan`, `BillingCycle`, `BillingType` (PIX/BOLETO/CREDIT), `Name`, `Email`, `Document`, `TotalPrice`
- [ ] 3.3 Redirecionar para `checkoutUrl` (abrir em nova aba no dev; no mobile usar redirect)
- [ ] 3.4 Na rota de retorno, consultar `GET /subscriptions/tenant` e navegar para `success` (ou `cancel`)
- [ ] 3.5 Remover o formulário de cartão mock se for pagamento via *redirect* (PIX/boleto) — manter para CREDIT apenas se o gateway exigir

## 4. Mock local (sem credenciais reais)
- [ ] 4.1 `MockPaymentCheckoutService` devolve URL `https://demo-payments.local/checkout/{id}` e persiste o *intent* em memória
- [ ] 4.2 Em dev, a página de retorno do mock marca o *intent* como `COMPLETED` e aplica a assinatura no backend (simula webhook)

## 5. Testes
- [ ] 5.1 E2E: checkout autenticado redireciona para o checkout do provider e a assinatura é criada como `Active` ao voltar (sem `setTimeout`)
- [ ] 5.2 E2E: checkout anônimo continua na página (não cria assinatura)
- [ ] 5.3 Unitário: `GatewayCheckoutRouter` escolhe mock quando chaves vazias

## Ordem de implementação
Gateway → UI checkout → dev return → E2E
