# Tasks — modelo de preços e superfícies comerciais

> Fase 1 independe da decisão A/B/C e pode ser executada após aprovação do change.
> Fase 2 **só começa** com a escolha do dono registrada no `design.md`.

## Fase 0 — Decisão (bloqueia a fase 2)

- [x] 0.1 Dono escolhe **A / B / C** e aprova os números-piloto (se B) — registrar no `design.md`
      → **26/11: B (híbrido) com faixa de entrada plana, §6 do `design.md`**
- [x] 0.2 Definir regra **trial→Free** → **26/11: trial vencido = somente-leitura + upsell** (§7)
      — backend 402 já existe, falta o modal na UI (task 2.7)
- [x] 0.3 Definir **oferta do Free** (quais features ficam de fora) — `design.md` §4.3: Free mantém
      gestão básica + portal admin; sem portal do responsável, financeiro, analytics, API, suporte
      prioritário e branding

## Fase 1 — Superfícies comerciais coerentes

- [x] 1.1 Traduzir as ~30 strings placeholder da `/pricing` para pt-BR
      (`school-management-ui/src/app/i18n-data.ts:752-795`: `HERO_TITLE`, `CTA_START`,
      `PRICE_ON_REQUEST`, `PLAN_FEATURE_*`, `COMPARISON_*`, `FAQ_*`…) — 51 chaves no total
- [x] 1.2 Free exibido como **R$ 0** (não "Price On Request"); CTA "Começar grátis" (Free) e
      "Escolher plano" (pagos)
- [x] 1.3 Tabela de comparação da `/pricing` passou a usar **os limites do catálogo** (API), fim do
      hardcoded `comparisonFeatures` (`pricing-page.component.ts`)
- [x] 1.4 Tela interna "Planos Disponíveis" consome o mesmo catálogo — fim da 3ª tabela
      (`subscriptions.component.html`/`.ts`)
- [x] 1.5 Corrigir `docs/plans/pricing-page.md`: desconto anual **16,7%** (não 15%), trial
      **14 dias** (não 30) e nota do modelo aprovado (fase 2)
- [x] 1.6 Aplicar `EnsureSchoolUnitLimitAsync` na criação de unidade escolar
      (`SubscriptionLimitService.cs:54` não tinha callers) + teste
      (API `4990a07`, `SchoolUnitServiceTests` 3/3; suíte 1222/0, 5 skips)
- [x] 1.7 Teste de superfície comercial: `cypress/e2e/pricing-commercial-surface.cy.ts` falha se
      existir placeholder i18n em inglês/chave crua ou preço divergente do catálogo (2/2)
- [x] 1.8 Validação: `ng build` (dev + prod) OK; bundle de produção sem placeholders (grep);
      Karma 820/820 (1 flaky conhecido do OfflineDraftService convergiu na rerun)

## Fase 2 — Modelo de cobrança (após 0.1)

- [x] 2.1 Seeder/catálogo com o modelo aprovado (`design.md` §6): Premium R$ 149 inclui 150
      alunos + 1 un.; Enterprise R$ 499 inclui 500 alunos + 3 un.; variáveis e mínimos + migration
      `20261127073152_AddHybridPricingFields`
- [x] 2.2 Metering por tenant: `SubscriptionPriceService.CalculateForTenantAsync` conta alunos
      (`ListByTenantPagedAsync`) e unidades (`ListByTenantAsync`)
- [x] 2.3 Cálculo de preço (base + R$/aluno com teto + R$/unidade + piso) no backend + endpoint
      `GET /api/v1/subscriptions/price-quote` (cotação por tenant ou simulador público);
      `SubscriptionPriceServiceTests` 12/12, suíte API 1234/0 (5 skips)
- [x] 2.4 Checkout: `CheckoutIntentService` calcula o preço com metering do tenant e grava
      `ServerPrice` (JsonIgnore) antes de chamar o gateway; Asaas/Stripe usam esse valor.
      `CheckoutIntentServiceTests` 4/4 (valor do cliente é ignorado); suíte API 1235/0
- [x] 2.5 UI: `/pricing` mostra "a partir de" e tem simulador de alunos/unidades/ciclo que
      consome `GET /subscriptions/price-quote`; Cypress 3/3 (inclui cotação R$ 524 para 300 alunos),
      Karma 824/824
- [x] 2.6 Modal de upgrade na UI: `SubscriptionUpgradeService` + interceptação de `402
      subscription_expired` no `errorToastInterceptor` (com precedência sobre `SKIP_ERROR_TOAST`)
      e dialog global com planos do catálogo + CTA `/checkout/:plan` (`design.md` §7) — pré-requisito
      para ligar `Entitlement:Enforce`. Cypress `subscription-upgrade-modal.cy.ts` 2/2,
      `error-toast.interceptor.spec.ts` 4/4, Karma 824/824
- [ ] 2.7 Feature gating por plano (`CheckSubscriptionFeatureAsync` + middleware/UI) e migração dos
      tenants existentes + doc comercial (`docs/plans/pricing-page.md`)
- [ ] 2.8 Testes: unit (cálculo), integração (limites/gating/402), Cypress (modal de upgrade e
      checkout variável)
- [x] 2.9 Ativar `Entitlement__Enforce` no **staging** — janela verificada em 27/11 07:13 UTC
      (`offline-sync-gate-closure-2026-11-27.md`: Δmissing=0, Δconflitos=0 em 33.570 ops);
      env var aplicada (25 vars), deploy `dep-dc4irc61egvs738jggjg` live, smoke 200/402/201/204
      e modal Cypress 2/2. Nova base do gate: `offline-sync-gate-base-2026-11-27.json`.
      Runbook: `docs/runbooks/entitlement-enforce-staging.md`

## Fase 3 — Cobrança real

- [ ] 3.1 Asaas de produção: `Asaas__ApiBaseUrl=https://api.asaas.com/v3` + chave de produção
      (Render env vars; **não** `PUT` que substitui o conjunto — merge com `GET ?limit=100`)
- [ ] 3.2 Webhook token cadastrado no painel Asaas (ação manual do dono)
- [ ] 3.3 Preço-piloto do primeiro cliente (R$ 399–499/mês por 6 meses) com cláusula de revisão
- [ ] 3.4 Smoke pós-ativação: checkout → webhook → status `ACTIVE` → reconciliação `ok`