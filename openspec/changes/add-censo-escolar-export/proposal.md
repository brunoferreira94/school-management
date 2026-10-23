## Why

O Censo Escolar (INEP) é uma dor anual gigante da secretaria e invisível nos comparativos de features dos ERP escolares. Nenhum concorrente o posiciona como produto. Resolvê-lo em 1 clique conquista a secretaria inteira como defensora do produto.

## What Changes

- Nova capability `censo-escolar`: exportação dos dados do Censo Escolar em 1 clique
- Coleta guiada dos campos obrigatórios do INEP com validação prévia (campos faltantes apontados antes do envio)
- Exportação no layout oficial do Censo Escolar (arquivo de importação) por ano letivo
- Checklist de prontidão: % de alunos/turmas/docentes com dados censitários completos

## Impact

- Affected specs: censo-escolar (novo)
- Affected code: novo `CensoExportService`, campos censitários opcionais em Student/Staff/ClassGroup (migrations), relatório de completude
