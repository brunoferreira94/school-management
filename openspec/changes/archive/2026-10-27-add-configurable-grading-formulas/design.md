## Context

- A média é hoje calculada inline em `AssessmentService.GetClassGradesReportAsync` e `GetStudentReportCardAsync` (duplicada), com escala 0–10 hardcoded (`percent * 0.1`), thresholds 6.0/5.0 repetidos em 4 endpoints + `ReportPreviewService`, e "período" resolvido por range de datas em query string. Não existem: entidade de período, tipo de avaliação, settings por tenant, nem engine de cálculo.
- Pesquisa de domínio (regimentos escolares BR): médias bimestrais como média aritmética das avaliações do bimestre; média anual/semestral como média (às vezes ponderada, ex. trimestres com pesos 1:2:3); recuperação que substitui a nota de um único bimestre; recuperação semestral; exame final com `MF = (M + PF)/2` ou `MF = (MA×4 + NE×3)/7`; sistemas de pontos por etapa (30/35/35, aprovação ≥60); escalas 0–10 e 0–100; regras de arredondamento explícitas nos regimentos. Referências internacionais (Canvas, OpenEduCat): categorias ponderadas, descartar menor nota, políticas de nota ausente.
- Emissão massiva: a geração de boletins já roda em batch de ≤50 com `ReportGenerationBackgroundService` para lotes grandes; `PreviewDataCache` (TTL 5 min) não é invalidado no upsert de nota; histórico escolar chama o boletim aluno a aluno por ano letivo (risco N+1 no cálculo).
- Stack UI: Angular 22 standalone + signals, sem NgRx e sem lib de undo/redo — undo/redo precisa de implementação própria e leve.
- Arquétipo arquitetural interno: `BillingCadenceEngine` (interface no Domain, engine no Application, entidades + repos + endpoints + seeds + testes) — a ser seguido.

## Goals / Non-Goals

**Goals**
- Secretária(o) da escola cria/ajusta fórmulas de nota por período (bimestral, semestral, anual ou período personalizado) sem escrever código, com templates comuns, preview com dados reais e undo/redo.
- Um único motor de cálculo para todas as saídas de nota, com status/arredondamento/escala configuráveis por fórmula.
- Emissão massiva de boletins performática: resultados materializados, recálculo incremental, batch por turma, snapshot imutável no relatório emitido.
- Consistência retroativa: boletins já emitidos não mudam quando a fórmula muda (versionamento).

**Non-Goals**
- Não é um construtor de fórmulas genérico (não calcula frequência, financeiro etc.) — apenas notas/avaliação.
- Não suporte a expressões em texto livre tipo Excel/parser de linguagem (segurança + UX).
- Não conceitos BNCC/competências (`StudentSkillEvaluation` já cobre) nem rematrícula automática.
- Não multi-tenant por unidade escolar na v1 (fórmula por escola/tenant; override por turma cobre casos pontuais).

## Decisions

- **Fórmula = AST JSON validada, não código nem texto livre.** Persistimos uma árvore de nós (`operator`, `operand`, `reference`, `constant`) com whitelist de operadores (`sum`, `avg`, `weightedAvg`, `min`, `max`, `round`, aritméticos básicos) e operandos (`assessment`, `categoryAvg`, `periodAvg`, `periodGrade`, `extraPoints`, `constant`). Validação server-side na gravação (aridade, profundidade máx. ~12, referências resolvíveis, pesos > 0). Alternativas rejeitadas: expressão textual (parser + injeção + UX ruim para leigo) e script/plugin (inaceitável em SaaS multi-tenant).
- **Períodos como entidade de primeira classe** (`GradingPeriod`: `TenantId`, `AcademicYearId`, `Name`, `Kind` [Bimonthly/Quarter/Semester/Custom], `StartDate`, `EndDate`, `Order`, `IsActive`). Templates geram o conjunto (2, 3, 4 períodos) a partir das datas do ano letivo; períodos Custom permitem "o período que ele quiser". `Assessment.PeriodId?` com fallback por data no cálculo — retrocompatível com avaliações existentes.
- **Categorias de avaliação como string livre com sugestões** (`Assessment.Category`, ex.: "Prova", "Trabalho", "Recuperação", "Exame final", "Ponto extra"). Enum fixo quebraria escolas com nomenclaturas próprias; a fórmula referencia a categoria por nome exato, validado na ativação.
- **Status, arredondamento e escala dentro da fórmula.** `GradingFormula` carrega `PassingThreshold`, `RecoveryThreshold`, `RoundingRule` (casas + modo: `halfUp`/`floor`/`ceil`) e escala do resultado (o cálculo trabalha em % e converte no final). Elimina os 6.0/5.0 e o `* 0.1` espalhados.
- **Versionamento + snapshot.** Editar fórmula já usada gera nova `Version` (incremento). `StudentPeriodGrade` materializado guarda `FormulaId` + `FormulaVersion` + hash dos inputs; `GeneratedReport`/PDF congela os valores calculados — boletim emitido nunca muda retroativamente.
- **Materialização incremental.** `StudentPeriodGrade` (único por `ClassGroupId × StudentCpf × PeriodId`) é recalculado apenas para o aluno×período afetado no `UpsertGrade` (uma linha, escrita barata) e em recálculo por turma em lote (uma query de grades por turma, sem N+1). Boletins leem resultados; nunca recalculam por aluno na renderização.
- **Defaults equivalentes ao comportamento atual.** Seed cria: 4 bimestres por ano letivo (se não existirem), fórmulas padrão ativas (bimestral ponderada por peso; anual = média dos períodos; final com exame `(M+PF)/2`) replicando o cálculo vigente — migração sem mudança de comportamento perceptível.
- **Undo/redo no cliente via snapshot stack.** O editor mantém a AST como estado imutável + duas pilhas (undo/redo) de snapshots; cada ação edita e empurra. Ctrl+Z/Ctrl+Y e botões. Sem NgRx: serviço de edição dedicado com signals. Simples, determinístico, testável.
- **Preview passo a passo server-side.** Endpoint `POST /api/grading-formulas/{id}/preview` (ou fórmula não salva) recebe `classGroupId`, `studentCpf?, periodId` e retorna a árvore avaliada com valores intermediários por nó + resultado + status. Reutiliza o mesmo avaliador do cálculo real (o que se vê no preview é o que o boletim calcula).
- **Nota ausente e divisão por zero como políticas da fórmula** (`MissingGradePolicy`: `ignore`/`treatAsZero`/`failWithWarning`), evitando o bug atual de "falta = 0" silencioso.

