# Design — Performance da API

## Decisão 1 — Paginação no banco (alunos)

`GetStudentsQuery` hoje devolve `List<Student>`. Novo contrato:

```csharp
public sealed record GetStudentsQuery(int Page, int PageSize, string? Q)
    : IQuery<PagedResult<Student>>;
```

- Handler: `IPagedResult` via `GetPagedAsync(page, pageSize, predicate, orderBy)`
  (já existe em `IRepository<T>`), com `CountAsync` para o total.
- Busca por `q` vira filtro no banco (`EF.Functions.ILike` ou `ToLower().Contains`).
- Controller: remove `PaginationHelper.Paginate` em memória; usa `result.Value`
  (items + total) e mantém os headers `X-Total-Count`/`X-Page`/... (mesmo contrato).
- **Índice**: `IX_Students_TenantId` (migration SchoolContext) — `ListByTenantAsync`
  filtra por `TenantId`; hoje só há PK.

### Alternativa descartada
Manter em memória e só criar o índice: resolve parte, mas o payload cresce com a
escola (1k+ alunos) e a paginação continuaria O(N).

## Decisão 2 — Login em ≤2 consultas

`AuthService.LoginAsync` faz: usuário → roles → permissions → school unit →
token audit (insert) → refresh revoke → refresh add → user update.

- **Leituras**: 1 consulta para usuário + papéis/permissões (join via
  `UserClaimsProvider` em lote — `GetRolesAndPermissionsAsync` já existe; garantir
  que não faça N+1).
- **Escritas**: auditoria + refresh + update permanecem (são 3-4 writes, não leituras).
- Meta: ≤2 **leituras** no caminho do login; o `TokenAuditService` não deve consultar
  permissões novamente.
- Medir com `Stopwatch`/`IMetricsService` (duração do login) para não regredir.

### Alternativa descartada
Cache de claims em memória: risco de permissões desatualizadas após mudança de papel.

## Decisão 3 — Auditoria assíncrona

`AuditLoggingMiddleware` faz `AddAsync` + `SaveChangesAsync` por mutação.

- Canal limitado (`Channel<IAuditLogRepository>` + `BackgroundService`) com
  `BoundedChannel` (capacidade 1000) e `FullMode = Wait` (não descarta auditoria).
- A requisição só enfileira (decoupled); o writer faz `AddAsync` + `SaveChanges`.
- **Fail-open**: falha do writer é logada, nunca derruba a requisição.
- Escopo: manter o `AuditLog` com os mesmos campos (método, path, user, tenant,
  status, duração, requestId).

### Alternativa descartada
Batch de auditoria no fim da requisição: ainda bloqueia; canal é melhor.

## Decisão 4 — Instância Render paga (infra)

O free tier (CPU 0,1) impõe ~0,4 s de overhead por request. Upgrade para o plano
pago (Starter) resolve o baseline. Não é código; tarefa de operação.

## Decisão 5 — Orçamento de bundle

- Medir o build de produção (`main` gzip) e listar os maiores chunks.
- Meta: `main` ≤ **1 MB gzip** (hoje 1,3 MB sem gzip; gzip ~350 KB?).
- Ações: remover dependências não usadas (ex.: Quill/Editor pesado só em telas
  específicas → lazy), verificar `moment` vs `date-fns`, etc.
- Guard: script `scripts/check-bundle-size.sh` (falha se main gzip > 1 MB).

## Riscos

| Risco | Mitigação |
|---|---|
| Paginação quebra contrato (total/items) | Manter headers `X-Total-Count` e formato `PagedResult` |
| Login em lote perde claims | Teste de regressão de permissões (roles/permissions por papel) |
| Canal de auditoria perde eventos | `BoundedChannel` com `FullMode=Wait` + log de falha |
| Downgrade do Render | Custo — decisão do dono |
| Bundle | Orçamento + script; sem mudança funcional |