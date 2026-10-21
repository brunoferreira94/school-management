# SLA — Modelo (template)

> Tarefa 1.2 do checklist legal. **Revisão jurídica/comercial obrigatória antes de uso.**

## Disponibilidade (uptime)

| Plano | Uptime comprometido | Janela | Medição |
|-------|--------------------|--------|---------|
| Essentials | 99,5% (≈ 18 h 15 min/mês ou 3,65 h (7 dias)) | mensal | `/api/support/health` + auditoria terceira |
| Professional | 99,7% | mensal | idem |

- **Exclusões**: janelas de manutenção (notificadas com ≥48h, max 4h/mês), falha de terceiros (`cloud`, Supabase/Auth0/Asaas) fora do nosso controle, força maior.

## Suporte e tempo de resposta

| Prioridade | O quê | Tempo de primeira resposta | Tempo de mitigação (workaround) |
|-----------|-------|---------------------------|--------------------------------|
| P0 | Sistema indisponível/viol LNGPD | 2h (dias úteis) | 8h |
| P1 | Função crítica degradada | 8h | 2 dias úteis |
| P2 | Bug com plano de contorno | 2 dias úteis | roadmap |
| P3 | Dúvida/solicitação | 5 dias úteis | — |

## Backup e continuidade

- Dump diário do Supabase (retenção 30 dias) + teste de restauração trimestral documentado.
- RPO ≤ 24 h · RTO ≤ 8 h (piloto). Reconfigurar para Pro quando cliente exigir.

## Créditos de SLA (opcional)

- Cada 0,1% abaixo do compromisso no mês ⇒ 1 dia de crédito no ciclo seguinte (cap: 30% da fatura). Aplicável ao plano pagar-fatura.
