## Context

Monorepo escolar multi-tenant (API .NET 10 + UI Angular 22). Hoje há 50 specs Cypress (15 "ao vivo" com `cy.request`, demais mockados) e 167 arquivos xUnit (774 testes), mas a cobertura é predominantemente happy-path. A infra de teste já madura existe nos dois lados: `TestWebApplicationFactory` com Postgres isolado por teste (Testcontainers) no back; specs live autocontidos com `cy.exec`+psql no front. O objetivo é organizar uma bateria adversarial que encontre bugs de front e back e corrija-os no mesmo change.

## Goals / Non-Goals

- Goals:
  - Matriz de status codes (401/403/404/400/409) sobre os controllers de maior risco.
  - Prova de wiring: DTO inválido → 400 problem-details nos endpoints com validator.
  - Valores de fronteira (paging, pesos de nota, arredondamento de moeda, datas, CPF/e-mail) e conflitos de concorrência.
  - E2E ao vivo dos caminhos de escrita de CRUD da UI + comportamento de negação (guard 403).
  - Corrigir cada bug encontrado, com teste de regressão.
- Non-Goals:
  - Reescrever ou converter specs mockados existentes para live.
  - Testes de carga/stress de produção, chaos engineering.
  - Cobertura de features que ainda não existem em produção (ex.: relatórios com modelo pendente).
  - Testes visuais (já cobertos por `cypress/visual/`).

## Decisions

- **Duas camadas, mesma bateria**: xUnit HTTP-level para matriz de status e bordas (rápido, isolado, roda em CI); Cypress live para fluxos de escrita de ponta a ponta e comportamento de UI negativo. Cada camada cobre o que a outra não consegue (UI guards só no Cypress; problema-details de validator só no xUnit HTTP).
- **Priorização por risco**: (1) auth/permissões/tenancy — já parcialmente coberto, gap é a matriz 401/403 completa; (2) financeiro (billing/cancel/checkout/installments) — dinheiro em jogo; (3) acadêmico CRUD (students/grades/classgroups); (4) dados sensíveis (LGPD/export); (5) demais controllers.
- **Helper Cypress compartilhado via import explícito** (`cypress/support/live.ts` importado pelo spec) em vez de `supportFile` global — evita quebrar os ~50 specs existentes e mantém cada spec autocontido quando preferido. Funções: `liveLogin()`, `psqlExec()` idempotente, `authHeader()`.
- **Dados de teste únicos por instância** (xUnit v3 paraleliza métodos da mesma classe) e seed fora da conexão singleton (`GetSeedConnectionString()`), conforme armadilha documentada no AGENTS.md.
- **Bugs no mesmo change**: task de triagem registra o bug → task de fix reproduz (teste vermelho) → corrige → verde → commit com suíte completa. Sem change separado por bug (evita overhead de spec para restauração de comportamento esperado — OpenSpec permite fix direto).
- **Rollback**: bateria nova é aditiva; se um teste revelar comportamento *desejado* diferente do atual, discutir com o dono antes de mudar o código de produção.

## Risks / Trade-offs

- Testes live dependem de ambiente local (API `:5067` + docker Postgres + seed) → documentar pré-requisitos no topo de cada spec novo; rodar em 2 blocos para reduzir tempo.
- Testes 403 exigem seed de roles/permissões por tenant → reutilizar `TestClientFactory` com headers explícitos (`X-Test-Permissions`) já existente.
- Volume de testes novos aumenta o tempo de suíte → manter a matriz por `[Theory]` (dados parametrizados) em vez de `[Fact]` repetidos.

## Migration Plan

1. Infra compartilhada (helpers back + front) sem alterar comportamento.
2. Bateria back por ordem de risco, commitando a cada bloco verde.
3. Bateria front live por fluxo, commitando a cada spec verde.
4. Triagem/fix dos bugs encontrados (uma task por bug, checklist no tasks.md).
5. Suíte completa verde → bump dos submodules no root.

## Open Questions

- Incluir controllers de baixo risco (operations/prometheus, captcha) na matriz ou deixar para rodada futura?
- Rodar a bateria live em CI ou mantê-la manual/local por enquanto?
