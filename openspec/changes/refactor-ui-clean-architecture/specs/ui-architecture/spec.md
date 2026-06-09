# ui-architecture Specification Delta

## ADDED Requirements

### Requirement: Feature-Based Vertical Architecture

O projeto UI SHALL reorganizar de arquitetura horizontal (components/, services/, models/) para arquitetura vertical baseada em features, onde cada feature MUST conter 4 camadas leves: domain/, data/, state/ e ui/.

#### Scenario: Academic Years Feature Structure

- **GIVEN** um desenvolvedor trabalhando com academic years
- **WHEN** ele navega para `src/app/features/academic-years/`
- **THEN** ele encontra toda a lógica de academic years organizada com:
  - `domain/` contendo modelos TypeScript puros (interfaces, enums)
  - `data/` contendo o HTTP service
  - `state/` contendo o Signal store
  - `ui/` contendo componentes e páginas Angular

#### Scenario: Developer Onboarding

- **GIVEN** um novo desenvolvedor precisa trabalhar na feature de students
- **WHEN** ele navega para `src/app/features/students/`
- **THEN** ele encontra domain, data, state e ui sem necessidade de navegar em múltiplas pastas

### Requirement: Domain Layer as Pure TypeScript Models

A camada `domain/` de cada feature MUST conter apenas interfaces e enums TypeScript, sem dependências de framework ou lógica de negócio.

#### Scenario: Student Model Definition

- **GIVEN** a camada domain de students
- **WHEN** examinando `features/students/domain/student.model.ts`
- **THEN** ele contém apenas interfaces e enums TypeScript, sem imports do Angular ou classes com métodos

### Requirement: Data Layer as HTTP Service

A camada `data/` de cada feature MUST conter um service concreto com HttpClient para comunicação com a API REST.

#### Scenario: Student HTTP Service

- **GIVEN** a camada data de students
- **WHEN** examinando `features/students/data/student.service.ts`
- **THEN** ele usa HttpClient injetado via inject(), expõe métodos getAll(), getById(), create(), update(), delete()

### Requirement: State Layer as Signal Store

Cada feature com estado não-trivial SHALL ter um Signal store injectable na camada `state/`.

#### Scenario: Student Signal Store

- **GIVEN** a camada state de students
- **WHEN** examinando `features/students/state/student.store.ts`
- **THEN** ele contém signals para students[], loading e selected, além de computed properties derivadas

#### Scenario: Store Provided at Component Level

- **GIVEN** o StudentStore
- **WHEN** declarado em providers de um componente raiz da feature
- **THEN** ele é scoped para aquela sub-árvore de componentes

### Requirement: UI Layer as Standalone Components with OnPush

A camada `ui/` de cada feature MUST conter componentes standalone com ChangeDetectionStrategy.OnPush.

#### Scenario: Student List Component

- **GIVEN** a camada ui de students
- **WHEN** examinando `features/students/ui/student-list/student-list.component.ts`
- **THEN** ele é standalone, usa OnPush, injeta o StudentStore e renderiza via signals

### Requirement: Lazy Loading per Feature Routes File

Cada feature SHALL expor um arquivo `*.routes.ts` carregado lazily no `app.routes.ts`.

#### Scenario: Students Lazy Route

- **GIVEN** a configuração de rotas em `app.routes.ts`
- **WHEN** um usuário navega para `/students`
- **THEN** Angular carrega apenas o bundle da feature students via loadChildren

### Requirement: Core Module for Global Singletons

O módulo `core/` SHALL conter apenas serviços singleton globais: autenticação, guards, interceptors e serviços transversais.

#### Scenario: Auth Service in Core

- **GIVEN** o serviço de autenticação
- **WHEN** examinando `core/auth/auth.service.ts`
- **THEN** ele é providedIn root, gerencia estado de autenticação e é injetado em guards e interceptors

### Requirement: Shared Module for Reusable UI

O módulo `shared/` SHALL conter apenas componentes, diretivas, pipes e utilitários usados em 2 ou mais features.

#### Scenario: Paginator Component in Shared

- **GIVEN** o componente de paginação
- **WHEN** múltiplas features precisam de paginação
- **THEN** ele vive em `shared/components/paginator/` e é importado individualmente por cada feature

### Requirement: TypeScript Path Aliases

O projeto MUST configurar path aliases no `tsconfig.json` para eliminar imports com caminhos relativos longos.

#### Scenario: Import Using Path Alias

- **GIVEN** um componente em `features/students/ui/`
- **WHEN** importando o StudentService
- **THEN** o import usa `@features/students/data/student.service` em vez de `../../data/student.service`

## REMOVED Requirements

### Requirement: Horizontal File Organization

A estrutura horizontal com pastas top-level `components/`, `services/` e `models/` MUST ser removida e substituída pela estrutura vertical por features.

#### Scenario: Services Folder Removal

- **GIVEN** a pasta `src/app/services/` com todos os serviços centralizados
- **WHEN** a reorganização é concluída
- **THEN** cada serviço está na camada `data/` de sua respectiva feature e a pasta `services/` não existe mais

#### Scenario: Models Folder Removal

- **GIVEN** a pasta `src/app/models/` com todos os modelos centralizados
- **WHEN** a reorganização é concluída
- **THEN** cada modelo está na camada `domain/` de sua respectiva feature e a pasta `models/` não existe mais
