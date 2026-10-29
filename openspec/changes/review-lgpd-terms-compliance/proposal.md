# Proposal: review-lgpd-terms-compliance

> **Reescopado (2026-10-29)**: a auditoria técnica de privacidade de 2026-10-29 já gerou
> o change de remediação `fix-lgpd-compliance-gaps` (erasure, export, 428, consentimento,
> retenção, aviso art. 9º, runbook art. 48, logs) e os rascunhos `docs/privacy-policy.md`
> e `docs/lgpd-data-endpoints.md`. Este change NÃO duplica esse escopo — cobre as lacunas
> que nele **não** estão e consolida o dossiê para o advogado.

## Why

A revisão jurídica (terms/privacy/DPA/LGPD) é bloqueador de lançamento pendente de
advogado. O change de remediação cobre as correções técnicas, mas faltam os três
insumos que a revisão externa exige e que nenhum artefato atual cobre:

1. **Menores (Art. 14 LGPD)** — o sistema processa dados de crianças/adolescentes
   (Student.BirthDate, notas, boletins, diário) e **não há captura de consentimento
   parental** em nenhuma superfície. Para um SaaS escolar é a lacuna de maior risco.
2. **Operadores/terceiros (Art. 39)** — não há inventário técnico de quais dados pessoais
   fluem para Render, Supabase, Auth0, Asaas, e-mail/notificação e IA (drafts), nem o
   status de DPA de cada um (o fluxo comercial B2B de DPA está fora do escopo do change
   de remediação e adiado; o inventário técnico é pré-requisito dele).
3. **Base legal por finalidade (Art. 7/11)** — o aviso de privacidade do art. 9º
   (task do change de remediação) precisa do mapeamento finalidade→base como insumo;
   hoje ele não existe.

Entregável: **dossiê de conformidade** (`docs/legal/lgpd-compliance-audit.md`) —
inventário por entidade, base legal por finalidade, inventário de operadores, análise de
menores e checklist P0/P1/P2 para o advogado validar.

## What Changes

- **Auditoria de menores (Art. 14)**: onde dados de menor são coletados/exibidos, o que
  existe de vínculo Guardian↔Student, proposta de remediação (termo específico do
  responsável + flag de consentimento + gating de funcionalidades).
- **Inventário de operadores**: dados → operador → finalidade → status DPA.
- **Mapeamento base legal por finalidade** (insumo do aviso art. 9º e dos termos).
- **Dossiê consolidado** p/ revisão jurídica, referenciando o change de remediação e os
  documentos existentes (sem duplicá-los).

**BREAKING**: nenhum (auditoria/documentação). Remediações de código viram proposals
próprios (o consentimento parental deverá ser proposal seguinte).

## Impact

- Specs: `lgpd-compliance` (capability nova — requisitos do dossiê, menores e operadores).
- Código: nenhum neste change.
- Docs: `docs/legal/lgpd-compliance-audit.md` (novo), extensões de `docs/privacy-policy.md`
  e `docs/lgpd-data-endpoints.md` onde o dossiê apontar lacunas de conteúdo.
