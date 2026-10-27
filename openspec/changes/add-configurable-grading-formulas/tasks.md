# Tasks — Fórmulas de cálculo de nota configuráveis

## 1. Fundação de domínio e dados (sem mudança de comportamento)

- [x] 1.1 Entidades no Domain: `GradingPeriod` (TenantId, AcademicYearId, Name, Kind, StartDate, EndDate, Order, IsActive), `GradingFormula` (TenantId, AcademicYearId?, Name, Description, TargetPeriodKind, Status, Version, DefinitionAst [JSON], PassingThreshold, RecoveryThreshold, RoundingRule, ResultScale, MissingGradePolicy, auditoria), `StudentPeriodGrade` (TenantId, ClassGroupId, StudentCpf, PeriodId, FormulaId, FormulaVersion, InputsHash, Result, Status, ComputedAtUtc) + interfaces `IGradingPeriodRepository`, `IGradingFormulaRepository`, `IStudentPeriodGradeRepository`
- [x] 1.2 `Assessment` ganha `PeriodId?` e `Category` (string, nullable — retrocompatível); `ClassGroup` ganha `GradingFormulaId?` (override por turma)
- [x] 1.3 Migration EF no SchoolContext (`Data/Migrations/`): `20261026133813_AddGradingFormulas` — 4 CreateTable (GradingPeriods, GradingFormulas, StudentPeriodGrades + ExportJobs pendente do DataPortability) + 3 AddColumn nullable + índices (único `(ClassGroupId, StudentCpf, PeriodId)` em resultados)
- [x] 1.4 Repositórios no Infrastructure (padrão `BaseRepository`) + registro no `RepositoryAndInfrastructureRegistration`

## 2. Motor de cálculo

- [x] 2.1 `IGradingCalculationEngine` no Domain + `GradingCalculationEngine` no Application: avaliador de AST com whitelist de operadores (`sum`, `avg`, `weightedAvg`, `min`, `max`, `round`, aritméticos) e operandos (avaliação, média por categoria, média/resultado de período, pontos extras, constante), limites de profundidade/aridade, políticas de nota ausente e divisão por zero
- [x] 2.2 Resolução de fórmula ativa: default do tenant por tipo de período + override por turma + fallback do cálculo legado para tenants sem fórmula (`GradingCalculationService.ResolveActiveFormulaAsync` — ano específico > genérica `AcademicYearId` null)
- [x] 2.3 Cálculo de status (Aprovado/Recuperação/Reprovado), arredondamento (HalfUp/HalfEven/Floor/Ceil) e escala como parte da avaliação da fórmula (a remoção dos 6.0/5.0 e `* 0.1` hardcoded do `AssessmentService` é a task 3.5)
- [x] 2.4 Cálculo por turma em lote (`ComputeClassPeriodAsync` — 1 query de avaliações + 1 de notas + 1 de alunos, sem N+1) e por aluno×período (`ComputeStudentPeriodAsync`, incremental) com materialização via `StudentPeriodGradeRepository.UpsertAsync`
- [x] 2.5 Catálogo de templates de fórmulas como ASTs pré-definidas no Application (`GradingFormulaTemplates` — os 9 templates da spec) com descrição legível e `ToFormula()` para instanciar
- [x] 2.6 Golden tests de paridade: fórmula default (ponderada por peso, `TreatAsZero`, `HalfEven`/2, escala 0–10, 6.0/5.0) produz exatamente os mesmos números do cálculo inline atual do `AssessmentService` (dataset com 3 alunos, nota ausente e escala 0–100) + verificação com valores calculados à mão
- [x] 2.7 Unit tests do engine no padrão `BillingCadenceEngineTests` (31 testes: 9 templates, escala ≠ 0–10, arredondamentos, 3 políticas de nota ausente, divisão por zero, referência de período ausente, coleção vazia, JSON inválido, validação de AST — operador/aridade/pesos/ref/profundidade, rastro de passos do preview, round-trip de serialização)

## 3. API (CQRS: commands/queries + handlers)