## Risks / Trade-offs

- **Editor visual é o maior risco de UX.** Mitigação: começar com templates + composição de blocos simples (não drag-drop completo), preview em tempo real como guía de confirmação, e testes E2E do fluxo.
- **AST JSON complexifica queries.** Mitigação: fórmulas são poucas por tenant e lidas por Id; resultados materializados nunca dependem de parse no hot path.
- **Mudança de fórmula em ano em andamento pode "mudar" notas de períodos passados.** Mitigação: versionamento + recálculo explícito opt-in por período/turma (o sistema nunca recalcula períodos fechados sozinho); snapshot protege boletins emitidos.
- **Cálculo incremental no upsert adiciona escrita ao path de lançamento de nota.** Mitigação: upsert de uma linha via repo dedicado; medida de p95 no teste de carga da suíte existente.
- **Consumidores das strings de status ("Aprovado"/"Recuperação"/"Reprovado").** Renderers, CSVs, narrativa e Swagger comparam/exibem — motor deve manter os mesmos rótulos com thresholds configuráveis (refatoração de leitura, não de contrato).

## Migration Plan

1. **Fase 1 (fundação, sem mudança de comportamento)**: entidades + migration EF (SchoolContext/`Data/Migrations/`), `Assessment.PeriodId?/Category`, seed de períodos por ano letivo existente + fórmulas default ativas equivalentes ao cálculo atual, engine + avaliador AST, `AssessmentService`/`ReportPreviewService` delegando ao engine (golden tests garantindo paridade numérica com o cálculo atual).
2. **Fase 2 (API de fórmulas)**: CRUD + ativação + versionamento + preview passo a passo + recálculo por turma/período; `StudentPeriodGrade` materializado no upsert de nota + invalidação do `PreviewDataCache`.
3. **Fase 3 (UI)**: feature `grading-formulas` (lista, editor com templates/blocos, undo/redo, preview), período/categoria no formulário de avaliação, permissões.
4. **Rollback**: migration é aditiva (tabelas novas + colunas nullable); fórmulas default ativas reproduzem o comportamento atual — desativar a feature não muda números já publicados.

## Decisões fechadas (2026-10-26, com o dono do produto)

- **Override de fórmula por turma: ENTRA na v1.** `ClassGroup.GradingFormulaId?` (nullable, sem FK cross-context — `ClassGroup` é dono do `AcademicContext`; a coluna migra no assembly Academic e a integridade é resolvida na aplicação, padrão já usado por `Assessment.ClassGroupId`). Resolução no engine: fórmula da turma > fórmula default da escola por tipo de período > fallback legado.
- **Frequência mínima (≥75% LDB): FORA do escopo v1.** Status (`Aprovado/Recuperação/Reprovado`) continua sendo calculado só por nota; frequência permanece como bloco informativo do boletim. Requer spec própria (compensação de faltas, presença por componente) — não é apenas um campo no motor.
- **Bug da narrativa IA: CORRIGIR junto.** Ao integrar o motor, `ReportNarrativeService` passa a ler os valores/status do engine (eliminando a comparação inconsistente threshold-em-nota × média-em-percentual), coberto por golden test na task 3.5.
