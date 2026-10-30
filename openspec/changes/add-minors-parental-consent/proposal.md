# Proposal: add-minors-parental-consent

> Implementa a lacuna P0 do dossiê LGPD (`docs/legal/lgpd-compliance-audit.md` §3) e
> operacionaliza o requirement "Dados de menores com consentimento do responsável" da
> capability `lgpd-compliance` (delta em `review-lgpd-terms-compliance`).

## Why

O sistema processa dados de crianças/adolescentes (Student: Cpf, nome, endereço, mãe,
sexo, **cor/raça** — dado sensível) sem **nenhum registro de consentimento parental**
(Art. 14 LGPD). Para um SaaS escolar é a lacuna de maior risco: sanção específica do
Art. 14 §2 e inviabilidade de demonstrar conformidade em auditoria. O vínculo
`StudentGuardian` (studentCpf ↔ guardianCpf + `relationship`) já existe — o
consentimento pode ancorar nele sem nova modelagem estrutural.

## What Changes

- **Registro de consentimento parental**: nova entidade `GuardianConsent` (guardianCpf,
  studentCpf, termsVersion, channel, acceptedAtUtc — mesmo padrão de
  `TermsOfUseAcceptance`), criada quando o cadastro/edição do aluno indica menor
  (BirthDate → < 18 anos na data do registro) e um Guardian está vinculado.
- **Termo específico de responsável**: texto dedicado (cláusula de menores nos termos +
  aviso na UI de cadastro), versionado via `Legal:TermsOfUseVersion` ou versão própria
  `Legal:GuardianConsentVersion`.
- **Gating**: funcionalidades dependentes (matrícula efetiva em turma, lançamento de
  notas, comunicações ao aluno) bloqueadas enquanto o consentimento do menor não
  estiver registrado — falha explícita e registrável, sem bloquear o cadastro em si.
- **Endpoint de aceite**: `POST /api/privacy/guardian-consent` (guardiã autenticada no
  portal aceita pelo próprio vínculo; staff com permissão pode registrar aceite
  presencial com canal documentado).
- **Painel de status**: listagem de alunos menores com estado de consentimento
  (pendente/aceito/revogado) para a escola operar a regularização.

**BREAKING**: nenhum (aditivo; gating limitado às funcionalidades listadas).

## Impact

- Specs: `lgpd-compliance` (registro + gating de consentimento parental).
- Código: Domain (entidade + repo), migration SchoolContext, Application (service),
  Host (controller), UI (portal: aceite; staff: painel de status).
- Docs: termos/privacidade ganham cláusula de menores (redação final: advogado —
  draft aqui, insumo no dossiê §3).
