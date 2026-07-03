# Finalizar Prontidão para Lançamento Público

Autor: _Bruno / Product_  
Data: 2026-06-20  
Status: draft

## Why

O School Management já possui funcionalidades centrais de gestão escolar, autenticação, permissões, Owner Dashboard, relatórios, monetização e integração inicial de checkout. Porém, as evidências atuais indicam que o produto ainda não está pronto para lançamento público amplo: risco de regressão por gates permissivos de CI, lacunas no Portal do Responsável sem evidência ponta a ponta de primeiro valor e trechos críticos de relatórios no frontend ainda com fallback mock/TODO.

Em visão founder, o gargalo principal deixou de ser stack e passou a ser **readiness operacional + ativação confiável**.

## What Changes

- Criar/fortalecer a capability OpenSpec de **prontidão para lançamento público**.
- Definir gates P0/P1/P2 para decidir entre piloto fechado, beta controlado e lançamento geral.
- Consolidar tarefas de estabilidade, segurança, LGPD, billing, self-service, QA automatizada, deploy e operação.
- Endurecer CI/CD para falhar pipeline em lint/test/unit/e2e críticos (sem bypass em gates de release).
- Garantir integração real de backend nos fluxos críticos de Portal do Responsável e Relatórios (sem mock para cenários de launch).
- Instituir pacote formal de evidências de go/no-go (testes, health checks, métricas de onboarding/TTV e checklist assinado).
- Garantir que nenhuma feature nova de produto avance antes do fechamento dos bloqueadores de release.

## Impact

- Affected specs: `public-launch-readiness`, `self-service-portal`, `payment-gateways`, `legal-terms`, `notifications`, `communications`, `monetization`, `automated-onboarding`.
- Affected code: API, frontend, testes, CI/CD, Docker Compose, documentação de deploy, documentação jurídica e materiais de onboarding.
- Impacto operacional: produto, engenharia, segurança, jurídico, suporte e comercial passam a trabalhar com uma definição comum de “pronto para lançar”.

## Founder Guardrails (P0 obrigatórios)

1. **Portal Responsável E2E com evidência**: cadastro/convite → login → dashboard → notas/frequência/boletos/comunicados com escopo correto por responsável/aluno.
2. **CI como gate real de release**: lint + unit + e2e críticos devem quebrar o pipeline em PR/main.
3. **Relatórios sem mock em fluxo crítico**: remover TODO/fallback mock dos caminhos usados em piloto/beta.
4. **Operação com health + resposta a incidente**: health checks automatizados, alertas e rollback testado.
5. **Go/No-Go formal**: decisão registrada por founder/product com scorecard e evidências anexadas.

## Founder Verdict

**Nota de prontidão atual:** 6,4 / 10  
**Recomendação:** não abrir cadastro público amplo ainda. Avançar com piloto fechado e critérios objetivos de saída.

## Current Evidence Snapshot

- Owner Dashboard validado via API/UI com usuário Owner autorizado.
- Relatório crítico retornou `200 OK` com `series: 2`.
- Asaas webhook idempotency: testes passando.
- CI alinhado para `net10.0`, porém ainda requer endurecimento de gates para release.
- Frontend unit suite estabilizada localmente com `ChromeHeadless`.
- OpenSpec change validada em modo estrito previamente.

## Scorecard

| Dimensão | Nota | Prioridade |
|---|---|---|
| Produto core | 7,5 | P1 |
| Estabilidade backend | 6,5 | P0 |
| Billing / monetização | 6,5 | P0 |
| Portal do responsável | 4,5 | P0 |
| Testes / CI gates | 5,0 | P0 |
| Segurança / LGPD | 7,0 | P0 |
| Deploy / operação | 6,0 | P1 |
| Observabilidade | 6,5 | P1 |
| Onboarding / suporte | 4,5 | P1 |
| Marketing / pricing | 4,0 | P2 |

## Launch Recommendation

- **Agora:** piloto fechado com onboarding assistido.
- **Depois de P0:** beta controlado com billing sandbox/prod e portal E2E validados.
- **Depois de P1:** lançamento público gradual.
- **P2:** otimizações de analytics, landing, pricing e suporte escalável.

## Documentação pós-implementação

- Atualizar README com critérios de release e evidências mínimas de go/no-go.
- Atualizar docs de deploy com backup, rollback, migrações e secrets.
- Atualizar docs de produto com onboarding, suporte e métricas de ativação (TTV, onboarding success).
- Atualizar pricing/FAQ somente após billing e portal validados.