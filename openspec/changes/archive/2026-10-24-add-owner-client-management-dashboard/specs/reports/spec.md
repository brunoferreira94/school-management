## ADDED Requirements

### Requirement: Interactive Reports

O sistema MUST oferecer relatórios interativos para o Owner, com filtros, visualizações, exportação e salvamento de views.

#### Scenario: Criar relatório interativo

- **WHEN** o Owner abre a tela de relatórios interativos
- **THEN** o sistema apresenta filtros de período, tenant, plano, unidade, curso, turma, status financeiro e status acadêmico

#### Scenario: Visualizar gráfico

- **WHEN** o Owner aplica filtros e escolhe uma visualização gráfica
- **THEN** o sistema exibe o resultado em gráfico de linha, barra, pizza ou comparação conforme a métrica selecionada

#### Scenario: Exportar relatório

- **WHEN** o Owner exporta um relatório permitido
- **THEN** o sistema gera CSV ou PDF com os dados filtrados e registra auditoria quando houver exportação cross-tenant

## ADDED Requirements

### Requirement: Report Drill-down

O sistema MUST permitir drill-down dos relatórios para detalhes operacionais.

#### Scenario: Drill-down por tenant

- **WHEN** o Owner clica em uma série de tenant dentro de um relatório agregado
- **THEN** o sistema filtra o relatório para aquele tenant

#### Scenario: Drill-down por unidade

- **WHEN** o Owner clica em uma unidade escolar dentro do relatório
- **THEN** o sistema exibe os dados daquela unidade

## ADDED Requirements

### Requirement: Saved Views

O sistema MUST permitir salvar views de relatório com filtros e visualização escolhida.

#### Scenario: Salvar view

- **WHEN** o Owner salva uma view de relatório
- **THEN** o sistema armazena nome, filtros e tipo de visualização para reuso

#### Scenario: Reutilizar view salva

- **WHEN** o Owner abre uma view salva
- **THEN** o sistema reaplica os filtros e carrega os dados correspondentes
