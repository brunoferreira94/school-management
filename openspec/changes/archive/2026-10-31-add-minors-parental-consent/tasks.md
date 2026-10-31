# Tasks — add-minors-parental-consent

## 1. Domain e persistência

- [x] 1.1 Entidade `GuardianConsent` (GuardianCpf, StudentCpf, TermsVersion, Channel,
      AcceptedAtUtc, RevokedAtUtc?) + `IGuardianConsentRepository`.
- [x] 1.2 Migration SchoolContext (índice único por guardian+student+versão ativa).
- [x] 1.3 Serviço de avaliação: aluno é menor? consentimento vigente? (usado pelo gating).

## 2. Termo e aceite

- [x] 2.1 Texto do termo de responsável (draft PT-BR, art. 14 §1º) versionado.
- [x] 2.2 `POST /api/privacy/guardian-consent` (portal: guardiã aceita pelo vínculo;
      staff com permissão registra aceite presencial com canal).
- [x] 2.3 UI portal: aceite do termo do responsável no primeiro acesso ao menor.

## 3. Gating

- [x] 3.1 Matrícula em turma (`BulkEnrollStudentsAsync` + enroll singular) bloqueada p/
      aluno menor sem consentimento vigente (erro explícito, registrável).
- [x] 3.2 Lançamento de notas/avaliações bloqueado (mesmo gate).
- [x] 3.3 Comunicações ao aluno bloqueadas (mesmo gate).
- [x] 3.4 Painel de status de consentimento (staff): alunos menores × estado.

## 4. Docs e QA

- [x] 4.1 Cláusula de menores nos termos + aviso de privacidade (draft p/ advogado).
- [x] 4.2 Testes: consentimento registra/revoga; gating bloqueia e libera; export inclui
      o consentimento; integração do endpoint.
- [x] 4.3 Suíte completa verde + `ng build`.
- [x] 4.4 Dossiê LGPD atualizado (lacuna P0 → implementada).
