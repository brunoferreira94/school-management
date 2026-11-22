# Runbook — Conquistas (Gamificação)

Como ligar, desligar, diagnosticar e reverter a gamificação em produção.
Feature: `openspec/changes/add-achievements-gamification/`.

## Visão geral

| Item | Valor |
|---|---|
| Feature flag | `Achievements__Enabled` (default `true`) |
| Motor | `AchievementService` (Infrastructure), idempotente por `UserId+AchievementId` |
| Gatilhos | 12 (`AchievementTrigger`) — todos com listener |
| Permissões | `achievements.read` (usuário), `achievements.manage` (diretoria/secretaria) |
| Isolamento | `TenantId` em `UserAchievements`/`AchievementProgresses` (migration `AchievementsTenantScope`) |
| UI | Central de Conquistas (Minha Área), toast 🏆, aba no Owner Dashboard |

## Ligar / desligar

```bash
# Desligar (engine vira no-op; dados existentes permanecem legíveis)
Achievements__Enabled=false

# Ligar (default)
Achievements__Enabled=true
```

Efeito de `false`:

- `RecordEventAsync`/`RecordDailyStreakAsync` retornam imediatamente (nenhuma
  escrita, nenhuma consulta).
- `GET /api/me/achievements` continua 200 e passa a responder `enabled: false`.
- A Central de Conquistas exibe "A gamificação está desativada para esta escola"
  (o toast não dispara — não há desbloqueios novos).

> A flag **não** esconde o link da Central na Minha Área: ela mostra o estado
> desativado. Ocultar a entrada exige deploy (item 6.4 do `tasks.md`).

## Permissões e catálogo

Permissões, papéis, vínculos e o catálogo v1 são **baseline de plataforma**
(`Infrastructure/Seeding/BaselineSeeder.cs`): idempotentes e aplicados
automaticamente no startup de todo ambiente não-Testing — inclusive produção,
sem `--seed-demo`.

Depois do deploy, o baseline garante:

- `achievements.read` para `Director`, `Coordinator` e `Teacher`;
- `achievements.manage` para `Director` e `Coordinator`;
- as 12 conquistas do catálogo v1 (600 pts).

Não é preciso comando manual. Se um ambiente **não** reiniciou desde o deploy,
reinicie o serviço (ou rode `--seed-demo` em Development) para aplicar.

> O modo demo (`--seed-demo`) só roda em Development: cria tenant piloto,
> `diretor.demo`, guardiões e fórmulas. Em Staging/Production ele **falha de
> propósito**.

## Verificação pós-deploy

```sql
-- Catálogo
SELECT "Key", "TriggerEvent", "Threshold", "Points" FROM "Achievements" ORDER BY "Points", "Key";

-- Permissões por papel
SELECT r."Name", p."Name" FROM "RolePermissions" rp
JOIN "Roles" r ON r."Id" = rp."RoleId"
JOIN "Permissions" p ON p."Id" = rp."PermissionId"
WHERE p."Name" LIKE 'achievements%' ORDER BY 1, 2;

-- Desbloqueios (por tenant)
SELECT "TenantId", count(*) FROM "UserAchievements" GROUP BY "TenantId";
```

Smoke test (autenticado):

```bash
curl -s "$API/api/me/achievements" -H "Authorization: Bearer $TOKEN" | jq '{enabled, totalPoints, level, unlockedCount}'
```

## Rollback

1. `Achievements__Enabled=false` (rollback funcional imediato — sem downtime).
2. Se precisar remover a UI, revert do commit de UI (o backend tolera a ausência).
3. A migration `AchievementsTenantScope` é aditiva (colunas + índices); não requer
   rollback. Dados de conquista podem ser mantidos sem impacto.

## Diagnóstico

| Sintoma | Causa provável | Ação |
|---|---|---|
| Tela da Central dá 403 | papel sem `achievements.read` | rodar o SQL de permissões acima |
| 404 em `/api/me/achievements` | rota incorreta/deploy antigo | confirmar `GET /api/me/achievements` (controller `AchievementsController`) |
| Toast nunca aparece | `localStorage` `sma.achievements.seen` já tem o desbloqueio | é esperado: o toast só dispara para desbloqueios **novos** |
| Conquista não desbloqueia | listener ausente para o gatilho | conferir `AchievementTrigger` × `docs/api/achievements.md` |
| `enabled: false` sem querer | flag `Achievements__Enabled=false` no ambiente | ajustar a env var e reiniciar |

## Referências

- [`docs/api/achievements.md`](../api/achievements.md) — endpoints, catálogo, streak, concorrência.
- `openspec/changes/add-achievements-gamification/tasks.md` — escopo e critérios.
- `openspec/changes/fix-demo-seeder-wiring/` — baseline vs. modo demo.
- `school-management-ui/cypress/e2e/achievements-live.cy.ts` — E2E ao vivo (idempotência).