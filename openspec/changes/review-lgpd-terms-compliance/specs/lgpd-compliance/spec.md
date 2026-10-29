## ADDED Requirements

### Requirement: Dossiê de conformidade LGPD para revisão jurídica

O projeto SHALL manter um dossiê de conformidade (`docs/legal/lgpd-compliance-audit.md`)
contendo: inventário de dados pessoais por entidade (campos → coleta → operador → base
legal → retenção), inventário de operadores/terceiros com status de DPA, mapeamento
finalidade → base legal (Art. 7/11) e lacunas priorizadas com remediações referenciadas —
atualizado quando novas superfícies de coleta forem adicionadas.

#### Scenario: Nova superfície de coleta atualiza o dossiê

- **GIVEN** um change que adiciona coleta de novo dado pessoal foi aprovado
- **WHEN** a proposta entra em implementação
- **THEN** o dossiê (inventário e base legal) é atualizado no mesmo change

### Requirement: Dados de menores com consentimento do responsável

O processamento de dados de crianças/adolescentes SHALL ocorrer com consentimento
específico e destacado de um dos pais ou responsável legal (Art. 14), registrado com
versão do termo, data e identificação do responsável — e as funcionalidades dependentes
SHALL permanecer bloqueadas enquanto o consentimento não estiver registrado.

#### Scenario: Cadastro de aluno menor sem consentimento é bloqueado

- **GIVEN** um cadastro de aluno identificado como menor (data de nascimento)
- **WHEN** o consentimento do responsável não está registrado
- **THEN** o fluxo dependente de consentimento é bloqueado até o aceite registrado

### Requirement: Inventário de operadores com fluxo de dados

O dossiê SHALL listar cada operador/terceiro (hosting, banco, identidade, pagamentos,
notificação, IA) com as categorias de dados pessoais que fluem a ele, a finalidade, a
localidade e o status de DPA/contrato — e SHALL ser atualizado quando um novo
operador for introduzido.

#### Scenario: Novo operador entra no inventário

- **GIVEN** a adoção de um novo serviço terceiro que trate dado pessoal
- **WHEN** o change correspondente é proposto
- **THEN** o inventário de operadores é atualizado com finalidade, categorias de dado,
  localidade e status de DPA
