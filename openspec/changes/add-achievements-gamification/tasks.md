# Tasks — Sistema de Conquistas (Gamificação)

## 1. Modelo de domínio (BACK)

- [ ] 1.1 Entidade `Achievement` — Id, Key (slug único), Title, Description, Category (`Onboarding`|`Practice`|`Mastery`|`Community`), Icon, Points, Kind (`Action`|`Milestone`|`Streak`), TriggerEvent, Threshold, VisibleInProfile, CreatedAtUtc
- [ ] 1.2 Entidade `UserAchievement` — Id, UserId, AchievementId, UnlockedAtUtc (FK composta UserId+AchievementId, índice único)
- [ ] 1.3 Entidade `AchievementProgress` — Id, UserId, AchievementId, ProgressCurrent, UpdatedAtUtc (upsert; não é conquista desbloqueada)
- [ ] 1.4 Migration `AchievementsGamification` (SchoolContext — tabelas `Achievements`, `UserAchievements`, `AchievementProgress` + índices) + `PilotEnvironmentSeeder` semeia o catálogo v1 (12 conquistas, idempotente) e as permissões `achievements.read`/`achievements.manage`
- [ ] 1.5 Testes unitários do catálogo (seed v1 tem as 12 conquistas com keys únicas, thresholds positivos, categorias válidas)

## 2. Motor de conquistas (BACK)

- [ ] 2.1 `IAchievementService` + `AchievementService` — `RecordEventAsync(userId, AchievementTrigger, amount)` (upsert do progresso; desbloqueia quando `>= Threshold`; idempotente por UserId+AchievementId)
- [ ] 2.2 `AchievementTrigger` (enum) — `GradeCreated`, `GradeUpdated`, `FormulaCreated`, `AttendanceSaved`, `DiarySaved`, `ReportGenerated`, `ReportExported`, `StudentCreated`, `ClassGroupCreated`, `PaymentReconciled`, `OfflineSyncCompleted`, `LoginStreakDay`
- [ ] 2.3 Listeners: hook nos handlers existentes (`UpsertGradeHandler` → GradeCreated/GradeUpdated; `GradingFormulas` create → FormulaCreated; `AttendanceService` → AttendanceSaved; `DiaryService` → DiarySaved; `ReportBuilder` generate/export → ReportGenerated/ReportExported; `StudentsService` → StudentCreated; `ClassGroupsService` → ClassGroupCreated; `PaymentReconciliation` → PaymentReconciled; `OfflineSyncService` drain → OfflineSyncCompleted; login diário → LoginStreakDay) — handler de conquista tolerante a falha (nunca derruba a operação de negócio)
- [ ] 2.4 `AchievementUnlockedEvent` (evento de domínio) + handler que persiste `UserAchievement` e publica `achievements_unlocked_total{user_id, achievement}` no Meter (H.8)
- [ ] 2.5 Testes: motor (threshold exato, idempotência — 2 eventos = 1 desbloqueio, progresso acumula, streak de login, tolerância a falha), listeners (1 por trigger, todos verdes)

## 3. API HTTP (BACK)

- [ ] 3.1 `AchievementsController` — `GET /api/me/achievements` (token; perfil + progresso), `GET /api/me/achievements/{key}` (detalhe), `GET /api/achievements` (catálogo + contagem de desbloqueios; `achievements.manage`), `GET /api/achievements/progress/{userId}` (equipe; `achievements.manage`)
- [ ] 3.2 DTOs: `AchievementDto`, `UserAchievementDto` (com `unlockedAtUtc`, `progress`), `AchievementCatalogDto`, `UserAchievementsSummaryDto` (pontos, nível = floor(pontos/100)+1, total, por categoria)
- [ ] 3.3 Testes de integração HTTP (200 perfil próprio, 403 catálogo sem permissão, 404 progresso de usuário inexistente, nunca 5xx)

## 4. Frontend (FRONT)

- [ ] 4.1 `achievement.service.ts` (GET /me/achievements, catálogo, progresso) + models
- [ ] 4.2 **Central de Conquistas** (Minha Área) — card: nível/pontos/progresso, conquistas desbloqueadas (data) e bloqueadas (barra de progresso), filtro por categoria
- [ ] 4.3 **Toast de desbloqueio** — `AchievementUnlockedComponent` global (signal no service; "🏆 Conquista desbloqueada: {título} (+{pontos} pts)")
- [ ] 4.4 **Painel do diretor** (Owner Dashboard) — seção "Conquistas da equipe": por usuário (pontos, nível, últimas conquistas), ranking, cobertura do catálogo
- [ ] 4.5 Testes Karma (service, central de conquistas, painel)

## 5. Documentação (BACK/FRONT)

- [ ] 5.1 `docs/api/achievements.md` (endpoints + catálogo v1 + como adicionar conquista nova)
- [ ] 5.2 Seção no runbook de rollout (como ligar/desligar a gamificação: feature flag `Achievements__Enabled` default true; desligar esconde a UI e o engine vira no-op)
- [ ] 5.3 Atualizar `docs/features.md` (índice de features)

## 6. Critérios de aceite

- [ ] 6.1 Desbloquear 2 eventos do mesmo tipo gera **1** conquista (idempotente) — teste E2E
- [ ] 6.2 Pontuação correta: 12 conquistas do catálogo v1 somam 600 pts; nível = floor(pts/100)+1
- [ ] 6.3 Diretor vê o progresso da equipe (GET progress/{userId} com `achievements.manage`); professor só vê o próprio (403 no escuro)
- [ ] 6.4 Feature flag desligada → engine no-op + UI oculta (sem regressão)
- [ ] 6.5 Suíte API 1080+ verde, Karma 807+ verde, migration aplicada idempotente