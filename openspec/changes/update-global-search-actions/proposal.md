## Why

Pesquisa passiva não reduz tempo: o usuário encontra o aluno X mas ainda precisa navegar até a fatura, turma ou comunicado. Busca → ação sugerida ("aluno X" → botão "gerar 2ª via") fecha o loop. O spec `global-search` atual descobre features e resultados, mas não oferece ações contextuais.

## What Changes

- Delta no spec `global-search`: para resultados de aluno/fatura/turma, o search devolve ações contextuais executáveis direto do resultado (gerar 2ª via, abrir financeiro do aluno, enviar comunicado à turma)
- Ações respeitam as permissões do usuário que busca (padrão já existente)

## Impact

- Affected specs: global-search (ADDED requirements)
- Affected code: `GlobalSearchService` (extensão do payload com ações), frontend do search palette
