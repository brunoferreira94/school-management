# PRD — School Management SaaS

> Produto: Plataforma SaaS de Gestão Escolar
> Stack: .NET 8 (Backend) + Angular 17 (Frontend) + PostgreSQL + Auth0
> Branch: `development`

---

## 1. Visão do Produto

Plataforma SaaS multi-tenant para gestão escolar completa. O administrador da escola gerencia alunos, turmas, professores, notas, frequência, financeiro e comunicados. Alunos e responsáveis acessam um portal dedicado com boletim, boletos e mensagens.

---

## 2. Análise do Estado Atual

### 2.1 Backend (API) — ~80% completo
- **58 controllers** com **209 endpoints** implementados
- Arquitetura limpa (Domain/Application/Infrastructure)
- Auth0 + JWT com refresh token
- 180 arquivos de teste
- 41 migrations do banco
- Observabilidade (Prometheus + Grafana)

### 2.2 Frontend (UI) — ~30% funcional
- **20 componentes HTML** com layout (design system aplicado)
- **51 services Angular** — mas **apenas 4 chamam a API de verdade**
- 24 features com API mas **sem UI**
- Portal do aluno/responsável **inexistente**
- Pricing/Checkout **inexistente**

### 2.3 Gap Principal
Os services do Angular estão escritos mas a maioria não faz chamadas HTTP reais. Os componentes HTML existem mas não se conectam ao backend.

---

## 3. Fases de Implementação

### FASE 1 — Conectar UI à API (CRÍTICO)
**Objetivo:** Todas as features com UI existente devem funcionar end-to-end.

#### 1.1 Services que precisam de chamadas HTTP reais

| Service | Status | Endpoints necessários |
|---------|--------|----------------------|
| `student.service.ts` | ✅ Já conectado | CRUD, bulk-enroll, search |
| `guardian.service.ts` | ✅ Já conectado | CRUD, paginated |
| `teacher.service.ts` | ✅ Já conectado | CRUD |
| `class-group.service.ts` | 🔴 Sem HTTP | CRUD, students, schedules, copy, bulk-assign |
| `course.service.ts` | 🔴 Sem HTTP | CRUD, copy |
| `classroom.service.ts` | 🔴 Sem HTTP | CRUD |
| `grade.service.ts` | 🔴 Sem HTTP | CRUD, class-report |
| `lesson-plan.service.ts` | 🔴 Sem HTTP | CRUD |
| `attendance.service.ts` | 🔴 Sem HTTP | CRUD, report, record |
| `finance.service.ts` | 🔴 Sem HTTP | installments, plans, subscriptions |
| `school-unit.service.ts` | 🔴 Sem HTTP | CRUD, paginated |
| `academic-year.service.ts` | 🔴 Sem HTTP | CRUD, copy, active |
| `announcement.service.ts` | 🔴 Sem HTTP | CRUD |
| `notice.service.ts` | ✅ Já conectado | CRUD |
| `communication.service.ts` | 🔴 Sem HTTP | send, templates, logs |
| `notification.service.ts` | 🔴 Sem HTTP | CRUD, preferences |
| `document.service.ts` | 🔴 Sem HTTP | CRUD, attachments |
| `event.service.ts` | 🔴 Sem HTTP | CRUD |
| `asset.service.ts` | 🔴 Sem HTTP | CRUD, attachments |
| `service.service.ts` | 🔴 Sem HTTP | CRUD, history |
| `enrollment.service.ts` | 🔴 Sem HTTP | bulk-enroll |
| `import.service.ts` | 🔴 Sem HTTP | upload, validate, run |
| `report.service.ts` | 🔴 Sem HTTP | attendance, grades |
| `my-area.service.ts` | 🔴 Sem HTTP | grades, attendance, bills |
| `portal.service.ts` | 🔴 Sem HTTP | login, register, profile |
| `subscription.service.ts` | 🔴 Sem HTTP | plans, tenant-subscription |
| `staff.service.ts` | 🔴 Sem HTTP | CRUD |
| `setup.service.ts` | 🔴 Sem HTTP | wizard |
| `analytics.service.ts` | 🔴 Sem HTTP | dashboard |
| `timetable.service.ts` | 🔴 Sem HTTP | generate, apply |
| `waitlist.service.ts` | 🔴 Sem HTTP | CRUD, promote |
| `submission.service.ts` | 🔴 Sem HTTP | CRUD, grade |

