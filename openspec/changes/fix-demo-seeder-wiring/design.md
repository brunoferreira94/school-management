# Design — Seeding de Ambiente

## Contexto

Hoje o `PilotEnvironmentSeeder` faz duas coisas distintas:

| Bloco | Natureza | Onde |
|---|---|---|
| Permissões + Papéis + `RolePermissions` | **Plataforma** (global, sem tenant) | linhas ~20–230 |
| Catálogo de conquistas v1 | **Plataforma** (global) | linhas ~317–341 |
| Tenant piloto, contas demo, guardiões, fórmulas | **Demo** (dados fictícios) | linhas ~69–120, 189–228, 231–343 |

O seed só é chamado via `IDemoDataSeeder`, que por sua vez só era chamado no
bloco `if (seedDemoData)` — removido em `1fce807`. Logo, **nada** roda.

## Decisão 1 — Separar baseline de demo

**BaselineSeeder** (novo, `Infrastructure/Seeding/BaselineSeeder.cs`):

```
SeedAsync(SchoolContext, ILogger, CancellationToken)
  1. Permissions          — upsert por Name (não duplica; atualiza Description)
  2. Roles                — upsert por Name (Director/Coordinator/Teacher/Parent)
  3. RolePermissions      — INSERT ... ON CONFLICT DO NOTHING por (RoleId, PermissionId)
  4. Achievement catalog  — upsert por Key (12 itens)
  SaveChanges + commit
```

**PilotEnvironmentSeeder** (remanescente): tenant piloto, contas demo, vínculos
e fórmulas padrão. Requer o baseline já aplicado (papéis existem).

### Por que não manter tudo no `PilotEnvironmentSeeder`

O acoplamento é a causa raiz: sem o modo demo, não há plataforma. Separar deixa
o baseline independente de qualquer dado fictício e permite que staging/produção
rodem o baseline sem risco de criar `diretor.demo`.

### Alternativa descartada — "rodar o seeder demo sempre"

Criaria tenant, usuários e fórmulas fictícias em produção. Inviável.

## Decisão 2 — Onde chamar o baseline

No `Program.cs`, logo após `Database.MigrateAsync` (School + Academic) e antes
do `EnsureDefaultTenantAsync`, dentro de um `scope` próprio:

```csharp
if (!app.Environment.IsEnvironment("Testing"))
{
    using var scope = app.Services.CreateScope();
    var seeder = scope.ServiceProvider.GetRequiredService<IBaselineSeeder>();
    await seeder.SeedAsync(scope.ServiceProvider.GetRequiredService<SchoolContext>(), ...);
}
```

- **Testing**: o `TestWebApplicationFactory` semeia o próprio banco por
  `PrepareDatabase`; rodar o baseline aqui seria lento e redundante (as specs
  criam tenants/catálogos próprios).
- **Ordem**: depois das migrations (as tabelas precisam existir) e antes de
  qualquer request (as permissões precisam existir no primeiro login).

## Decisão 3 — Fail-closed no baseline

`SeedAsync` propaga exceções; o `Program.cs` deixa o startup falhar com log
`Baseline seeding failed`. Motivo: uma API que sobe sem permissões/new roles
devolve 403 para tudo e mascara o problema. Se o banco estiver saudável, o
baseline é idempotente e não falha.

## Decisão 4 — `--seed-demo` restaurado e protegido

```csharp
if (seedDemoData)
{
    if (!app.Environment.IsDevelopment())
        throw new InvalidOperationException("--seed-demo é exclusivo de Development.");

    using var scope = app.Services.CreateScope();
    var logger = ...;
    await new BaselineSeeder(...).SeedAsync(context, logger, ct);
    await new DemoDataSeeder(...).SeedAsync(ct);   // Frontend + Pilot
    logger.LogInformation("Seed demo concluído.");
    return;   // encerra antes de MapXxx/app.Run()
}
```

- `return` no `Program.cs` (top-level statements) encerra o processo sem subir
  os hosted services nem o Kestrel.
- A ordem baseline → demo é obrigatória (o seeder demo usa os papéis).

## Riscos

| Risco | Mitigação |
|---|---|
| Baseline lento em startup (centenas de `Any()`) | idempotente e pequeno (38 permissões, 4 papéis, ~60 grants, 12 conquistas) — milissegundos |
| Condição de corrida com múltiplas instâncias | `ON CONFLICT DO NOTHING` + transação; duplicatas são no-op |
| Ambiente sem `Roles` (banco legado) | o baseline cria os papéis que faltam |
| `--seed-demo` em produção | recusa explícita com `InvalidOperationException` |

## Descoberta durante a implementação

`FrontendDemoDataSeeder` cria `diretor.demo` **antes** do `PilotEnvironmentSeeder`
e sem vínculo com staff. Como o pilot seeder só criava o vínculo quando a conta
não existia, em banco novo o diretor ficava **sem papel Director** — logo, sem
nenhuma permissão no login (o E2E só passava porque o banco de dev havia sido
semeado antes dessa ordem). O pilot seeder agora faz **backfill** do vínculo
(cria `Staff` + `StaffRole` quando `StaffId` é nulo).

## Testes

- **Integração** (`BaselineSeederIntegrationTests`): banco vazio → baseline cria
  38 permissões, 4 papéis, grants esperados (Director tem `achievements.manage`;
  Coordinator/Teacher têm `achievements.read`; Teacher **não** tem
  `achievements.manage`) e 12 conquistas; rodar 2× não duplica nada.
- **Integração** (`SeedDemoFlagTests`): `--seed-demo` fora de Development falha;
  em Development cria o tenant piloto e `diretor.demo` (com senha hasheada) e
  encerra sem subir o host.
- **Regressão**: `AchievementsIntegrationTests` e o E2E
  `achievements-live.cy.ts` continuam verdes.