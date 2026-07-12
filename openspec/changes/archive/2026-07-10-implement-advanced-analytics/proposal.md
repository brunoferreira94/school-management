# Implementar Analytics Avançado

Autor: _a definir_
Data: 2025-10-18
Atualizado: 2026-07-10
Status: **Phase 1 (MVP) ✅ Concluído** — Decisão: PostgreSQL OLAP

## Resumo

Dashboards avançados para performance operacional e pedagógica: retenção e inadimplência.

**Phase 1 (MVP) implementada:** 2 dashboards (retenção + inadimplência) usando PostgreSQL
existente com views materializadas, sem custo adicional de infraestrutura.

**Próximas fases (pendentes):** Ocupação, Performance acadêmica, Exportação, Redis cache.

## Status Atual

✅ **MVP Phase 1 concluído** — 10/07/2026

**Decisão arquitetural:** PostgreSQL OLAP (já existente) — sem custo adicional.
As decisões sobre ClickHouse/BigQuery, streaming CDC e ML foram postergadas para as fases 2 e 3.

### ✅ Phase 1 Implementado

#### Backend (já existia antes desta sprint)

- **Views materializadas:** `mv_retention_by_cohort` + `mv_delinquency_by_period` (migration `20251121133306`)
- **Domain entities:** `RetentionByCohort`, `DelinquencyByPeriod`, `RetentionSnapshot`, `DelinquencySnapshot`
- **API:** `GET /api/analytics/retention` + `GET /api/analytics/delinquency` (com filtros startMonth, endMonth, limit)
- **Service:** `AnalyticsService` com cache em MemoryCache (TTL 10 min)
- **Snapshots:** `SnapshotController` + `SnapshotService` para snapshots manuais/histórico
- **Testes:** 9 testes de integração (`AnalyticsIntegrationTests`)

#### Frontend (implementado nesta sprint)

- **Página `/analytics`** com dashboards lado a lado
- **Dashboard de Retenção:** Cohort chart (barras empilhadas), summary cards, tabela detalhada
- **Dashboard de Inadimplência:** Período chart, aging distribution, valor em atraso
- **Filtro de período:** 3M, 6M, 12M, Tudo
- **Estados:** Loading, error (com retry), empty
- **Build Angular:** 0 erros

### ⏳ Pendente para fases futuras

- Dashboard de Ocupação (Phase 2)
- Dashboard de Performance acadêmica (Phase 2)
- Exportação CSV/PDF/Excel (Phase 2)
- Cache com Redis (Phase 2)
- ClickHouse/BigQuery (Phase 3)
- ML/Churn prediction (Phase 3)

## Escopo

> **Nota:** Este escopo descreve a **visão completa** do projeto (fases 1–3).
> A **Phase 1 (MVP)** foi entregue sem DW dedicado, pipeline ETL ou Redis —
> utilizando apenas PostgreSQL com views materializadas + cache em MemoryCache.
> Veja [tasks.md](tasks.md) para o detalhamento por fase.

### Backend

- **Pipelines ETL**: Captura de eventos (enrollment, payment, attendance, grades, churn)
- **Data Warehouse**: Modelo dimensional (star schema) com fatos e dimensões
- **Agregações**: Rollups periódicos (daily, weekly, monthly)
- **Analytics API**: Endpoints REST para dashboards (`/api/analytics/*`)
- **Cache**: Redis para queries pesadas
- **Permissões**: `analytics.read`, `analytics.admin`

### Frontend

- **Dashboards Interativos**:
  - Retenção por coorte (cohort analysis)
  - Inadimplência por segmento e aging
  - Ocupação de turmas e salas
  - Performance acadêmica agregada
  - Análise de churn (evasão)
- **Filtros Globais**: Período, unidade escolar, curso, turma
- **Exportação**: CSV, PDF, Excel
- **Visualizações**: Charts (line, bar, pie), heatmaps, tabelas

### Testes

- Validação de métricas e cálculos
- Testes de data quality (completude, consistência, acurácia)
- Monitoramento de data drift
- Testes de carga para queries analytics

## Abordagem Recomendada: Implementação Faseada

### Phase 1: MVP com PostgreSQL (2-3 semanas)

**Objetivo**: Validar valor com investimento mínimo

- Usar PostgreSQL existente
- Views materializadas para agregações
- 2 dashboards prioritários (retenção + inadimplência)
- Refresh manual ou agendado (nightly)
- Sem CDC, apenas queries sobre dados transacionais

**Vantagens**:

- ✅ Zero custo de infraestrutura adicional
- ✅ Aproveita stack existente
- ✅ Entrega rápida para validação
- ✅ Aprendizado sobre métricas importantes

**Desvantagens**:

- ❌ Performance pode degradar com volume
- ❌ Refresh não é em tempo real
- ❌ Limitado a SQL analytics (sem ML fácil)

### Phase 2: Otimização (2-3 semanas)

