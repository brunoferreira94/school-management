## Context

O School Management é SaaS educacional para gestão de escolas. O onboarding atual segue padrão wizard tradicional. Aplicação dos princípios RCD visa reduzir TTV (< 5 min) e aumentar taxa de ativação (meta: 40%+).

## Goals / Non-Goals

- Goals: TTV reduzido, taxa de ativação medida, celebração visual do aha moment
- Non-goals: Redesign completo da UI, novos módulos, auth flows

## Decisions

- Decision: Welcome modal + seed data automático em vez de wizard completo
  - Por que: Remove decisão inicial, entrega valor imediato, reduz abandono
- Decision: Progress bar iniciando em 20%
  - Por que: Started-progress effect (Zeigarnik) reduz percepção de esforço
- Decision: Template única "Escola Padrão 2026" como default
  - Por que: Remove escolha do usuário, acelera TTV

## Risks / Trade-offs

- Risco: Seed data pode não atender todas escolas
  - Mitigation: Admin pode customizar após primeira turma

## Migration Plan

1. Deploy em ambiente piloto
2. Medir TTV/activation rate com PostHog
3. Iterar baseado em eventuais abandonos