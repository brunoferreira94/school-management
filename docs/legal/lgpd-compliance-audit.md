# Dossiê de Conformidade LGPD — school-management

> **Status**: draft técnico para revisão jurídica externa (advogado). Gerado pelo change
> OpenSpec `review-lgpd-terms-compliance`. Complementa o change de remediação
> `fix-lgpd-compliance-gaps` (erasure/export/consentimento/retenção/aviso art. 9º/runbook
> art. 48) — este dossiê cobre o que aquele não cobre: menores (Art. 14), operadores
> (Art. 39) e base legal por finalidade (Art. 7/11).
> **Data**: 2026-10-29 · **Versão dos termos vigente**: 2026.1 (`Legal:TermsOfUseVersion`)

---

## 1. Sumário executivo

| Área | Estado | Risco |
|---|---|---|
| Direitos do titular (Art. 18) | Endpoints existem (export/correção/exclusão); correções P0 em andamento no change de remediação (CPF persiste após erasure; export incompleto; gate 428 bloqueia DSR) | **Alto** até remediação |
| **Menores (Art. 14)** | **Sem consentimento parental em qualquer superfície** — lacuna crítica | **Crítico** |
| Dados sensíveis (Art. 5º II) | `Student.ColorRace` (origem racial) e `Gender` coletados sem tratamento diferenciado | **Alto** |
| Operadores/terceiros (Art. 39) | Inventário abaixo; IA e e-mail ainda mock/placeholder; DPA pendente de contratação | Médio |
| Base legal (Art. 7/11) | Parcial (página de privacidade cita Art. 7º II/IX); mapeamento completo ausente | Médio |
| Retenção/eliminação | Sem política formal (remediação em andamento) | Médio |
| Incidentes (Art. 48) | Runbook em andamento no change de remediação | Médio |

**Conclusão**: o sistema **não deve ser lançado** antes de (a) concluir a remediação P0 do
change `fix-lgpd-compliance-gaps` e (b) implementar o consentimento parental para menores
(proposal seguinte). Ambos são pré-requisitos para a validação jurídica externa ter
material mínimo.

---

## 2. Inventário de dados pessoais por entidade

| Entidade/Tabela | Campos pessoais | Coleta | Base legal (ver §4) | Retenção atual |
|---|---|---|---|---|
| `Student` (global, CPF=PK) | Cpf, Name, BirthDate, Address, ParentContact, MotherName, **Gender**, **ColorRace** (sensível), InepCode | CRUD pelo staff da escola, importação CSV, censo escolar | Contrato (escola↔SaaS) + **obrigação legal** (Censo/INEP) para censo; sensíveis → Art. 11, II, "a" | Sem política formal; soft/hard delete a auditar |
| `Guardian` | Name, Cpf, Phone, Email, PasswordHash | Cadastro no portal/pela escola | Contrato | Sem política formal |
| `StudentGuardian` (vínculo) | studentCpf, guardianCpf, relationship | Vinculação pela escola | Contrato | Segue as entidades |
| `UserAccount` | Username (e-mail), PasswordHash, StaffId, StudentCpf (portal), **TenantId** (binding) | Register-school (staff), portal (StudentCpf), seed demo | Contrato + legítimo interesse (segurança) | Sem política formal |
| `Staff` | Name, BirthDate, Cpf, InepCode, Expertise | CRUD pela escola | Contrato + obrigação legal (INEP) | Sem política formal |
| `TermsOfUseAcceptance` + `...Audit` | subjectId (user:<id>), TenantId, TermsVersion, Channel, timestamps, IP? | Aceite no login/portal | Legítimo interesse (comprovação) | Sem política formal |
| `CookieConsent` | decisão, categorias, timestamps | Banner de cookies | **Consentimento** | Sem política formal |
| `RefreshTokens` / `TokenAudits` | token hash, userId, IP?, user-agent? | Login/refresh | Legítimo interesse (segurança) | Expiração por janela (refresh) — auditoria sem prazo |
| AuditLogs / rate-limit logs | usuário, rota, status, **IP/user-agent** (→ hash na remediação) | Middleware | Legítimo interesse (segurança) | Sem prazo formal |
| Billing (Installments/Plans/Asaas ids) | valores, referências de titular (StudentPlan→Student.Cpf) | Fluxo financeiro | Contrato + obrigação legal (fiscal) | Obrigação fiscal (5 anos — a confirmar) |
| Backups (Supabase staging) | Tudo acima (cópia) | Automático | — | Sem política formal |

