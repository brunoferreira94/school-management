# Design — apply-product-strategy-discipline

## Context

O School Management tem 18 capabilities / 86 requirements especificados, mas nenhuma medição de uso. O crescimento do catálogo sem filtro gera os três riscos RCD: (1) SKI desconhecido, (2) baixa descoberta de features (inattentional blindness), (3) atenção mal direcionada. Esta change é de **governança de portfólio + instrumentação de adoção** — não adiciona features de produto, só mede e superficia o que já existe.

Stakeholders: Product (Bruno), engenharia frontend/backend, comercial.

## Goals

- Tornar o SKI e a taxa de adoção mensuráveis e visíveis ao Owner.
- Implantar gate de disciplina de portfólio no processo de roadmap.
- Superficiar features existentes por empty states direcionais e triggered onboarding.

## Non-Goals

- Pricing/tiers públicos (→ `monetization-strategy`).
- Cancel/pause/win-back (→ `add-churn-retention-flows`).
- Wizard de primeiro login (→ `refactor-onboarding-rcd`).
- Gateway de cobrança (→ `integrate-payment-gateways`).

## Decisions

- **Medir, não adivinhar**: SKI e adoção vêm de eventos de uso reais (janela 30d), não de opinião de time.
- **Hide, don't delete**: feature de baixa adoção vai para configurações avançadas, preservando os 3% que usam.
- **Triggered, not badged**: descoberta por comportamento, uma única vez, para não virar spam.
- **Score explícito**: `(Novos Usuários + Nova Receita + Impacto) / Esforço` para ranquear o inventário.

## Risks / Trade-offs

- Custo de telemetria adicional → mitigado reusando pipeline OpenTelemetry já existente.
- Falso negativo de adoção (feature sazonal) → mitigado por janela de 2 ciclos antes de ocultar.
- Overlap com `advanced-analytics` → deltas MODIFIED, não nova spec concorrente.

## Migration Plan

- Fase 1: instrumentação + endpoints (sem UI quebra).
- Fase 2: widgets de SKI/adoção no dashboard owner.
- Fase 3: empty states/triggered hints + gate de roadmap.
