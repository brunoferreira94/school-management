# Proposta: Sistema de Conquistas (Gamificação)

## Why

O sistema é completo funcionalmente, mas não há nenhum incentivo à **exploração**
e ao **domínio das funcionalidades** — professores e secretaria usam um subconjunto
das telas e não descobrem recursos que resolveriam problemas reais (fórmulas,
relatórios, portal dos responsáveis, API offline). Uma camada de conquistas
(gamificação) transforma ações e volume de uso em **progressão visível**, aumenta
retenção e serve de **onboarding gamificado** para escolas novas.

## What Changes

- **Catálogo de conquistas** (`achievements`) — definições versionadas: tipo
  (`action` | `streak` | `milestone`), evento/gatilho, limiar, título, descrição,
  ícone, categoria, pontos, visibilidade (automática vs. perfil).
- **Motor de conquistas** (`achievement-engine`) — listeners de eventos de
  domínio (nota lançada, boletim gerado, fórmula criada, chamada salva, diário
  preenchido, pagamento conciliado, relatório exportado, 7 dias de acesso…);
  avaliação determinística e idempotente (uma conquista desbloqueia **uma vez**).
- **Perfil do usuário** — `UserAchievement` (conquista desbloqueada + progresso
  parcial com `progressCurrent/target`); endpoint `GET /api/me/achievements`
  (token do usuário) com resumo (pontos totais, nível, conquistas) e detalhe.
- **Visão administrativa** — `GET /api/achievements/progress/{userId}` e
  `GET /api/achievements` (catálogo + contagem de desbloqueios por conquista)
  para diretores/secretaria acompanharem a equipe; permissão nova
  `achievements.read` / `achievements.manage`.
- **UI**:
  - **Central de Conquistas** (Minha Área) — card do usuário: nível, pontos,
    barra de progresso, conquistas desbloqueadas (com data) e bloqueadas (com
    progresso).
  - **Toast de desbloqueio** — "🏆 Conquista desbloqueada: X (+50 pts)".
  - **Painel do diretor** (Owner Dashboard) — visão da equipe: quem desbloqueou
    o quê, ranking por pontos, cobertura do catálogo.
- **Catálogo inicial (v1, 12 conquistas)** cobrindo os 4 perfis:
  - Professor: `first-grade` (1ª nota), `grades-10` (10 notas),
    `first-formula` (1ª fórmula), `attendance-streak` (chamada 5 dias seguidos),
    `diary-first` (1º diário), `report-card-bimestral` (boletim gerado)
  - Secretaria/Diretor: `students-10` (10 alunos), `first-turma` (1 turma),
    `payment-reconciled` (1ª conciliação), `report-exported` (1º relatório
    exportado), `offline-sync-master` (sync offline usado), `early-bird`
    (7 dias de acesso consecutivos)
- **Métricas**: contadores de uso por usuário/evento (já no `Meter` do H.8) +
  `achievements_unlocked_total` por usuário/conquista para o Prometheus.

## Fora do escopo (v1)

- Pontos trocáveis por benefícios (loja), leaderboards públicos entre escolas.
- Conquistas por tempo real (streaks que exigem relógio confiável no cliente).
- Notificações push de conquista (o canal push v1 já existe; o evento entra
  depois).

## Impact

- **Specs**: nova capability `achievements` (spec + deltas nos changes).
- **Código**:
  - API: `SchoolManagement.Domain/Achievement.cs`, `UserAchievement.cs`,
    `AchievementProgress.cs` (projeção); `SchoolManagement.Application/Achievements/`
    (queries/commands + handlers); `SchoolManagement.Infrastructure/Data/Migrations/`
    (tabelas `Achievements`, `UserAchievements`; SchoolContext — dono).
  - UI: `features/achievements/` (perfil + painel), `services/achievement.service.ts`,
    toast no desbloqueio; `my-area` e `owner-dashboard` ganham seções.
  - Permissões: `achievements.read` (qualquer usuário vê as próprias),
    `achievements.manage` (diretor/secretaria veem a equipe) — seed no
    `PilotEnvironmentSeeder`.
- **DB**: 2 tabelas novas no SchoolContext (migration `AchievementsGamification`).
- **LGPD**: conquistas não carregam dados de alunos — só metadados de uso
  (evento, data). Exclusão de conta remove `UserAchievements` (FK cascade).