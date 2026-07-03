## ADDED Requirements

### Requirement: Owner Dashboard

O sistema MUST oferecer ao usuário com perfil Owner um dashboard centralizado para acompanhar a saúde da base de clientes do SaaS.

#### Scenario: Abrir dashboard do Owner

- **WHEN** um usuário Owner acessa `/owner/dashboard`
- **THEN** o sistema exibe KPIs de clientes ativos, receita recorrente, inadimplência, retenção, crescimento, uso de limites e alertas críticos

#### Scenario: Filtrar dashboard por período

- **WHEN** o Owner seleciona um período no filtro global
- **THEN** os KPIs e gráficos são recalculados para o período selecionado

#### Scenario: Drill-down de alerta crítico

- **WHEN** o Owner clica em um alerta crítico de tenant
- **THEN** o sistema navega para o detalhe do tenant com o contexto do alerta

## ADDED Requirements

### Requirement: KPI Cards

O dashboard MUST apresentar cartões de métrica com valor atual, comparação com período anterior, indicador de tendência e status visual.

#### Scenario: Exibir tendência positiva

- **WHEN** a receita recorrente aumenta em relação ao período anterior
- **THEN** o cartão exibe tendência positiva e cor de destaque verde

#### Scenario: Exibir limite próximo do estouro

- **WHEN** um tenant está acima de 90% do limite de alunos, staff, unidades ou armazenamento
- **THEN** o dashboard exibe alerta de limite próximo para o Owner

## ADDED Requirements

### Requirement: Alertas Acionáveis

O dashboard MUST listar alertas acionáveis para clientes com risco financeiro, técnico ou operacional.

#### Scenario: Tenant com assinatura prestes a vencer

- **WHEN** a assinatura de um tenant vence nos próximos 7 dias
- **THEN** o dashboard exibe alerta de renovação pendente

#### Scenario: Tenant com inadimplência alta

- **WHEN** a inadimplência de um tenant ultrapassa o limite configurado
- **THEN** o dashboard exibe alerta financeiro com link para o detalhe do tenant
