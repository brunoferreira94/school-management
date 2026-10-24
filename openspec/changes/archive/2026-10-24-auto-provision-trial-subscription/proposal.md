# Provisionar assinatura trial no momento da criação do tenant

## Why

Hoje o tenant só existe (seed default ou portal) mas **não recebe assinatura** até o checkout.
Isso invalida o requisito "nova escola começa no plano Free/trial" — hoje um tenant sem assinatura
ativa vê o sistema bloqueado, não o dashboard. A criação da assinatura trial precisa estar amarrada
à criação do tenant (seed e signup), não ao checkout.

## What Changes

- `TenantProvisioningService` (e a seed do `Program.cs`) criam um `TenantSubscription` com
  `Status = Trial` e `TrialEndsAtUtc = +14 dias` sempre que criam um tenant.
- `GET /api/subscriptions/tenant` devolve `Status = Trial`, `Plan = Free` para esses tenants
  (já usado pela UI; garante consistência).
- A assinatura trial é cancelada/expirada automaticamente quando o trial acaba se não houver
  pagamento (job já existente — validar).

## Impact

- Nenhum BREAKING
- Specs: `subscription-model` (MODIFIED: trial provisioning)
- API: `SetupProgressRepository` não afetado; `SubscriptionPlanSeeder` garante plano `Free`

## Observação

Este change é o **half** da `self-service-school-registration` item 2 — se separa para servir
também do seed default do `Program.cs` e de eventuais provisionamentos internos futuros.