#### 1.2 Componentes TS que precisam de integração

| Componente | Service dependency | Ação necessária |
|------------|-------------------|-----------------|
| `students.component.ts` | StudentService | ✅ Já integrado — verificar |
| `guardians.component.ts` | GuardianService | ✅ Já integrado — verificar |
| `teachers` (sem UI) | TeacherService | Criar componente TS + HTML |
| `class-groups` (sem UI) | ClassGroupService | Criar componente TS + HTML |
| `courses.component.ts` | CourseService | Conectar service ao componente |
| `classrooms` (sem UI) | ClassroomService | Criar componente TS + HTML |
| `grades` (sem UI) | GradeService | Criar componente TS + HTML |
| `lesson-plans` (sem UI) | LessonPlanService | Criar componente TS + HTML |
| `attendance.component.ts` | AttendanceService | Conectar service ao componente |
| `finance.component.ts` | FinanceService | Conectar service ao componente |
| `school-units.component.ts` | SchoolUnitService | Conectar service ao componente |
| `academic-years.component.ts` | AcademicYearService | Conectar service ao componente |
| `announcements.component.ts` | AnnouncementService | Conectar service ao componente |
| `notices.component.ts` | NoticeService | ✅ Já integrado — verificar |
| `communications-manager.component.ts` | CommunicationService | Conectar service ao componente |
| `notifications-list.component.ts` | NotificationService | Conectar service ao componente |
| `documents.component.ts` | DocumentService | Conectar service ao componente |
| `calendar.component.ts` | EventService | Conectar service ao componente |
| `assets.component.ts` | AssetService | Conectar service ao componente |
| `services-list.component.ts` | ServiceService | Conectar service ao componente |
| `enrollments.component.ts` | EnrollmentService | Conectar service ao componente |
| `import-wizard.component.ts` | ImportService | Conectar service ao componente |
| `reports.component.ts` | ReportService | Conectar service ao componente |
| `my-area.component.ts` | MyAreaService | Conectar service ao componente |
| `timetabling.component.ts` | TimetableService | Conectar service ao componente |

---

### FASE 2 — Features sem UI (24 features)
**Objetivo:** Criar componentes para todas as features que têm API mas não têm interface.

#### 2.1 Pessoas (People)
- **Teachers** — CRUD completo com listagem, formulário, especialidade
- **Staff** — CRUD de funcionários (admin, secretaria, etc.)
- **Student Guardians** — Vínculo aluno-responsável
- **Student Plans** — Vínculo aluno-plano

#### 2.2 Acadêmico (Academic)
- **Class Groups** — CRUD de turmas com alunos, horários, professores
- **Classrooms** — CRUD de salas
- **Courses** — CRUD de cursos
- **Grades** — Lançamento de notas por turma/aluno
- **Lesson Plans** — Planos de aula
- **Submissions** — Entregas de tarefas pelos alunos
- **Waitlist** — Fila de espera para matrícula
- **Timetable Templates** — Templates de horários

#### 2.3 Facilities
- **Events** — Calendário de eventos da escola

#### 2.4 Financeiro
- **Subscriptions** — Gestão de assinatura do tenant

#### 2.5 Operações
- **Analytics** — Dashboard com métricas
- **Setup Wizard** — Wizard de configuração inicial

#### 2.6 Admin
- **Admin** — Gestão de tenants
- **Roles** — Gestão de roles
- **Permissions** — Gestão de permissões

---

### FASE 3 — Portal do Aluno/Responsável
**Objetivo:** Portal dedicado para alunos e responsáveis.

#### 3.1 Autenticação
- **Portal Login** — Login via Auth0
- **Portal Register** — Registro de novos usuários
- **Portal Email Verification** — Verificação de e-mail
- **Portal MFA** — Autenticação de dois fatores

#### 3.2 Dashboard
- **Portal Dashboard** — Visão geral (notas recentes, próximos eventos, avisos)

#### 3.3 Acadêmico
- **Portal Academic** — Boletim, frequência, tarefas, materiais

#### 3.4 Financeiro
- **Portal Financial** — Boletos, pagamentos, histórico

#### 3.5 Perfil
- **Portal Profile** — Dados pessoais, alteração de senha, preferências

#### 3.6 My Area
- **My Area** — Área pessoal do responsável (boletos, notas, frequência, mensagens)

---

### FASE 4 — Monetização (SaaS)
**Objetivo:** Fluxo completo de assinatura.

