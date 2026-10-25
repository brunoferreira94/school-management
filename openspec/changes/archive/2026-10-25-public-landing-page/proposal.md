# Landing page pública (raiz do produto)

## Why

No funil ao vivo, a raiz `/` redireciona para `/login` em build sem `devAuth`. A "landing"
anônima é apenas a tela de login — **não há página de produto/marketing pública**. Visitantes
não-autenticados não veem a proposta de valor, diferenciais 2026 ou um CTA direto para
cadastro/preços.

## What Changes

- Nova página pública em `/` (rota sem `authGuard`) com: headline, bullets dos diferenciais
  2026 (régua, IA com revisão, WhatsApp, transparência, portabilidade LGPD), depoimentos,
  CTAs "Saiba mais" (→ `/pricing`) e "Iniciar" (→ `/cadastro`).
- A `/login` continua importada; para visitantes anônimos a raiz NÃO força login.
- `/pricing` já pública permanece; sua CTA primária passa a apontar para `/cadastro` (quando
  não houver sessão) ou `/checkout/:plan` (quando autenticado).

## Impact

- Specs: `public-presence` (nova)
- UI: nova feature `features/public/` (landing, pricing-cta), `app.routes.ts` (root público),
  `pricing-page.component.ts` (CTA conditional)

## Não incluído

- SSR/pre-render: a build atual é estática (`outputMode: "static"`); a landing carrega via
  Angular sem SSR suficiente. Fora do escopo aqui.
