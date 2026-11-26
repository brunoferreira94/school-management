# API de Conquistas (Gamificação)

## Endpoints

### `GET /api/me/achievements`
Perfil do usuário: pontos, nível e conquistas (com progresso).

**Permissão:** `achievements.read` (professor e coordenador incluídos no seed)

**Resposta 200:**
```json
{
  "totalPoints": 50,
  "level": 1,
  "pointsForNextLevel": 50,
  "totalAchievements": 12,
  "unlockedCount": 1,
  "items": [
    {
      "key": "first-grade",
      "title": "Primeira nota",
      "description": "Lançou a primeira nota de um aluno.",
      "category": "Onboarding",
      "icon": "📝",
      "points": 50,
      "kind": "Action",
      "threshold": 1,
      "unlockedAtUtc": "2026-11-19T12:00:00Z",
      "progressCurrent": 1
    },
    {
      "key": "grades-10",
      "title": "Lançando notas",
      "description": "Acumulou 10 notas lançadas.",
      "category": "Practice",
      "icon": "📊",
      "points": 50,
      "kind": "Milestone",
      "threshold": 10,
      "unlockedAtUtc": null,
      "progressCurrent": 4
    }
  ]
}
```

### `GET /api/Achievements`
Catálogo + contagem de desbloqueios (diretoria/secretaria).

**Permissão:** `achievements.manage`

### `GET /api/Achievements/team`
Visão da equipe (diretoria/secretaria): ranking por pontos, nível, última
conquista e cobertura do catálogo.

**Permissão:** `achievements.manage`

```json
{
  "totalUsers": 1,
  "catalogTotal": 12,
  "distinctUnlocked": 1,
  "coveragePercent": 8.3,
  "users": [
    {
      "userId": "…",
      "username": "diretor.demo",
      "points": 50,
      "level": 1,
      "unlockedCount": 1,
      "lastUnlockedTitle": "Turma criada",
      "lastUnlockedAtUtc": "2026-11-22T16:36:37Z"
    }
  ]
}
```

### `GET /api/Achievements/progress/{userId}`
Progresso de um usuário (diretoria/secretaria). Só responde 200 para usuário
**do mesmo tenant** do chamador (qualquer outro devolve 404 — sem enumerar
usuários de outra escola).

**Permissão:** `achievements.manage`

## Catálogo v1 (12 conquistas, 600 pts)

| Key | Título | Categoria | Gatilho | Threshold | Pontos |
|---|---|---|---|---|---|---|
| `first-grade` | Primeira nota | Onboarding | GradeCreated | 1 | 50 |
| `grades-10` | Lançando notas | Practice | GradeCreated | 10 | 50 |
| `first-formula` | Fórmula própria | Practice | FormulaCreated | 1 | 50 |
| `attendance-streak` | Chamada em dia | Practice | AttendanceSaved | 5 | 50 |
| `diary-first` | Diário preenchido | Practice | DiarySaved | 1 | 50 |
| `report-card-bimestral` | Boletim gerado | Mastery | ReportGenerated | 1 | 50 |
| `students-10` | Matrículas em dia | Practice | StudentCreated | 10 | 50 |
| `first-turma` | Turma criada | Onboarding | ClassGroupCreated | 1 | 50 |
| `payment-reconciled` | Financeiro em dia | Mastery | PaymentReconciled | 1 | 50 |
| `report-exported` | Relatório exportado | Mastery | ReportExported | 1 | 50 |
| `offline-sync-master` | Trabalho offline | Mastery | OfflineSyncCompleted | 1 | 50 |
| `early-bird` | Ponto de presença | Community | LoginStreakDay | 7 | 50 |

## Como adicionar uma conquista nova

1. Adicione ao `PilotEnvironmentSeeder` no array `achievementCatalog`:
   ```csharp
   new Achievement {
       Key = "minha-conquista",
       Title = "Minha conquista",
       Description = "Descrição",
       Category = AchievementCategory.Practice,
       Icon = "🎯",
       Points = 50,
       Kind = AchievementKind.Action,
       TriggerEvent = "GradeCreated",
       Threshold = 10,
   }
   ```
