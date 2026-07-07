# 📚 Índice de Documentação

> Documentação completa do School Management SaaS.

---

## 🚀 Início Rápido

| Documento | Descrição | Público |
|-----------|-----------|---------|
| [README.md](../README.md) | Visão geral do projeto | Todos |
| [PRD.md](../PRD.md) | Product Requirements Document | Product / Dev |
| [DEPLOY.md](../DEPLOY.md) | Guia de deploy em produção | DevOps |

---

## 🏗️ Arquitetura

| Documento | Descrição | Público |
|-----------|-----------|---------|
| [ARCHITECTURE.md](./ARCHITECTURE.md) | Arquitetura do sistema (backend + frontend) | Dev |
| [CONTRIBUTING.md](./CONTRIBUTING.md) | Guia de contribuição e padrões de código | Dev |

---

## 🔌 Backend (API)

| Documento | Descrição | Público |
|-----------|-----------|---------|
| [README](../school-management-api/README.md) | Documentação completa da API | Dev / Integradores |
| [Getting Started](../school-management-api/docs/getting-started.md) | Guia de início rápido | Dev |
| [API Clients](../school-management-api/docs/api-clients.md) | Ferramentas e clientes de API | Dev |
| [Frontend Integration](../school-management-api/docs/frontend-integration.md) | Guia de integração frontend | Dev |
| [Observability](../school-management-api/docs/observability.md) | Métricas e monitoramento | DevOps |
| [Timetabling](../school-management-api/docs/timetabling.md) | Sistema de horários | Dev |
| [Teacher Availability API](../school-management-api/docs/api/teacher-availability.md) | Disponibilidade de professores | Dev |
| [Analytics MVP](../school-management-api/docs/analytics-mvp.md) | Analytics (retenção, inadimplência) | Dev / Product |
| [CQRS Guide](../school-management-api/docs/cqrs-migration-guide.md) | Guia CQRS | Dev |
| [Domain Events](../school-management-api/docs/domain-events-pattern.md) | Padrão Domain Events | Dev |
| [Testing](../school-management-api/docs/testing-configuration.md) | Configuração de testes | Dev |
| [Multi-tenancy](../school-management-api/docs/multi-tenancy-summary.md) | Resumo multi-tenancy | Dev |
| [Import Guide](../school-management-api/docs/import-guide.md) | Guia de importação em massa | Dev / Admin |
| [Communication](../school-management-api/docs/communication.md) | Sistema de comunicação | Dev |
| [Global Search](../school-management-api/docs/global-search.md) | Busca global (Ctrl+K) | Dev |
| [Academic Year Copy](../school-management-api/docs/academic-year-copy-guide.md) | Guia de cópia de ano letivo | Dev / Admin |
| [Pricing Analysis](../school-management-api/docs/pricing-analysis.md) | Análise de precificação | Product |
| [Roadmap](../school-management-api/docs/ROADMAP.md) | Roadmap do projeto | Product / Dev |
| [Report Endpoints](../school-management-api/report-endpoints-mapping.md) | Mapeamento de endpoints de relatórios | Dev |
| [Terms of Use Middleware Exceptions](./middleware/terms-of-use-exceptions.md) | Exceções e respostas HTTP do middleware de termos | Dev / Audit |

---

## 🎨 Frontend (UI)

| Documento | Descrição | Público |
|-----------|-----------|---------|
| [README](../school-management-ui/README.md) | Documentação do frontend | Dev |
| [Auth0 Setup](../school-management-ui/docs/auth0-setup.md) | Configuração do Auth0 | Dev |
| [API Documentation](../school-management-ui/docs/api-documentation.md) | Documentação de integração com API | Dev |
| [E2E Testing](../school-management-ui/docs/e2e-testing.md) | Guia de testes E2E | QA / Dev |

---

## 📦 Deploy e Infraestrutura

| Documento | Descrição | Público |
|-----------|-----------|---------|
| [Deploy Guide](../DEPLOY.md) | Guia de deploy (Docker + Cloudflare) | DevOps |
| [Docker Compose](../docker-compose.prod.yaml) | Configuração Docker de produção | DevOps |
| [Nginx Config](../nginx/nginx.conf) | Configuração Nginx | DevOps |
| [CI/CD](../.github/workflows/ci-cd.yml) | Pipeline GitHub Actions | DevOps |

---

## 📋 Produto

| Documento | Descrição | Público |
|-----------|-----------|---------|
| [PRD](../PRD.md) | Product Requirements Document | Product / Dev |
| [Plano de Lançamento](../school-management-api/docs/PLANO_LANCAMENTO_PRODUTO.md) | Plano completo de lançamento | Product / Business |
| [Guia Rápido de Lançamento](../school-management-api/docs/LANCAMENTO_GUIA_RAPIDO.md) | Sumário executivo de lançamento | Product |
| [Roteiro de Demo](../school-management-api/examples/README.md) | Roteiro de demonstração (10 min) | Sales / Product |
| [Onboarding Piloto](./onboarding-piloto.md) | Guia de onboarding para escola piloto (Portal do Responsável) | Product / Admin |
| [Usability Improvements](../school-management-api/docs/usability-improvements.md) | Melhorias de usabilidade | UX / Product |

---

## 🗺️ Navegação por Perfil

### 👨‍💻 Desenvolvedor Backend
1. [README](../README.md) → Visão geral
2. [ARCHITECTURE.md](./ARCHITECTURE.md) → Arquitetura
3. [CONTRIBUTING.md](./CONTRIBUTING.md) → Padrões
4. [API README](../school-management-api/README.md) → Endpoints
5. [Getting Started](../school-management-api/docs/getting-started.md) → Setup

### 🎨 Desenvolvedor Frontend
1. [README](../README.md) → Visão geral
2. [ARCHITECTURE.md](./ARCHITECTURE.md) → Arquitetura
3. [CONTRIBUTING.md](./CONTRIBUTING.md) → Padrões
4. [Frontend README](../school-management-ui/README.md) → Setup
5. [Auth0 Setup](../school-management-ui/docs/auth0-setup.md) → Auth

### 📦 DevOps
1. [README](../README.md) → Visão geral
2. [DEPLOY.md](../DEPLOY.md) → Deploy
3. [Observability](../school-management-api/docs/observability.md) → Monitoramento
4. [CI/CD](../.github/workflows/ci-cd.yml) → Pipeline

### 📋 Product Manager
1. [PRD](../PRD.md) → Requisitos
2. [Roadmap](../school-management-api/docs/ROADMAP.md) → Roadmap
3. [Plano de Lançamento](../school-management-api/docs/PLANO_LANCAMENTO_PRODUTO.md) → Lançamento
4. [Roteiro de Demo](../school-management-api/examples/README.md) → Demo

### 🧪 QA
1. [E2E Testing](../school-management-ui/docs/e2e-testing.md) → Testes E2E
2. [Testing Configuration](../school-management-api/docs/testing-configuration.md) → Testes backend
3. [API Clients](../school-management-api/docs/api-clients.md) → Postman/Insomnia
