## Why

Hoje os relatórios dependem de "uma pessoa que sabe montar" — a pesquisa mostra que gerar relatórios consolidados sem depender de TI/pessoa específica é ganho top de integração. O `report-builder` gera documentos com blocos de dados, mas não produz narrativa. Conectar ao padrão `ai-drafts` (citação da base + revisão humana) dá ao diretor um resumo executivo em linguagem natural sem retrabalho.

## What Changes

- Delta no spec `report-builder`: bloco de "narrativa IA" nos templates, gerado a partir dos próprios dados do relatório
- Narrativa sempre cita a base (números que a originaram) e passa por revisão antes de publicar/exportar
- Resumo executivo mensal pronto (matrículas, inadimplência, frequência) como template padrão

## Impact

- Affected specs: report-builder (ADDED requirements), segue padrão ai-drafts
- Affected code: `ReportBuilder` (novo tipo de bloco), `AiDraftService` (narrativa), export PDF
