# Runbook de Incidente de Segurança de Dados Pessoais (LGPD — art. 48)

Guia operacional para resposta a **incidentes de segurança que envolvam dados pessoais** —
ex.: vazamento, exposição indevida, acesso não autorizado, perda de integridade/confidencialidade.

> **Escopo:** não cobre incidentes operacionais genéricos (API fora, latência, billing) —
> veja `operations/incident-runbook.md`. Este trata de incidentes com **risco a titulares**,
> com foco no prazo de notificação de 48h (art. 48 da LGPD).

---

## 1. Gatilho / quando acionar

Acione o plano imediatamente quando houver conhecimento de:

- Exposição de CPF, dados de saúde, dados bancários/financeiros, dado sensível (cor/raça, etc.) em trânsito ou repositório;
- Acesso ou alteração não autorizada a registros com dados pessoais (ex.: `Students`, `UserAccounts`, `AuditLogs`, `CookieConsents`);
- Comprometimento de credenciais que permita acesso a dados pessoais (ex.: vazamento de `User secrets` / `Render` env);
- Perda de backup/replica que exponha dados pessoais.

⚠️ Não espere confirmação total: **48h contam a partir do conhecimento fundamentado do fato** —
se houver motivo razoável para acreditar que houve incidente, inicie.

---

## 2. Papéis e escalação

| Papel | Responsável |
|------|-------------|
| **On-call / Eng** | Detetiva — contenção técnica + coleta de evidências (primeiros 30 min) |
| **DPO (Encarregado LGPD)** | `dpo@escolamais.com.br` — valida risco, decide notificação ANPD/titulares |
| **Incident Commander (IC)** | Coordena comunicação interna + escala jurídico |
| **Jurídico** | Revisa texto de notificação + libera comunicação a titulares |
| **Comunicação** | Status page / suporte (após liberação jurídico) |

Escalada: `#incidentes` (Slack) → e-mail DPO — **24h sem resposta do DPO = escalar ao CEO.**

---

## 3. Checklist de resposta (≤60 min iniciais)

1. **Confirmar e conter**
   - [ ] Isolar recurso comprometido (revogar token, bloquear IP, rollback de deploy, revogar secret).
   - [ ] Determinar escopo: quais tabelas, chaves (tenant_id), linhas afetadas, CorrelationId do `AuditLoggingMiddleware`.
   - [ ] Parar coleta: `SELECT ... FROM "AuditLogs" WHERE "Timestamp" >= <início suspeito> AND ("Path" LIKE '%/api/students%' OR ...)` — coletar amostra sem exponha mais dados.

2. **Avaliar risco (art. 48 §1º)**
   - Dado sensível envolvido?  ☐ Sim ☐ Não
   - CPF/ID direto exposto sem hash? ☐ Sim ☐ Não
   - Dados bancários/financeiros/saúde? ☐ Sim ☐ Não
   - Risco de discriminação, dano material ou moral? ☐ Sim ☐ Não
   - Nº estimado de titulares afetados: ___
   - **Classificação:** Baixo / Médio / Alto — só "Alto" e "Médio" com dano provável implicam notificação.

3. **Coletar evidências (art. 30)**
   - [ ] Dump de logs (audit + middleware) do período — **sem CPFs em claro** (anonymizar antes de compartilhar fora do time).
   - [ ] Snapshot da tabela afetada (colunas apenas): `tenant_id`, chave primária, `Timestamp`, `Method`, `Path`, `User` (logado) — sem colunas pessoais.
   - [ ] Registro de incidente em `docs/operations/incident-log-<date>.md`: descrição do fato, data/hora (UTC), dados envolvidos (categoria, sem valores), prováveis consequências, medidas adotadas, contato DPO.

4. **Medidas corretivas**
   - [ ] Corrigir vetor (credencial exposta, validação, migração de permissão).
   - [ ] Revogar sessões/tokens afetados (`DELETE /api/auth/revoke`? `RefreshTokens` invalidados).
   - [ ] Rotacionar secret envolvido (`Privacy:IpHashSalt`, `Jwt:Secret`, `Auth0:...`) — via secret manager + redeploy.

