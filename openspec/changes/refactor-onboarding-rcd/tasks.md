## 1. Welcome Flow (Frontend) ✅

- [x] 1.1 Criar welcome modal component em `src/app/shared/onboarding-welcome/`
- [x] 1.2 Integrar vídeo placeholder (30s) no modal
- [x] 1.3 Adicionar opção "Usar modelo padrão de escola"
- [x] 1.4 Hook `onboarding.service.ts` verifica primeiro acesso

## 2. Seed Data Automático (Backend) ✅

- [x] 2.1 Criar endpoint `POST /api/onboarding/seed-standard`
- [x] 2.2 Implementar seed: turma modelo + calendário 200 dias (via SetupService)
- [x] 2.3 Executar seed ao completar welcome modal (frontend chama endpoint)
- [x] 2.4 Tabela `SetupProgress` para tracking de etapas (persistência real)

## 3. Empty State + CTA Única (Frontend) ✅

- [x] 3.1 Atualizar empty state em `src/app/shared/empty-state/`
- [x] 3.2 CTA "Criar primeira turma" visível na home do admin
- [x] 3.3 Wizard inline na mesma página (não navegação)

## 4. Checklist de Ativação (Frontend) ✅

- [x] 4.1 Component `activation-checklist.component.ts`
- [x] 4.2 Progress bar iniciando em 20%
- [x] 4.3 Micro-loops: Importar turma (40%) → Convidar 3 professores (60%) → Ver primeiro boletim (80%)

## 5. Celebração Visual (Frontend) ✅

- [x] 5.1 Animação linha do tempo após turma criada (gráfico + confetti)
- [x] 5.2 Integração com canvas confetti + stats animados
- [x] 5.3 Stats salvos localmente para evidência TTV

## 6. Integração App Root ✅

- [x] 6.1 Registrar components no app.component.ts
- [x] 6.2 Adicionar imports no standalone component

## 7. Backend Seed Endpoint ✅

- [x] 7.1 OnboardingController com `POST /api/onboarding/seed-standard`
- [x] 7.2 DefaultSchoolTemplate2026 com template pré-definido (4 salas, 4 cursos, 3 turmas)
- [x] 7.3 Build .NET passou (0 erros)

## 8. Backend SetupProgress Persistence ✅

- [x] 8.1 Entidade `SetupProgress` (Domain) com campos de etapas
- [x] 8.2 `ISetupProgressRepository` + `SetupProgressRepository` (Infra)
- [x] 8.3 Endpoints `GET/POST /api/onboarding/progress`
- [x] 8.4 Migration `AddSetupProgress` aplicada no banco local
- [x] 8.5 Registro DI em `RepositoryAndInfrastructureRegistration`

## 9. Frontend Sync (Backend <-> LocalStorage) ✅

- [x] 9.1 `OnboardingService` usa `signal` reativo para `progress`
- [x] 9.2 `syncProgress()` busca `GET /api/onboarding/progress` no app init
- [x] 9.3 `updateProgress()` faz `POST` para persistir etapas
- [x] 9.4 `app.component.ts` chama `syncProgress()` quando autenticado
- [x] 9.5 `activation-checklist` usa `progressPercent` do backend
- [x] 9.6 Teste E2E `syncs onboarding progress from backend on app load`

## 10. Testes E2E ✅

- [x] 10.1 Test: admin completa onboarding em < 5 min
- [x] 10.2 Test: welcome modal aparece apenas primeiro acesso
- [x] 10.3 Test: seed data aplicado automaticamente
- [x] 10.4 `rcd-onboarding-flow.cy.ts` com 5 specs