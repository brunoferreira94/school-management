# 🏫 School Management SaaS

> Plataforma completa de gestão escolar — multi-tenant, moderna e intuitiva.

[![Backend](https://img.shields.io/badge/.NET-8-512BD4?logo=dotnet)](https://dotnet.microsoft.com/)
[![Frontend](https://img.shields.io/badge/Angular-17-DD0031?logo=angular)](https://angular.io/)
[![Database](https://img.shields.io/badge/PostgreSQL-16-4169E1?logo=postgresql)](https://www.postgresql.org/)
[![Auth](https://img.shields.io/badge/Auth0-EB5424?logo=auth0)](https://auth0.com/)
[![License](https://img.shields.io/badge/license-MIT-green)](LICENSE)

---

## 📋 Índice

- [Visão Geral](#-visão-geral)
- [Arquitetura](#-arquitetura)
- [Stack Tecnológico](#-stack-tecnológico)
- [Estrutura do Projeto](#-estrutura-do-projeto)
- [Começando](#-começando)
- [Documentação](#-documentação)
- [Funcionalidades](#-funcionalidades)
- [API](#-api)
- [Frontend](#-frontend)
- [Deploy](#-deploy)
- [Contribuição](#-contribuição)
- [Licença](#-licença)

---

## 🎯 Visão Geral

O **School Management SaaS** é uma plataforma multi-tenant de gestão escolar que permite administrar alunos, turmas, professores, notas, frequência, financeiro e comunicados. Inclui um portal dedicado para alunos e responsáveis com boletim, boletos e mensagens.

### Diferenciais

- 🎨 **Design iOS-inspired** — Interface moderna, acolhedora e intuitiva
- 📱 **PWA** — Funciona offline, instalável no celular
- 🌍 **i18n** — Português, Inglês e Espanhol
- 🔐 **Auth0** — Autenticação enterprise com MFA
- 📊 **Analytics** — Relatórios de retenção, inadimplência e frequência
- 🔔 **Notificações** — Multi-canal (email, SMS, push, in-app)
- ⚡ **Performance** — OnPush, lazy loading, virtual scroll

---

## 🏗️ Arquitetura

```
┌─────────────────────────────────────────────────────────────────┐
│                        Cloudflare Tunnel                        │
│                           (HTTPS)                               │
└──────────────────────────────┬──────────────────────────────────┘
                               │
┌──────────────────────────────▼──────────────────────────────────┐
│                         Nginx (Reverse Proxy)                   │
│                    ┌─────────┴─────────┐                        │
│                    │                   │                        │
│              ┌─────▼─────┐      ┌─────▼─────┐                  │
│              │  Frontend  │      │   API     │                  │
│              │  (Angular) │      │  (.NET 8) │                  │
│              │  Port 80   │      │  Port 5066│                  │
│              └────────────┘      └─────┬─────┘                  │
│                                        │                        │
│                                  ┌─────▼─────┐                  │
│                                  │ PostgreSQL │                  │
│                                  │  Port 5432 │                  │
│                                  └───────────┘                  │
└─────────────────────────────────────────────────────────────────┘
```

### Padrões Arquiteturais

| Camada | Padrão | Descrição |
|--------|--------|-----------|
| **Backend** | Clean Architecture | Domain → Application → Infrastructure → API |
| **Backend** | CQRS | LiteBus para commands e queries separados |
| **Backend** | Repository | Abstração de persistência via EF Core |
| **Frontend** | Standalone Components | Sem NgModules, tudo standalone |
| **Frontend** | Facade Pattern | Services encapsulam chamadas HTTP |
| **Frontend** | Signals | Estado reativo com Angular Signals |
| **Auth** | RBAC | Permissões granulares via JWT claims |

---

## 🛠️ Stack Tecnológico

### Backend
| Tecnologia | Versão | Propósito |
|------------|--------|-----------|
| .NET | 8.0 | Runtime |
| ASP.NET Core | 8.0 | Web API |
| Entity Framework Core | 8.0 | ORM |
| LiteBus | Latest | CQRS Mediator |
| PostgreSQL | 16 | Banco de dados |
| Auth0 | - | Autenticação |
| xUnit | Latest | Testes |
| Serilog | Latest | Logging estruturado |
| Prometheus | - | Métricas |

### Frontend
| Tecnologia | Versão | Propósito |
|------------|--------|-----------|
| Angular | 17+ | Framework |
| TypeScript | 5+ | Linguagem |
| Tailwind CSS | 3+ | Estilos |
| Angular CDK | 17+ | Drag & Drop, a11y |
| @ngx-translate | 15+ | Internacionalização |
| Angular PWA | 17+ | Service Worker |
| Cypress | 13+ | Testes E2E |
| Karma + Jasmine | - | Testes unitários |

### Infraestrutura
| Tecnologia | Propósito |
|------------|-----------|
| Docker + Docker Compose | Containerização |
| Nginx | Reverse proxy + SSL |
| Cloudflare Tunnel | Exposição segura |
| Grafana | Dashboards |
| Prometheus | Métricas |

---

## 📁 Estrutura do Projeto

```
school-management/
├── 📄 README.md                    # Este arquivo
├── 📄 PRD.md                       # Product Requirements Document
├── 📄 DEPLOY.md                    # Guia de deploy
│
├── 📁 school-management-api/       # Backend (.NET 8)
│   ├── 📁 src/
│   │   ├── 📁 SchoolManagement.Domain/         # Entidades, agregados
│   │   ├── 📁 SchoolManagement.Application/    # Casos de uso, DTOs
│   │   ├── 📁 SchoolManagement.Infrastructure/ # EF Core, repositórios
│   │   └── 📁 SchoolManagement/                # API controllers
│   ├── 📁 tests/                               # Testes unitários + integração
│   ├── 📁 docs/                                # Documentação da API
│   └── 📄 README.md
│
├── 📁 school-management-ui/        # Frontend (Angular 17)
│   ├── 📁 src/
│   │   ├── 📁 app/
│   │   │   ├── 📁 core/                        # Auth, guards, interceptors
│   │   │   ├── 📁 features/                    # Módulos de funcionalidades
│   │   │   │   ├── 📁 home/                    # Dashboard
│   │   │   │   ├── 📁 students/                # Gestão de alunos
│   │   │   │   ├── 📁 teachers/                # Gestão de professores
│   │   │   │   ├── 📁 class-groups/            # Gestão de turmas
│   │   │   │   ├── 📁 grades/                  # Notas e avaliações
│   │   │   │   ├── 📁 attendance/              # Frequência
│   │   │   │   ├── 📁 reports/                 # Relatórios
│   │   │   │   ├── 📁 finance/                 # Financeiro
│   │   │   │   ├── 📁 notices/                 # Comunicados
│   │   │   │   ├── 📁 pwa/                     # PWA (offline, push)
│   │   │   │   └── 📁 ...                      # Outros módulos
│   │   │   ├── 📁 shared/                      # Componentes compartilhados
│   │   │   └── 📁 services/                    # Serviços globais
│   │   ├── 📁 assets/                          # Imagens, i18n, ícones
│   │   └── 📁 environments/                    # Configs de ambiente
│   ├── 📁 docs/                                # Documentação do frontend
│   ├── 📁 cypress/                             # Testes E2E
│   └── 📄 README.md
│
├── 📁 docker/                        # Configs Docker
├── 📁 nginx/                         # Configs Nginx
└── 📁 .github/workflows/             # CI/CD (GitHub Actions)
```

---

## 🚀 Começando

### Pré-requisitos

- [.NET 8 SDK](https://dotnet.microsoft.com/download/dotnet/8.0)
- [Node.js 18+](https://nodejs.org/)
- [Docker](https://www.docker.com/) + Docker Compose
- [PostgreSQL 16](https://www.postgresql.org/) (ou use Docker)

### Clone

```bash
git clone https://github.com/brunoferreira94/school-management.git
cd school-management
```

### Backend

```bash
cd school-management-api

# Restaurar dependências
dotnet restore

# Configurar banco (PostgreSQL)
# Edite ConnectionStrings__DefaultConnection em appsettings.Development.json

# Rodar migrações
dotnet ef database update --project src/SchoolManagement

# Executar
dotnet run --project src/SchoolManagement
# API: https://localhost:7046
# Swagger: https://localhost:7046/swagger
```

### Frontend

```bash
cd school-management-ui

# Instalar dependências
npm ci

# Executar
npm start
# App: http://localhost:4200
```

### Docker (Completo)

```bash
# Build + Start
docker compose -f docker-compose.prod.yaml up -d --build

# Ver logs
docker compose -f docker-compose.prod.yaml logs -f

# Parar
docker compose -f docker-compose.prod.yaml down
```

---

## 📚 Documentação

| Documento | Descrição |
|-----------|-----------|
| [PRD.md](./PRD.md) | Product Requirements Document |
| [DEPLOY.md](./DEPLOY.md) | Guia de deploy em produção |
| [API Docs](./school-management-api/README.md) | Documentação completa da API |
| [API Endpoints](./school-management-api/report-endpoints-mapping.md) | Mapeamento de endpoints de relatórios |
| [Frontend Docs](./school-management-ui/README.md) | Documentação do frontend |
| [Auth0 Setup](./school-management-ui/docs/auth0-setup.md) | Configuração do Auth0 |
| [E2E Testing](./school-management-ui/docs/e2e-testing.md) | Guia de testes E2E |
| [Getting Started](./school-management-api/docs/getting-started.md) | Guia de início rápido |
| [Observability](./school-management-api/docs/observability.md) | Métricas e monitoramento |
| [Timetabling](./school-management-api/docs/timetabling.md) | Sistema de horários |
| [Analytics](./school-management-api/docs/analytics-mvp.md) | Analytics MVP |
| [CQRS Guide](./school-management-api/docs/cqrs-migration-guide.md) | Guia CQRS |
| [Domain Events](./school-management-api/docs/domain-events-pattern.md) | Padrão Domain Events |

---

## ✨ Funcionalidades

### Gestão Acadêmica
- ✅ **Alunos** — CRUD completo, matrícula, histórico
- ✅ **Professores** — CRUD, especialidades, turmas
- ✅ **Turmas** — CRUD, capacidade, horários, cópia
- ✅ **Cursos** — CRUD, BNCC, cópia
- ✅ **Avaliações** — Notas, pesos, recuperação
- ✅ **Frequência** — Chamada, relatórios, justificativas
- ✅ **Anos Letivos** — CRUD, cópia, contexto global

### Financeiro
- ✅ **Planos** — Criação, associação a alunos
- ✅ **Parcelas** — Geração, vencimento, pagamento
- ✅ **Inadimplência** — Aging, relatórios
- ✅ **Assinaturas** — Gestão SaaS do tenant

### Comunicação
- ✅ **Comunicados** — CRUD, agendamento, público-alvo
- ✅ **Notificações** — Multi-canal (email, SMS, push, in-app)
- ✅ **Eventos** — Calendário escolar
- ✅ **Portal** — Área do aluno/responsável

### Relatórios
- ✅ **Frequência** — Por turma, por aluno
- ✅ **Notas** — Distribuição, boletim
- ✅ **Financeiro** — Receita x despesa, fluxo de caixa
- ✅ **Analytics** — Retenção, inadimplência
- ✅ **Exportação** — CSV + PDF

### Plataforma
- ✅ **Auth0** — Login, MFA, roles, permissões
- ✅ **PWA** — Offline, instalável, push notifications
- ✅ **i18n** — pt-BR, en, es
- ✅ **Dashboard** — Widgets com drag & drop
- ✅ **Busca Global** — Ctrl+K, histórico, analytics

---

## 🔌 API

A API REST está documentada via Swagger/OpenAPI:

```
https://localhost:7046/swagger
```

### Endpoints Principais

| Controller | Endpoints | Descrição |
|------------|-----------|-----------|
| `Students` | 12 | CRUD, matrícula, busca |
| `Teachers` | 8 | CRUD, especialidades |
| `ClassGroups` | 15 | CRUD, alunos, horários, cópia |
| `Courses` | 10 | CRUD, BNCC, cópia |
| `Grades` | 8 | Notas, avaliações |
| `Attendance` | 10 | Frequência, relatórios |
| `Reports` | 6 | Relatórios diversos |
| `Analytics` | 4 | Retenção, inadimplência |
| `Notifications` | 12 | Templates, regras, envio |
| `Finance` | 20 | Planos, parcelas, assinaturas |

> 📖 [Documentação completa da API](./school-management-api/README.md)

---

## 🎨 Frontend

### Design System v2 (iOS-inspired)

- **Cores quentes** — Paleta acolhedora, sem cinza enterprise
- **Espaçamento generoso** — Respiro visual
- **Bordas arredondadas** — 12px–24px radius
- **Frosted glass** — Backdrop blur em cards e modais
- **Animações spring** — Transições naturais
- **Skeletons** — Loading states elegantes

### PWA

- ✅ Service Worker com cache offline
- ✅ Página `/offline` funcional
- ✅ Push notifications (VAPID)
- ✅ Instalável (manifest webapp)

### i18n

- ✅ Português (Brasil) — padrão
- ✅ Inglês
- ✅ Espanhol (estrutura pronta)
- ✅ Seletor de idioma no header
- ✅ Persistência em localStorage

> 📖 [Documentação completa do Frontend](./school-management-ui/README.md)

---

## 🚢 Deploy

### Docker Compose (Recomendado)

```bash
# Produção
docker compose -f docker-compose.prod.yaml up -d --build
```

### Cloudflare Tunnel

```bash
cloudflared tunnel run school-management
```

### Variáveis de Ambiente

| Variável | Descrição | Obrigatório |
|----------|-----------|-------------|
| `DB_USER` | Usuário PostgreSQL | Sim |
| `DB_PASSWORD` | Senha PostgreSQL | Sim |
| `AUTH0_DOMAIN` | Domínio Auth0 | Sim |
| `AUTH0_CLIENT_ID` | Client ID Auth0 | Sim |
| `AUTH0_CLIENT_SECRET` | Client Secret Auth0 | Sim |
| `AUTH0_AUDIENCE` | Audience da API | Sim |

> 📖 [Guia completo de deploy](./DEPLOY.md)

---

## 🤝 Contribuição

### Fluxo de Desenvolvimento

1. Crie uma branch a partir de `development`
2. Faça commits semânticos (`feat:`, `fix:`, `refactor:`)
3. Abra um Pull Request para `development`
4. Aguarde review e CI passar

### Padrões de Código

- **Backend**: Seguir Clean Architecture + CQRS
- **Frontend**: Standalone components + Signals
- **Commits**: Conventional Commits
- **Testes**: Obrigatório para novas features

### Comandos Úteis

```bash
# Backend
dotnet build
dotnet test
dotnet ef migrations add <Nome>

# Frontend
npm start
npm run build
npm run test
npm run lint
npm run e2e:open
```

---

## 📄 Licença

Este projeto está licenciado sob a [MIT License](LICENSE).

---

## 📞 Contato

- **Autor**: Bruno Ferreira
- **GitHub**: [@brunoferreira94](https://github.com/brunoferreira94)
- **API Repo**: [school-management-api](https://github.com/brunoferreira94/school-management-api)
- **Frontend Repo**: [school-management-ui](https://github.com/brunoferreira94/school-management-ui)

---

<p align="center">
  Feito com ❤️ para transformar a gestão escolar
</p>
