# Implementar Analytics Avançado

Autor: _a definir_
Data: 2025-10-18
Status: **BLOCKED** - Requer decisões arquiteturais e infraestrutura

## Resumo

Dashboards avançados para performance operacional e pedagógica: retenção, inadimplência, ocupação de turmas, performance de alunos, churn de responsáveis.

## Motivação

- Fornecer insights acionáveis para escolas melhorarem retenção e eficiência
- Centralizar métricas operacionais e pedagógicas em dashboards interativos
- Permitir análises de coorte e tendências históricas
- Detectar padrões de evasão e inadimplência antecipadamente

## Status Atual

⚠️ **BLOQUEADO** - Este change não pode ser implementado até que sejam tomadas decisões críticas sobre:

1. **Arquitetura de Dados**: Escolha entre PostgreSQL OLAP, ClickHouse ou BigQuery
2. **Pipeline ETL**: Definir estratégia de CDC (Change Data Capture) e frequência de atualização
3. **Orçamento**: Aprovação de custos de infraestrutura (se usar serviços cloud)
4. **Governança**: Políticas de privacidade e anonimização de dados (LGPD/GDPR)

## Contexto Atual do Sistema

O sistema já possui infraestrutura básica de analytics:

### ✅ Já Implementado

- **ReportsController** com endpoints de relatórios de frequência
- **SearchAnalytics** para tracking de uso da busca global
- Múltiplos relatórios com filtros e paginação
- Exportação CSV de relatórios

### ❌ Faltando para Analytics Avançado

- Data Warehouse ou camada OLAP
- Pipeline ETL/CDC automático
- Agregações dimensionais (coortes, períodos)
- Dashboards interativos no frontend
- Métricas complexas (retenção, churn prediction)

## Escopo

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

## Decisões Necessárias

### 1. Arquitetura de Dados (BLOCKER)

| Opção               | Investimento | Performance | Complexidade | Custo Mensal (estimado)   |
| ------------------- | ------------ | ----------- | ------------ | ------------------------- |
| **PostgreSQL OLAP** | Baixo        | Média       | Baixa        | $0 (já existe)            |
| **ClickHouse**      | Médio        | Alta        | Média        | $200-500 (self-hosted)    |
| **BigQuery**        | Alto         | Muito Alta  | Média-Alta   | $500-2000 (pay-per-query) |

**Recomendação**: Começar com PostgreSQL, migrar para ClickHouse se necessário após validação

### 2. Pipeline ETL (BLOCKER)

| Abordagem            | Latência      | Complexidade | Custo    |
| -------------------- | ------------- | ------------ | -------- |
| **SQL Triggers**     | Segundos      | Baixa        | $0       |
| **Batch Jobs**       | Minutos-Horas | Baixa        | $0-50    |
| **Debezium + Kafka** | Milissegundos | Alta         | $200-500 |

**Recomendação**: Batch jobs diários inicialmente, CDC streaming se necessário após validação

### 3. Governança de Dados (BLOCKER)

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

1. **Decisão de Stakeholders**: Aprovar abordagem (MVP vs Full Stack)
2. **Orçamento**: Aprovar custos de infraestrutura (se aplicável)
3. **Priorização**: Definir quais dashboards são críticos
4. **Discovery**: Workshop com usuários para entender necessidades reais
5. **Unblock**: Tomar decisões arquiteturais para desbloquear implementação

## Referências

- Ver `tasks.md` para breakdown detalhado de tarefas
- Ver `design.md` para considerações de arquitetura
- Sistema atual: `SchoolManagement/ReportsController.cs`
- Analytics existente: `SchoolManagement.Domain/SearchAnalytics.cs`
