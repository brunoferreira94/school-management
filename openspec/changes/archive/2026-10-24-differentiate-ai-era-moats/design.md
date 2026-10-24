## Context

O refactor de onboarding RCD (mergeado na `main` via PRs #73/#7/#3) establish o pilar de **Value delivery / TTV**: welcome modal no primeiro acesso, seed "Escola Padrão 2026", checklist de ativação começando em 20%. Mas isso é apenas o entry-point. A era da IA torna o código commodity — o diferencial tem que ser estrutural (moat), não funcional.

Este change aplica 3 dos 7 princípios de `ai-era-differentiation`:
1. **Same engine, different UX** → Moat 1 (switching cost via UX internalizada)
2. **A validated idea is a short-term game — plan the moat** → Moat 2 (expansion architecture / network effects)
3. **Beat the four AI failure modes** (trust/visual confidence + human touch) → Moat 3 (brand power)

Mais o princípio de **atenção militante** (shrinking attention spans).

## Goals / Non-Goals

**Goals:**
- Fechar o loop de convite de professores (checklist existente só marca local)
- Transformar checklist estático em caminho de uso contínuo (moat de switching cost)
- Criar identidade visual proprietária (não Material default) para sinalizar autoridade
- Reduzir carga cognitiva do dashboard para usuários condicionados por feeds curtos

**Non-Goals:**
- Não reescrever o backend de auth (JWT/OAuth2 já existe; link mágico de convite é separado)
- Não criar nova categoria de produto (mantém "gestão escolar", mas com nicho de UX)
- Não remover os widgets do dashboard (mantidos como fallback togglável)

## Decisions

- **Convite de professor via link mágico assinado** (não senha temporária): menor atrito = mais professores ativos = mais dados no tenant = maior LTV. Token com expiração de 7 dias, armazenado no `SetupProgress.TeachersInvited`.
- **SetupProgress como fonte de verdades do moat**: os campos de micro-loop (`LastGradeEntryAt`, etc.) orientam o "próximo passo" no checklist — o backend, não o frontend, decide o que sugerir. Isso impede que um clone copie a lógica de "caminho do diretor" sem copiar o estado histórico do tenant.
- **Design tokens proprietários em SCSS** (não CSS-in-JS): consistency enforcement via build, não via convenção. O `theme/escola-tokens.scss` é importado por todos os componentes RCD.
- **"Tela de hoje" como default do dashboard**: os 5 widgets viram um toggle secundário. O usuário vê 1 ação primária no load; isso respeita o teto de atenção.

## Risks / Trade-offs

- **Mudança de hábito do usuário** (dashboard novo) → mitigado por toggle "ver dashboard completo" que restaura os widgets.
- **Link mágico de convite pode ser abusado** → mitigado por token assinado com expiração + rate limit por tenant.
- **Design tokens podem quebrar componentes Material existentes** → aplicados apenas em componentes RCD (onboarding-welcome, activation-checklist, activation-celebration, empty-state), não no core.

## Migration Plan

1. API: adicionar endpoints de convite + campos em `SetupProgress` + migration EF
2. UI: evoluir `activation-checklist` + adicionar "tela de hoje" + design tokens + human touch
3. E2E: `rcd-moats-flow.cy.ts` valida convite, tela de hoje, erro gentil
4. Submodules: API `feature/onboarding-invite-teacher` → UI `feat/ai-era-moats` → pai `differentiate/ai-era-moats`
5. PRs: #74 (API), #8 (UI), #4 (pai)