**Nota de minimização**: os seeds/E2E usam CPFs sintéticos (910.../920...) e staging usa
fixtures sintéticas — bom estado. Revisar que **nenhum dado real de cliente** vá para
staging (hoje o staging roda com dados demo — OK).

---

## 3. Menores — Art. 14 LGPD (crítico)

### Achados (auditoria 2026-10-29)

1. **Coleta ampla de dados de menor**: `Student` carrega Cpf, nome, endereço, contato do
   responsável, nome da mãe, sexo e **cor/raça** — coletados via CRUD, bulk-update e
   importação CSV pela escola; expostos em listagens e no portal (notas, boletins,
   diário, comunicações).
2. **Dado sensível sem tratamento diferenciado**: `ColorRace` = origem racial (Art. 5º, II).
   Hoje não há base legal específica registrada nem controle diferenciado de acesso —
   embora a finalidade (Censo Escolar/INEP) caiba em **Art. 11, II, "a" (obrigação legal
   pelo controlador)**, isso precisa estar **documentado e limitado** (coleta só quando
   necessária ao censo; não usar para outras finalidades).
3. **Sem consentimento parental**: não existe registro de consentimento de responsável
   em nenhuma superfície — nem nos termos (`termos.component.html`, 63 linhas), nem na
   página de privacidade (62 linhas), nem no fluxo de cadastro de aluno.
4. **Âncora disponível**: o vínculo `StudentGuardian` (studentCpf ↔ guardianCpf +
   `relationship`) já existe no modelo — o consentimento parental pode ancorar nele sem
   nova modelagem estrutural.

### Remediação proposta (proposal seguinte — P0)

- Termo específico de consentimento parental exibido no cadastro do aluno menor
  ( BirthDate → < 18 anos na data do cadastro).
- Registro do consentimento (entidade nova ou extensão de StudentGuardian): versão do
  termo, data, canal, identificação do responsável (guardianCpf do vínculo).
- **Gating**: funcionalidades dependentes (matrícula efetiva, lançamento de notas,
  comunicações ao aluno) bloqueadas até o consentimento registrado.
- Cláusula de menores nos termos + na política de privacidade (art. 14 §1º, §2º —
  conteúdo e aspectos relevantes, com redação final do advogado).
- Nota: em escola, o **controlador** do dado do aluno é a ESCOLA (cliente B2B); o SaaS
  opera como **operador** para esses dados. O consentimento parental é capturado pela
  escola — o SaaS deve **fornecer o mecanismo** e guardar a comprovação. Esse desenho
  controlador/operador precisa constar dos termos (ver §6).

---

## 4. Base legal por finalidade — Art. 7/11

| Finalidade | Superfícies | Base legal (Art.) | Observação |
|---|---|---|---|
| Gestão escolar (alunos, turmas, notas, frequência, diário, comunicações) | `/api/students`, `/api/classgroups`, assessments, diary, communications | **Contrato** (7º, II) entre escola e SaaS; escola é controladora do dado do aluno | Já citada na página de privacidade ✓ |
| Censo Escolar / INEP (MotherName, Gender, ColorRace, InepCode) | censo, Student | **Obrigação legal** (7º, II; sensíveis → 11º, II, "a") | Documentar no aviso; limitar coleta ao necessário |
| Faturamento/assinatura (SaaS) | checkout, subscriptions, Asaas | **Contrato** (7º, II) + obrigação fiscal | Dados do pagador (CPF) → operador de pagamento |
| Segurança, anti-fraude, rate limit, auditoria | middleware de auth, rate limit, AuditLogs, TokenAudits | **Legítimo interesse** (7º, IX) | Minimização de IP em andamento (remediação) |
| Cookies opcionais / analytics do portal | CookieConsent, PortalAnalytics | **Consentimento** (7º, I) | Unificação do consentimento em andamento (remediação) |
| Aceite de termos | TermsOfUseAcceptance(+Audit) | Comprovação — legítimo interesse | N/A |
| Exportação portabilidade | DSR me/export | Dever legal (18º, II) | N/A |

