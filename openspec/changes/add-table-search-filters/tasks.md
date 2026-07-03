# Tasks — add-table-search-filters

## Planejamento e alinhamento

- [x] Selecionar a próxima sugestão da nota do Obsidian: busca instantânea com debounce e filtros salvos no `localStorage` para tabelas grandes.
- [x] Verificar que a spec não conflita diretamente com a mudança aprovada de Setup Wizard.
- [x] Criar proposal, tasks, design e spec delta no Openspec.
- [x] Validar a mudança com `openspec validate add-table-search-filters --strict`.

## Implementação

- [x] Criar utilitário compartilhado de filtros de tabela com debounce de `500ms` e persistência no `localStorage`.
- [x] Aplicar filtros de tabela na listagem de alunos.
- [x] Aplicar filtros de tabela na listagem de professores.
- [x] Adicionar botão para limpar filtros.
- [x] Adicionar estado vazio quando nenhum item corresponder aos filtros atuais.
- [x] Criar testes unitários para o utilitário compartilhado.

## Validação

- [x] Executar build do frontend.
- [ ] Executar testes unitários do frontend com Karma/ChromeHeadless.
- [x] Executar validação final da change Openspec com `openspec validate add-table-search-filters --strict`.

## Resultado

- Build do frontend passou.
- Testes unitários do frontend ainda não rodam no ambiente local por falta de ChromeHeadless e erro conhecido do Karma/rimraf.
- A validação final da change Openspec passou.
