# Design — Finalizar Prontidão para Lançamento Público

## Context

O produto tem base funcional e features relevantes já implementadas, mas lançamento público exige maturidade operacional superior a piloto assistido. A decisão de founder deve ser baseada em evidências objetivas de estabilidade, segurança, billing, self-service, testes, deploy e suporte.

## Goals / Non-Goals

### Goals

- Definir critérios claros de prontidão para lançamento.
- Separar bloqueadores P0 de melhorias P1/P2.
- Criar plano executável para transformar o produto em beta/piloto confiável.
- Evitar lançamento público antes de billing, segurança e estabilidade estarem validados.
- Transformar CI em gate real de qualidade (sem bypass para checks críticos).
- Garantir fluxos críticos sem mock em produção-like.

### Non-Goals

- Implementar todas as features de analytics avançado neste ciclo.
- Reescrever arquitetura inteira antes do piloto.
- Substituir decisão jurídica por texto gerado automaticamente.

## Decisions

### Decision 1: lançamento público deve ser precedido por piloto fechado

A estratégia recomendada é não abrir cadastro público amplo agora. O produto deve passar por piloto fechado com escolas reais, onboarding assistido e critérios de saída objetivos.

### Decision 2: Portal do Responsável E2E é gate P0

O lançamento depende de evidência ponta a ponta em cenário realista:

- cadastro/convite;
- login (incluindo MFA/SSO quando aplicável);
- dashboard;
- acesso correto a boletos, notas, frequência e comunicados;
- isolamento de dados por responsável/aluno com auditoria.

### Decision 3: CI/CD sem bypass em checks críticos

Etapas de lint/test/unit/e2e críticas devem falhar o pipeline em PR/main. `continue-on-error` só pode existir em checks explicitamente não-bloqueantes e rotulados como informativos.

#### Matriz definida (v1)

- **Bloqueantes (PR/main):**
  - Backend (restore/build/test)
  - Frontend (lint/build/unit)
  - E2E (Cypress)
- **Informativos (não bloqueantes):**
  - `quality-informational` com `npm audit` e `npm outdated`

Regra operacional: checks informativos podem alertar dívida técnica, mas não liberam bypass de checks bloqueantes.

### Decision 4: Relatórios críticos sem fallback mock

Fluxos usados em piloto/beta devem usar endpoints reais e contratos versionados. Comentários TODO/mock devem ser removidos dos caminhos críticos antes de go/no-go.

### Decision 5: operação deve comprovar resiliência mínima

Antes de abrir beta público:

- health checks automatizados;
- alertas ativos para indisponibilidade e falhas críticas;
- rollback exercitado em ambiente de homologação;
- runbook de incidente testado.

### Decision 6: go/no-go formal obrigatório

A decisão de estágio (piloto, beta, público) deve ser registrada por founder/product com scorecard, riscos e evidências anexadas.

## Risks / Trade-offs

- **Lançar cedo demais:** falhas em portal, billing ou operação podem destruir confiança.
- **Atrasar demais:** perfeccionismo pode travar validação comercial.
- **Trade-off recomendado:** piloto fechado agora, beta controlado após P0, público somente após P1 mínimo.

## Migration Plan

1. Endurecer checklist de release com P0/P1/P2 e evidência obrigatória.
2. Fechar Portal do Responsável E2E com contratos e testes.
3. Remover mocks dos fluxos críticos de relatórios.
4. Endurecer CI gates e política de qualidade em PR/main.
5. Validar operação (health, alertas, rollback, incident runbook).
6. Registrar go/no-go formal para próximo estágio.

## Weekly Review Cadence

A cada semana até lançamento público:

1. scorecard por dimensão;
2. status dos P0;
3. evidências de testes e estabilidade;
4. progresso de billing e portal;
5. riscos jurídicos e operacionais;
6. decisão de manter piloto, avançar para beta ou voltar para correção.