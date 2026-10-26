## Why

Hoje a média dos alunos é calculada de forma fixa no código (`AssessmentService`): média ponderada inline, duplicada em dois métodos, escala 0–10 hardcoded (`percent * 0.1`), thresholds de aprovação/recuperação fixos (6.0/5.0) espalhados por 4 endpoints, e sem modelo de períodos (bimestre/semestre/trimestre) — "período" hoje é apenas um range de datas em query string. Escolas reais usam formas diferentes: média aritmética simples, ponderada por peso ou por tipo de avaliação, recuperação que substitui nota de bimestre, exame final `(M+PF)/2`, sistema de pontos por etapa (30+35+35), média anual ponderada 1:2:3 etc. Além disso, a emissão massiva de boletins (bimestres, semestres, histórico anual) precisa ser performática.

## What Changes

- **Períodos de avaliação configuráveis**: a secretaria cria subdivisões do ano letivo (bimestres, trimestres, semestres ou períodos personalizados com nome e datas próprios); avaliações passam a pertencer a um período (atribuição automática por data ou manual).
- **Categorias de avaliação**: avaliações ganham categoria (Prova, Trabalho, Recuperação, Exame final, Ponto extra...), permitindo fórmulas ponderadas por tipo e regras de recuperação/exame.
- **Fórmulas de cálculo por escola**: entidade versionada com estado (rascunho/ativa/arquivada), uma fórmula ativa por tipo de período (default da escola, com override opcional por turma). Fórmula é persistida como AST JSON validada server-side — nunca código arbitrário.
- **Templates de fórmulas comuns**: catálogo pronto (média simples, ponderada por peso, ponderada por categoria, recuperação substitui período, exame final `(M+PF)/2`, `MF=(MA×4+NE×3)/7`, pontos por etapa, média anual ponderada, descartar menor nota).
- **Editor amigável na UI (secretaria)**: editor visual de blocos com operandos/operadores em português claro (sem código/JSON), **pré-visualização com dados reais** de aluno/turma mostrando o cálculo passo a passo, e **desfazer/refazer** com histórico de edição e atalhos.
- **Motor único de cálculo**: `GradingCalculationEngine` substitui a média inline; relatório de turma, boletim do aluno, portal do responsável, blocos do report-builder, CSVs e narrativa passam a usar o mesmo motor; status (Aprovado/Recuperação/Reprovado), arredondamento e escala deixam de ser hardcoded.
- **Performance para emissão massiva**: resultados materializados por aluno×turma×período (com versão da fórmula), recálculo incremental no lançamento de nota, cálculo por turma em lote (sem N+1), snapshot imutável no boletim emitido e invalidação dos caches de preview.
- **Permissões**: `grading-formulas.read`/`grading-formulas.manage` para secretaria (Diretor/Coordenador), Professor somente leitura; ativação auditada.

## Impact

- **Affected specs**: nova capability `grading-formulas` (ADDED requirements). O comportamento dos blocos `grades`/`academic-history` do `report-builder` passa a consumir o motor, sem alterar seus requisitos.
- **Affected code**:
  - API Domain: novas entidades `GradingPeriod`, `GradingFormula`, `StudentPeriodGrade`; `Assessment` ganha `PeriodId?` e `Category`; interfaces `IGradingFormulaRepository`, `IGradingPeriodRepository`, `IStudentPeriodGradeRepository`, `IGradingCalculationEngine` (padrão `IBillingCadenceEngine`).
  - API Application: `GradingCalculationEngine` + parser/avaliador de AST + templates + queries/commands CRUD, ativação, preview passo a passo, recálculo.
  - API Infrastructure: repositórios, migration EF no SchoolContext (`Data/Migrations/`), índices, seeds idempotentes (períodos padrão, templates, permissões) no `PilotEnvironmentSeeder`.
  - API: `AssessmentService`/`ReportPreviewService` passam a delegar ao motor; `UpsertGrade` recalcula o par aluno×período e invalida `PreviewDataCache`; endpoints novos em controller de secretaria.
  - UI: nova feature `features/grading-formulas` (lista, editor com undo/redo, preview); lançamento de notas e criação de avaliação passam a expor período/categoria; permissões em `config/permissions.ts`.
  - Testes: unit tests do engine (padrão `BillingCadenceEngineTests`), handlers, integração, E2E Cypress.
