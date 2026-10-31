# lgpd-compliance Specification

## Purpose

Garantir conformidade LGPD ao sistema de gestão escolar: consentimento parental
para menores (art. 14), registro versionado e auditável, e bloqueio (gating) das
funcionalidades dependentes de dados do menor enquanto o consentimento não estiver
vigente — permitindo que a escola regularize o status sem perder a operação.

## Requirements

### Requirement: Registro de consentimento parental

O sistema SHALL registrar o consentimento específico de responsável para o
processamento de dados de aluno menor (Art. 14) com: identificação do responsável
(vínculo `StudentGuardian`), identificação do aluno, versão do termo aceito, canal e
timestamp — e SHALL permitir revogação registrada.

#### Scenario: Aceite do responsável é registrado e verificável

- **GIVEN** um aluno menor com responsável vinculado
- **WHEN** o responsável aceita o termo específico (portal) ou o staff registra aceite
  presencial com canal documentado
- **THEN** o consentimento fica registrado com versão, canal e timestamp
- **AND** o status aparece no painel de consentimentos da escola

### Requirement: Gating de funcionalidades sem consentimento

As funcionalidades dependentes de dados do menor (matrícula em turma, lançamento de
notas/avaliações, comunicações ao aluno) SHALL permanecer bloqueadas enquanto não
houver consentimento parental vigente, com falha explícita e registrável — sem bloquear
o cadastro do aluno em si.

#### Scenario: Matrícula de menor sem consentimento é bloqueada

- **GIVEN** um aluno menor sem consentimento parental vigente
- **WHEN** a escola tenta matriculá-lo em uma turma
- **THEN** a operação falha com erro explícito de consentimento pendente
- **AND** nenhum vínculo aluno-turma é criado

#### Scenario: Consentimento registrado libera as funcionalidades

- **GIVEN** o consentimento do responsável registrado
- **WHEN** as mesmas operações são repetidas
- **THEN** executam normalmente
