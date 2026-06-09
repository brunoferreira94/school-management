# Project Context

## Propósito

Este repositório contém o frontend e partes auxiliares para a aplicação de gestão escolar "School Management". O objetivo do projeto é fornecer um sistema completo para escolas gerenciarem alunos, responsáveis, turmas, horários, avaliações, planos e comunicações (comunicados, documentos, relatórios), incluindo funcionalidades de multi‑tenancy, geração de relatórios e integração com serviços externos (telemetria, armazenamento de anexos, e-mail, pagamentos quando aplicável).

## Tech Stack

- Frontend: Angular (standalone components), TypeScript, Angular Material (componentes de UI), RxJS.
- Testes frontend: Karma + Jasmine para testes unitários, HttpClientTestingModule para mocks HTTP.
- Backend (monorepo/adjacente): ASP.NET Core (C#) com separação em camadas/feature folders (pastas `SchoolManagement.Application`, `SchoolManagement.Domain`, `SchoolManagement.Infrastructure`), Entity Framework Core para persistência e SQL Server / Postgres como opções de banco de dados (DB migrations presentes no repositório).
- Infra & DevOps: Docker / docker-compose para ambiente local, OpenTelemetry collector + Prometheus + Grafana para observabilidade.
- Build & package managers: npm/yarn para frontend; dotnet CLI para backend.

Nota: algumas versões específicas (por exemplo versão do Angular ou .NET) não são explicitamente listadas neste documento — use os arquivos de manifesto (`package.json`, `*.csproj`) para confirmar versões exatas. Estas suposições estão documentadas e podem ser atualizadas.

## Convenções do Projeto

### Estilo de código

- Frontend: aproveitar o ecossistema Angular — formato de código consistente com Prettier/TSLint/ESLint (se presente). Utilizar nomes em inglês para símbolos públicos e manter mensagens de commit em português ou inglês conforme guia do time.
- Backend: seguir convenções C# (PascalCase para tipos e métodos, camelCase para parâmetros locais). DTOs com sufixo `Dto`.
- Arquivos de configuração e textos podem estar em português (a interface também usa pt-BR em muitos locais).

### Organização / Naming

- Estrutura em camadas: `SchoolManagement.Api` / `SchoolManagement` (controllers), `SchoolManagement.Application` (use cases), `SchoolManagement.Domain` (entidades/validações), `SchoolManagement.Infrastructure` (persistência, integrações).
- No frontend, componentes usam o padrão de componente Angular standalone quando possível, Reactive Forms para formulários, e serviços compartilhados em `src/app/services`.

### Componentes e UI

- Preferir componentes reutilizáveis (small, focused). Usar Angular Material para formulários, botões, diálogos e indicadores de progresso.
- Editor WYSIWYG simples implementado via contenteditable com sanitização do HTML antes de persistir.

## Padrões de arquitetura

- Clean Architecture / Onion-like layering: separação clara entre domínio, casos de uso e infraestrutura.
- APIs RESTful no backend, com DTOs para entrada/saída.
- CQRS com LiteBus: `SchoolManagement` controllers despacham `ICommandMediator` e `IQueryMediator` para handlers em `SchoolManagement.Application`, enquanto a lógica de negócio fica encapsulada em use cases/serviços.
- Handlers e validators são registrados via assembly no container de DI do backend, e pipelines de behaviors (logging, tenant, validation, metrics) são aplicados antes da execução.
- Observability-first: métricas, traces e logs instrumentados via OpenTelemetry; coletor configurado em `observability/`.

## Estratégia de Testes

- Frontend: unit tests com Karma + Jasmine; testar componentes isoladamente com `TestBed` e `HttpClientTestingModule` para serviços HTTP.
- Backend: presumivelmente xUnit / NUnit para testes unitários e testes de integração para controllers (ver `SchoolManagement.Tests` para exemplos).
- Recomenda-se cobertura mínima para funcionalidades críticas (autenticação, permissões, upload de anexos e sanitização de conteúdo).

## Git Workflow

- Branching: usar branches por feature/issue (ex.: `feature/<descrição>`, `fix/<descrição>`).
- Pull Requests com revisão obrigatória (code review). Incluir descrição do que foi alterado e instruções de teste.
- Commits: seguir convenções curtas e descritivas; o projeto não força um padrão específico, mas Conventional Commits é recomendado para facilitar changelogs.

## Contexto de Domínio (resumo curto)

- Entidades principais: Students, Guardians, ClassGroups, Classrooms, Courses, Assessments, Grades, Plans, Events, Announcements, Documents, Roles, Permissions.
- Regras importantes: permissões baseadas em roles, multi‑tenancy (registro por tenant / escola), sanitização de HTML para conteúdos ricos (editor de comunicados/documentos), e auditoria de ações sensíveis.

## Restrições importantes

- Segurança/privacidade: dados pessoais sensíveis (estudantes/responsáveis) devem ser tratados conforme regras locais/regulatórias — exportação/distribuição de dados deve ser protegida.
- Sanitização: conteúdo HTML enviado pelo editor precisa ser sanitizado no cliente e servidor (há utilitário de sanitização no frontend e HtmlSanitizer no backend).
- Perfis de carga: alguns relatórios e operações de geração (export) podem ser pesada; considerar jobs assíncronos para tarefas longas.

## Dependências externas e integrações

- Telemetria: OpenTelemetry collector (config em `observability/otel-collector-config.yaml`), Prometheus, Grafana.
- Armazenamento de anexos: endpoint de anexos (upload/download) e possível backend de blob (S3 / Azure Blob) — confirmar provider no ambiente.
- Email: envio de notificações e comunicados via serviço SMTP ou provedor de e-mail (config também presente em appsettings).
- Autenticação: JWT/OAuth2 (backend expõe endpoints de auth e roles/permissions).

## Como usar este documento

- Mantenha este arquivo atualizado quando houver mudanças significativas de arquitetura, dependências externas ou convenções de equipe.
- Para dúvidas sobre decisões arquiteturais, consultar `openspec/AGENTS.md` e os arquivos de design em `docs/`.

## Suposições documentadas

- Assumi que o backend é ASP.NET Core (C#) pela estrutura de pastas e arquivos presentes; confirme a versão dotnet em arquivos `*.csproj`.
- Assumi que o armazenamento de anexos e provedores externos não são fixos — verifique `appsettings*.json` e a infraestrutura (IaC) do deploy.

---

Atualize esta especificação com detalhes adicionais (versões, endpoints, fluxos de autorização) quando forem confirmados em arquivos de configuração ou documentação de infra.
