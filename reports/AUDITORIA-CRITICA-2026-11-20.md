# Auditoria Crítica — School Management SaaS

> **Data:** 2026-11-20
> **Escopo:** monorepo `school-management` (root + `school-management-api` + `school-management-ui`)
> **Base de código auditada:** worktree principal `/home/bruno/workspace/school-management` (submódulos preenchidos). O worktree `hidden-wizard` tem os submódulos **vazios** (não inicializados) — a auditoria de código foi feita no clone real.
> **Tom:** dureza deliberada, evidência acima de opinião. Cada crítica aponta arquivo:linha.

---

## Sumário executivo (veredito)

**Engenharia: acima da média. Produto: pela metade. Marketing: adiantado em relação à realidade.**

O repositório contém trabalho de engenharia genuinamente bom (offline-sync com runbook, observabilidade, LGPD, 974 testes reais) afogado por três problemas estruturais:

1. **Multi-tenancy não é defense-in-depth** — a tabela mais importante (`ClassGroup`) não tem filtro global de tenant; o isolamento depende de `.Where(...)` manual em repositório. Um `Where` esquecido = vazamento cross-tenant.
2. **O loop de negócio não fecha** — cobrança degrada para mock sem credenciais, sem enforcement de entitlement, sem dunning. Ninguém paga nada.
3. **A fachada mente** — README afirma "completo"/"produção" enquanto `evidence.md` diz "não abrir cadastro" e o dossiê LGPD diz "não deve ser lançado".

---

## 1. Multi-tenancy — o risco nº 1

### 1.1. `ClassGroup` (tabela real) NÃO tem filtro de tenant

`src/SchoolManagement.Infrastructure/AcademicContext.cs:85`

```csharp
modelBuilder.Entity<ClassGroup>().HasQueryFilter(cg => cg.SchoolUnitId != null);
```

Isto **não é** um filtro de tenant — é um filtro de "tem SchoolUnit". Qualquer turma com `SchoolUnitId` preenchido passa, independente do tenant. As demais entidades do `AcademicContext` (`LessonPlan`, `TimetableTemplate`, `TeacherAvailability`) têm filtro real (`x.TenantId == _tenantId`), mas `ClassGroup`, `StudentClass`, `Classroom` e `ClassSchedule` **não**.

A `StudentClass` (matrícula aluno↔turma) sequer aparece com `TenantId` no entity (`grep TenantId src/SchoolManagement.Domain/StudentClass.cs` → vazio).

### 1.2. Isolamento real depende de `.Where` manual

`src/SchoolManagement.Infrastructure/ClassGroupRepository.cs:38`

```csharp
.Where(cg => cg.TenantId == tenantId)
```

O isolamento de turmas vive inteiramente em filtros manuais por repositório. Não há rede de segurança: um novo handler que esqueça o `.Where` vaza dados entre escolas silenciosamente. Em `SchoolContext` há 20 `HasQueryFilter`, mas entidades gerenciadas pelo `AcademicContext` (o dono real de `ClassGroup`/`StudentClass`, conforme `SchoolContext.cs:592`) ficam de fora.

**Achado:** arquitetura de tenancy por convenção, não por construção. Para um SaaS multi-tenant, isso é o calcanhar de Aquiles.

### 1.3. Fallback silencioso para `DefaultTenantId` (45 ocorrências em 38 arquivos)

`src/SchoolManagement/Services/HttpContextTenantProvider.cs:69`

```csharp
return TenantConstants.DefaultTenantId;
```

Quando não há claim nem header, o provider **retorna um tenant padrão** em vez de falhar. Pior: 45 chamadas em serviços/handlers repetem o padrão `tenantContext?.HasTenant == true ? tenantContext.TenantId : TenantConstants.DefaultTenantId` (ex.: `AssignmentService.cs:28`, `ClassroomService.cs:119`, todos os handlers de `AcademicYears`, `NoticeService.cs:34`, `CreateClassGroupHandler.cs:38`).

Efeito: uma requisição sem contexto de tenant **lê e escreve no tenant DEFAULT** em vez de ser rejeitada. Isso transforma "esqueci de setar o tenant" em "acidentalmente acessei a escola padrão". É contaminação cross-tenant por omissão.

`GuardianRequestController.cs:74-76` e `:218-220` (portal, dados de responsáveis/alunos) repetem o fallback.

### 1.4. `TenantResolutionMiddleware` não roda em Testing

`src/SchoolManagement/Middleware/TenantResolutionMiddleware.cs:24`

```csharp
if (_environment.IsEnvironment("Testing") || !context.Request.Path.StartsWithSegments("/api", ...))
```