2. Rode `--seed-demo` (idempotente) para aplicar.
3. O motor passa a considerá-la sem mudança de código.

## Feature flag

`Achievements__Enabled` (default `true`). Desligada:
- Engine vira no-op (não registra eventos nem desbloqueia)
- Dados existentes permanecem legíveis (endpoints continuam respondendo)
- A UI **não** esconde a Central de Conquistas/toast por flag — esconder exige
  deploy (fora do escopo v1; ver `tasks.md` 6.4)

Para desligar de verdade em produção: `Achievements__Enabled=false` + rollback
da UI (ou feature toggle no sidebar — aberto, item 6.4).

## Permissões

- `achievements.read` — qualquer usuário vê as próprias conquistas
- `achievements.manage` — diretor/secretaria veem catálogo e progresso da equipe

## Métricas

- `achievements_unlocked{achievement, category}` — contador por conquista.
  **Sem `user_id`** de propósito: uma série por usuário multiplicaria a
  cardinalidade (mesma razão da normalização de `route` no
  `MetricsMiddleware`). O desenho original previa
  `achievements_unlocked_total{user_id, achievement}`; a versão entregue usa
  apenas os rótulos agregados.
- O motor também loga cada desbloqueio em Information:
  `Achievement unlocked: {Achievement} for user {UserId}`.

Fluxo: `AchievementService` → `AchievementUnlockedEvent` (domínio) →
`IncrementAchievementUnlockedOnEvent` → `IMetricsService`.
- `achievements_unlocked_total` — total por usuário (rate)
## Concorrência e isolamento do `DbContext`

O motor escreve via `ExecuteUpdate`/`ExecuteSql` (`INSERT ... ON CONFLICT DO
NOTHING`), **nunca** via `SaveChanges`:

- **Sem lost update**: o progresso é incrementado com
  `SET ProgressCurrent = ProgressCurrent + delta` (atômico no Postgres). A
  corrida só existe na inserção da linha; aí o conflito de índice único faz o
  delta ser reaplicado sobre a linha vencedora.
- **Sem flush indevido**: como o motor não chama `SaveChanges`, ele nunca
  persiste mudanças pendentes da operação de negócio que compartilha o mesmo
  `DbContext` (ex.: aluno adicionado mas ainda não salvo).
- **Desbloqueio idempotente**: `ON CONFLICT DO NOTHING` no índice único
  `(TenantId, UserId, AchievementId)`.

## Sequência de dias (streak)

`attendance-streak` e `early-bird` medem **dias consecutivos**, não total de
eventos. O motor (`RecordDailyStreakAsync`) usa `TimeProvider`:

- mesmo dia → no-op (não conta duas vezes)
- dia seguinte → +1
- qualquer lacuna → reinicia em 1

A data do último registro vive em `AchievementProgress.UpdatedAtUtc`.

## Tenant (isolamento)

`UserAchievements`/`AchievementProgresses` têm `TenantId` próprio — desbloqueios
e progresso nunca atravessam escolas, mesmo para o mesmo `UserId` (o motor
grava o tenant do request e as consultas filtram por ele). O catálogo
(`Achievements`) é global por design.

### Fallback no login (tenant do request vazio)

O `login` é **anônimo**: quando o motor roda (`early-bird`, streak de acesso)
ainda não existe token, então o tenant do request está vazio
(`HttpTenantContext` → `ITenantProvider` sem claim `tenant_id`). Nesse caso o
motor usa o **tenant da própria conta do usuário** (`UserAccounts.TenantId`),
nunca o de outra escola.

Sem esse fallback o progresso nascia com `TenantId` vazio e ficava invisível
para o perfil (que filtra por tenant) — o streak de login nunca apareceria nem
desbloquearia, e o mesmo usuário teria duas linhas de progresso (uma por
tenant). Implementação: `AchievementService.ResolveTenantIdAsync`.
