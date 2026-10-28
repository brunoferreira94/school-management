# feature-adoption Specification

## ADDED Requirements

### Requirement: Usage Instrumentation per Feature

O sistema SHALL instrumentar, para cada feature/capability, eventos de descoberta e de uso real, e SHALL expor uma taxa de adoção medida pela frequência apropriada ao hábito da feature (não por cliques isolados).

#### Scenario: Adoption rate computed per feature

- **WHEN** a janela de medição de 30 dias fecha
- **THEN** o sistema calcula a taxa de adoção de cada feature como (usuários ativos que a usaram na frequência apropriada) ÷ (usuários ativos elegíveis)

### Requirement: Directional Empty States

O sistema SHALL superficiar uma feature no empty state do local onde ela seria usada (ex.: convidar responsável a partir do cartão de turma), em vez de anunciá-la em modal global ou changelog.

#### Scenario: Empty state surfaces contextual feature

- **WHEN** um usuário atinge um estado vazio onde uma feature existente seria útil
- **THEN** o sistema exibe um empty state direcional com CTA única para aquela feature, e não um estado genérico

### Requirement: Triggered Onboarding by Behavior

O sistema SHALL disparar onboarding de uma feature quando o comportamento do usuário sinaliza necessidade (ex.: responsável abre notas → introduzir comparativo de desempenho), e NÃO por badges "novo" globais.

#### Scenario: Behavior signals need

- **WHEN** o usuário realiza a ação que indica necessidade de uma feature ainda não adotada
- **THEN** o sistema apresenta um gatilho contextual de uma única vez (sem spam recorrente)

### Requirement: Adoption Threshold Review

O sistema SHALL marcar para revisão qualquer feature cuja taxa de adoção fique abaixo do threshold definido pelo time de produto; a ação padrão SHALL ser "ocultar em configurações avançadas" (alcance para os 3%, invisível para os 97%), não exclusão.

#### Scenario: Low-adoption feature hidden not deleted

- **WHEN** a taxa de adoção de uma feature fica abaixo do threshold por duas janelas consecutivas
- **THEN** o sistema move a feature para configurações avançadas e notifica o owner, preservando acesso para quem já a usa
