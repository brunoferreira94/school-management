# Go / No-Go — Decisão de lançamento (template)

> Tarefa: 1.1, 1.3, 1.4. **Preencher/assinar founder.** Revisar antes de qualquer campanha pública.

## Fases e critérios objetivos

| Fase | Critérios objetivos para entrar | Critérios objetivos para sair |
|------|--------------------------------|-------------------------------|
| **Piloto fechado** (≤5 escolas parceiras) | 1. Produção saudável ≥7 dias consecutivos (health 200, sem crash-loop). 2. Backup diário verificado. 3. LGPD: DPA assinado com cada escola-piloto. | 5 flow-lives E2E completos no portal (cadastro→primeiro valor ≤10 min, TTV) |
| **Beta controlado** (até 50 escolas, convite) | 1. Zero P0 aberto. 2. Taxa de erro HTTP <1% (7 dias). 3. Cancelamento/pausa funcionando honesto (RCD). 4. Suporte com SLA definido | NPS ≥ 30 + churn-beta ≤ 5%/semana |
| **Lançamento público** | 1. Alertas de pagina/observability ativos + on-call respondendo. 2. Asaas em produção validado (sandbox→runbook assinado). 3. Evacuação/dump do piloto testado. 4. Termos/privacidade publicados + versão `2026.x` | Runbook revisado e assinado |

## Política de severidade (P0 não rebaixa)

- **P0**: indisponibilidade total, corrompimento/leitura cruzada de dados entre tenants, cobrança errada, exposição de dados pessoais.
- Regra: **P0 só rebaixa com aprovação explícita do founder**, registrada (data, motivo, mitigação) neste arquivo em "Registro de decisões".
- P0 precedentemente aberto ⇒ lança rollback imediato (Render rollback ou marco van prev).

**Registro de decisões** (append):
| Data | Fase | Decisão | Assinatura |
|---|---|---|---|
| | | | |
