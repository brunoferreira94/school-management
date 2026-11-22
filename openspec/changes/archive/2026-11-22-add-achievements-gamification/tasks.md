# Tasks — Sistema de Conquistas (Gamificação)

> **Escopo entregue (v1):** motor, API, Central de Conquistas e toast.
> **Concluído:** os 26 itens. 2.4 saiu com evento de domínio
> (`AchievementUnlockedEvent`) + métrica agregada `achievements.unlocked`
> (sem `user_id` — cardinalidade); 4.4 com `GET /api/achievements/team`
> (ranking + cobertura) e aba do Owner Dashboard; 4.5 com specs Karma de
> `achievement.service`, `team-achievements.service` e da Central; 5.3 com a
> linha de Achievements em `school-management-api/docs/features.md`.
>
> **2.3 concluído:** os 12 gatilhos emitem. `attendance-streak` e `early-bird`
> usam `RecordDailyStreakAsync` (sequência real de dias com `TimeProvider`,
> não contador de eventos).
>
> **Robustez do motor:** escrita atômica (`ExecuteUpdate` com delta relativo +
> `INSERT ... ON CONFLICT DO NOTHING`), sem `SaveChanges` no contexto
> compartilhado (não faz flush de mudanças pendentes da operação de negócio).
> Testes de corrida (concorrência real) e de não-flush cobertos.

## 1. Modelo de domínio (BACK)

- [x] 1.1 Entidade `Achievement` — Id, Key (slug único), Title, Description, Category (`Onboarding`|`Practice`|`Mastery`|`Community`), Icon, Points, Kind (`Action`|`Milestone`|`Streak`), TriggerEvent, Threshold, VisibleInProfile, CreatedAtUtc
- [x] 1.2 Entidade `UserAchievement` — Id, UserId, AchievementId, UnlockedAtUtc (FK composta UserId+AchievementId, índice único)
- [x] 1.3 Entidade `AchievementProgress` — Id, UserId, AchievementId, ProgressCurrent, UpdatedAtUtc (upsert; não é conquista desbloqueada)
- [x] 1.4 Migration `AchievementsGamification` (SchoolContext — tabelas `Achievements`, `UserAchievements`, `AchievementProgress` + índices) + `PilotEnvironmentSeeder` semeia o catálogo v1 (12 conquistas, idempotente) e as permissões `achievements.read`/`achievements.manage`
- [x] 1.5 Testes unitários do catálogo (seed v1 tem as 12 conquistas com keys únicas, thresholds positivos, categorias válidas)

## 2. Motor de conquistas (BACK)

- [x] 2.1 `IAchievementService` + `AchievementService` — `RecordEventAsync(userId, AchievementTrigger, amount)` (upsert do progresso; desbloqueia quando `>= Threshold`; idempotente por UserId+AchievementId)
- [x] 2.2 `AchievementTrigger` (enum) — `GradeCreated`, `GradeUpdated`, `FormulaCreated`, `AttendanceSaved`, `DiarySaved`, `ReportGenerated`, `ReportExported`, `StudentCreated`, `ClassGroupCreated`, `PaymentReconciled`, `OfflineSyncCompleted`, `LoginStreakDay`
- [x] 2.3 Listeners: hook nos handlers existentes (`UpsertGradeHandler` → GradeCreated/GradeUpdated; `GradingFormulas` create → FormulaCreated; `AttendanceService` → AttendanceSaved; `DiaryService` → DiarySaved; `ReportBuilder` generate/export → ReportGenerated/ReportExported; `StudentsService` → StudentCreated; `ClassGroupsService` → ClassGroupCreated; `PaymentReconciliation` → PaymentReconciled; `OfflineSyncService` drain → OfflineSyncCompleted; login diário → LoginStreakDay) — handler de conquista tolerante a falha (nunca derruba a operação de negócio)
- [x] 2.4 `AchievementUnlockedEvent` (evento de domínio) + handler que persiste `UserAchievement` e publica `achievements_unlocked_total{user_id, achievement}` no Meter (H.8)
- [x] 2.5 Testes: motor (threshold exato, idempotência — 2 eventos = 1 desbloqueio, progresso acumula, streak de login, tolerância a falha), listeners (1 por trigger, todos verdes)

## 3. API HTTP (BACK)

- [x] 3.1 `AchievementsController` — `GET /api/me/achievements` (token; perfil + progresso), `GET /api/me/achievements/{key}` (detalhe), `GET /api/achievements` (catálogo + contagem de desbloqueios; `achievements.manage`), `GET /api/achievements/progress/{userId}` (equipe; `achievements.manage`)
- [x] 3.2 DTOs: `AchievementDto`, `UserAchievementDto` (com `unlockedAtUtc`, `progress`), `AchievementCatalogDto`, `UserAchievementsSummaryDto` (pontos, nível = floor(pontos/100)+1, total, por categoria)
- [x] 3.3 Testes de integração HTTP (200 perfil próprio, 403 catálogo sem permissão, 404 progresso de usuário inexistente, nunca 5xx)

## 4. Frontend (FRONT)

- [x] 4.1 `achievement.service.ts` (GET /me/achievements, catálogo, progresso) + models
- [x] 4.2 **Central de Conquistas** (Minha Área) — card: nível/pontos/progresso, conquistas desbloqueadas (data) e bloqueadas (barra de progresso), filtro por categoria
- [x] 4.3 **Toast de desbloqueio** — `AchievementUnlockedComponent` global (signal no service; "🏆 Conquista desbloqueada: {título} (+{pontos} pts)")
- [x] 4.4 **Painel do diretor** (Owner Dashboard) — seção "Conquistas da equipe": por usuário (pontos, nível, últimas conquistas), ranking, cobertura do catálogo
- [x] 4.5 Testes Karma (service, central de conquistas, painel)

## 5. Documentação (BACK/FRONT)

- [x] 5.1 `docs/api/achievements.md` (endpoints + catálogo v1 + como adicionar conquista nova)
- [x] 5.2 Seção no runbook de rollout (como ligar/desligar a gamificação: feature flag `Achievements__Enabled` default true; desligar esconde a UI e o engine vira no-op) → `docs/runbooks/achievements-rollout.md`
- [x] 5.3 Atualizar `docs/features.md` (índice de features)

## 6. Critérios de aceite

- [x] 6.1 Desbloquear 2 eventos do mesmo tipo gera **1** conquista (idempotente) — teste E2E (`cypress/e2e/achievements-live.cy.ts`, 2/2)
- [x] 6.2 Pontuação correta: 12 conquistas do catálogo v1 somam 600 pts; nível = floor(pts/100)+1
- [x] 6.3 Diretor vê o progresso da equipe (GET progress/{userId} com `achievements.manage`); professor só vê o próprio (403 no escuro)
- [x] 6.4 Feature flag desligada → engine no-op + UI oculta (sem regressão) — `AchievementsDisabledIntegrationTests` (2/2) + estado "desativada" na Central (Karma)
- [x] 6.5 Suíte API 1080+ verde, Karma 807+ verde, migration aplicada idempotente