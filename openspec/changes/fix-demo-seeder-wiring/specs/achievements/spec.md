# Spec Delta — Capability `achievements`

## ADDED Requirements

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