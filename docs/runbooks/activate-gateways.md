# Runbook — Ativar gateways de pagamento (Asaas + Stripe) em produção

> Change: `openspec/changes/activate-dual-gateway-rollout/`
> Objetivo: fechar o loop de cobrança ponta-a-ponta (checkout → webhook → assinatura `Active`),
> com idempotência, e nunca deixar produção degradar para mock.
> Pré-requisito de código já entregue: `GatewayCheckoutRouter` só usa `MockPaymentCheckoutService`
> em Development/Testing; em Production/Staging sem credenciais, retorna erro explícito (`UnavailableGateway`).

---

## 0. Visão geral do fluxo

```
UI (/checkout/:planId) → POST /api/subscriptions/checkout-intents
    → GatewayCheckoutRouter roteia por billingType:
        PIX/BOLETO/CARNE/BOLETO_PARCELADO → Asaas (BRL)
        CREDIT/DEBIT                     → Stripe (USD)
    → retorna { provider, checkoutUrl, status }
UI redireciona para checkoutUrl (hosted page do provedor)
    → pagamento → provedor chama o webhook:
        Asaas  → POST /api/subscriptions/webhooks/asaas   (header asaas-access-token)
        Stripe → POST /api/subscriptions/webhooks/stripe  (header Stripe-Signature, HMAC)
    → webhook atualiza a assinatura do tenant → Status = Active
```

**Segurança já no código:** ambos os webhooks validam origem (token Asaas / assinatura HMAC Stripe)
e são idempotentes (repetir o mesmo evento não duplica efeito). Rotas de webhook estão fora do
`MutatingRoutes` (não exigem `If-Match`/idempotência de cliente).

---

## 1. Variáveis de ambiente (Render)

Configure no Render (API `school-management-api-sik5` para produção; `school-management-api-dev` para staging).
**PUT substitui o conjunto inteiro** — revise antes de aplicar.

| Variável | Onde obter | Obrigatória para |
|---|---|---|
| `ASAAS_API_KEY` | Painel Asaas → Integrações → API Key (sandbox e produção são chaves diferentes) | checkout BRL (PIX/boleto/carnê) |
| `ASAAS_WEBHOOK_TOKEN` | Painel Asaas → Integrações → Webhook (defina você; é o `asaas-access-token` esperado) | webhook Asaas |
| `STRIPE_SECRET_KEY` | Stripe Dashboard → Developers → API keys (`sk_test_...` / `sk_live_...`) | checkout cartão (USD) |
| `STRIPE_PUBLISHABLE_KEY` | Stripe Dashboard → API keys (`pk_test_...` / `pk_live_...`) | UI (se usar Stripe.js) |
| `STRIPE_WEBHOOK_SECRET` | Stripe → Developers → Webhooks → endpoint → `whsec_...` | webhook Stripe |
| `STRIPE_SUCCESS_URL` | URL da UI de sucesso (ex.: `https://<front>/checkout/success`) | redirect pós-pagamento |
| `STRIPE_CANCEL_URL` | URL da UI de cancelamento (ex.: `https://<front>/checkout/cancel`) | redirect pós-cancelamento |

> `ASPNETCORE_ENVIRONMENT=Production` (produção) / `Staging` (staging) já define qual `appsettings.*.json`
> é carregado. Produção usa `${...}` do `appsettings.Production.json`.

---

## 2. Asaas (BRL — PIX/boleto/carnê)

### 2.1 Conta e chave
1. Criar/entrar na conta Asaas (sandbox: `sandbox.asaas.com`; produção: `www.asaas.com`).
2. **Sandbox primeiro**: gerar API Key de teste e configurar `ASAAS_API_KEY` no Render **de staging**.
3. Validar no staging (passo 4). Só depois gerar a chave de produção.

### 2.2 Webhook
1. No painel Asaas, configurar a URL do webhook:
   - Staging: `https://school-management-api-dev.onrender.com/api/subscriptions/webhooks/asaas`
   - Produção: `https://school-management-api-sik5.onrender.com/api/subscriptions/webhooks/asaas`
2. Definir o mesmo valor em `ASAAS_WEBHOOK_TOKEN` (Render) e no painel Asaas (campo "token de acesso").
3. Confirmar que o header `asaas-access-token` chega com o token configurado (o backend rejeita com 401
   se divergir — ver `SubscriptionsController.ProcessAsaasWebhook`).

