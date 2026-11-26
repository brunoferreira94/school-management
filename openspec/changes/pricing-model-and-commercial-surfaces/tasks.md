# Tasks — modelo de preços e superfícies comerciais

> Fase 1 independe da decisão A/B/C e pode ser executada após aprovação do change.
> Fase 2 **só começa** com a escolha do dono registrada no `design.md`.

## Fase 0 — Decisão (bloqueia a fase 2)

- [x] 0.1 Dono escolhe **A / B / C** e aprova os números-piloto (se B) — registrar no `design.md`
      → **26/11: B (híbrido) com faixa de entrada plana, §6 do `design.md`**
- [ ] 0.2 Definir regra **trial→Free** (expira / cai no Free / somente-leitura) — `design.md` §4.2
- [ ] 0.3 Definir **oferta do Free** (quais features ficam de fora) — `design.md` §4.3

## Fase 1 — Superfícies comerciais coerentes

- [ ] 1.1 Traduzir as ~30 strings placeholder da `/pricing` para pt-BR
      (`school-management-ui/src/app/i18n-data.ts:752-795`: `HERO_TITLE`, `CTA_START`,
      `PRICE_ON_REQUEST`, `PLAN_FEATURE_*`, `COMPARISON_*`, `FAQ_*`…)
- [ ] 1.2 Free exibido como **R$ 0** (não "Price On Request"); CTA "Cta Start"/"Cta Sales" reais
      (`pricing-page.component.html` + `formatPrice` em `pricing-page.component.ts`)
- [ ] 1.3 Tabela de comparação da `/pricing` passa a usar **os limites do catálogo** (API), fim do
      hardcoded `comparisonFeatures` (`pricing-page.component.ts:31-45`)
- [ ] 1.4 Tela interna "Planos Disponíveis" consome o mesmo catálogo — remover a 3ª tabela
      (`subscriptions.component.html:35-60`)
- [x] 1.5 Corrigir `docs/plans/pricing-page.md`: desconto anual **16,7%** (não 15%), trial
      **14 dias** (não 30) e nota do modelo aprovado (fase 2)
- [x] 1.6 Aplicar `EnsureSchoolUnitLimitAsync` na criação de unidade escolar
      (`SubscriptionLimitService.cs:54` não tinha callers) + teste
      (API `4990a07`, `SchoolUnitServiceTests` 3/3; suíte 1222/0, 5 skips)
- [ ] 1.7 Teste de superfície comercial: falha se existir placeholder i18n em inglês na `/pricing`
      ou preço/limite hardcoded divergente do catálogo (Cypress spec dedicada)
- [ ] 1.8 Validar: `ng build` + Karma verde; bundle de produção sem placeholders (grep)

## Fase 2 — Modelo de cobrança (após 0.1)

- [ ] 2.1 Seeder/catálogo com o modelo aprovado (`design.md` §6): Premium R$ 149 inclui 150
      alunos + 1 un.; Enterprise R$ 499 inclui 500 alunos + 3 un.; variáveis e mínimos + migration
- [ ] 2.2 Metering por tenant: contagem de alunos ativos e unidades escolares para cálculo de preço
- [ ] 2.3 Cálculo de preço (base + R$/aluno com teto + R$/unidade) no backend + endpoint de consulta
- [ ] 2.4 Checkout: valor variável criado corretamente no ciclo (Asaas não propaga update de valor
      para charges já geradas — spec `asaas-plan-catalog`)
- [ ] 2.5 UI: preço "a partir de" + simulador (alunos/unidades) na `/pricing`
- [ ] 2.6 Feature gating por plano (`CheckSubscriptionFeatureAsync` + middleware/UI) e regra
      trial→Free (0.2) antes de ligar `Entitlement:Enforce`
- [ ] 2.7 Migração dos tenants existentes + doc comercial (`docs/plans/pricing-page.md`)
- [ ] 2.8 Testes: unit (cálculo), integração (limites/gating), Cypress (checkout variável)

## Fase 3 — Cobrança real

- [ ] 3.1 Asaas de produção: `Asaas__ApiBaseUrl=https://api.asaas.com/v3` + chave de produção
      (Render env vars; **não** `PUT` que substitui o conjunto — merge com `GET ?limit=100`)
- [ ] 3.2 Webhook token cadastrado no painel Asaas (ação manual do dono)
- [ ] 3.3 Preço-piloto do primeiro cliente (R$ 399–499/mês por 6 meses) com cláusula de revisão
- [ ] 3.4 Smoke pós-ativação: checkout → webhook → status `ACTIVE` → reconciliação `ok`