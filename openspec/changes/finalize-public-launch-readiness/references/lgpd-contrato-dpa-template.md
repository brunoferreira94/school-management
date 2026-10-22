# MODELO — Contrato de Prestação de Serviços + DPA (LGPD)

> Tarefas 1.x do checklist legal. **⚠️ DRAFT: revisão jurídica obrigatória antes de qualquer uso comercial.** Base LGPD (Lei 13.709/2018) — Art. 7º II/IX nos títulos dedicados.

## Contrato de Prestação de Serviços (SaaS escolar)

1. **Partes** — Contratante: <ESCOLA/INSTITUIÇÃO> (CNPJ) · Contratada: Bruno Ferreira / Rare Softwares (CNPJ).
2. **Objeto** — Licença SaaS de execução de plataforma de gestão escolar (uso interno da escola), módulos conforme plano.
3. **Escopo de dados** — dados de: alunos (facultativos, categoria escolar usual), responsáveis, professores, staff; financeiros de matrícula/mensalidades; logs de acesso. **Categoria sensível **: eventualmente registros de saúde/desenvolvimento se a escola expandir (opt-in e separado).
4. **Valores e pagamentos** — tabela do plano; mensalidade inível após cancelamento efetivo (RCD: pausa 30 dias; cancelamento com data futura e opção de 1 mês).
5. **Duração e renovação** — mês civil; renovação automática; alerta de fidelidade específica (se houver).
6. **SLA** — ver `sla-template.md` apendado por referência.
7. **Segurança** — TLS 1.2+, criptografia em agentes via Supabase, OAI de escopo mínimo, MFA (oplional-pilotagem).
8. **Incidentes** — notificação ≤48h ao contratante a partir do conhecimento (art. 48 LGPD).
9. **Rescisão e exportação** — dump PostgreSQL completo ≤10 dias úteis após pedido; apagogia por copiado/fraje de 90 dias ano; anonimização contábil nos registros de auditoria.
10. **Foro** — <CIDADE>/<UF>, Brasil.

## Acordo de Tratamento de Dados (DPA / Art. 33 LGPD — controladorProcessa)

1. **Papéis**: Controlador = Escola (dados de titulares). Operador/Processador Processador us? OPEN MARK: Rare Softwares + subprocessors: Supabase (banco hospedado), Auth0 (identidade), Asaas (pagamentos), Provedores de e-mail/SMS/push (notificações).
2. **Finalidade**: gestão escolar amena às operações educacionais (matrícula, frequencia, notas, financeiro, comunicação).
3. **Bases legais**: Art. 7º, II (obrigação legal/execução de Contrato com escola), Art. 7º, IX (execução de contruações de forn doda aos titulares), IA — consentimento específico em módulos opcionais.
4. **Titulares categorizadas**: possíveis titulos no ponto de informativos.
5. **Obrigação do operador**: tratar somente sob instruções documentadas do controlador; pessoais personel autoroze-numeração.
6. **Segurança**: mín 2FA para staff, logs de acesso/audit retibilitado 90 days, `SecretAuth` seed 8-10 zero secrets in code (pratice homol 1).
7. **Subprocessadores**: lista mantida aqui; alterações notificadas com antecendência de 15 dias; objeção do controlador → saída.
8. **Direitos dos titulares**: operador executa solicitações no prazo ≤15 dias (recomendação fora required LGPD 5 dias).
9. **Retenção**: dados do titular ativo desde contendo no cycle escolar atual; após rescisão: 12 meses apostasalagam/delivery (conflict) full-delete via script a provisionar.
10. **Auditoria**: controlador pode solicitar certificado/anexo de segurança anual do operador.

**Checklist assinatura por escola** (antes do onboarding, tarefa "Checklist assinado pelo cliente"):
- [ ] Contrado recebido e válido (assinatura digital/e "punho e papel").
- [ ] DPA assinado + lista de subprocessadores aceita.
- [ ] Admin designado (data LGPD) + contato de consentimento de menor (responsável).
- [ ] Dados importados env — declaração de legalidade do conteúdo pela escola.

Uma vez assinado → registrar `ContractSignedAt`/`DpaSignedAt` no Tenant e anexar documentos via upload no sistema (bloqueio dedatadops operações departamento).
