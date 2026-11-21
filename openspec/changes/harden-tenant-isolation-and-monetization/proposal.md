## Why

A auditoria crítica de 2026-11-20 (`reports/AUDITORIA-CRITICA-2026-11-20.md`) identificou três
falhas estruturais que impedem o produto de ser multi-tenant seguro e de fechar o loop de negócio:

1. **Isolamento de tenant por convenção, não por construção** — `ClassGroup`, `StudentClass`,
   `Classroom` e `ClassSchedule` não têm filtro global de tenant; o isolamento depende de `.Where`
   manual em repositório, e 45 pontos caem silenciosamente em `TenantConstants.DefaultTenantId`.
2. **Loop de monetização aberto** — sem credenciais, todo checkout degrada para
   `MockPaymentCheckoutService`; não há enforcement de entitlement (trial expira → nada acontece).
3. **Configuração de produção frágil** — `docker-compose.prod.yaml` tem sintaxe de env inválida,
   CI não valida OpenSpec, e a fachada (README) promete mais do que o sistema entrega.

Este change torna o isolamento de tenant **fail-closed**, adiciona **entitlement enforcement**
(empty states de trial expirado) e endurece os **gates de lançamento**.

## What Changes

- **BREAKING** — Resolução de tenant passa a ser *fail-closed*: ausência de tenant resolvido em
  rota `/api` autenticada retorna erro explícito, nunca fallback para `DefaultTenantId`.
- **BREAKING** — Entidades do `AcademicContext` (`ClassGroup`, `StudentClass`, `Classroom`,
  `ClassSchedule`) passam a ter `HasQueryFilter` de tenant no `OnModelCreating`.
- Checkout em **produção/staging** nunca degrada para `MockPaymentCheckoutService`; a degradação
  para mock fica restrita a `Development`/`Testing`.
- Trial expirado (`TrialEndsAtUtc` no passado e sem assinatura `Active`) passa a ser aplicado:
  o sistema bloqueia escrita/avanço de plano e sinaliza downgrade, com enforcement testável.
- CI passa a executar `openspec validate --strict` como gate bloqueante.
- `docker-compose.prod.yaml` corrigido (sintaxe de env válida, sem placeholder como valor).
- README deixa de afirmar ✅ em capacidades não entregues; métrica de "TTV 614ms" removida ou
  reescrita como latência de API (não time-to-value).
- Sanitização de HTML unificada (DOMPurify ou util compartilhado) e `rel="noopener noreferrer"`
  forçado em links de conteúdo rico.

## Impact

- Affected specs: `security`, `tenant-management`, `subscription-model`, `checkout-gateway`
- Affected code:
  - `src/SchoolManagement.Infrastructure/AcademicContext.cs` (query filters)
  - `src/SchoolManagement/Services/HttpContextTenantProvider.cs` + 38 arquivos com fallback `DefaultTenantId`
  - `src/SchoolManagement/Services/GatewayCheckoutRouter.cs` (degradação condicionada a env)
  - novo enforcement de entitlement no pipeline de requisição / `SubscriptionService`
  - `.github/workflows/ci-cd.yml` (gate `openspec validate`)
  - `docker-compose.prod.yaml`, `README.md`, `docs/pilot-feedback.md`
  - UI: `src/app/utils/html-sanitize.util.ts`, componentes com `innerHTML`
- Non-goals: fechar todas as pendências LGPD P0 (erasure/export/DSR) — tratadas no change de
  remediação LGPD existente; este change não substitui aquele.