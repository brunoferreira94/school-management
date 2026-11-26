# Modelo de preços e superfícies comerciais (auditoria de 26/11)

Autor: Bruno Ferreira (assistente)
Data: 2026-11-26
Status: draft — aguarda decisão do dono (opção A/B/C da §7 de `docs/auditoria-precos.md`)

## Motivação

A auditoria `docs/auditoria-precos.md` (commit `3a3037f`) concluiu que o modelo de cobrança atual
**não se sustenta** e que **hoje não cobramos nada** (produção: 1 tenant, 0 alunos, 0
`TenantSubscriptions`). Em paralelo, as superfícies que mostram preço ao cliente estão divergentes
e parcialmente em inglês:

1. **3 tabelas de preço diferentes**: catálogo no banco (correto), `/pricing` pública (limites
   hardcoded que contradizem o catálogo) e a tela interna "Planos Disponíveis"
   (R$ 99 / R$ 299 / Sob consulta).
2. **~30 strings de i18n em placeholder inglês** na `/pricing` — `HERO_TITLE: "Hero Title"`,
   `CTA_START: "Cta Start"`, `PRICE_ON_REQUEST: "Price On Request"` — confirmadas no bundle de
   produção (`main-Y6EZDGCH.js`, grep em 26/11).
3. **Limite de unidades escolares nunca aplicado**: `EnsureSchoolUnitLimitAsync` não tem callers —
   pré-requisito de qualquer cobrança por unidade.
4. **Nenhuma feature é bloqueada por plano**: `CheckSubscriptionFeatureAsync` sem consumidor; o
   único gatilho de upgrade é o teto de 50 alunos do Free.
5. **Gateway de produção em sandbox** (`Asaas__ApiBaseUrl=https://sandbox.asaas.com/api/v3`).
6. **Desconto anual**: doc diz 15%, o catálogo aplica 16,7% (R$ 2.999 vs R$ 3.598,80).

A decisão de modelo (manter fixo / híbrido / por aluno) é do dono e segue pendente. Este change
**registra os achados e a pesquisa de preços de concorrentes** (26/11, ver `design.md`) e organiza
a execução em fases: a fase 1 (superfícies + limites) independe da decisão e pode ser aprovada já;
a fase 2 (modelo) só começa após a escolha.

## Escopo

**Fase 1 — superfícies comerciais coerentes (independe da decisão de modelo)**

- `/pricing` 100% em pt-BR, com preço e limites vindos do catálogo (API), sem tabela hardcoded.
- Tela interna "Planos Disponíveis" consumindo o mesmo catálogo (fim da 3ª tabela).
- `docs/plans/pricing-page.md` corrigido (desconto anual real e oferta do Free coerentes).
- Enforcement do limite de unidades escolares na criação (`EnsureSchoolUnitLimitAsync`).
- Teste automatizado que falha se voltar a existir placeholder em inglês ou preço hardcoded.

**Fase 2 — modelo de cobrança (após decisão A/B/C)**

- Seeder/catálogo com o modelo escolhido; metering de alunos e unidades por tenant.
- Checkout com valor variável (base + por aluno + por unidade).
- UI com preço "a partir de" + simulador.
- Feature gating por plano e regra trial→Free antes de ligar `Entitlement:Enforce`.

**Fase 3 — cobrança real**

- Asaas de produção (URL + chave) e webhook token no painel.
- Preço-piloto do primeiro cliente com cláusula de revisão para o modelo híbrido.

## Critérios de aceitação

- Nenhum visitante de produção vê placeholder em inglês ou preço divergente do catálogo.
- Criar unidade escolar acima do limite do plano retorna erro de limite (nunca 500 nem silêncio).
- `openspec validate pricing-model-and-commercial-surfaces --strict` passa.
- A decisão A/B/C está registrada no `design.md` antes de a fase 2 começar.

## Fora de escopo

- Token do webhook no painel Asaas e troca de chave (ação manual do dono).
- Storage persistente de anexos (disco efêmero do Render).
- Reajuste de contratos já assinados.