#### 4.1 Pricing
- **Pricing Page** — Tela de planos e preços
- **Plan Comparison** — Tabela comparativa de planos

#### 4.2 Checkout
- **Checkout Page** — Fluxo de assinatura
- **Payment Integration** — Integração com gateway (Stripe/Pagar.me)
- **Subscription Management** — Gestão da assinatura

#### 4.3 Billing
- **Invoice History** — Histórico de faturas
- **Payment Methods** — Métodos de pagamento

---

### FASE 5 — Polimento e Produção
**Objetivo:** Preparar para lançamento.

#### 5.1 Infraestrutura
- CI/CD pipeline (GitHub Actions)
- Deploy automatizado
- Monitoramento de erros (Sentry)

#### 5.2 Qualidade
- Testes E2E (Cypress/Playwright)
- Testes de performance
- Acessibilidade (WCAG 2.1)

#### 5.3 Produto
- SEO + Meta tags
- PWA (service worker)
- i18n (internacionalização)
- Onboarding flow
- Documentação do usuário

---

## 4. Modelos de Dados (Referência)

### Student
```typescript
interface Student {
  cpf: string;
  name: string;
  birthDate: string;
  address: string;
  guardians?: Guardian[];
}
```

### Teacher
```typescript
interface Teacher {
  id: Guid;
  name: string;
  expertise: string;
}
```

### ClassGroup
```typescript
interface ClassGroup {
  id: Guid;
  name: string;
  schoolUnitId: Guid;
  courseId: Guid;
  capacity: number;
}
```

### Grade
```typescript
interface Grade {
  id: Guid;
  studentCpf: string;
  classGroupId: Guid;
  assessmentId: Guid;
  value: number;
  date: string;
}
```

### Attendance
```typescript
interface Attendance {
  id: Guid;
  classGroupId: Guid;
  studentCpf: string;
  date: string;
  status: 'present' | 'absent' | 'late' | 'justified';
}
```

### Installment
```typescript
interface Installment {
  id: Guid;
  installmentNumber: number;
  dueDate: string;
  amount: number;
  status: 'pending' | 'overdue' | 'paid' | 'cancelled';
  paymentDate?: string;
}
```

---

## 5. Permissões (RBAC)

| Permissão | Descrição |
|-----------|-----------|
| `students.read` | Visualizar alunos |
| `students.write` | Criar/editar alunos |
| `teachers.read` | Visualizar professores |
| `teachers.write` | Criar/editar professores |
| `classes.read` | Visualizar turmas |
| `classes.write` | Criar/editar turmas |
| `grades.read` | Visualizar notas |
| `grades.write` | Lançar notas |
| `finance.read` | Visualizar financeiro |
| `finance.write` | Gerenciar financeiro |
| `reports.read` | Visualizar relatórios |
| `admin.full` | Acesso administrativo total |

---

## 6. Definição de Done

Uma feature está **pronta para produção** quando:

- [ ] API endpoints implementados e testados
- [ ] UI component com formulário/listagem funcionando
- [ ] Service Angular conectado à API (HTTP calls reais)
- [ ] Tratamento de erros (loading, empty state, error state)
- [ ] Validação de formulários
- [ ] Permissões aplicadas (RBAC)
- [ ] Responsivo (mobile + desktop)
- [ ] Testes unitários passando
- [ ] Sem erros no console

---

## 7. Estimativa de Esforço

| Fase | Tarefas | Estimativa |
|------|---------|------------|
| Fase 1 — Conectar UI à API | ~35 services + componentes | 2-3 semanas |
| Fase 2 — Features sem UI | 24 features | 3-4 semanas |
| Fase 3 — Portal | 6 telas | 2 semanas |
| Fase 4 — Monetização | 4 telas + gateway | 2 semanas |
| Fase 5 — Polimento | CI/CD, testes, PWA | 1-2 semanas |
| **TOTAL** | | **10-13 semanas** |

---

## 8. Riscos

| Risco | Impacto | Mitigação |
|-------|---------|-----------|
| API models ≠ UI models | Alto | Criar mappers/DTOs no frontend |
| Auth0 config incompleta | Alto | Documentar setup passo a passo |
| Permissões granulares | Médio | Implementar RBAC progressivo |
| Performance com muitos dados | Médio | Paginação + lazy loading |
| Multi-tenant isolation | Alto | Validar queries por tenant |
