# Design — fix-register-school-provisioning

## Context

Descobertas empíricas (24–28/10/2026):

1. **Register-school (`OnboardingController`, linhas 135–157)** cria `Tenant`, `SchoolUnit`,
   `UserAccount` (Username = e-mail), `Staff` (Expertise = "Direção"), `Account.StaffId` —
   mas **nunca cria `StaffRole`** → o provider de claims (`UserClaimsProvider`) volta vazio
   (`permissions: []`, `roles: []`) e o diretor não passa de nenhum `[Authorize(Policy = "Permission:…")]`.
2. **`AuthService.LoginAsync` emite o claim `school_unit_id` estático** — `_demoDefaults.SchoolUnitId`
   (`appsettings.json`: `00000000-0000-0000-0000-000000009101`) — para qualquer conta;
   **o JWT nunca carrega `tenant_id`**.
3. **Resolução de tenant por request (`HttpContextTenantProvider`)**: `Items` → header
   `X-Tenant-Id` → claim `tenant_id` → **fallback `TenantConstants.DefaultTenantId` (aaaa)**.
   Permissões do JWT são globais (strings): token válido + header falsificado = leitura do
   tenant alvo. Evidência: ataques IDOR do `tenant-isolation.cy.ts` (24/10) — hoje o que
   bloqueou foram comparações pontuais em handlers (ex.: subscriptions 403), não um modelo coerente.
4. **`Roles`/`RolePermissions`/`Permission` são GLOBAIS** (sem TenantId) — diretor.demo →
   role "Director" → 32 permissões. O sistema de autorização já reflete o tenant pelo
   *contexto* (query filter + `LoginByTenantAsync`), não pelo papel.

## Goals / Non-Goals

- Goals: diretor novo **funciona no primeiro login**; tenant do token **determinístico e
  à prova de spoofing** para contas bound; zero regressão para demo/portal/legado.
- Non-Goals: roles tenant-scoped; mudança de permissões globais; binding de contas de
  portal (`StudentCpf` — multi-escolas por design); selector de unidade para multi-unidade.

## Decisions

- **D1 — Reuso da role global "Director"**: `StaffRole` aponta para a role global idêntica
  à do piloto (32 perms). Alternativa (roles por tenant) rejeitada — gateway de autorização
  já usa permissões claim-based + contexto de tenant; duplicar papéis por tenant cria dois
  lugares de verdade.
- **D2 — Binding na `UserAccount` (coluna nova `TenantId Guid?`)**: o registro é o lugar
  determinístico; contas antigas/demos sem binding caem no fallback atual. Alternativa
  (binding via `Staff`) rejeitada — `Staff`/`StaffRoles` são globais e não têm TenantId,
  backfill não é confiável para contas existentes.
- **D3 — Claim vence header APENAS quando existe**: middleware respeita `tenant_id` claim
  de requests autenticadas; sem claim a ordem atual permanece (portal multi-escola segue
  via header). TokenService emite `tenant_id` nunca quando `TenantId` null → portal não
  emite claim → comportamento preservado.
- **D4 — `school_unit_id` real quando bound**: primeira unidade ativa do tenant
  (o register cria exatamente uma). Contas não-bound mantêm o fallback `DemoDefaults`
  (o diretor.demo continua com o claim da unidade demo como hoje).

## Risks / Trade-offs

- Portal (`StudentCpf` sem binding) continua vulnerável a declaração de header por token
  roubado → conhecido, segue para binding próprio em follow-up (não bloqueia o lançamento;
  dados de responsáveis são escopados por `student_cpf` claim nos handlers de portal).
- Contas bound ficam "amarradas" ao tenant gravado — trocar de escola exige fluxo próprio
  (provavelmente lesgeto multi-staff). Implícito hoje: nenhuma conta bound existe fora do register.
- Migration toca `UserAccounts` (coluna novas adicionais, sem filtro/sem default) — aditiva.

## Migration Plan

1. Migration SchoolContext: `ALTER TABLE "UserAccounts" ADD COLUMN "TenantId" uuid NULL`.
2. Seeder backfill idempotente para contas demo (base nos nomes/roles conhecidos).
3. Deploy: código + migration aplicada no staging via `dotnet ef database update` a partir
   da máquina local (padrão usado desde o seed do staging) — não há runtime que aplique
   migrations no start (Program.cs não chama `Migrate()`).

## Open Questions

- **Unidade principal** do tenant quando >1 unidade: primeira ativa por CreatedAt? (hoje o
  register cria uma; documentar como regra de provisionamento).
