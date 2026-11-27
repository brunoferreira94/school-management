# Tasks — Nudges de upgrade de plano

> Change de **planejamento/UX**. Nenhuma task altera `FeatureGating:Enforce`,
> `Entitlement:Enforce`, preços, checkout ou API.

## Fase 0 — Aprovação

- [ ] 0.1 Dono aprova os 4 títulos/benefícios e os bullets de valor (`design.md` §3.1)
- [ ] 0.2 Definir destino da telemetria (backend `IMetricsService` vs. analytics de frontend)
- [ ] 0.3 Decidir se o modal exibe dados reais de uso (`GET /subscriptions/usage`) e o prazo do piloto

## Fase 1 — Copy e infraestrutura de leitura

- [ ] 1.1 Adicionar chaves i18n pt-BR para os 4 recursos (título, 3 bullets, CTA) em
      `school-management-ui/src/app/i18n-data.ts`
- [ ] 1.2 Escrever copy do modal por motivo (`feature_not_in_plan`, `trial_expired`, genérico)
      com ancoragem em dados reais — sem urgência/prova social inventada
- [ ] 1.3 Serviço de features do plano no front (reaproveitar
      `GET /api/v1/subscriptions/tenants/{tenantId}/features/{featureName}` ou expor as flags no
      DTO do tenant) — **somente leitura**, sem bloqueio
- [ ] 1.4 Buscar contagem real de alunos/turmas para a linha de progresso
      (`GET /api/v1/subscriptions/usage`, já existente); fallback sem número se falhar

## Fase 2 — Superfícies visuais (soft gate)

- [ ] 2.1 `SidebarComponent`: itens dos 4 recursos com cadeado + badge "Premium" e cor atenuada
      quando o plano não inclui a feature
- [ ] 2.2 Clique nesses itens abre `SubscriptionUpgradeDialogComponent` com o motivo
      `feature_not_in_plan` **sem navegar**; rota direta continua funcionando
- [ ] 2.3 Componente de tela "recurso travado": preview desfocada + título + 3 bullets + CTA
      "Desbloquear com Premium" (`/checkout/:plan`) e "Falar com vendas"
- [ ] 2.4 Registrar qual feature originou o nudge (estado no serviço) para escolher o copy certo
- [ ] 2.5 Modal de trial expirado: acrescentar linha de progresso real (alunos/turmas cadastrados)

## Fase 3 — Frequência e telemetria

- [ ] 3.1 Cooldown por feature: `localStorage sma_upgrade_nudge_<feature>` com expiração de 7 dias;
      não reabrir automaticamente no boot
- [ ] 3.2 Eventos `nudge_shown`, `nudge_dismissed`, `upgrade_clicked`, `checkout_started` com props
      `feature`/`plan`/`source`, conforme decisão 0.2
- [ ] 3.3 Não disparar nudge em `/`, `/login`, `/cadastro` nem `/pricing`

## Fase 4 — Verificação

- [ ] 4.1 Testes Karma: serviço de features, cooldown (7 dias), copy por motivo, fallback sem dados
- [ ] 4.2 Cypress: menu com cadeado abre modal e não navega; tela travada com CTA; modal dismiss
      não reaparece na mesma sessão; trial expirado mostra progresso real
- [ ] 4.3 `ng build` (dev + prod) e grep do bundle: nenhuma string de urgência/escassez falsa
- [ ] 4.4 Validar `openspec validate add-plan-upgrade-nudges --strict`
