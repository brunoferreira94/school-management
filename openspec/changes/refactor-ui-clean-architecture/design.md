# Design: Reorganização da UI com Feature-Sliced Architecture

**Change ID:** `refactor-ui-clean-architecture`

## Decisões Técnicas

### 1. Feature-Sliced com 4 Camadas Leves (não Clean Architecture completa)

**Decisão:** Usar 4 camadas por feature (`domain/`, `data/`, `state/`, `ui/`) em vez das 5 camadas da Clean Architecture clássica

**Justificativa:**

- Clean Architecture completa foi projetada para backends com regras de negócio complexas — em uma SPA, cria boilerplate desnecessário
- 4 camadas têm responsabilidade clara sem over-engineering
- Alinhado com o estilo idiomático do Angular moderno (standalone, signals, inject())
- Mais fácil de onboarding para novos devs Angular

**Estrutura por feature:**

```
features/students/
├── domain/            # Modelos TypeScript puros (interfaces, types, enums)
├── data/              # HTTP service que chama a API REST
├── state/             # Signal store com estado reativo local
└── ui/                # Componentes e páginas standalone Angular
```

### 2. `domain/` = Modelos TypeScript, não Entidades DDD

**Decisão:** `domain/` contém apenas interfaces e tipos TypeScript — sem classes, sem validação, sem métodos de negócio

**Justificativa:**

- No Angular (frontend), modelos são DTOs recebidos/enviados para a API
- Lógica de negócio real vive no backend (ASP.NET Core)
- Adicionar entidades DDD no frontend duplica regras já validadas pelo backend

### 3. `data/` = HTTP Service (sem interface abstrata de Repository)

**Decisão:** `data/` contém um service concreto com HttpClient — sem interface IStudentRepository ou implementação separada

**Justificativa:**

- Interfaces de repository fazem sentido quando há múltiplas implementações (HTTP, localStorage, mock)
- Para este projeto, sempre HTTP — a abstração não agrega valor real
- Em testes, HttpTestingController do Angular já provê mockabilidade

### 4. `state/` = Signal Store por Feature

**Decisão:** Cada feature com estado não-trivial recebe um Signal store injectable

**Justificativa:**

- Signals do Angular v20+ são o padrão recomendado para estado local
- Evita prop-drilling e acoplamento entre componentes da mesma feature
- Simples e sem boilerplate de NgRx ou RxJS pesado

### 5. `ui/` = Componentes Standalone com OnPush

**Decisão:** Todos os componentes são standalone com ChangeDetectionStrategy.OnPush

### 6. `core/` = Singletons Globais

**O que vai em core/:**

- Serviços de autenticação (Auth0)
- Guards
- Interceptors HTTP
- Serviços transversais (theme, toast, layout)

### 7. `shared/` = Componentes e Utilitários Reutilizáveis

**O que vai em shared/:**

- Componentes usados em 2+ features (paginator, confirm-dialog, loading, toast-container)
- Directives globais
- Pipes customizadas
- Funções utilitárias puras

### 8. Lazy Loading por Feature Route File

Cada feature expõe um \*.routes.ts com suas rotas, carregado lazily no app.routes.ts

### 9. Path Aliases no tsconfig

Configurar @core/_, @features/_, @shared/_, @layout/_ em tsconfig.json

### 10. Features no Scope

**Fase 1 — Core:** academic-years, courses, students, teachers, class-groups, plans
**Fase 2 — Suporte:** assessments, assignments, finance, enrollments
**Fase 3 — Auxiliares:** notices, communications, notifications, documents, calendar
**Fase 4 — Admin:** assets, scheduling, timetabling, security, announcements, guardians, school-units, reports, import, audit-logs
**Fase 5 — Especiais:** home, portal, my-area, checkout, pricing-page, advanced-finance, services

## Mitigação de Riscos

| Risco              | Mitigação                                                    |
| ------------------ | ------------------------------------------------------------ |
| Imports quebrados  | Executar ng build após cada batch de arquivos movidos        |
| Testes falhando    | Atualizar imports nos specs, manter cobertura                |
| Performance        | Validar bundle size com ng build --stats-json após conclusão |
| Conflitos de merge | Trabalhar em feature branch isolada                          |
