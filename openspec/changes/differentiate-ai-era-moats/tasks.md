## 1. Moat 2 — Expansion architecture (convite real de professores)

- [ ] 1.1 API: criar `POST /api/onboarding/invite-teacher` (ou estender `OnboardingController`) que gera link mágico de convite (token assinado, sem senha) e registra o convite no `SetupProgress`
- [ ] 1.2 API: criar `POST /api/onboarding/accept-invite` que consome o token, cria/ativa o professor no tenant e marca `teacherActivated` no `SetupProgress`
- [ ] 1.3 API: estender `SetupProgress` com campo `TeachersInvited` (count) e `TeachersActivated` (count) para o checklist refletir o loop fechado
- [ ] 1.4 UI: `activation-checklist` — passo "Convidar professores" dispara `invite-teacher` (não só marca local) e mostra estado de "convidado / ativo"
- [ ] 1.5 UI: tela de aceite de convite (rota `/invite/:token`) com formulário mínimo de nome + confirmação

## 2. Moat 1 — Switching cost via UX internalizada (caminho do diretor)

- [ ] 2.1 UI: `activation-checklist` evolui para sequência de micro-loops repetíveis (nota→boletim→comunicado→cobrança) com estado persistido no backend
- [ ] 2.2 UI: cada loop concluído mostra "próximo passo sugerido" baseado no uso real (não lista estática)
- [ ] 2.3 API: `SetupProgress` ganha campos de micro-loop (`LastGradeEntryAt`, `LastReportCardViewedAt`, `LastAnnouncementAt`, `LastPaymentAt`) para o backend orientar o próximo passo
- [ ] 2.4 UI: celebração de micro-loop (`activation-celebration`) reutilizada para cada loop, não só no seed

## 3. Atenção militante — "tela de hoje"

- [ ] 3.1 UI: `home.component` ganha modo "tela de hoje" com 1 ação primária (item mais urgente: inadimplência > faltas > evento)
- [ ] 3.2 UI: widgets antigos mantidos como toggle "ver dashboard completo" (fallback, não competem por atenção no default)
- [ ] 3.3 UI: `tela de hoje` usa `activation-checklist` como primário no primeiro dia, transiciona para "tela de hoje" após conclusão do onboarding

## 4. Moat 3 — Brand Power / visual confidence

- [ ] 4.1 UI: criar design tokens proprietários (`styles/theme/escola-tokens.scss`) — cor ESCOLA+, raio 12px, sombra de confirmação, tipografia de marca
- [ ] 4.2 UI: aplicar tokens em `onboarding-welcome`, `activation-checklist`, `activation-celebration`, `empty-state` (já fora do Material default)
- [ ] 4.3 UI: micro-interação de 200ms de confirmação em ações críticas (salvar nota, enviar comunicado, confirmar pagamento)

## 5. Human touch

- [ ] 5.1 UI: componente de erro gentil com recovery (`shared/error-recovery`) — "Ops, [contexto]. Quer [ação recuperável]?"
- [ ] 5.2 UI: 404 que retorna o usuário (busca sugestão de rota + botão voltar ao dashboard)
- [ ] 5.3 UI: mensagens de erro de API mapeadas para tom humano (não "500 Internal Server Error")

## 6. Testes E2E (Cypress)

- [ ] 6.1 `cypress/e2e/rcd-moats-flow.cy.ts`: testar convite de professor (invite → accept → checklist mostra ativo)
- [ ] 6.2 `cypress/e2e/rcd-moats-flow.cy.ts`: testar "tela de hoje" com 1 ação primária após onboarding
- [ ] 6.3 `cypress/e2e/rcd-moats-flow.cy.ts`: testar erro gentil em turma duplicada

## 7. Integração e submodules

- [ ] 7.1 API: branch `feature/onboarding-invite-teacher`, commit, push
- [ ] 7.2 UI: branch `feat/ai-era-moats`, commit, push
- [ ] 7.3 Pai: apontar submodules, branch `differentiate/ai-era-moats`, PR #4
- [ ] 7.4 Validar `openspec validate differentiate-ai-era-moats --strict`
