# Changelog

Todas as alterações notáveis deste projeto serão documentadas neste arquivo.

O formato é baseado em [Keep a Changelog](https://keepachangelog.com/pt-BR/1.0.0/),
e este projeto adere ao [Semantic Versioning](https://semver.org/lang/pt-BR/).

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
