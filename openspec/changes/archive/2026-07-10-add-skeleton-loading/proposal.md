## Why

As listagens de alunos, professores e outras tabelas podem demorar alguns segundos para carregar. Hoje o usuário vê uma mensagem genérica de carregamento; adicionar skeleton loading deixa a interface mais responsiva e reduz a sensação de espera.

## What Changes

- Criar componente reutilizável de skeleton loading para linhas de tabela.
- Aplicar o skeleton nas listagens de alunos e professores enquanto os dados carregam.
- Preservar o layout da tabela para evitar salto visual entre loading e dados carregados.
- Adicionar testes simples do componente skeleton.

## Impact

- Affected specs: `listings`
- Affected code: `school-management-ui/src/app/shared/skeleton-loading/*`, `students.component.*`, `teachers.component.*`
