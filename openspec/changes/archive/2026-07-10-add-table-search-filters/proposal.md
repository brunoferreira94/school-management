<!-- markdownlint-disable MD041 -->

## Why

As telas de listagem ficam mais úteis quando o usuário consegue encontrar rapidamente alunos, professores, turmas e outros registros sem recarregar a página ou refazer filtros manualmente. A nota do Obsidian aponta a necessidade de busca instantânea com debounce e filtros salvos no `localStorage`, especialmente em tabelas grandes.

## What Changes

- Criar um utilitário reutilizável de filtros de tabela com:
  - busca por texto com debounce de `500ms`;
  - persistência dos últimos filtros por tela no `localStorage`;
  - restauração automática dos filtros ao reabrir a tela;
  - ação clara para limpar filtros salvos.
- Aplicar o padrão inicialmente nas listagens de:
  - alunos;
  - professores.
- Adicionar feedback visual de busca/filtro ativo e estado vazio quando nenhum item corresponde aos filtros.
- Adicionar testes unitários para o utilitário de filtros e para persistência no `localStorage`.

## Impact

- Affected specs: nova capability `table-filters`.
- Affected code:
  - `school-management-ui/src/app/features/students/ui/students.component.ts`
  - `school-management-ui/src/app/features/students/ui/students.component.html`
  - `school-management-ui/src/app/features/students/ui/students.component.scss`
  - `school-management-ui/src/app/features/teachers/ui/teachers.component.ts`
  - `school-management-ui/src/app/features/teachers/ui/teachers.component.html`
  - `school-management-ui/src/app/features/teachers/ui/teachers.component.scss`
  - novos utilitários/specs em `school-management-ui/src/app/shared/table-filters/`
