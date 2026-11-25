# Proposta: Melhorar a Performance da API e do Bundle

## Why

Medições reais (staging/produção, 25/11) mostram latências incompatíveis com
produto B2B:

| Endpoint | Latência |
|---|---|
| `GET /api/students` | **1,07 s** |
| `POST /api/auth/login` | **0,5–1,6 s** |
| `GET /api/me/achievements` | 0,62 s |
| `GET /api/achievements/team` | 0,68 s |
| Overhead base por request (free tier) | ~0,4 s |

Gargalos comprovados no código:

1. `StudentsController.ListStudents` carrega **todos** os alunos
   (`GetStudentsQuery` → `List<Student>`) e pagina **em memória** — O(N).
   `Students` não tem índice em `TenantId`.
2. `AuthService.LoginAsync` faz **6–8 consultas sequenciais** + PBKDF2.
3. `AuditLoggingMiddleware` faz `SaveChangesAsync` **por requisição mutante**
   (write síncrono no caminho crítico).
6. Bundle de produção **4,6 MB** (main 1,3 MB) — sem orçamento definido.
8. Free tier (Render CPU 0,1) impõe overhead base — resolvido por instância paga.

## What Changes

- **Paginação no banco** para a lista de alunos (query + controller) e índice
  `Students.TenantId` (migration SchoolContext).
- **Login em ≤2 consultas** (usuário + claims em lote), mantendo auditoria/refresh.
- **Auditoria assíncrona** (canal limitado, fail-open) — a requisição não espera
  o `SaveChanges` do log.
- **Orçamento de bundle** (main ≤ 1 MB gzip) + auditoria das dependências pesadas.
- **Instância Render paga** (tarefa de infra, não código) para eliminar o
  overhead de CPU do free tier.

## Impact

- **API**: `StudentsController`, `GetStudentsQuery`/handler, `StudentRepository`
  (paginação), `AuthService`, `TokenAuditService`/`AuditLoggingMiddleware`,
  migration `StudentsTenantIdIndex`.
- **UI**: auditoria de bundle (sem mudança funcional).
- **Infra**: upgrade do plano Render (custo).
- **Testes**: paginação (page/pageSize/total), login (claims corretos), auditoria
  (não bloqueia; eventual consistência).

## Fora do escopo

- Cache distribuído (Redis) e réplicas de leitura.
- Microserviços ou CQRS distribuído.
- Reescrita do modelo de auditoria (só torná-la assíncrona).
- Otimização de todas as telas (foco nos 2 gargalos medidos + bundle).