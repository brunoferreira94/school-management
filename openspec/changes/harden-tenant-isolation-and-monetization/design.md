## Context

Auditoria de 2026-11-20 confirmou, com arquivo:linha, que o isolamento multi-tenant é feito por
`.Where(...)` manual (ex.: `ClassGroupRepository.cs:38`) porque o `AcademicContext` só filtra
tenant em parte das entidades (`AcademicContext.cs:85-88` filtra `LessonPlan`, `TimetableTemplate`,
`TeacherAvailability`, mas `ClassGroup` usa `SchoolUnitId != null`, e `StudentClass`/`Classroom`/
`ClassSchedule` não têm filtro). Em paralelo, `HttpContextTenantProvider.cs:69` e 45 pontos em
serviços/handlers caem em `TenantConstants.DefaultTenantId` quando não há contexto — transformando
"esqueci de setar tenant" em "acessou a escola padrão".

O checkout degrada para `MockPaymentCheckoutService` sempre que `Asaas:ApiKey`/`Stripe:SecretKey`
estão vazios (`GatewayCheckoutRouter`), e não existe enforcement de trial expirado em spec alguma.

Restrições:
- `ClassGroup`/`StudentClass` são gerenciados pelo `AcademicContext` (o `SchoolContext` os ignora,
  `SchoolContext.cs:592`), então o filtro de tenant vai no `AcademicContext`.
- Contas de portal (multi-escola, sem `tenant_id` no JWT) precisam continuar resolvendo tenant por
  header — o fail-closed não pode quebrar o portal legítimo.
- O ambiente `Testing` não roda `TenantResolutionMiddleware` (`TenantResolutionMiddleware.cs:24`),
  então os testes de isolamento precisam exercitar o caminho real.

## Goals / Non-Goals

- Goals:
  - Isolamento de tenant fail-closed e com rede de segurança (query filters) nas entidades acadêmicas.
  - Eliminar o fallback silencioso para `DefaultTenantId` em rotas autenticadas `/api`.
  - Condicionar a degradação para mock a `Development`/`Testing`; produção nunca usa mock.
  - Aplicar trial expirado (entitlement) de forma testável.
  - Endurecer gates de lançamento (CI, compose, README) e unificar sanitização de HTML.
- Non-Goals:
  - Remediação LGPD P0 (erasure de CPF, export, DSR 428) — change separado.
  - Migração dos ~1.100-linhas componentes de UI (dívida de manutenibilidade, não de segurança).
  - Sair do free tier (decisão de negócio/infra, fora de spec de código).

## Decisions

- **Decisão: query filter de tenant nas entidades do `AcademicContext`.**
  Adicionar `HasQueryFilter(e => e.TenantId == _tenantId)` para `ClassGroup`, `StudentClass`,
  `Classroom`, `ClassSchedule` quando `_tenantFilterEnabled`. Onde a entidade não tem `TenantId`
  escalar (ex.: `StudentClass`), avaliar ancorar via navegação ignorada ou adicionar coluna por
  migration do `AcademicContext`.
  - Alternativa considerada: manter `.Where` manual e dobrar testes. Rejeitada — não escala e
    um handler esquecido vaza silenciosamente.

- **Decisão: fail-closed na resolução de tenant.**
  `HttpContextTenantProvider`/serviços passam a **falhar** (ex.: `Result.Fail` / 400/401) quando
  `TenantId == Guid.Empty` em rota autenticada `/api`, em vez de retornar `DefaultTenantId`.
  `DefaultTenantId` só pode ser usado em seed/migration/design-time (nunca em request).
  - Alternativa: manter default e auditar. Rejeitada — o default é a origem do risco de contaminação.

- **Decisão: degradação para mock restrita a env.**
  `GatewayCheckoutRouter` só usa `MockPaymentCheckoutService` quando `env.IsDevelopment() ||
  env.IsEnvironment("Testing")`. Em Production/Staging sem credenciais → erro explícito no
  startup (fail-fast), não checkout silencioso.

- **Decisão: enforcement de entitlement no pipeline.**
  Middleware/handler de subscription avalia `Status`/`TrialEndsAtUtc`; trial expirado sem `Active`
  → respostas de escrita retornam bloqueio (com código dedicado) e leitura sinaliza downgrade.

## Risks / Trade-offs

- **Risco:** query filter novo quebra consultas legítimas que cruzam unidade/ano letivo.
  Mitigação: rodar suíte completa (974 testes) + smoke em staging antes de produção.
- **Risco:** fail-closed quebra integrações E2E/scripts que não setam tenant.
  Mitigação: atualizar harness (GenerateJwt já emite claims) e seeds; adicionar teste de
  "request sem tenant → erro".
- **Risco:** enforcement de entitlement bloqueia tenant legítimo em glitch de webhook.
  Mitigação: enforcement fail-open em incidente? Não — fail-closed com log + alerta; rollback via
  reprocessamento de webhook idempotente.

## Migration Plan

1. Adicionar `HasQueryFilter` no `AcademicContext` e rodar suíte; corrigir queries quebradas.
2. Introduzir modo estrito de tenant atrás de flag (`Tenant:FailClosed`), default `false` em dev,
   `true` em staging; validar 1 semana em staging.
3. Promover `FailClosed=true` em produção após gate verde + smoke.
4. Rollback: desligar a flag (mantém query filters, que são aditivos e seguros).

## Resolved Decisions (ex-Open Questions)

- **`StudentClass` ganha `TenantId` escalar** (migration `AcademicContext`), consistente com
  `ClassGroup`, em vez de ancorar o filtro via navegação. Motivo: filtro escalar é simples,
  indexável e não depende de joins; evita a armadilha de navegação ignorada do `AcademicContext`.
  A migration backfilla `TenantId` a partir da `ClassGroup` âncora antes de tornar a coluna
  obrigatória, e cria índice `(TenantId, ...)`.
- **Trial expirado bloqueia escrita e mantém leitura com aviso.** Operações de escrita retornam
  código dedicado de assinatura expirada; leituras permanecem acessíveis com sinalização de
  downgrade. Motivo: bloqueio total de leitura prende dados do cliente (anti-retention / ruim para
  o usuário), enquanto bloqueio de escrita é o enforcement de pagamento justo e reversível.