**Objetivo**: Melhorar performance e adicionar funcionalidades

- Índices especializados (BRIN, GIN, GIST)
- Cache em Redis
- Mais dashboards (ocupação, performance)
- Automatizar refresh de agregações
- Considerar extensões TimescaleDB ou Citus

### Phase 3: Escalabilidade (4-6 semanas)

**Objetivo**: Preparar para escala e features avançadas

- Avaliar migração para ClickHouse/BigQuery
- Implementar CDC com Debezium/Kafka
- Streaming de eventos em tempo real
- Predições com ML (churn, performance)
- Dashboard executivo (C-level KPIs)

## Decisões Tomadas (2026-07-10)

### 1. Arquitetura de Dados ✅ Decidido

**Escolha: PostgreSQL OLAP** — $0 (já existe)

| Opção               | Investimento | Status |
| ------------------- | ------------ | ------ |
| **PostgreSQL OLAP** | Baixo        | ✅ **Selecionado** |
| **ClickHouse**      | Médio        | ⏳ Reavaliar na Phase 3 |
| **BigQuery**        | Alto         | ⏳ Reavaliar na Phase 3 |

### 2. Pipeline ETL ✅ Decidido

**Escolha: Views materializadas + queries diretas** — sem CDC/pipeline dedicado

| Abordagem            | Latência      | Status |
| -------------------- | ------------- | ------ |
| **Materialized Views** | Diário     | ✅ **Implementado** |
| **Batch Jobs**       | Minutos-Horas | ⏳ Phase 2 |
| **Debezium + Kafka** | Milissegundos | ⏳ Phase 3 |

### 3. Governança de Dados ⏳ Pendente

- [ ] Definir quais dados podem ser agregados/visualizados
- [ ] Implementar anonimização para dados sensíveis
- [ ] Documentar retenção de dados analytics (quanto tempo manter)
- [ ] Estabelecer processo de audit para acesso a analytics

## Estimativa de Esforço

### Phase 1 (MVP com PostgreSQL)

- Arquitetura e decisões: 1 semana
- Backend (views, endpoints): 1.5 semanas (1 dev)
- Frontend (2 dashboards): 1 semana (1 dev)
- Testes e docs: 0.5 semana
- **Total**: 2-3 semanas, 2 devs

### Phase 2 (Otimização)

- Otimizações backend: 1 semana
- Mais dashboards: 1.5 semanas
- Testes de carga: 0.5 semana
- **Total**: 2-3 semanas, 2 devs

### Phase 3 (Escalabilidade)

- Infraestrutura DW: 2 semanas (infra + backend)
- CDC/Streaming: 2 semanas (backend)
- Features avançadas (ML): 2 semanas (data scientist + backend)
- **Total**: 4-6 semanas, 3-4 pessoas

**Total Geral**: 8-12 semanas (2-3 meses) para implementação completa

## Alternativa: Estender Sistema Existente

Antes de investir em DW completo, considerar:

1. **Adicionar agregações aos endpoints existentes**

   - Endpoint `/api/reports/retention` com cohort analysis
   - Endpoint `/api/reports/revenue` com análise de inadimplência
   - Usar queries SQL existentes com GROUP BY e window functions

2. **Criar views materializadas no PostgreSQL**

   - `mv_retention_by_cohort`
   - `mv_revenue_by_period`
   - `mv_occupancy_by_class`
   - Refresh agendado via cron job

3. **Dashboards simples no frontend**
   - Reutilizar componentes de charts existentes
   - Filtros padrão (período, unidade)
   - Exportação CSV (já implementada)

**Vantagens**:

- ✅ Entrega em 2-4 semanas
- ✅ Zero custo adicional
- ✅ Validação antes de grande investimento
- ✅ Pode ser suficiente para necessidades atuais

## Documentação pós-implementação

- Documentar no `README.md` os dashboards criados
- Data dictionary com definições de métricas (fórmulas, periodicidade)
- Instruções para reproduzir relatórios e exportar dados
- Guia de troubleshooting para problemas comuns
- Arquitetura de dados (ERD dimensional)
- SLAs e latência esperada

## Próximos Passos

✅ **Decisões arquiteturais tomadas** — PostgreSQL OLAP selecionado

### Imediatos

1. Validar os dashboards com usuários reais (feedback)
2. Coletar métricas de performance das queries analytics
3. Planejar escopo da Phase 2 (ocupação, performance acadêmica)

### Phase 2

4. Dashboard de Ocupação de turmas e salas
5. Dashboard de Performance acadêmica
6. Exportação CSV/PDF nos dashboards
7. Cache com Redis
8. Automatizar refresh das materialized views

## Referências

- Ver `tasks.md` para breakdown detalhado de tarefas
- Ver `design.md` para considerações de arquitetura
- Sistema atual: `SchoolManagement/ReportsController.cs`
- Analytics existente: `SchoolManagement.Domain/SearchAnalytics.cs`
