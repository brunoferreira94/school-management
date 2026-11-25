# Tasks — Melhorar a Performance da API

## 1. Paginação no banco (alunos)

- [ ] 1.1 `GetStudentsQuery` passa a receber `Page`/`PageSize`/`Q` e devolver `PagedResult<Student>`
- [ ] 1.2 Handler usa `GetPagedAsync` + `CountAsync` (filtro `q` no banco, `TenantId` escopado)
- [ ] 1.3 `StudentsController.ListStudents` remove `PaginationHelper.Paginate` em memória e mantém os headers `X-Total-Count`/`X-Page`/`X-Page-Size`/`X-Total-Pages`
- [ ] 1.4 Migration `StudentsTenantIdIndex` (SchoolContext) + `dotnet ef database update`
- [ ] 1.5 Testes: paginação (page 2, pageSize 10, total), busca `q`, isolamento por tenant

## 2. Login em ≤2 leituras

- [ ] 2.1 `UserClaimsProvider.GetRolesAndPermissionsAsync` em 1 consulta (join usuário→papéis→permissões), sem N+1
- [ ] 2.2 `AuthService.LoginAsync` não repete leitura de claims (usar o resultado do provider)
- [ ] 2.3 Medir duração do login (Stopwatch + log) e adicionar teste de regressão de claims
- [ ] 2.4 Testes: login retorna roles/permissions corretos; ≤2 leituras (contador no provider mock)

## 3. Auditoria assíncrona

- [ ] 3.1 `IAuditLogWriter` + `ChannelAuditLogWriter` (BoundedChannel 1000, FullMode=Wait)
- [ ] 3.2 `BackgroundService` que consome o canal e faz `AddAsync` + `SaveChangesAsync`
- [ ] 3.3 `AuditLoggingMiddleware` enfileira (não salva); falha do writer é logada (fail-open)
- [ ] 3.4 Testes: mutação não espera o save (writer mock); evento é persistido eventualmente

## 4. Bundle

- [ ] 4.1 Medir `main` gzip do build de produção e listar os maiores chunks
- [ ] 4.2 Remover/adiar dependências pesadas não usadas no boot (lazy)
- [ ] 4.3 `scripts/check-bundle-size.sh` (falha se main gzip > 1 MB)
- [ ] 4.4 Atualizar `school-management-ui/AGENTS.md` com o orçamento

## 5. Infra (adiado — free tier mantido)

- [ ] 5.1 ~~Upgrade do Render para plano pago~~ — **adiado por decisão do dono (25/11)**; manter free tier
- [ ] 5.2 Medir latência antes/depois dos ajustes 1–3 (mesmos endpoints) e registrar no progresso

## 6. Critérios de aceite

- [ ] 6.1 `GET /api/students?page=1&pageSize=20` executa 1 query paginada (sem carregar tudo)
- [ ] 6.2 Login com ≤2 leituras e mesmas permissões de antes
- [ ] 6.3 Mutação não bloqueia no `SaveChanges` de auditoria
- [ ] 6.4 `main` gzip ≤ 1 MB (script verde)
- [ ] 6.5 Suíte API verde + Karma verde; latência medida no progresso