### 2.3 Validação ponta-a-ponta (staging)
1. `POST /api/subscriptions/checkout-intents` com `billingType=PIX` → deve retornar `provider=Asaas` e `checkoutUrl` real (domínio Asaas).
2. Abrir o `checkoutUrl`, pagar com PIX de teste (ou cartão de teste do sandbox).
3. Aguardar o webhook → verificar `GET /api/subscriptions/tenant` com `Status=Active`.
4. **Idempotência:** repetir o mesmo evento de webhook (replay) → assinatura permanece `Active`, sem duplicar.

---

## 3. Stripe (USD — cartão)

### 3.1 Conta e chaves
1. Criar conta Stripe (test mode primeiro).
2. Copiar `sk_test_...`/`pk_test_...` e configurar `STRIPE_SECRET_KEY`/`STRIPE_PUBLISHABLE_KEY` no Render de staging.
3. Configurar `STRIPE_SUCCESS_URL` e `STRIPE_CANCEL_URL` apontando para a UI.

### 3.2 Webhook
1. Stripe → Developers → Webhooks → **Add endpoint**:
   - URL: `https://school-management-api-dev.onrender.com/api/subscriptions/webhooks/stripe`
   - Eventos: `checkout.session.completed`, `customer.subscription.updated`, `customer.subscription.deleted`,
     `invoice.payment_failed`, `invoice.payment_succeeded`.
2. Copiar o `whsec_...` (Signing secret) → `STRIPE_WEBHOOK_SECRET` no Render.
3. O backend valida a assinatura HMAC (`StripeWebhookProcessor.VerifySignature`); payload adulterado → rejeitado.

### 3.3 Validação ponta-a-ponta (staging, test mode)
1. `POST /api/subscriptions/checkout-intents` com `billingType=CREDIT` → `provider=Stripe`, `checkoutUrl` do Stripe.
2. Usar cartão de teste Stripe (`4242 4242 4242 4242`, qualquer CVC/data futura).
3. Webhook → `Status=Active`. Repetir evento (Stripe permite "resend") → idempotente.

---

## 4. Promoção para produção

1. **Só promover `development → main` dos submódulos após o founder aprovar** (ver tasks 1 do change).
2. Gerar chaves **live** (`sk_live_...`, Asaas produção) e configurar no Render de produção.
3. Configurar os webhooks de produção (URLs `...-sik5...`).
4. Rodar a suíte E2E de produção (`premium-portal-activation.cy.ts`) e o smoke de checkout.
5. Confirmar `ASPNETCORE_ENVIRONMENT=Production` (senão o `GatewayCheckoutRouter` pode degradar para mock).

---

## 5. Rollback / mitigação

- **Cobrança em produção degradou para mock?** Não deveria (o `UnavailableGateway` impede). Se um checkout
  retornar erro "Gateway não configurado", falta `ASAAS_API_KEY`/`STRIPE_SECRET_KEY` no Render.
- **Webhook não atualiza assinatura:** conferir (a) token/secret, (b) URL pública acessível, (c) evento
  correto configurado no painel, (d) `ExternalSubscriptionId` persistido no checkout intent.
- **Flag de enforcement:** `Entitlement:Enforce=true` bloqueia escrita de trial vencido (402). Para
  desligar em incidente, setar `Entitlement__Enforce=false` no Render e redeployar.

---

## 6. Checklist final (Definition of Done)

- [ ] `ASAAS_API_KEY`/`ASAAS_WEBHOOK_TOKEN` ativos em staging e produção
- [ ] `STRIPE_SECRET_KEY`/`STRIPE_WEBHOOK_SECRET`/`STRIPE_SUCCESS_URL`/`STRIPE_CANCEL_URL` ativos
- [ ] 1 checkout PIX real (sandbox) → webhook → assinatura `Active` (staging)
- [ ] 1 checkout cartão real (test mode) → webhook → assinatura `Active` (staging)
- [ ] Idempotência validada (replay de evento não duplica efeito)
- [ ] `premium-portal-activation.cy.ts` verde em produção
- [ ] Nenhum checkout de produção cai em `MockPaymentCheckoutService` (só dev/testing)