Bypass em `Testing` é razoável, mas significa que **a suíte de testes não exercita o caminho real de resolução de tenant**. Os testes de isolamento precisam setar tenant manualmente — o que pode mascarar regressões no middleware real.

### 1.5. Fallback determinístico do provider (ponto positivo parcial)

`HttpContextTenantProvider.cs:47-58` — o claim `tenant_id` do token **vence** o header `X-Tenant-Id` para contas com vínculo. Isso impede que um token bound declare outro tenant. Bem pensado. Mas a existência do fallback `DefaultTenantId` (1.3) enfraquece a garantia.

**Recomendação:** (a) adicionar `HasQueryFilter` de tenant em `ClassGroup`/`StudentClass`/`Classroom`/`ClassSchedule` no `AcademicContext`; (b) trocar todos os fallbacks `DefaultTenantId` por **falha explícita** (throw / 400) quando não houver tenant; (c) rodar um teste de integração que exercite o middleware real (fora de `Testing`) contra dois tenants.

---

## 2. Segurança

### 2.1. Cobertura de autorização (bom, com ressalvas)

- 76 de 86 controllers usam `[Authorize]`.
- 9 sem `[Authorize]`: `SupportHealthController`, `TrustStatusController`, `MetricsController`, `HealthController`, `PrometheusController`, `CaptchaController`, `WhatsAppWebhookController`, `CookieConsentController`, `PortalAuthController` — a maioria é legitimately pública (health, métricas, webhook com validação própria, auth). **A auditar:** `MetricsController`/`PrometheusController` expostos sem auth podem vazar métricas de negócio; confirmar se há restrição de rede.
- Políticas granulares (`Permission:classes.read/write`, `students.read`) usadas de forma consistente — ponto forte.

### 2.2. Segredos

`src/SchoolManagement/appsettings.json`:
- JWT dev secret hardcoded (`"change-this-development-secret-key..."`) — aceitável para dev, **inaceitável se vazar para qualquer env**. Confirmar que produção usa user-secrets/variáveis (o `docker-compose.prod.yaml` tem placeholder inválido — ver §6).
- `Asaas:ApiKey = ""`, Twilio `AuthToken = "your-twilio-auth-token"`, SMTP `Password: "secret"` — placeholders. Sem segredo real commitado (bom), mas confirma que **tudo que é integração externa está mockado/desligado**.

### 2.3. XSS na UI

- **Não há `bypassSecurityTrust`** no código (grep = 0). Bom.
- 8 usos de `innerHTML`, mas concentrados em editores rich-text (`announcements`, `documents`, `notices`) e no util `html-sanitize.util.ts`.
- `sanitizeHtml` (util) é whitelist via `DOMParser` + remoção de `on*`/`style` — razoável, mas **custom, não DOMPurify**. Falta: bloquear `javascript:` em `href` (só valida `^https?:|/`); aceita `//evil.com` e `data:` não cobertos; `target`/`rel` não forçam `noopener`.
- **Inconsistência:** `portal-dashboard.component.ts:173-177` reimplementa um `sanitizeHtml` **fraco** (textContent/innerText) em vez de usar o util compartilhado — funciona (é mais restritivo), mas é duplicação que diverge.

**Recomendação:** adotar DOMPurify; unificar os dois sanitizers; forçar `rel="noopener noreferrer"` em links.

### 2.4. Armazenamento de token

- `impersonation.service.ts` guarda auth original em `localStorage` (`ORIGINAL_AUTH_KEY`) — funcionalidade de "impersonar" com token em localStorage é risco de XSS→sequestro. Confirmar que só roda em dev/staging e é removível.
- Vários usos de `localStorage` para auth payload (`portal-analytics.service.ts:180`) — ok se for dado não-sensível; auditar.

---

## 3. Billing / monetização — não fecha

### 3.1. Degradação para mock sem credenciais

`src/SchoolManagement/Services/GatewayCheckoutRouter.cs` — a doc do próprio arquivo: *"Sem credenciais do provider escolhido, degrada para o mock de desenvolvimento."* Com `Asaas:ApiKey=""` (appsettings), **todo checkout cai em `MockPaymentCheckoutService`**, que retorna `Status = "PENDING"` e `CheckoutUrl = "https://demo-payments.local/checkout/..."` (`MockPaymentCheckoutService.cs:34-38`).

Traduzindo: **nenhum pagamento real é processado.** O código de Asaas/Stripe existe e é sério, mas está atrás de uma chave vazia.

### 3.2. Sem enforcement de entitlement

Não há spec/req de "trial expira → suspende", "limite do plano → bloqueia", "falha de pagamento → downgrade". O change `activate-dual-gateway-rollout` está **0/7** e diz literalmente *"nada disso roda em produção ou staging ainda"*. Um `[x]` em change draft não é enforcement.

