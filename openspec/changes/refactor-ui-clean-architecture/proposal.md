# Refactor: Reorganização da UI com Feature-Sliced Architecture

**Change ID:** `refactor-ui-clean-architecture`

**Status:** `Proposal`

**Updated:** 2026-05-13

## Why

A arquitetura atual horizontal (components/, services/, models/) cria acoplamento desnecessário, dificulta a localização de código relacionado e aumenta a complexidade cognitiva para novos desenvolvedores. Clean Architecture completa aplicada ao Angular gera boilerplate excessivo (5 camadas por feature) e vai contra o estilo idiomático da plataforma. A abordagem **Feature-Sliced** com camadas leves é mais adequada: organiza por domínio, usa os padrões nativos do Angular (signals, standalone, lazy loading) e mantém cerimônia proporcional ao tamanho do projeto.

## Visão Geral

Reorganizar a estrutura do projeto `school-management-ui` para uma arquitetura **Feature-Sliced** com 4 camadas leves por feature, migrando de uma organização horizontal (por tipos de arquivo) para uma organização vertical (por domínio de negócio).

### Problemas Atuais

- ❌ Estrutura horizontal dificulta visualização de contexto de feature
- ❌ Services e componentes espalhados tornam manutenção difícil
- ❌ Difícil identificar dependências entre features
- ❌ Novo desenvolvedor precisa navegar entre múltiplas pastas para entender uma feature

### Benefícios

- ✅ Estrutura baseada em features (coesão alta)
- ✅ Cada feature é auto-contida com 4 camadas leves
- ✅ Angular-idiomático: signals, standalone components, lazy loading nativo
- ✅ Onboarding mais rápido para novos desenvolvedores
- ✅ Facilita migração para micro-frontends no futuro

## Estrutura Proposta

```
src/app/
├── core/                          # Singleton services, auth, guards, interceptors
│   ├── auth/
│   ├── guards/
│   ├── interceptors/
│   └── services/
├── features/                      # Features do negócio (vertical)
│   ├── academic-years/
│   │   ├── domain/                # Modelos TypeScript puros (interfaces, enums)
│   │   │   └── academic-year.model.ts
│   │   ├── data/                  # HTTP: service + repository
│   │   │   └── academic-year.service.ts
│   │   ├── state/                 # Signal store (estado local da feature)
│   │   │   └── academic-year.store.ts
│   │   ├── ui/                    # Componentes e páginas Angular
│   │   │   ├── academic-years-list/
│   │   │   └── academic-year-form/
│   │   └── academic-years.routes.ts
│   ├── courses/
│   │   └── (mesma estrutura)
│   ├── students/
│   │   └── (mesma estrutura)
│   └── ... (outras features)
├── shared/                        # Código compartilhado entre features
│   ├── components/
│   ├── directives/
│   ├── pipes/
│   └── utils/
└── layout/                        # Shell, topbar, sidebar
```

## Responsabilidade de Cada Camada

| Camada      | Responsabilidade                           | Exemplo                             |
| ----------- | ------------------------------------------ | ----------------------------------- |
| **domain/** | Modelos TypeScript puros, sem dependências | `AcademicYear`, `Student`, `Course` |
| **data/**   | Serviço HTTP que comunica com a API        | `AcademicYearService`               |
| **state/**  | Signal store com estado reativo local      | `AcademicYearStore`                 |
| **ui/**     | Componentes e páginas standalone Angular   | `AcademicYearsListComponent`        |

## Scope de Trabalho

- ✅ Reorganizar estrutura de pastas para feature-sliced
- ✅ Mover models para `domain/` de cada feature
- ✅ Mover services para `data/` de cada feature
- ✅ Criar `state/` com Signal stores por feature
- ✅ Mover componentes para `ui/` de cada feature
- ✅ Configurar lazy loading por feature via `*.routes.ts`
- ✅ Mover `core/` (auth, guards, interceptors)
- ✅ Consolidar `shared/` (componentes reutilizáveis)
- ✅ Atualizar todos os imports
- ✅ Atualizar `app.routes.ts`

## Fora do Scope

- ❌ Refatorar lógica interna de serviços
- ❌ Implementar repository pattern completo com interfaces abstratas
- ❌ Adicionar use-cases / DTOs explícitos (overkill para SPA)
- ❌ Testes completos (cobertura mantida, mas não expandida)
