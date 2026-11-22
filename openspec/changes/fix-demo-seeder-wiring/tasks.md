# Tasks — Corrigir o Seeding de Ambiente

## 1. Baseline (plataforma)

- [x] 1.1 Criar `IBaselineSeeder` (Domain) + `BaselineSeeder` (Infrastructure/Seeding) com `SeedAsync(SchoolContext, ILogger, CancellationToken)`
- [x] 1.2 Mover de `PilotEnvironmentSeeder` para o baseline: lista de `Permissions`, `Roles` (Director/Coordinator/Teacher/Parent) e vínculos `RolePermissions` (diretor = tudo exceto platform-only; coordenador/professor = subconjunto)
- [x] 1.3 Mover o catálogo de conquistas v1 (12 itens) para o baseline (upsert por `Key`)
- [x] 1.4 `PilotEnvironmentSeeder` passa a conter só dados fictícios (tenant piloto, contas demo, guardiões, fórmulas) e falha com mensagem clara se os papéis não existirem
- [x] 1.5 Registrar `IBaselineSeeder` no DI (`RepositoryAndInfrastructureRegistration`)

## 2. Wiring no `Program.cs`

- [x] 2.1 Restaurar o bloco `if (seedDemoData)` removido em `1fce807` (que estava órfão) **antes** de `app.Run()`
- [x] 2.2 Rodar o baseline em todo ambiente não-Testing, após as migrations e antes do primeiro request
- [x] 2.3 `--seed-demo` fora de `Development` → falha com mensagem explícita (nunca criar dados fictícios em staging/produção)
- [x] 2.4 `--seed-demo` encerra o processo (exit 0) antes dos hosted services/Kestrel
- [x] 2.5 Falha do baseline aborta o startup com log `Baseline seeding failed` (fail-closed)

## 3. Testes

- [x] 3.1 `BaselineSeederIntegrationTests`: banco vazio → 38 permissões, 4 papéis, grants esperados (Director com `achievements.manage`; Coordinator/Teacher com `achievements.read`; Teacher sem `manage`), 12 conquistas
- [x] 3.2 `BaselineSeederIntegrationTests`: idempotência (rodar 2× não duplica permissões/grants/conquistas)
- [x] 3.3 `SeedDemoGuardTests` (política: Development passa; Staging/Production/Testing falham) + `DemoDataSeederIntegrationTests` (cria tenant piloto + `diretor.demo` com vínculo Director; idempotente). Encerramento com exit 0 e recusa em Staging verificados manualmente com o processo real
- [x] 3.4 Regressão: `AchievementsIntegrationTests`, `AchievementsDisabledIntegrationTests` e E2E `achievements-live.cy.ts` verdes

## 4. Documentação

- [x] 4.1 Atualizar `docs/runbooks/achievements-rollout.md` (o baseline roda no deploy — remover o passo manual de SQL)
- [x] 4.2 Atualizar `school-management-api/AGENTS.md` e `docs/how-to.md` (se existir) com `--seed-demo` restaurado e a diferença baseline × demo
- [x] 4.3 Atualizar `docs/INDEX.md` se houver novo documento

## 5. Critérios de aceite

- [x] 5.1 Banco novo sobe com permissões, papéis e catálogo sem nenhum comando manual
- [x] 5.2 `--seed-demo` funciona em Development (cria demo + encerra com exit 0)
- [x] 5.3 `--seed-demo` em Produção/Staging falha antes de criar qualquer dado
- [x] 5.4 Baseline é idempotente (redeploy não duplica nem remove)
- [x] 5.5 Suíte API verde + Karma verde