- [x] 3.1 Períodos: CRUD (`CreateGradingPeriod`/`UpdateGradingPeriod`/`DeleteGradingPeriod`) + `GenerateGradingPeriods` (2/3/4 períodos sobre o ano letivo + "Ano Letivo" anual opcional, idempotente, sem sobreposição) + reatribuição de período por data na criação de avaliação (`AssessmentService.CreateAsync` resolve `PeriodId` por data quando não informado)
- [x] 3.2 Fórmulas: CRUD com validação da AST no servidor (validador compartilhado create/update), ativação com **arquivamento automático da ativa anterior** do mesmo tipo de período, versionamento na edição de fórmula ativa (`Version++` — materializados preservam a versão antiga), arquivamento (bloqueia edição), exclusão apenas de rascunhos, override por turma (`SetClassGroupGradingFormula` — só fórmulas ativas)
- [x] 3.3 Preview passo a passo: `POST api/grading-formulas/preview` aceita fórmula salva (`formulaId`) OU rascunho do editor (`astDraft` + config de thresholds/arredondamento/escala/política) + turma/aluno/período → árvore avaliada com valores intermediários (`Steps`), resultado e status — **mesmo avaliador do cálculo real** (`BuildPreviewInputAsync`), sem persistir
- [x] 3.4 Recálculo: `POST api/grading-formulas/recalculate` (turma×período em lote) + recálculo incremental no `UpsertGradeCommand` (apenas aluno×período afetado, período explícito ou por data; falha nunca quebra o lançamento de nota) + invalidação do `PreviewDataCache` por CPF no upsert
- [x] 3.5 Integração do motor como fonte única: `AssessmentService` (relatório de turma + boletim do aluno) calcula via engine com fórmula virtual default (golden tests garantem paridade com o legado) — loops inline duplicados removidos; **bug da narrativa corrigido** (`ReportNarrativeService` agora compara média em nota 0–10 com threshold em nota — antes comparava percentual com nota e nunca detectava "abaixo da média"; teste da narrativa atualizado); portal do responsável, CSVs e blocos `grades`/`academic-history` do report-builder herdam o cálculo via `AssessmentService`
- [x] 3.6 Controllers `GradingPeriodsController` + `GradingFormulasController` com `[Authorize(Policy = "Permission:grading-formulas.read/manage")]` + permissões `grading-formulas.read/manage` no `PilotEnvironmentSeeder` (Diretor/Coordenador gerenciam, Professor somente leitura) — audit explícito de ativação fica para a task 5.3 (o middleware de auditoria já registra as requisições mutantes)

## 4. UI (Angular, área da secretaria)

- [x] 4.1 Feature `features/grading-formulas`: lista de fórmulas (nome, período-alvo, status com badge, versão; ações ativar/arquivar/excluir-rascunho; seletor de templates como ponto de partida), permissões `GRADING_FORMULAS_READ/MANAGE` em `config/permissions.ts`, rotas lazy com `roleGuard` em `grading-formulas.routes.ts` + registro em `app.routes.ts` + link no sidebar com `*can`
- [x] 4.2 Editor visual de blocos (`grading-formula-editor.component.ts`): operação principal em português claro (média, média ponderada, soma de pontos, maior valor, (A+B)/2, (MA×4+NE×3)/7), paleta de termos (avaliações do período / notas de uma categoria / resultado de um período / valor fixo), opções por termo (ponderar por peso, descartar menor, somar pontos, excluir categoria — com sugestões), pesos por termo na média ponderada, regras de aprovação/arredondamento/escala/política de nota ausente — **usuário nunca vê JSON/código** (Draft↔AST em `formula-draft.ts`); fórmulas com estrutura fora do editor abrem em modo visualização com aviso
- [x] 4.3 Undo/redo (`FormulaEditorState`): snapshot stack imutável com signals, botões Desfazer/Refazer/Restaurar, atalhos Ctrl+Z / Ctrl+Y / Ctrl+Shift+Z, ilimitado na sessão; toda mutação do draft passa por `mutate()` que registra histórico
- [x] 4.4 Preview no editor: seleção de turma → período → aluno (carregamento em cascata), resultado em destaque com status colorido, **passo a passo com valores intermediários por nó**, avisos do cálculo (notas ausentes, divisão por zero); envia rascunho + config para `POST api/grading-formulas/preview` — o que se vê é o que o boletim calcula
- [x] 4.5 Gestão de períodos letivos (`grading-periods.component.ts`): por ano letivo, geração a partir de templates (4 bimestres/3 trimestres/2 semestres + "Ano Letivo" opcional), criação/edição/exclusão manual com validação de datas sobrepostas
- [x] 4.6 Formulário de avaliação: campos **Período** (default "Automático pela data") e **Categoria** (com datalist de sugestões) em criar/editar; o efeito do recálculo no lançamento é automático via hook do backend (materializa aluno×período sem abrir a fórmula)
- [x] 4.7 Boletim existente exibe média/status vindos do motor — automático pela integração do backend (sem mudança de layout)