5. **Decisão de notificação (DPO + Jurídico)**
   - **ANPD:** obrigatória se risco a direitos (art. 48 §2º) — notificar em até **48h** do conhecimento.
   - **Titulares:** obrigatória se risco relevante a direitos — comunicação individial quando viável.
   - Não houver risco relevante? Registrar o atendimento mesmo assim (art. 48 §3º).

---

## 4. Texto de notificação (templates)

### 4.1 ANPD (art. 48 §2º)

```
Assunto: Notificação de incidente de segurança — ANPD

À ANPD (autoridade nacional de proteção de dados):

Tipo de fato: [exposição / acesso não autorizado]
Data/hora do conhecimento: <UTC>
Período afetado: <UTC início> a <UTC fim>
Dados pessoais envolvidos: [categoria — ex.: CPF, nome, e-mail de responsáveis]
Número aproximado de titulares: ___
Risco: [baixo/médio/alto]
Probabilidade de dano: [ex.: acesso a CPF sem hash — dano de privacidade]
Medidas adotadas: [contenção + correção + revisão de acesso]
Medidas adotadas para mitigar: [rotação de credencial X, invalidez de tokens, revisão de permissões]
Contato do encarregado: dpo@escolamais.com.br
```

### 4.2 Titulares (quando houver risco relevante)

```
Assunto: Comunicado de segurança — [NOME DA SUA ESCOLA]

Em <data>, identificamos um acesso não autorizado a dados que podem incluir
informações pessoais de responsáveis/alunos vinculados ao seu cadastro.

O que aconteceu: <descrição objetiva — ex.: exposição temporária de um backup>.
O que fizemos: <medidas> e notificamos a ANPD, conforme LGPD.
O que você pode fazer: monitorei chamadas/senhas — troque a senha em [link] se for
impacto. Dúvidas: dpo@escolamais.com.br.
```

> Sempre revisado pelo Jurídico antes do envio.

---

## 5. Prazos (art. 48)

| Etapa | Prazo |
|------|-------|
| Conhecimento fundamentado → início do atendimento | ≤ 1 h |
| Contenção técnica + coleta de evidências iniciais | ≤ 1 h |
| Decisão DPO/Jurídico sobre notificação | ≤ 2 h (até 24h em casos complexos) |
| Envio à ANPD (art. 48 §2º) | ≤ 48 h do conhecimento |
| Comunicação a titulares (risco relevante) | ≤ 48 h do conhecimento |
| Justificativa para prorrogação (se não for possível em 48h) | no prazo restante |

Se o fato for conhecido fora de expediente, o on-call inicia o atendimento e escala o DPO;
o 48h é corrido — **não interrompe**.

---

## 6. Registro de atividades de tratamento (art. 30)

Todo incidente deve gerar um registro versionado em `docs/operations/` com:
- descrição do fato e classificação de risco;
- categorias e bases legais dos dados envolvidos (ver `docs/privacy-policy.md` §3);
- destinatários/compartilhamento envolvidos;
- prazos de retenção aplicáveis (ver `docs/privacy-policy.md` §4);
- medidas de segurança adotadas (`docs/lgpd-data-endpoints.md` §Observações de conformidade).

---

## 7. Simulado (game day) LGPD — trimestral

- [ ] Injetar exposição de CPF sem hash (seed em DB de staging): confirmar detecção do `AuditLog` + escoragem ≤ 1h + 48h-sim window para notificação.
- [ ] Validar redação do template ANPD contra campos obrigatórios do formulário da ANPD.
- [ ] Validar comunicação a titulares via envio real para contas de teste do DPO.
- [ ] Registrar no postmortem: gaps de detecção/prevenção.

---

## 8. Referências rápidas

- LGPD art. 48 (notificação de incidentes de segurança);
- LGPD art. 4º (definição de dado pessoal — inclui IP quando identifica);
- LGPD art. 8º & §2º (consentimento); art. 18 (direitos do titular);
- `docs/privacy-policy.md`, `docs/lgpd-data-endpoints.md`, `docs/legal/lgpd-compliance-audit.md`.
