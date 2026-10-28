# Tasks: Refactor UI com Feature-Sliced Architecture

**Change ID:** `refactor-ui-clean-architecture`

**Status:** Planning

## Preparação

- [ ] Criar feature branch: `refactor/ui-feature-sliced`
- [ ] Adicionar path aliases no tsconfig.json (@core, @features, @shared, @layout)

## Fase 1: Features Core

### academic-years

- [ ] Criar `features/academic-years/domain/academic-year.model.ts` (mover de models/)
- [ ] Criar `features/academic-years/data/academic-year.service.ts` (mover de services/)
- [ ] Criar `features/academic-years/state/academic-year.store.ts` (novo - signals)
- [ ] Criar `features/academic-years/ui/` (mover de components/academic-years/)
- [ ] Criar `features/academic-years/academic-years.routes.ts`
- [ ] Atualizar imports

### courses

- [ ] Criar `features/courses/domain/course.model.ts`
- [ ] Criar `features/courses/data/course.service.ts`
- [ ] Criar `features/courses/state/course.store.ts`
- [ ] Criar `features/courses/ui/` (mover de components/courses/)
- [ ] Criar `features/courses/courses.routes.ts`
- [ ] Atualizar imports

### students

- [ ] Criar `features/students/domain/student.model.ts`
- [ ] Criar `features/students/data/student.service.ts`
- [ ] Criar `features/students/state/student.store.ts`
- [ ] Criar `features/students/ui/` (mover de components/students/)
- [ ] Criar `features/students/students.routes.ts`
- [ ] Atualizar imports

### teachers

- [ ] Criar `features/teachers/domain/teacher.model.ts`
- [ ] Criar `features/teachers/data/teacher.service.ts`
- [ ] Criar `features/teachers/ui/` (mover de components/)
- [ ] Criar `features/teachers/teachers.routes.ts`
- [ ] Atualizar imports

### class-groups

- [ ] Criar `features/class-groups/domain/class-group.model.ts`
- [ ] Criar `features/class-groups/data/class-group.service.ts`
- [ ] Criar `features/class-groups/state/class-group.store.ts`
- [ ] Criar `features/class-groups/ui/` (mover de components/class-groups/)
- [ ] Criar `features/class-groups/class-groups.routes.ts`
- [ ] Atualizar imports

### plans

- [ ] Criar `features/plans/domain/plan.model.ts`
- [ ] Criar `features/plans/data/plan.service.ts`
- [ ] Criar `features/plans/state/plan.store.ts`
- [ ] Criar `features/plans/ui/` (mover de components/plans/)
- [ ] Criar `features/plans/plans.routes.ts`
- [ ] Atualizar imports

- [ ] **Executar `ng build` — Fase 1**
- [ ] **Executar `ng test --watch=false` — Fase 1**

## Fase 2: Features de Suporte

### assessments

- [ ] Estrutura completa (domain, data, state, ui, routes)
- [ ] Mover de components/assessments/

### assignments

- [ ] Estrutura completa (domain, data, state, ui, routes)
- [ ] Mover de components/assignments/

### finance

- [ ] Estrutura completa (domain, data, state, ui, routes)
- [ ] Mover de components/finance/

### enrollments

- [ ] Estrutura completa (domain, data, state, ui, routes)
- [ ] Mover de components/enrollments/

- [ ] **Executar `ng build` — Fase 2**
- [ ] **Executar `ng test --watch=false` — Fase 2**

## Fase 3: Features Auxiliares

- [ ] `notices` — estrutura completa
- [ ] `communications` — estrutura completa
- [ ] `notifications` — estrutura completa
- [ ] `documents` — estrutura completa
- [ ] `calendar` — estrutura completa

- [ ] **Executar `ng build` — Fase 3**

## Fase 4: Features Administrativas

- [ ] `assets` — estrutura completa
- [ ] `scheduling` — estrutura completa
- [ ] `timetabling` — estrutura completa
- [ ] `security` — estrutura completa
- [ ] `announcements` — estrutura completa
- [ ] `guardians` — estrutura completa
- [ ] `school-units` — estrutura completa
- [ ] `reports` — estrutura completa
- [ ] `import` — estrutura completa
- [ ] `audit-logs` — estrutura completa

- [ ] **Executar `ng build` — Fase 4**

## Fase 5: Features Especiais

- [ ] `home` — estrutura completa
- [ ] `portal` — estrutura completa
- [ ] `my-area` — estrutura completa
- [ ] `checkout` — estrutura completa
- [ ] `pricing-page` — estrutura completa
- [ ] `advanced-finance` — estrutura completa
- [ ] `services` — estrutura completa

- [ ] **Executar `ng build` — Fase 5**

## Core e Shared

- [ ] Reorganizar `core/` (auth, guards, interceptors, serviços transversais)
- [ ] Consolidar `shared/` (paginator, confirm-dialog, loading, toast-container, directives, pipes, utils)
- [ ] Remover `services/` (todos movidos para features)
- [ ] Remover `models/` (todos movidos para features)
- [ ] Remover `components/` (todos movidos para features)

## app.routes.ts

- [ ] Atualizar todas as rotas para usar `loadChildren` com `*.routes.ts` de cada feature
- [ ] Garantir `canActivate: [authGuard]` nas rotas protegidas

## Validação Final

- [ ] `ng lint` — zero warnings
- [ ] `ng build --configuration production` — sem erros
- [ ] `ng test --watch=false` — todos os testes passando
- [ ] `ng build --stats-json` — verificar bundle size
- [ ] Atualizar proposal.md com resultado final

## Merge

- [ ] Create PR
- [ ] Obter approval
- [ ] Merge para main
