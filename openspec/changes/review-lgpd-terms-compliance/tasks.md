# Tasks — review-lgpd-terms-compliance

> Complementa `fix-lgpd-compliance-gaps` (remediação técnica) — não o duplica.

## 1. Menores — Art. 14 LGPD (crítico)

- [x] 1.1 Mapear coleta/exibição de dados de menor: Student (BirthDate, Cpf, nome,
      endereço, contato), notas/avaliações/boletins, diário de classe, fotos (se houver),
      endpoints que expõem PII de aluno para cada papel.
- [x] 1.2 Verificar vínculo Guardian↔Student atual (modelo, FK, quem cadastra) e onde
      um consentimento parental poderia ancorar (StudentPlan? Guardian? tabela nova).
- [x] 1.3 Auditar termos/aviso vigentes (versão 2026.1, `docs/privacy-policy.md`):
      há cláusula sobre menores/consentimento parental?
- [x] 1.4 Documentar no dossiê: lacuna, risco (sanção Art. 14 §2), proposta de
      remediação (termo específico + registro de consentimento + gating) — insumo do
      proposal seguinte.

## 2. Operadores e terceiros — Art. 39

- [x] 2.1 Inventariar operadores e dados que fluem a cada um: Render (host/logs),
      Supabase (banco de staging + backups), Auth0 (identidade) + auth0-mock,
      Asaas (pagamentos/CPF/titular financeiro), e-mail/notificações, provedor de IA
      (drafts de avaliação), Cypress/E2E (dados sintéticos vs reais em staging).
- [x] 2.2 Para cada operador: finalidade, categorias de dado, localidade (BR/exterior),
      status de DPA/contrato (verificar configs/links no repositório).
- [x] 2.3 Documentar no dossiê + marcar os que exigem ação do dono (contrato/DPA).

## 3. Base legal por finalidade — Art. 7/11

- [x] 3.1 Mapear finalidades reais: execução de contrato (gestão escolar/alunos),
      obrigação legal (registros escolares), legítimo interesse (segurança, anti-fraude,
      rate limit, auditoria), consentimento (cookies, marketing, analytics do portal).
- [x] 3.2 Atribuir base legal por superfície (endpoints do `lgpd-data-endpoints.md`
      + entidades do inventário) e apontar inconsistências (ex.: analytics sem base).
- [x] 3.3 Entregar o mapeamento como insumo direto para a task de aviso art. 9º do
      change de remediação (referência cruzada).

## 4. Dossiê consolidado p/ advogado

- [x] 4.1 Escrever `docs/legal/lgpd-compliance-audit.md`: sumário executivo, inventário
      por entidade (entidade → campos → coleta → operador → base legal → retenção),
      análise de menores, inventário de operadores, base legal, lacunas P0/P1/P2 com
      remediações (referenciando `fix-lgpd-compliance-gaps` e proposals futuros) e
      checklist de validação jurídica.
- [x] 4.2 Revisar/cruzar `docs/privacy-policy.md` e `docs/lgpd-data-endpoints.md`:
      apontar no dossiê o que cada um ainda não cobre (sem reescrever — conteúdo é do
      change de remediação).
- [ ] 4.3 Entregar ao dono do produto p/ advogado; P0s viram proposals (menores em
      primeiro).