### 3.3. Provedores mockados além de pagamento

- `MockAiDraftProvider` (IA de avaliações) — sem PII de aluno saindo, o que é bom para LGPD, mas significa que a feature de IA não existe de verdade.
- `FakeSmsProvider`, `FakeEmailProvider` — notificações "multi-canal" do README não enviam nada.

### 3.4. Preços e trial contraditórios

- Spec `subscription-model`: trial **14 dias**. `docs/plans/pricing-page.md`: **"30 dias"**. Preços (R$ 299,90 / R$ 999,90) só em wireframe.

---

## 4. Qualidade de código — API

### 4.1. Métricas objetivas

| Métrica | Valor |
|---|---|
| Arquivos `.cs` (src) | 1.238 |
| Serviços (`*Service.cs`) | 154 |
| Migrations | dezenas (maiores arquivos do repo, ~4.900 linhas cada — normais) |
| TODO/FIXME/HACK em src | **1** (higiene excelente) |
| Raw SQL (`FromSqlRaw`/`ExecuteSqlRaw`) | 3 (baixo — bom) |
| Testes `[Fact]/[Theory]` | **974** em 196 arquivos |
| Skips | 5 |

### 4.2. Pontos fortes

- Quase zero TODO/FIXME — raro e sinal de maturidade.
- CQRS (LiteBus) + Clean Architecture genuínos (4 projetos, dependências apontam Domain←Application←Infrastructure←API).
- 974 testes reais (não triviais) com Testcontainers — a suíte é substancial.
- 3 raw SQL apenas — EF usado corretamente.

### 4.3. Pontos fracos

- **154 services** — superfície grande; risco de lógica duplicada entre services (a实施条例 do tenant fallback repetido 45x é sintoma).
- A arquitetura de tenancy (ver §1) é o débito técnico central.
- `SchoolContext` + `AcademicContext` (dual-context) é fonte recorrente de bugs (o próprio `AGENTS.md` documenta a armadilha `ClassGroup` vs `ClassGroups`) — dívida estrutural não resolvida.

---

## 5. Qualidade de código — UI

### 5.1. Métricas objetivas

| Métrica | Valor |
|---|---|
| Componentes | 157 |
| `.ts` em src | 602 |
| Specs unitários | 99 |
| Cypress E2E | 40+ specs |
| TODO/FIXME | **1** |
| console.log | 7 |
| `ChangeDetectionStrategy.OnPush` | **4 de 157** |

### 5.2. O OnPush é ficção

O README lista *"Performance — OnPush, lazy loading"* como diferencial. Na prática, **só 4 componentes** usam OnPush (`grades`, `reports-hub`, `home`, `zeca-mascot`). 153 componentes usam change detection default. O "diferencial de performance" não existe.

### 5.3. Componentes gigantes

- `report-template-editor.component.ts`: **1.101 linhas**
- `report-generator.component.ts`: 1.100
- `students.component.ts`: 1.070
- `grading-formula-editor.component.ts`: 963

Problema de babysitting: um único editor de template de relatório com 1.100 linhas é maint. nightmare. Faltam decomposição e state management (signals) reais.

### 5.4. Auditoria de design já existente (AUDIT_REPORT.md)

O próprio repo tem um `AUDIT_REPORT.md` (2026-07-10) honesto: score 13/20, P1s de acessibilidade (dark mode quebrado, contraste gray-on-color, sem `prefers-reduced-motion` global), e **"tells sistemáticos de geração assistida"** (side-tab accent 10x, bounce easing 5x). Ou seja, a UI tem cara de "AI slop não revisado" em pontos — documentado por eles mesmos e **não resolvido** (o report é de julho; estamos em novembro).

---

## 6. Operação / deploy

### 6.1. Free tier sustentado por cron

- Render hiberna ~15 min; Supabase pausa ~7 dias. "Alta disponibilidade" = `keep-alive.yml` pingando hora a hora.
- `DEPLOY.md` documenta incidente real: Supabase pausado → API em **crash-loop SIGSEGV/exit 139**, Vercel congelado, **17 de 20 deploys `update_failed`**.
- Auto-deploy **desligado**; deploy manual via script com chave no `.env`.
- Job "Deploy" da CI **constrói imagens Docker que nunca são empurradas** — teatro.
- `quality-informational`: `continue-on-error: true` + `npm audit || true` — checagem de segurança decorativa.

### 6.2. `docker-compose.prod.yaml` quebrado

