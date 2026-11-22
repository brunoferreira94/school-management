# achievements Specification

## Purpose

Gamificação da gestão escolar: transforma uso das funcionalidades em progressão
visível. Catálogo versionado de conquistas (gatilho + limiar + pontos), motor
idempotente por usuário, perfil do usuário, visão da equipe (ranking e
cobertura) e telemetria agregada.

## Requirements

### Requirement: Catálogo de conquistas versionado

O sistema SHALL manter um catálogo versionado de conquistas (seed idempotente),
cada uma com chave única (`Key`), título, descrição, categoria, ícone, pontos,
tipo (`Action`|`Milestone`|`Streak`) e gatilho (`TriggerEvent`).

#### Scenario: Catálogo v1 semeado

- **WHEN** o banco está vazio (seed inicial)
- **THEN** existem exatamente 12 conquistas com keys únicas (`first-grade`,
  `grades-10`, `first-formula`, `attendance-streak`, `diary-first`,
  `report-card-bimestral`, `students-10`, `first-turma`, `payment-reconciled`,
  `report-exported`, `offline-sync-master`, `early-bird`)
- **AND** os pontos somam 600 (50 por conquista)
- **AND** rodar o seed novamente não duplica conquistas

#### Scenario: Conquista nova sem migration

- **WHEN** um dev adiciona uma conquista ao seed do `PilotEnvironmentSeeder`
- **THEN** ela aparece no catálogo após o próximo `--seed-demo` (idempotente)
- **AND** o motor passa a considerá-la sem mudança de código

### Requirement: Motor de conquistas idempotente

O sistema SHALL avaliar eventos de domínio e desbloquear conquistas **uma única
vez** por usuário (`UserId + AchievementId`), acumulando progresso parcial.

#### Scenario: Limiar exato desbloqueia

- **WHEN** um professor lança a 10ª nota (`GradeCreated` × 10)
- **THEN** `grades-10` é desbloqueada (`UserAchievement` criada com `UnlockedAtUtc`)
- **AND** um evento `achievements_unlocked_total{achievement="grades-10"}` é emitido

#### Scenario: Repetição não duplica

- **WHEN** o professor lança a 11ª nota (`GradeCreated` × 11)
- **THEN** `grades-10` **não** é desbloqueada de novo (idempotente)
- **AND** o progresso parcial de `first-grade` segue `>= 1` (já desbloqueada)

#### Scenario: Progresso parcial visível

- **WHEN** o professor lançou 4 notas
- **THEN** `first-formula` (0/1) e `grades-10` (4/10) aparecem como bloqueadas com progresso
- **AND** `first-grade` aparece desbloqueada com data

#### Scenario: Falha do motor não derruba a operação

- **WHEN** o handler de conquista lança exceção (DB fora)
- **THEN** a nota é salva normalmente (o listener é tolerante a falha)
- **AND** a falha é logada sem dado sensível (só userId + trigger)

### Requirement: API de conquistas

O sistema SHALL expor endpoints REST para o usuário ver as próprias conquistas e
para diretores/secretaria verem a equipe.

#### Scenario: Usuário vê as próprias conquistas

- **WHEN** `GET /api/me/achievements` com token válido
- **THEN** 200 com resumo (pontos, nível, total, por categoria) e lista com
  status/progresso de cada conquista

#### Scenario: Catálogo exige permissão

- **WHEN** `GET /api/achievements` sem `achievements.manage`
- **THEN** 403 (professor vê o próprio perfil, não o catálogo da equipe)

#### Scenario: Diretor vê o progresso da equipe

- **WHEN** diretor (com `achievements.manage`) consulta `GET /api/achievements/progress/{userId}`
- **THEN** 200 com as conquistas do usuário + progresso parcial
- **AND** usuário inexistente → 404 (nunca 5xx)

### Requirement: Perfil e painel na UI

A UI SHALL exibir as conquistas do usuário na Minha Área e um painel da equipe
no Owner Dashboard.

#### Scenario: Central de conquistas

- **WHEN** o usuário abre Minha Área
- **THEN** vê nível, pontos, barra de progresso do nível, conquistas
  desbloqueadas (data) e bloqueadas (progresso)
- **AND** pode filtrar por categoria

#### Scenario: Toast de desbloqueio

- **WHEN** uma conquista é desbloqueada durante a sessão
- **THEN** um toast "🏆 Conquista desbloqueada: {título} (+{pontos} pts)" aparece
- **AND** some sozinho após 4s

#### Scenario: Painel do diretor

- **WHEN** o diretor abre o Owner Dashboard
- **THEN** vê a seção "Conquistas da equipe" (por usuário: pontos, nível,
  últimas conquistas; ranking; cobertura do catálogo)

### Requirement: Feature flag

O sistema SHALL permitir desligar a gamificação (`Achievements__Enabled=false`),
devolvendo o comportamento anterior (engine no-op, UI oculta).

#### Scenario: Desligada

- **WHEN** a flag está false
- **THEN** o engine não registra eventos nem desbloqueia
- **AND** a UI não exibe Central de Conquistas, toast ou painel
- **AND** os endpoints respondem 200 com lista vazia (sem quebrar clientes)

### Requirement: Catálogo de conquistas como baseline de plataforma

O sistema SHALL tratar o catálogo de conquistas como **dado de plataforma**
(não fictício): ele faz parte do baseline idempotente aplicado em todo ambiente
não-Testing no startup, independentemente do modo demo. Assim, o catálogo existe
em produção sem `--seed-demo` e sem comando manual.

#### Scenario: Catálogo v1 aplicado pelo baseline

- **WHEN** a API inicia contra um banco novo (qualquer ambiente)
- **THEN** existem exatamente 12 conquistas com keys únicas (`first-grade`,
  `grades-10`, `first-formula`, `attendance-streak`, `diary-first`,
  `report-card-bimestral`, `students-10`, `first-turma`, `payment-reconciled`,
  `report-exported`, `offline-sync-master`, `early-bird`)
- **AND** os pontos somam 600 (50 por conquista)
- **AND** rodar o baseline novamente não duplica conquistas

#### Scenario: Conquista nova sem migration

- **WHEN** um dev adiciona uma conquista ao catálogo do baseline
- **THEN** ela aparece no próximo deploy (baseline idempotente)
- **AND** o motor passa a considerá-la sem mudança de código

#### Scenario: Catálogo em ambiente de produção

- **WHEN** a API inicia em Produção (sem `--seed-demo`)
- **THEN** o catálogo v1 está disponível
- **AND** nenhum dado fictício (tenant/usuário demo) é criado
