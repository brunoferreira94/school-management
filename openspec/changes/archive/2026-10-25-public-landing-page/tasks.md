# Tasks — Landing page pública

## 1. UI — página
- [x] 1.1 `features/public/landing/landing-page.component.{ts,html,scss}` standalone — criado e commitado em `01d7adb` (feat(landing+cadastro+checkout))
- [x] 1.2 Headline + bullets diferenciais 2026 + depoimentos + CTAs — hero `Gestão escolar inteligente para o futuro`, grid `Diferenciais 2026`, CTAs Iniciar/Saiba mais no hero e header (Planos/Entrar/Começar grátis)

## 2. Rotas
- [x] 2.1 Raiz `/` carrega a landing via `home.routes HOME_DEFAULT_ROUTES` sem authGuard (2026-10-25). `index.html` early-redirect INVERTIDO: antes o script mandava anônimo de `/` para `/login` (escondia a landing inteira); agora anônima fica na landing e a sessão existente vai para `/home`
- [x] 2.2 Visitante anônimo vê a landing em `/` e o login só ao clicar Entrar — consagrado no E2E `public-landing.cy.ts` (visit `/` anônimo não escapa para `/login`)
- [x] 2.3 `/pricing` pública; CTA primária → `/cadastro` (anônimo), `/checkout/:plan` (autenticado) — `PricingPageComponent.getCheckoutUrl` passa a considerar o ESTADO DE SESSÃO (`AuthService.isAuthenticated()`); `?new=1`/`?existing=1` sobrescrevem para o funil público

## 3. Pricing CTA
- [x] 3.1 `PricingPageComponent`: botão Iniciar → `/cadastro` sem sessão, `/checkout/:plan` com sessão — mesmo método `getCheckoutUrl` usado nos cards; o CTA do rodapé (`CTA_START_FREE`) foi wired com `getBottomCtaUrl()` mesma heurística. Note: no build e2e o devAuth semeia `dev-token` (todos ficam "autenticados") — a fronteira anônima é exercida em produção/espec com `?new=1`

## 4. Testes
- [x] 4.1 E2E `public-landing.cy.ts`: visita `/` anônimo → headline + CTAs visíveis, sem redirect para /login (2026-10-25)
- [x] 4.2 E2E `public-landing.cy.ts`: CTA "Iniciar teste grátis" → `/cadastro"; "Saiba mais" → `/pricing` (2026-10-25)

> Extra do escopo (regressão revelada pelo funnel live): checkout-intents agora envia o **slug** do plano (`premium`), não o id (contrato real dos gateways Asaas/Stripe/Mock — rodou 400 "Apenas o plano Premium" no funnel live). Ajustes em `checkout-page.component.ts` + `subscription.service` (expõe `slug` no `SubscriptionPlan`).
> Nota honesta: o spec `monetization-plans-checkout.cy.ts` (julho/2026, slice antigo) tem rot pré-existente — 12/26 testes falham antes e depois das mudanças de hoje (overlay de boas-vindas cobre elementos, classes/classes de loading desatualizadas). Não é resultado desta change.

## Ordem
Landing → rotas → CTA pricing → E2E
