# AGENTS.md — Mapa do Monorepo (school-management)

Guia de orientação para **agentes de IA** (e humanos) trabalhando neste repositório. Objetivo: você encontrar o caminho certo na primeira tentativa. Documentos específicos são modulares — carregue apenas o que precisa.

## O que é este projeto

Sistema de gestão escolar multi-tenant (SaaS): alunos, responsáveis, turmas, horários, avaliações/notas, planos de pagamento escolar, comunicação, boletins, assinaturas. Monorepo com **API .NET**, **UI Angular** e **specs OpenSpec** (spec-driven development).

```
school-management/
├── school-management-api/     # API ASP.NET Core (.NET 10) — submodule git
├── school-management-ui/      # UI Angular 22 (standalone + signals) — submodule git
├── openspec/                  # Specs: changes (propostas) + specs (verdade atual)
├── docs/                      # Docs transversais do monorepo
│   └── auth0-mock.md          # Mock do Auth0 p/ desenvolvimento (histórico, movido da raiz)
└── AGENTS.md                  # ← você está aqui
```

> ⚠️ `school-management-api` e `school-management-ui` são **submodules**. Commits são feitos dentro de cada submodule e depois o ponteiro é bumpado no repositório raiz (padrão já usado por todo o histórico).

## Documentos por projeto (carregue só o que precisa)

| Preciso… | Leia |
|---|---|
| Trabalhar na API (.NET) | `school-management-api/AGENTS.md` |
| Trabalhar na UI (Angular) | `school-management-ui/AGENTS.md` |
| Criar/alterar uma proposta de mudança | `openspec/AGENTS.md` (workflow OpenSpec) |
| Entender o mock do Auth0 | `docs/auth0-mock.md` |

## Comandos essenciais

### API (`school-management-api/`)

```bash
export PATH="$HOME/.dotnet:$PATH"
dotnet build src/SchoolManagement                      # build (API + camadas)
dotnet test tests/SchoolManagement.Tests               # suíte completa (xUnit + Testcontainers)
dotnet test tests/SchoolManagement.Tests --filter "FullyQualifiedName~Grading"   # subconjunto
dotnet ef migrations add <Nome> --context SchoolContext \
     --project src/SchoolManagement.Infrastructure --output-dir Data/Migrations   # a partir de src/SchoolManagement
dotnet run --project src/SchoolManagement --no-launch-profile -- --seed-demo     # aplica seeds (idempotentes) e sai
dotnet run --project src/SchoolManagement --no-launch-profile                    # sobe a API (Development)
```

### UI (`school-management-ui/`)

```bash
source ~/.nvm/nvm.sh && nvm use 24     # Node ≥ 22 exigido pelo CLI (24 LTS instalado)
npm ci
npx ng build --configuration development     # build
npx cypress run --spec cypress/e2e/<spec>.cy.ts --config baseUrl='http://127.0.0.1:5067'  # E2E ao vivo (API real)
```

> E2E "ao vivo" = API local (porta 5067, Development) + Postgres do `docker compose` + seed demo, sem UI servida — specs API-only (`cy.request`). E2E de UI real usa `ng serve --configuration e2e` (devAuth).

### Ambiente local

```bash
docker compose up -d postgres   # dentro de school-management-api (container school-management-api-postgres-1, porta 5433)
docker exec -i school-management-api-postgres-1 psql -U postgres -d SchoolManagementDb   # psql direto
```

## Convenções de commit

- Mensagens detalhadas em uma linha, no estilo do histórico: `feat(escopo): o que mudou — detalhes; suíte N/N`.
- Escopos comuns: `grading-formulas`, `billing-cadence`, `report-builder`, `export`, `ui`, `seed`, `test`.
- Sempre: build verde + `dotnet test` (ou `ng build`) antes de commitar. A suíte atual é **755 testes, 0 falhas** (5 skips conhecidos).
- Commits em dois níveis: dentro do submodule → bump do ponteiro na raiz com mensagem resumida apontando o commit do submodule.

## Fluxo de trabalho (OpenSpec — spec-driven)

1. **Proposta**: crie `openspec/changes/<verb-kebab-case>/` com `proposal.md`, `tasks.md`, `design.md` (se preciso) e deltas em `specs/<capability>/spec.md`. Valide com `openspec validate <id> --strict` (CLI: `npx -y @fission-ai/openspec`).
2. **Aprovação**: confirme com o dono do produto antes de implementar.
3. **Implementação**: siga as tasks de `tasks.md` **na ordem**; marque `- [x]` conforme conclui. Cada requirement do delta precisa de pelo menos um `#### Scenario:`.
4. **Archive**: após deploy, `openspec archive <change>` (specs → `openspec/specs/`).

Inventário atual: `openspec list` (changes ativos) · `ls openspec/changes/archive/` (concluídos).

## Armadilhas conhecidas (economize debug)

- **Duas tabelas "turma"**: `"ClassGroup"` (singular — modelo espelho do SchoolContext, relíquia) e `"ClassGroups"` (plural — **a real**, dono do AcademicContext). O app lê/escreve na **plural**. Entidades compartilhadas entre contexts têm colunas só onde o dono mapeia — colunas novas de `ClassGroup` vão por **migration do AcademicContext**.
- **Idem `StudentClass`/`StudentClasses`**. O seed demo **não cria vínculos aluno-turma** (só notas) — E2E que precisa de matrícula as cria via psql idempotente.
- **Seed**: `--seed-demo` só aplica em banco vazio para o demo de frontend (slug fixo); o Pilot é idempotente e reponível. Períodos letivos e fórmula default vêm do Pilot (recomendado re-rodar `--seed-demo` após migrations novas).
- **xUnit v3 paraleliza métodos da mesma classe**: testes de integração com dados compartilhados correm riscos — use dados únicos por instância e semeadura fora da conexão singleton (`GetSeedConnectionString()`).
- `IStudentClassRepository`/`IClassGroupRepository` resolvem para `AcademicContext ?? SchoolContext`.
- Migration nova de entidade School + `dotnet ef` **a partir de `src/SchoolManagement`** com `--project .../SchoolManagement.Infrastructure` (senão falta o pacote Design).
