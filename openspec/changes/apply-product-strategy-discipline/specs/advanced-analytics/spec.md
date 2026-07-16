# advanced-analytics Specification (delta)

## MODIFIED Requirements

### Requirement: Operational analytics dashboards

O sistema SHALL fornecer dashboards analíticos operacionais para equipes administrativas incluindo, no mínimo, indicadores de inadimplência, retenção, matrícula e presença, E SHALL incluir um widget de **Swiss Knife Index (SKI)** e um widget de **taxa de adoção por feature** derivados de eventos de uso reais. Os dashboards SHALL expor a lista de features abaixo do threshold de adoção para revisão de portfólio.

#### Scenario: Owner views portfolio health

- **WHEN** um Owner abre o dashboard analítico operacional
- **THEN** o sistema exibe SKI atual, tendência e taxa de adoção por feature, sinalizando itens <0,3 e <threshold de adoção