## 5. Seeds e permissões

- [x] 5.1 Permissões `grading-formulas.read`/`grading-formulas.manage` no `PilotEnvironmentSeeder` (array + mapeamentos de papéis: Diretor/Coordenador gerenciam via prefixo `grading-formulas.*`, Professor lê)
- [x] 5.2 Seed idempotente (executado junto com `--seed-demo`): períodos padrão **4 bimestres + "Ano Letivo"** (âncora de fórmulas anuais) para cada ano letivo existente sem períodos + **fórmula default ATIVA por tenant** (ponderada por peso, `TreatAsZero`, `HalfEven`/2, escala 0–10, 6.0/5.0 — exatamente o cálculo histórico, paridade golden-tested); templates são estáticos na API, disponíveis a todos os tenants por design; queries com `IgnoreQueryFilters()` (seed é cross-tenant)
- [x] 5.3 Audit log de ativação/edição de fórmula ativa (quem = `User`/claims, quando = timestamp, versão = `RequestId` no formato `formula:{id}:v{versão}`) via `IAuditLogRepository`; `ActivatedBy` gravado na fórmula; criação/edição comum cobertas pelo middleware de auditoria HTTP existente

## 6. Testes de integração e E2E

- [ ] 6.1 Integração (xUnit, `Support/`): CRUD de fórmulas com AST inválida rejeitada; ativação com arquivamento da anterior; preview com aluno real; recálculo incremental no upsert; materialização lida pelo boletim; histórico escolar usa resultados materializados (sem N+1 — assert de contagem de queries)
- [ ] 6.2 E2E Cypress: secretaria cria fórmula a partir de template, monta ponderada por categoria, usa undo/redo, prevê com aluno real, ativa e vê o boletim refletir; professor recebe 403/botão oculto
- [ ] 6.3 Teste de performance da emissão massiva: geração de boletins de uma escola inteira em background com p95 aceitável (baseline antes/depois)

## 7. Documentação

- [ ] 7.1 README/docs da API: como funcionam fórmulas, AST, templates e preview
- [ ] 7.2 Guia na UI (ajuda da secretaria): como criar uma fórmula a partir de um template e ajustar

## 8. Documentação para agentes de IA (modular)

- [ ] 8.1 `AGENTS.md` na raiz do repo: mapa do monorepo (api/ui/openspec), comandos essenciais (build, testes, migrations, seeds, e2e), convenções de commit e layout de pastas — incorporando o conteúdo atual (Auth0 mock vira doc modular em `docs/`)
- [ ] 8.2 `school-management-api/AGENTS.md`: arquitetura em camadas (Domain/Application/Infrastructure/SchoolManagement), **bounded contexts EF (SchoolContext vs AcademicContext — entidades compartilhadas, regra de migrations separadas por assembly e o precedente ClassGroup)**, padrão CQRS LiteBus (commands/queries/handlers/behaviors), repositórios (BaseRepository + registro no DI), multi-tenancy (ITenantContext/ITenantProvider, query filters), permissões (Policy "Permission:", PilotEnvironmentSeeder, roles), migrations (gerar/aplicar, design-time factories, School vs Academic), seeds idempotentes e testes (padrões xUnit, TestWebApplicationFactory, Postgres container)
- [ ] 8.3 `school-management-ui/AGENTS.md`: stack (Angular standalone + signals, Material, ngx-translate), estrutura (features/app/core/config), data services + models espelhando DTOs do backend, guards e PERMISSIONS (roleGuard), rotas, ambiente e2e (`--configuration e2e`), Cypress live (API + Postgres + seed)
- [ ] 8.4 `docs/` modular no api (docs/architecture/*.md): um arquivo curto por tema — bounded-contexts, cqrs, multitenancy, permissions, migrations, grading-formulas — com caminhos de arquivo reais (`arquivo.cs:linha`), para um agente carregar apenas o que precisa
- [ ] 8.5 Índice de features (docs/features.md): cada pasta de feature da Application/UI em 2–3 linhas (o que faz, endpoints principais, entidades) para navegação rápida
- [ ] 8.6 Checklists de manutenção para agentes (docs/how-to.md): onde registrar DI, quando gerar migration School vs Academic, como adicionar permissão/perfil, como adicionar entidade/testes — passo a passo verificável
