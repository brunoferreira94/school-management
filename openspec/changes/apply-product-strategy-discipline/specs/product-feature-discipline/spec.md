# product-feature-discipline Specification

## ADDED Requirements

### Requirement: Portfolio Feature Audit and Ranking

O sistema SHALL manter um inventário ranqueado de todas as capabilities/features do produto, avaliado pelo filtro "Swiss Knife" de duas camadas: (Camada 1) merece existir? — carga cognitiva, especificidade de ICP, custo operacional de sustentação, reforço à claims centrais; (Camada 2) constrói agora? — facilmente rejeitável? facilmente implementável?.

Cada item SHALL ter um score calculado como `(Novos Usuários + Nova Receita + Impacto) / Esforço`, onde os componentes são estimativas do time de produto.

#### Scenario: Quarterly portfolio audit

- **WHEN** o time de produto executa a auditoria trimestral
- **THEN** o sistema apresenta todas as features ranqueadas por score, com sinalização das que falharam na Camada 1 (candidatas a remoção/ocultação)

#### Scenario: New roadmap item filtered

- **WHEN** um novo item de roadmap é proposto
- **THEN** ele passa pelo filtro de duas camadas e só entra no backlog se aprovar a Camada 1; itens rejeitáveis (clear "no") ou de baixo score são mortos sem culpa

### Requirement: Cognitive-Room Gate on New Features

O sistema SHALL exigir, para todo novo item de roadmap aprovado, a resposta explícita a "qual feature existente eu mato/escondo para abrir espaço cognitivo?". Itens sem resposta SHALL ser bloqueados na triagem.

#### Scenario: Gate enforced at triage

- **WHEN** um item de roadmap é submetido sem declarar a feature sacrificada
- **THEN** o sistema bloqueia a entrada no backlog e sinaliza o autor

### Requirement: Swiss Knife Index Calculation

O sistema SHALL calcular o Swiss Knife Index (SKI) = (features usadas por >40% dos usuários ativos em janela de 30 dias) ÷ (total de features), a partir de dados de uso reais, e SHALL alertar quando SKI < 0.3.

#### Scenario: SKI below healthy threshold

- **WHEN** o SKI calculado é menor que 0.3
- **THEN** o sistema sinaliza "faca suíça desajeitada" e lista as features de baixa adoção (<10% da base ativa) para revisão

#### Scenario: SKI dashboard available to owner

- **WHEN** um Owner abre o dashboard de portfólio
- **THEN** o sistema exibe o SKI atual, a tendência e a lista de candidatas a ocultar/remover
