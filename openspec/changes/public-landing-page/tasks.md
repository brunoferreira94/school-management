# Tasks — Landing page pública

## 1. UI — página
- [ ] 1.1 Criar `features/public/landing/landing-page.component.{ts,html,scss}` (standalone)
- [ ] 1.2 Headline + bullets diferenciais 2026 + depoimentos + CTAs (Saiba mais → /pricing,
      Iniciar → /cadastro)

## 2. Rotas
- [ ] 2.1 `app.routes.ts`: a raiz `/` passa a carregar a landing page diretamente (sem `authGuard`)
      — atualmente redireciona para `/login`
- [ ] 2.2 Garantir que visitantes anônimos veem a landing em `/` e login só ao clicar em entrar
- [ ] 2.3 `/pricing` continua pública; CTA primária aponta para `/cadastro` (anon) ou
      `/checkout/:plan` (autenticado)

## 3. Pricing CTA
- [ ] 3.1 `PricingPageComponent`: botão "Iniciar" → `/cadastro` se não autenticado,
      `/checkout/:plan` se autenticado

## 4. Testes
- [ ] 4.1 E2E: visita `/` anônimo → landing com headline + CTAs; não redireciona para /login
- [ ] 4.2 E2E: CTA "Iniciar" na landing → `/cadastro`; CTA "Saiba mais" → `/pricing`

## Ordem
Landing → rotas → CTA pricing → E2E
