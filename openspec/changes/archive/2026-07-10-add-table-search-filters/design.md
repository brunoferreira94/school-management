<!-- markdownlint-disable MD041 -->

## Decisions

- Usar `localStorage` apenas para preferências locais de filtro, sem enviar dados sensíveis ao backend.
- Criar um serviço/utilitário compartilhado para evitar duplicação entre listagens.
- O debounce será de `500ms`, conforme a sugestão da nota do Obsidian.
- A persistência será por tela, usando chaves explícitas como `table-filters.students` e `table-filters.teachers`.
- O filtro ativo deve ser visível e reversível por um botão "Limpar filtros".
- A busca será aplicada inicialmente no lado do cliente nas listagens já carregadas.

## UX

- Campo de busca com placeholder contextual.
- Indicador visual quando houver filtros ativos.
- Estado vazio explicando que nenhum item corresponde aos filtros.
- Botão para limpar filtros e restaurar a lista completa.

## Testing

- Testar o utilitário puro de normalização/combinação de filtros.
- Testar persistência e restauração no `localStorage`.
- Validar build Angular após aplicar os filtros nas telas.
