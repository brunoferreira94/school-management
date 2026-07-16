## Why

O código virou commodity na era da IA: um concorrente com Claude recria 90% do backend em um fim de semana. O refactor de onboarding RCD (PRs #73/#7/#3, mergeados na `main`) resolveu o pilar de **Value delivery / TTV**, mas não atacou o problema estrutural — **não há moat**. O produto ainda é "gestão escolar genérica" com CRUD copiável em dias.

Sem moat planejado, o school-management compete por preço num red ocean. A différenciação tem que vir de onde a IA falha: UX internalizada, arquitetura de expansão (network effects), e confiança visual — não do engine.

## What Changes

- **Moat 1 — Switching cost via UX internalizada**: o checklist de ativação (já existe) evolui para um "caminho do diretor" — micro-loops repetíveis (lançar nota → boletim → comunicado → cobrança) que o usuário automatiza. Cada loop concluído eleva o custo de migrar para um clone 20% mais barato.
- **Moat 2 — Expansion architecture (network effects internos)**: o passo `threeTeachersInvited` do checklist dispara convite real com link mágico (sem senha); professor convidado que entra vira nó ativo na rede, puxando mais dados (frequência, notas) e elevando LTV.
- **Moat 3 — Brand Power / visual confidence**: design tokens proprietários (cor ESCOLA+, raio, sombra, micro-interações de 200ms de confirmação) aplicados fora do welcome modal, criando identidade consistente que sinaliza autoridade e baixa CAC.
- **Atenção militante**: dashboard "tela de hoje" com 1 ação primária (o que precisa de ação agora: 1 inadimplência, 2 faltas, 1 evento) substituindo ou complementando os 5 widgets concorrentes.
- **Human touch**: erros gentis com recovery ("Ops, essa turma já existe — quer usar a turma modelo?"), 404 que retorna o usuário, micro-interações de confirmação em ações críticas.

**Não é alvo deste change**: onboarding (já feito), engine/backend (commodity), novas entidades de domínio além das necessárias para convite de professor.

## Impact

- Affected specs: `automated-onboarding` (MODIFIED — checklist de ativação vira caminho do diretor + convite real de professores), `product-differentiation` (ADDED — nova capability para moats de UX/expansão/marca)
- Affected code:
  - `school-management-ui`: `activation-checklist` (evolução), `home.component` (tela de hoje), design tokens (`styles/` ou `theme`), `activation-celebration` (micro-interações), componentes de erro/404
  - `school-management-api`: endpoint de convite de professor com link mágico (`InviteController` ou extensão de `OnboardingController`), estado de "professor ativo" no `SetupProgress`
  - `school-management` (pai): ponteiros de submodule
- Riscos: exige mudança de hábito do usuário (dashboard novo); mitigado por manter os widgets antigos como fallback togglável.
