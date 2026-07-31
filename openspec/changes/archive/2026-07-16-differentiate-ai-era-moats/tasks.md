## 1. Moat 2 — Expansion architecture (convite real de professores)

- [x] 1.1 API: criar `POST /api/onboarding/invite-teacher` (estender `OnboardingController`) que gera link mágico de convite (token assinado, sem senha) e registra o convite no `SetupProgress`
- [x] 1.2 API: criar `POST /api/onboarding/accept-invite` que consome o token, cria/ativa o professor no tenant e marca `teacherActivated` no `SetupProgress`
- [x] 1.3 API: estender `SetupProgress` com campo `TeachersInvited` (count) e `TeachersActivated` (count) para o checklist refletir o loop fechado
- [x] 1.4 UI: `activation-checklist` — passo "Convidar professores" dispara `invite-teacher` (não só marca local) e mostra estado de "convidado / ativo"
- [x] 1.5 UI: tela de aceite de convite (rota `/invite/:token`) com formulário mínimo de nome + confirmação

## 2. Moat 1 — Switching cost via UX internalizada (caminho do diretor)

- [x] 2.1 UI: `activation-checklist` evolui para sequência de micro-loops repetíveis (nota→boletim→comunicado→cobrança) com estado persistido no backend
- [x] 2.2 UI: cada loop concluído mostra "próximo passo sugerido" baseado no uso real (não lista estática)
- [x] 2.3 API: `SetupProgress` ganha campos de micro-loop (`LastGradeEntryAt`, `LastReportCardViewedAt`, `LastAnnouncementAt`, `LastPaymentAt`) para o backend orientar o próximo passo
- [x] 2.4 UI: celebração de micro-loop (`activation-celebration`) reutilizada para cada loop, não só no seed

## 3. Atenção militante — "tela de hoje"

- [x] 3.1 UI: `home.component` ganha modo "tela de hoje" com 1 ação primária (item mais urgente: inadimplência > faltas > evento)
- [x] 3.2 UI: widgets antigos mantidos como toggle "ver dashboard completo" (fallback, não competem por atenção no default)
- [x] 3.3 UI: `tela de hoje` usa `activation-checklist` como primário no primeiro dia, transiciona para "tela de hoje" após conclusão do onboarding

## 4. Moat 3 — Brand Power / visual confidence

- [x] 4.1 UI: criar design tokens proprietários (`styles/escola-brand.scss`) — cor ESCOLA+ `#4f46e5`, raio 12px, sombra de confirmação, pulse de marca
- [x] 4.2 UI: aplicar tokens em `onboarding-welcome`, `activation-checklist`, `micro-loops`, `activation-celebration`
- [x] 4.3 UI: micro-interação de 200ms de confirmação (`EscolaConfirmPulseDirective`) em ações críticas (convidar professor)

## 5. Human touch

- [x] 5.1 UI: componente de erro gentil com recovery (`shared/error-recovery`) — "Ops, [contexto]. Quer [ação recuperável]?"
- [x] 5.2 UI: 404 que retorna o usuário (busca sugestão de rota + botão voltar ao dashboard)
- [x] 5.3 UI: mensagens de erro de API mapeadas para tom humano (não "500 Internal Server Error")

## 6. Testes E2E (Cypress)

- [x] 6.1 `cypress/e2e/rcd-moats-flow.cy.ts`: testar convite de professor (invite → accept → checklist mostra ativo)
- [x] 6.2 `cypress/e2e/rcd-moat4-today-focus.cy.ts`: testar "tela de hoje" com 1 ação primária após onboarding
- [s] 6.3 `cypress/e2e/rcd-moat5-humantouch.cy.ts`: 404 testado; error-recovery skipado (backend offline bloqueia intercept)

## 7. Integração e submodules

- [x] 7.1 API: branch `feature/onboarding-invite-teacher`, commit `e1e65a9` (Moat 2) + `feature/onboarding-microloops` (Moat 1)
- [x] 7.2 UI: branch `feat/ai-era-moats`, commit `97fa4ad` (Moat 2) + `feat/microloops` (Moat 1) + `feat/brand-power`, commit `0cba976` (Moat 3)
- [x] 7.3 Pai: apontar submodules, branch `differentiate/ai-era-moats`, PR #5 (atualizado)
- [x] 7.4 Validar `openspec validate differentiate-ai-era-moats --strict`
