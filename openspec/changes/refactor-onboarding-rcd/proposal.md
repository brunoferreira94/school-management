## Why

O onboarding atual é um wizard multi-passo que coleta dados de escola → cursos → turmas → template → background jobs. Quando MRR e churn sobem juntos, o usuário foi perdido no primeiro dia — ele caiu num painel vazio sem direção clara para valor. O TTV atual é indefinido porque focamos em signups e tour completion, não em ações úteis repetidas.

Baseado nos princípios de Revenue-Centric Design (Richard @richardrx):
- "Rising MRR with rising churn means you lost them on day one"
- "Measure activation, not signups"
- "Never ship a blank dashboard"

## What Changes

- **MODIFIED** automated-onboarding: reduzir wizard para 3 passos críticos + welcome video
- **ADDED** welcome modal com video curto + ação imediata
- **ADDED** seed data (turma modelo, calendário padrão) aplicado automaticamente
- **ADDED** empty state com CTA única para primeira turma
- **ADDED** checklist de ativação com progress bar iniciando em 20%
- **ADDED** celebração visual (gráfico animado) após primeira turma criada

## Impact

- Affected specs: automated-onboarding
- Affected code: frontend onboarding wizard, admin dashboard empty states, welcome flow
- Métrica nova: TTV (tempo até primeira turma + 3 alunos importados) alvo < 5 minutos