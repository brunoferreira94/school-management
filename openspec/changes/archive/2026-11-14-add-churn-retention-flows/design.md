## Context

O produto tem MRR crescente mas trata retenção como afterthought. A tela de assinatura é um stub e o cancelamento é um `confirm()` nativo. Não há sinal de risco de churn, nem gancho de re-engajamento vinculado ao ciclo escolar. Este change aplica os princípios de Churn & Retention do RCD, priorizando os pontos de maior alavancagem com menor esforço de implementação.

Stack: Angular 22 (standalone components, signals, localStorage para estado leve) + .NET API (Clean Architecture, bounded contexts, EF Core). Submodule `school-management-ui` é git submodule do repo pai.

## Goals / Non-Goals

- **Goals:** cancel screen com win-back; health score de conta; expansion prompt no limite; re-engagement anchor por evento escolar; redução de jargão no portal.
- **Non-Goals:** integração com gateway de pagamento real (coberto por `integrate-payment-gateways`); billing/medição de uso produtiva (coberto por `monetization-strategy`); refatoração de onboarding (coberto por `refactor-onboarding-rcd`). Este change foca no pós-ativação (retenção), não na aquisição/ativação.

## Decisions

- **Decision:** Cancel flow como componente dedicado (`cancel-flow`), não modal genérico — precisa de 3 telas (perda concreta → alternativa → motivo). Alternativa considerada: reaproveitar `confirm-dialog` — rejeitada por não comportar loss aversion nem coleta de motivo.
- **Decision:** Health score calculado no backend (bounded context) e exposto via endpoint read-only; UI só consome. Alternativa: cálculo no cliente — rejeitada (dados de uso agregados vivem na API, e queremos consistência para relatórios de NRR).
- **Decision:** Re-engagement anchor reutiliza o módulo `notifications`/`communications` existente + eventos do `calendar`, em vez de criar um scheduler novo. Sinais recorrentes: início de bimestre, período de matrícula, fechamento de notas.
- **Decision:** Expansion prompt é não-bloqueante (banner contextual no momento do limite), respeitando "expansion born of usage, never by interruption".
- **Decision:** Motivos de cancelamento coletados via pergunta aberta (texto livre) + tag opcional, persistidos para análise — não dropdown fechado que raramente lista o motivo real.

## Risks / Trade-offs

- **Risco:** health score impreciso gera alarme falso → mitigar com limiares conservadores e janela de 14/30 dias, validados contra dados reais antes de exibir ao owner.
- **Risco:** cancel flow percebido como "dark pattern" se dificultar a saída → mitigar mantendo o botão de cancelar sempre acessível e honesto (loss aversion factual, não manipulação).
- **Trade-off:** re-engagement por evento escolar depende do calendário estar configurado; para escolas sem calendário, cai em fallback de cadência simples.

## Migration Plan

1. Adicionar spec `subscription-retention` (nova capability) e deltas em `self-service-portal`.
2. Implementar cancel-flow UI + endpoints de cancelamento/pausa (feature-flagged).
3. Implementar health score (backend + widget no dashboard do owner).
4. Implementar expansion prompt e re-engagement anchor.
5. Reduzir jargão no portal + FAQ contextual.
6. Rollout incremental; medir NRR e taxa de save antes de remover flags.
