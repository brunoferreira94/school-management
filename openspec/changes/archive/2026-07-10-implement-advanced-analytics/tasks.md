# Tasks — Implementar Analytics Avançado

## Status: MVP Phase 1 — ✅ Concluído

> **Decisão arquitetural:** PostgreSQL OLAP (já existente) — sem custo adicional de infra.
> As decisões sobre ClickHouse/BigQuery, streaming CDC e ML foram postergadas para as fases 2 e 3.

---

## ✅ Phase 1: MVP com PostgreSQL (Completo)

### Backend — Views Materializadas (já existia)

- [x] Migration `20251121133306_AddAnalyticsMaterializedViews` com:
  - [x] `mv_retention_by_cohort` — retenção por coorte de matrícula
  - [x] `mv_delinquency_by_period` — inadimplência por período de vencimento

### Backend — Domain & Infra (já existia)

- [x] Domain entities: `RetentionByCohort`, `DelinquencyByPeriod`, `RetentionSnapshot`, `DelinquencySnapshot`
- [x] SchoolContext: `DbSet`s configurados para as 4 entidades analytics
- [x] DTOs: `RetentionAnalyticsDto`, `DelinquencyAnalyticsDto` (com aging distribution)
- [x] `AnalyticsService` com cache em MemoryCache (TTL 10 min)
- [x] `SnapshotService` para snapshots manuais/agendados

### Backend — API (já existia)

- [x] `GET /api/analytics/retention` — Análise de retenção por coorte (com filtros startMonth, endMonth, limit)
- [x] `GET /api/analytics/delinquency` — Análise de inadimplência por período (com filtros startMonth, endMonth, limit)
- [x] `SnapshotController` — endpoints para criar snapshots manuais e consultar histórico

### Backend — Testes (já existia)

- [x] `AnalyticsIntegrationTests` — 9 testes cobrindo retention, delinquency, filtros, aging, auth

### Frontend — Implementado nesta sprint

- [x] **Modelos:** `RetentionByCohortDto`, `RetentionSummaryDto`, `RetentionAnalytics` em `models/analytics.model.ts`
- [x] **Service:** `getRetentionAnalytics()` adicionado ao `AnalyticsService` (services/)
- [x] **Página de Analytics (`/analytics`):**
  - [x] Rota adicionada em `app.routes.ts` (lazy load)
  - [x] Link na sidebar (Gestão → Analytics)
- [x] **Dashboard de Retenção (`RetentionDashboardComponent`):**
  - [x] Cohort analysis chart (barras empilhadas: ativos vs evasões por coorte)
  - [x] Summary cards (total matriculados, ativos, evasões)
  - [x] Taxa de retenção geral com badge colorido
  - [x] Tabela detalhada por coorte com taxas individuais
- [x] **Dashboard de Inadimplência (`DelinquencyDashboardComponent`):**
  - [x] Summary cards (total parcelas, vencidas)
  - [x] Barras por período (pagas vs vencidas)
  - [x] Aging distribution (0-30, 31-60, 61-90, +90 dias) com barras horizontais
  - [x] Valor total em atraso em destaque
  - [x] Tabela detalhada por período
- [x] **Filtro de período:** 3M, 6M, 12M, Tudo — controla o limit enviado à API
- [x] **Estados:** loading com spinner, error com botão de retry, empty state por dashboard
- [x] **Build Angular:** ✅ 0 erros

---

## ⏳ Phase 2: Otimização (Pendente)

### Backend

- [ ] Adicionar índices especializados (BRIN/TimescaleDB) nas tabelas base
- [ ] Cache com Redis (substituir MemoryCache)
- [ ] Otimizar queries das materialized views (EXPLAIN ANALYZE)

### Frontend — Novos Dashboards

- [ ] Dashboard de Ocupação:
  - [ ] Taxa de ocupação por turma
  - [ ] Utilização de salas de aula
  - [ ] Heatmap de horários mais usados
- [ ] Dashboard de Performance:
  - [ ] Médias de notas por turma/curso
  - [ ] Distribuição de aprovação/reprovação
  - [ ] Comparativo entre períodos

### Features adicionais

- [ ] Exportação CSV/PDF/Excel nos dashboards
- [ ] Filtros por unidade e curso (além de período)
- [ ] Automatizar refresh das materialized views (nightly cron)

---

## ⏳ Phase 3: Escalabilidade (Pendente)

- [ ] Avaliar migração para ClickHouse/BigQuery se necessário
- [ ] Implementar streaming de eventos com Kafka/CDC
- [ ] Adicionar predições com ML (churn prediction)
- [ ] Dashboard de C-level com KPIs executivos
- [ ] Rate limiting para proteção de recursos
- [ ] Permissões granulares (`analytics.read`, `analytics.admin`)

---

## Testes & Qualidade (Pendente)

- [ ] Testes unitários para agregações e cálculos de métricas
- [ ] Testes de carga para queries analytics (benchmark)
- [ ] Data quality checks: completude, consistência, acurácia
- [ ] Alertas para anomalias em métricas críticas

## Documentação (Pendente)

- [ ] Data dictionary com definições de métricas
- [ ] Arquitetura de dados (ERD dimensional)
- [ ] SLAs e latência esperada
- [ ] Guia de troubleshooting
