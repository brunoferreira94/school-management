# Proposta: Corrigir o Seeding de Ambiente (Baseline + `--seed-demo`)

## Why

O seed de ambiente está **morto** e o comando documentado não funciona:

- `var seedDemoData = args.Any(a => a == "--seed-demo")` existe no `Program.cs`,
  mas o bloco `if (seedDemoData) { … }` que chamava `IDemoDataSeeder` foi
  removido no commit `1fce807` (*feat(churn-validation)*). A variável ficou
  órfã: `dotnet run --project src/SchoolManagement --no-launch-profile -- --seed-demo`
  sobe a API e **não semeia nada**.
- `IDemoDataSeeder` continua registrado no DI
  (`RepositoryAndInfrastructureRegistration.cs`), mas **nunca é resolvido** —
  `FrontendDemoDataSeeder` e `PilotEnvironmentSeeder` não rodam em nenhum fluxo.
- Como o catálogo de conquistas, as permissões e os vínculos
  papel↔permissão vivem dentro do `PilotEnvironmentSeeder` (que só deveria rodar
  no modo demo), **ambientes novos sobem sem dados de plataforma**. Efeito
  observado em campo: o banco de desenvolvimento não tinha nenhuma permissão
  `achievements.*` nem o catálogo v1 — a Central de Conquistas dava 403 e as
  conquistas não desbloqueavam.

Em resumo: dados de **plataforma** (permissões, papéis, catálogo) estão
acoplados a dados **fictícios** (tenant piloto, `diretor.demo`, fórmulas demo).
O modo demo não deve ser a condição para a plataforma existir.

## What Changes

- **Novo `BaselineSeeder`** — idempotente, roda em **todos os ambientes** após
  as migrations:
  - `Permissions` (lista completa, inclusive `achievements.read`/`manage`);
  - `Roles` (`Director`, `Coordinator`, `Teacher`, `Parent`);
  - `RolePermissions` (vínculos por papel — diretor recebe tudo exceto
    platform-only; coordenador e professor recebem o subconjunto definido);
  - Catálogo de conquistas v1 (12 conquistas, 600 pts).
- **`--seed-demo` restaurado** — exclusivo de `Development`: baseline +
  `FrontendDemoDataSeeder` + `PilotEnvironmentSeeder` (dados fictícios), com
  **encerramento do processo (exit 0)** antes de subir os hosted services.
- **Divisão do `PilotEnvironmentSeeder`** — permissões/papéis/grants/catálogo
  migram para o `BaselineSeeder`; o seeder demo passa a conter apenas tenant
  piloto, contas demo (`diretor.demo`, guardiões), vínculos e fórmulas padrão.
- **Falha de baseline é fail-closed** — se o baseline não puder ser aplicado, o
  startup aborta com log explícito (uma API sem permissões não é utilizável).
- **`--seed-demo` fora de Development** — recusa com mensagem clara (dados
  fictícios nunca em staging/produção).

## Impact

- **Specs**: nova capability `environment-seeding`; delta em `achievements`
  (catálogo passa a ser baseline, não demo).
- **Código**: `Program.cs`, `PilotEnvironmentSeeder` (dividido), novo
  `BaselineSeeder`, testes de integração do seed.
- **Operação**: primeiro deploy após a mudança aplica o baseline em
  staging/produção (idempotente). Nenhum dado fictício é criado.

## Fora do escopo

- Migração/backfill de ambientes existentes (o baseline roda no próximo deploy).
- Dados fictícios em produção (nunca — o modo demo fica preso a Development).
- Mover o catálogo de conquistas para migration (continua em seed idempotente).