# Aplicar Disciplina de Estratégia de Produto e Features (RCD)

Autor: Bruno / Product (via RCD — Richard @richardrx)
Data: 2026-07-15
Status: draft

## Why

O School Management já tem uma base técnica sólida, mas o catálogo de funcionalidades cresceu sem um filtro: **18 capabilities / 86 requirements** especificados, e **nenhuma instrumentação de uso real**. Pelo prisma Revenue-Centric Design, três sinais indicam que o produto está cobrando "aluguel" de features que não se sabe se retêm:

1. **Swiss Knife Index desconhecido** — não medimos qual % das 86 features é usado por >40% da base ativa em janela de 30 dias. Sem isso, cada nova feature aprovada "por feel" aumenta carga cognitiva e custo de sustentação (Hick's law + feature fatigue: Thompson/Hamilton/Rust 2005; Iyengar & Lepper 2000).
2. **Descoberta ≠ anúncio** — features são "lançadas" (changelog/badge) mas usuários seguem o caminho habitual e não as veem (inattentional blindness + status-quo bias). Adoção de feature é problema de *design*, não de comunicação.
3. **Atenção mal direcionada** — a hierarquia visual não força o uso do que retém (onboarding do responsável, primeira turma, boletim), enquanto módulos de nicho (inventory, copy-assistants) competem pelo mesmo espaço.

Sem essa disciplina, o roadmap continua a ser uma *wishlist* de usuários e o ICP escolar (que deu amor ao produto) se dilui — exatamente o erro do "all-in-one" (Porsche: margem 18%→0,2%).

## What Changes

- **ADDED capability `product-feature-discipline`** com:
  - Portfólio auditado e ranqueado por valor (Swiss Knife filter de 2 camadas: merece existir? constrói agora? Score = (Novos Usuários + Nova Receita + Impacto) / Esforço).
  - Gate obrigatório de "qual feature eu mato para abrir espaço cognitivo?" em todo novo item de roadmap.
  - Cálculo e dashboard do **Swiss Knife Index (SKI)** trimestral a partir de dados de uso reais (não opinião de time).
- **ADDED capability `feature-adoption`** com:
  - Instrumentação de descoberta/uso por feature (taxa de adoção por frequência apropriada, não cliques).
  - Empty states direcionais que superficiam a feature no ponto de uso (não em modal global).
  - Triggered onboarding disparado pelo comportamento que sinaliza necessidade (ex.: responsável entra em notas → introduz comparativo de desempenho).
  - Limiar de adoção: feature abaixo do threshold volta para revisão (hide, não delete).
- **MODIFIED capability `advanced-analytics`** para incluir eventos de uso por feature (fonte do SKI e da taxa de adoção).
- **MODIFIED capability `automated-onboarding`** para estender a atenção direcionada ao pós-login (hierarquia que prioriza o que retém).

## Impact

- Affected specs: product-feature-discipline (nova), feature-adoption (nova), advanced-analytics (MODIFIED), automated-onboarding (MODIFIED)
- Affected code:
  - `school-management-api`: eventos de uso por feature (telemetria/analytics), endpoint de SKI e taxa de adoção.
  - `school-management-ui`: instrumentação de descoberta (data-cy/hooks de uso), empty states direcionais, triggered onboarding.
  - Dashboards internos (owner/admin): widget de SKI + adoção.
- Impacto operacional: product, engenharia e comercial passam a avaliar roadmap por valor retido, não por pedido.

## Non-Goals (cerca para evitar overlap com changes existentes)

- **Não** define pricing/tiers públicos → pertence a `monetization-strategy` / `finalize-public-launch-readiness`.
- **Não** implementa fluxo de cancel/pause/win-back → pertence a `add-churn-retention-flows` (`subscription-retention`).
- **Não** reescreve o wizard de primeiro login → pertence a `refactor-onboarding-rcd`.
- **Não** implementa gateway de cobrança → pertence a `integrate-payment-gateways`.
- Esta change é de **governança de portfólio + instrumentação de adoção**. O trabalho de *código* aqui é só o necessário para medir (eventos de uso) e para superficiar features existentes (empty states/triggered hints) — não novas features de produto.

## Princípios RCD aplicados (mecanismo nomeado → movimento)

- **Swiss Knife Index** (2057124008445796659): medir utilidade real; <0.3 = faca suíça desajeitada.
- **Feature adoption is a design problem** (2057162392048476345): directional empty states + triggered onboarding.
- **Attention hierarchy** (2039399756452057159): tornar o que retém o mais saliente.
- **Focus on your core** (2031722047080960265): matar ou esconder o que dilui o ICP.
- **Feature fatigue** (2034248739557159293): cada feature extra íngreme a curva de aprendizado e silencia o churn pré-trial.
