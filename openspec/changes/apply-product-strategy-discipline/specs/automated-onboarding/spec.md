# automated-onboarding Specification (delta)

## MODIFIED Requirements

### Requirement: Guided onboarding wizard

O sistema SHALL guiar o admin através de um wizard de no máximo 3 passos críticos seguido de welcome modal com vídeo curto e ação imediata, E SHALL direcionar a atenção pós-login para as features que retêm (primeira turma, importação de alunos, boletim, portal do responsável) usando hierarquia visual que prioriza o que gera valor sobre o que é mais saliente por acidente. Empty states e triggered hints SHALL superficiar features existentes no ponto de uso, não em modais globais.

#### Scenario: Post-login attention directs to retention-driving features

- **WHEN** o admin conclui o setup e cai no painel
- **THEN** o sistema apresenta hierarquia visual onde a primeira ação recomendada é a feature de maior retenção (ex.: criar primeira turma), e features de nicho aparecem em segundo plano