- `ASAAS_API_KEY = production Asaas API key (use .NET user-secrets)` — **sintaxe inválida** (espaços no `=`) + placeholder literal como valor. Se rodar como está, a API recebe chave-lixo.
- Postgres exposto em `5432:5432` em todas as interfaces, sem limites de recurso.

---

## 7. Governança de OpenSpec (resumo)

- 61 changes arquivados (83% completo), mas **nenhum jamais saiu de `draft`**.
- Fluxo "aprovar antes de implementar" (escrito no `openspec/AGENTS.md`) **sistematicamente ignorado**.
- 3 de 8 changes ativos apodrecendo (1 com 0/7, parado há 4 meses).
- **CI não roda `openspec validate`**; `validate_openspec.sh` imprime `OK (sem frontmatter)` e não valida nada.
- Specs mentem: `payment-gateways/spec.md` cita "Stripe e Pagar.me" — Pagar.me não existe no código.
- Specs cobrem os ~30% novos; núcleo (students, grades, auth, billing) não tem spec.

---

## 8. Conformidade LGPD

- Dossiê honesto: `docs/legal/lgpd-compliance-audit.md` diz **"o sistema não deve ser lançado"** (§1).
- Menores (Art. 14): consentimento parental **implementado** em 31/10 (`GuardianConsent`, `POST /api/privacy/guardian-consent`, gating) — ponto forte real.
- Pendências P0: erasure não remove CPF; export incompleto; DSR bloqueado por 428; DPAs (Render/Supabase/Auth0/Asaas) pendentes.
- Dado sensível `Student.ColorRace` (origem racial) sem tratamento diferenciado completo.

---

## 9. Plano de ação priorizado

| # | Ação | Por quê | Onde |
|---|---|---|---|
| 1 | `HasQueryFilter` de tenant em `ClassGroup`/`StudentClass`/`Classroom`/`ClassSchedule` | fechar o buraco nº 1 de vazamento | `AcademicContext.cs:85` |
| 2 | Trocar todos os fallbacks `DefaultTenantId` por falha explícita | eliminar contaminação por omissão | 45 pontos (38 arquivos) |
| 3 | Teste de integração do middleware real (fora de `Testing`) com 2 tenants | provar isolamento ponta-a-ponta | `tests/` |
| 4 | Ativar Asaas real + 1 charge sandbox→produção + webhook idempotente | sem isso não há SaaS | `GatewayCheckoutRouter` / `AsaasOptions` |
| 5 | Enforcement de entitlement (trial expira → bloqueia) + spec | fechar o loop de negócio | novo change OpenSpec |
| 6 | Corrigir README (remover ✅ não entregues, criar LICENSE ou remover badge, remover métrica 614ms) | credibilidade | `README.md`, `docs/pilot-feedback.md` |
| 7 | Resolver LGPD P0 (erasure CPF, export, DSR 428) | risco jurídico com dados de menores | change de remediação |
| 8 | `openspec validate --strict` na CI + status real | governança | `.github/workflows/ci-cd.yml` |
| 9 | Sair do free tier cron-based antes do 1º cliente | SIGSEGV em produção = fim | Render/Supabase |
| 10 | Adicionar OnPush nos componentes pesados; decompor os de 1.000+ linhas | perf real + manutenibilidade | `report-builder/`, `students.component.ts` |
| 11 | DOMPurify + unificar sanitizers + `rel=noopener` | XSS | `html-sanitize.util.ts`, `portal-dashboard` |

---

## 10. O que é genuinamente bom (justiça)

1. **`api-offline-sync-contract`** (33/38): idempotência HMAC+TTL, ETag/If-Match, sync-batch, runbook de rollout 7 dias, métricas Prometheus, harness de 5 clientes × 10k ops/dia. Melhor que muito time financiado.
2. **974 testes reais** com Testcontainers + Cypress com JWT gerado contra API real.
3. **974 testes, 1 TODO** — higiene de código rara.
4. **LGPD**: consentimento parental implementado de verdade; dossiê honesto; erasure/export com cenários.
5. **Autorização granular** consistente (`Permission:*`) em 76/86 controllers.
6. **`archive/abandoned/`** honesto sobre fracassos.
7. **Offline/PWA** com service worker standalone e fila de sync — engenharia de ponta.
8. **Identity**: claim `tenant_id` vence header (impede token bound de trocar de tenant).

---

## Nota final

Este não é um projeto ruim. É um projeto **com craft de engenharia real, engolido por três falhas estruturais**: tenancy por convenção (não por construção), loop de negócio aberto, e marketing adiantado em relação à realidade. As três são resolvíveis e estão mapeadas acima com arquivo:linha. A verdade mais dura continua válida: **o próprio repositório, nos docs de LGPD e launch-readiness, já diz que não está pronto — e está certo.**