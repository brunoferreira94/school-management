# Tasks — Implementar Analytics Avançado

## Status: BLOCKED - Requer Decisões Arquiteturais

Este change está bloqueado até que decisões fundamentais sejam tomadas sobre infraestrutura e arquitetura de dados.

## Pré-requisitos Necessários

### 1. Decisão de Arquitetura (BLOCKER)

- [ ] Escolher solução de Data Warehouse (opções avaliadas):
  - **PostgreSQL OLAP** (minimal, já disponível, extensões TimescaleDB/Citus)
  - **ClickHouse** (médio investimento, alta performance para analytics)
  - **BigQuery** (alto investimento, requer migração para GCP)
- [ ] Definir orçamento e SLAs para analytics (latência aceitável, volume de dados)
- [ ] Avaliar necessidade de streaming em tempo real vs batch diário

### 2. Infraestrutura de Dados (BLOCKER)

- [ ] Provisionar infraestrutura de Data Warehouse escolhida
- [ ] Configurar pipeline de ETL/CDC:
  - **Opção A (Minimal)**: Triggers PostgreSQL + stored procedures
  - **Opção B (Médio)**: Debezium CDC + Kafka Connect
  - **Opção C (Completo)**: Kafka + Stream Processing (Kafka Streams/Flink)
- [ ] Implementar data retention policies e compactação
- [ ] Configurar backup e disaster recovery para DW

### 3. Governança e Compliance (BLOCKER)

- [ ] Definir políticas de privacidade para dados agregados (LGPD/GDPR)
- [ ] Implementar anonimização/pseudonimização onde necessário
- [ ] Documentar data dictionary e lineage
- [ ] Estabelecer processos de data quality monitoring

## Implementação (Após Desbloqueio)

### Backend - ETL/Data Pipeline

- [ ] Implementar captação de eventos-chave:
  - [ ] Eventos de matrícula (enrollment events)
  - [ ] Eventos de pagamento (payment events)
  - [ ] Eventos de frequência (attendance events)
  - [ ] Eventos de notas (grade events)
  - [ ] Eventos de evasão (churn events)
- [ ] Criar tabelas dimensionais (dim_student, dim_class, dim_time, etc.)
- [ ] Criar tabelas de fatos (fact_enrollment, fact_payment, fact_attendance, etc.)
- [ ] Implementar agregações periódicas (daily/weekly/monthly rollups)
- [ ] Configurar jobs de processamento batch (scheduler/cron)

### Backend - Analytics API

- [ ] Criar endpoints de analytics:
  - [ ] `GET /api/analytics/retention` - Análise de retenção por coorte
  - [ ] `GET /api/analytics/revenue` - Análise de receita e inadimplência
  - [ ] `GET /api/analytics/occupancy` - Ocupação de turmas e salas
  - [ ] `GET /api/analytics/performance` - Performance acadêmica agregada
  - [ ] `GET /api/analytics/churn` - Predição e análise de evasão
- [ ] Implementar cache para queries pesadas (Redis/MemoryCache)
- [ ] Adicionar rate limiting para proteção de recursos
- [ ] Implementar permissões granulares (`analytics.read`, `analytics.admin`)

### Frontend - Dashboards

- [ ] Criar página de Analytics (`/analytics`)
- [ ] Dashboard de Retenção:
  - [ ] Cohort analysis chart (matriculados por período)
  - [ ] Taxa de renovação de matrícula
  - [ ] Filtros por unidade, curso, período
- [ ] Dashboard de Inadimplência:
  - [ ] Taxa de inadimplência por segmento
  - [ ] Aging de parcelas em aberto
  - [ ] Previsão de recebimento
- [ ] Dashboard de Ocupação:
  - [ ] Taxa de ocupação por turma
  - [ ] Utilização de salas de aula
  - [ ] Heatmap de horários mais usados
- [ ] Dashboard de Performance:
  - [ ] Médias de notas por turma/curso
  - [ ] Distribuição de aprovação/reprovação
  - [ ] Comparativo entre períodos
- [ ] Implementar exportação (CSV/PDF/Excel)
- [ ] Adicionar filtros globais (período, unidade, curso)

### Testes & Qualidade

- [ ] Testes unitários para agregações e cálculos de métricas
- [ ] Testes de integração para pipeline ETL
- [ ] Testes de carga para queries analytics (benchmark)
- [ ] Implementar data quality checks:
  - [ ] Validação de completude (missing data)
  - [ ] Validação de consistência (referential integrity)
  - [ ] Validação de acurácia (comparação com fonte)
  - [ ] Monitoramento de data drift
- [ ] Criar alertas para anomalias em métricas críticas

### Documentação

- [ ] Documentar arquitetura de dados (ERD dimensional)
- [ ] Criar data dictionary com definições de métricas:
  - [ ] Taxa de retenção (formula, periodicidade)
  - [ ] Taxa de inadimplência (critérios, aging)
  - [ ] Taxa de ocupação (cálculo, limites ideais)
  - [ ] Performance acadêmica (pesos, médias)
- [ ] Documentar SLAs e latência esperada
- [ ] Guia de troubleshooting para problemas comuns
- [ ] Documentar processos de backup e recovery

## Recomendação de Abordagem Incremental

Dado que este é um projeto complexo, recomenda-se abordagem faseada:

### Phase 1: MVP com PostgreSQL (2-3 semanas)

- Usar PostgreSQL existente com views materializadas
- Implementar 1-2 dashboards prioritários (retenção + inadimplência)
- Refresh manual ou agendado (nightly)
- Validar valor antes de investir em infraestrutura pesada

### Phase 2: Otimização (2-3 semanas)

- Adicionar índices especializados (BRIN, GIN)
- Implementar cache em Redis
- Adicionar mais dashboards (ocupação, performance)
- Automatizar refresh de agregações

### Phase 3: Escalabilidade (4-6 semanas)

- Avaliar migração para ClickHouse/BigQuery se necessário
- Implementar streaming de eventos com Kafka
- Adicionar predições com ML (churn prediction)
- Dashboard de C-level com KPIs executivos

## Estimativa de Esforço

- **Decisões Arquiteturais**: 1-2 semanas (arquiteto + infra + segurança)
- **Infraestrutura**: 2-4 semanas (depende da escolha)
- **Implementação Backend**: 4-6 semanas (2 devs)
- **Implementação Frontend**: 3-4 semanas (1-2 devs frontend)
- **Testes & QA**: 2-3 semanas (concorrente)
- **Documentação**: 1 semana (técnico + product)

**Total estimado**: 12-20 semanas (3-5 meses) dependendo do escopo e arquitetura escolhida

## Alternativa: Aproveitar Sistema Existente

O sistema já possui:

- ✅ Relatórios de frequência (`/api/reports/attendance/*`)
- ✅ SearchAnalytics para tracking de uso
- ✅ Múltiplos relatórios já implementados

Considerar **extend existing reports** antes de criar DW completo:

- Adicionar mais agregações aos endpoints existentes
- Criar views materializadas no PostgreSQL atual
- Adicionar dashboards básicos sem DW separado
- Avaliar se resolve necessidades antes de investir em infraestrutura pesada
