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

- [ ] 4.1 Feature `features/grading-formulas`: lista de fórmulas (estado, versão, período-alvo, ações ativar/arquivar/duplicar), permissões em `config/permissions.ts` + rotas com `roleGuard`
- [ ] 4.2 Editor visual de blocos: paleta de operandos/operadores em português claro, templates como ponto de partida, propriedades da fórmula (thresholds, arredondamento, escala, política de nota ausente), validação em tempo real — sem JSON/código exposto ao usuário
- [ ] 4.3 Undo/redo: serviço de edição com snapshot stack + botões + atalhos (Ctrl+Z/Ctrl+Y), desfazer/refazer ilimitado na sessão, restaurar estado inicial
- [ ] 4.4 Preview no editor: seleção de turma/aluno/período, árvore avaliada com valores intermediários, resultado e status, avisos de dados ausentes/referências sem notas
- [ ] 4.5 Gestão de períodos letivos (crédio a partir de templates + criação/edição manual) no contexto do ano letivo
- [ ] 4.6 Formulário de avaliação: campos período (default por data) e categoria com sugestões; lançamento de nota mostra o efeito (recálculo) sem abrir a fórmula
- [ ] 4.7 Boletim existente passa a exibir média/status vindos do motor (sem mudança de layout)

## 5. Seeds e permissões

- [ ] 5.1 Permissões `grading-formulas.read`/`grading-formulas.manage` no `PilotEnvironmentSeeder` (array + mapeamentos de papéis: Diretor/Coordenador gerenciam, Professor lê)
- [ ] 5.2 Seed idempotente: períodos padrão (4 bimestres) por ano letivo existente + fórmulas default ativas equivalentes ao cálculo atual + templates disponíveis a todos os tenants
- [ ] 5.3 Audit log de criação/edição/ativação de fórmula (quem, quando, versão)

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
