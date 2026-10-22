# Changelog

Todas as alterações notáveis deste projeto serão documentadas neste arquivo.

O formato é baseado em [Keep a Changelog](https://keepachangelog.com/pt-BR/1.0.0/),
e este projeto adere ao [Semantic Versioning](https://semver.org/lang/pt-BR/).

## [Unreleased]

### Corrigido
- Deploy de produção restaurado: recriado deploy da UI após deployment Vercel congelado (file tree ausente) e desativação do Deployment Protection
- Env vars no Render atualizadas (incl. `Cors__AllowedOrigins__0/1`) — browser disciplina CORS para os 2 domínios de produção
- `development` sincronizada com `main` nos 2 submódulos (18/7 commits FF) e repo pai em merge

### Adicionado
- Workflow `keep-alive.yml`: ping por hora em `main` (free, repo público) que mantém Render quente e impede pause do Supabase
- Topologia de produção documentada (Vercel + Render + Supabase) no README/DEPLOY
- Branch backup `backup/development-pre-sync` (API) preservando linhagem local divergente

### Removido
- `docker-compose.prod.yml` legacy (duplicado de `docker-compose.prod.yaml` com envs divergentes + typo `STRIPE_WEBHOOk_SECRET`)

## [1.0.0] - 2026-07-31

### Adicionado
- Plataforma multi-tenant de gestão escolar (alunos, turmas, professores, notas, frequência, financeiro)
- Portal do aluno/responsável com boletim, boletos e mensagens
- Autenticação com Auth0 (JWT, MFA, roles, permissões)
- API REST em .NET com Clean Architecture + CQRS
- Frontend Angular com PWA, i18n (pt-BR/en/es) e design iOS-inspired
- Relatórios de frequência, notas e financeiro
- Notificações multi-canal (email, SMS, push, in-app)
- Analytics de retenção e inadimplência
- Deploy com Docker Compose e Cloudflare Tunnel

### Notas de release
- Teste de unidade `UnitOfWorkTests.MultipleRepositories_ShareSameContext` está pulado
  por limitação do InMemory Database (não compartilha estado entre contextos).
- Use `UnitOfWorkIntegrationTests` para validar transações reais em PostgreSQL.
