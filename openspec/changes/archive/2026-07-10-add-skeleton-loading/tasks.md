# Tasks — add-skeleton-loading

## Planejamento e alinhamento

- [x] Selecionar a próxima sugestão da nota do Obsidian: skeleton loading nas listagens.
- [x] Verificar changes Openspec ativas para evitar conflito direto.
- [x] Criar proposal, tasks, design e spec delta no Openspec.
- [x] Validar a mudança com `openspec validate add-skeleton-loading --strict`.

## Implementação

- [x] Criar componente reutilizável de skeleton loading para tabelas.
- [x] Aplicar skeleton loading na listagem de alunos.
- [x] Aplicar skeleton loading na listagem de professores.
- [x] Criar testes unitários do componente skeleton.

## Validação

- [x] Executar build do frontend.
- [x] Executar testes unitários do frontend com Karma/ChromeHeadless. ✅ **548/548 testes passando** (full suite, inclui skeleton-loading).
- [x] Executar validação final da change Openspec com `openspec validate add-skeleton-loading --strict`.

## Resultado

- Build do frontend passou.
- Testes unitários do frontend: **548/548 passando** no ChromeHeadless ✅ (inclui 2 testes do skeleton-loading).
- A validação final da change Openspec passou.
