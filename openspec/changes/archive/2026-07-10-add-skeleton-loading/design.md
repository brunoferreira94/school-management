# add-skeleton-loading Design

## Context

As telas de listagem já possuem estados de loading genéricos. A mudança quer substituir essa experiência por um placeholder visual que preserve o formato da tabela.

## Goals / Non-Goals

- Goals:
  - criar componente reutilizável de skeleton loading;
  - aplicar em alunos e professores;
  - evitar salto visual durante carregamento.
- Non-Goals:
  - alterar APIs;
  - alterar paginação;
  - alterar filtros já implementados.

## Decisions

- Decision: criar componente standalone `skeleton-loading` em `src/app/shared/skeleton-loading/`.
- Decision: usar CSS puro com animação `shimmer` para evitar nova dependência.
- Decision: aplicar apenas nas listagens de alunos e professores nesta change.

## Risks / Trade-offs

- Risco: duplicar colunas da tabela no skeleton.
- Mitigação: definir número de linhas e colunas via `@Input`.

## Migration Plan

- Nenhuma migração.