**Inconsistência a resolver**: analytics do portal hoje fragmentado entre dois stores
locais (remediação em andamento); base legal do analytics = consentimento — o gating
precisa refletir isso (task do change de remediação).

---

## 5. Operadores e terceiros — Art. 39

| Operador | Serviço | Dados que fluem | Localidade | Status DPA |
|---|---|---|---|---|
| Render | hosting API + UI (prod/staging) + logs de request | Todo tráfego da API (payloads em trânsito), IPs, headers | EUA (região a confirmar na contratação prod) | **Pendente** — exigir DPA na contratação prod |
| Supabase | banco staging + backups | Cópia completa do staging (dados demo/sintéticos) | Região a confirmar | **Pendente** |
| Auth0 | identidade (prod; hoje Domain vazio → auth0-mock em dev) | e-mail, identificador externo, claims de permissões | A definir na configuração | **Pendente** (configs do dashboard no blocker de launch) |
| Asaas | pagamentos (hoje `Asaas__ApiKey=""` → MockPayment) | CPF/nome do pagador, valores, referências | Brasil (Asaas é nacional) | **Pendente** — credenciais reais pendentes |
| E-mail/notificação | SMTP placeholder (`smtp.example.com`) — sem operador real | e-mails transacionais (nome, e-mail) | — | Não contratado ainda |
| IA (drafts de avaliação) | `MockAiDraftProvider` apenas — **sem provedor externo real** | Se contratado: texto de avaliações (dado de menor!) | — | **Bloquear envio de PII de aluno a LLM externo sem DPA + base legal** |
| Navegador do titular | cookies locais (consentimento, sessão) | decisão de consentimento, token | Dispositivo do titular | N/A |

**Ação do dono**: contratação prod (Render) deve incluir DPA; Supabase/AUTH0/Asaas
igual. **Regra técnica proposta**: nenhum conteúdo de aluno (notas, avaliações, diário)
enviado a serviço de IA externo antes de DPA + base legal documentada — hoje o mock
elimina o risco; manter guarda quando real (proposal futuro).

---

## 6. Controlador × Operador (cláusula dos termos)

- **Escola (cliente B2B)** = controladora dos dados de alunos/responsáveis/staff dela.
- **Plataforma (SaaS)** = operadora para esses dados + controladora para dados de conta
  (usuário administrador da escola) e de uso do serviço.
- Os termos atuais não explicitam esse desenho → lacuna de conteúdo (redação final:
  advogado; insumo no §3 e §4).

---

## 7. Lacunas priorizadas

| Prio | Lacuna | Ação | Onde |
|---|---|---|---|
| **P0** | Consentimento parental para menores (Art. 14) | Proposal novo (termo + registro + gating) | Este dossiê §3 |
| **P0** | Erasure não remove CPF; export incompleto; DSR bloqueado por 428 | Em andamento | `fix-lgpd-compliance-gaps` |
| **P1** | Dado sensível (ColorRace) sem documentação de base/gating | Incluir no proposal de menores + aviso art. 9º | Este dossiê §3/§4 |
| **P1** | DPA com Render/Supabase/Auth0/Asaas | Ação comercial do dono na contratação prod | Este dossiê §5 |
| **P1** | Política de retenção formal (logs, tokens, backups, escola cancelada) | Em andamento | `fix-lgpd-compliance-gaps` |
| **P2** | Controlador×operador nos termos | Conteúdo p/ advogado (§6) | Este dossiê |
| **P2** | Regra de PII de aluno × IA externa | Guarda técnica quando IA real | Proposal futuro |

---

## 8. Checklist para o advogado validar

- [ ] Redação final dos termos (incl. cláusula controlador×operador e menores)
- [ ] Redação final do aviso de privacidade (art. 9º — insumo: §4 deste dossiê)
- [ ] Aprovação do desenho de consentimento parental (§3) e do termo específico
- [ ] Confirmação das bases legais por finalidade (§4), especialmente censo/sensíveis
- [ ] Revisão dos DPAs a contratar (§5) — Render, Supabase, Auth0, Asaas
- [ ] Validação do runbook de incidentes (art. 48) — change de remediação
- [ ] Confirmação dos prazos de retenção por classe de dado (§2 última coluna)

---
*Próxima revisão: após implementação do consentimento parental e da remediação P0.*
