# Tasks — Nudges de upgrade de plano

> Change de **planejamento/UX**. Nenhuma task alterou `FeatureGating:Enforce`,
> `Entitlement:Enforce`, preços, checkout ou API.

## Fase 0 — Aprovação

- [x] 0.1 Dono aprovou os 4 títulos/benefícios e os bullets (proposta em `design.md` §3.1) — seguiu com "pode seguir"
- [x] 0.2 Telemetria: destino padrão = `window.dataLayer` do frontend (se existir), sem mudança na API
- [x] 0.3 Modal exibe dados reais de uso (`GET /subscriptions/tenant/usage`); sem prazo de piloto

## Fase 1 — Copy e infraestrutura de leitura

- [x] 1.1 Chaves i18n pt-BR para os 4 recursos + modal em `i18n-data.ts` (bloco `UPSELL`, 23 chaves)
- [x] 1.2 Copy por motivo (`feature_not_in_plan`, `trial_expired`, genérico) com ancoragem em dados
      reais — sem urgência/prova social inventada
- [x] 1.3 `PlanUpgradeService` lê o plano via `GET /subscriptions/tenant` (somente leitura, sem bloqueio)
- [x] 1.4 `SubscriptionService.getUsage()` → `GET /subscriptions/tenant/usage`; fallback sem número

## Fase 2 — Superfícies visuais (soft gate)

- [x] 2.1 Sidebar: itens com cadeado + badge "Premium" e cor atenuada quando Free
- [x] 2.2 Clique nesses itens abre `SubscriptionUpgradeDialogComponent` sem navegar; rota direta intacta
- [x] 2.3 Tela `/premium/:feature` com preview desfocada, título, 3 bullets e CTA "Desbloquear"
- [x] 2.4 `currentFeature` no serviço escolhe o copy certo por recurso
- [x] 2.5 Modal de trial expirado com linha de progresso real (alunos/unidades)

## Fase 3 — Frequência e telemetria

- [x] 3.1 Cooldown por feature: `localStorage sma_upgrade_nudge_<feature>` com 7 dias; clique manual sempre abre
- [x] 3.2 Eventos `nudge_shown`, `nudge_dismissed`, `upgrade_clicked`, `checkout_started` com
      `feature`/`plan`/`source` no `dataLayer`
- [x] 3.3 Nudge automático apenas na tela `/premium/:feature` — não dispara em `/`, `/login`, `/cadastro`, `/pricing`

## Fase 4 — Verificação

- [x] 4.1 Karma: `plan-upgrade.service.spec.ts` 7/7 (travamento por plano, cooldown, dismiss, dados reais)
- [x] 4.2 Cypress `plan-upgrade-nudges.cy.ts` 3/3 (menu travado sem navegar, preview, cooldown no reload)
- [x] 4.3 `ng build` (dev + prod) OK; bundle sem strings de urgência/escassez falsa
- [x] 4.4 `openspec validate add-plan-upgrade-nudges --strict` OK; suíte Karma 832/832
