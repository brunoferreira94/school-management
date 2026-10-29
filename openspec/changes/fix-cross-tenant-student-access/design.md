# Design — fix-cross-tenant-student-access

## Context

`Student` é global por design (chave CPF; um mesmo aluno pode ter plano em unidade de outro tenant —
enunciado do doc de multitenancy). A proteção live **existe** para as entidades ligadas via
`SchoolContext.OnModelCreating` (`SchoolContext.cs:162-181`), e `StudentRepository.ListByTenantAsync`
é o padrão canônico de listagem por vínculo (`StudentPlan → SchoolUnit → TenantId`) — a superfície
por `{cpf}` apenas nunca aderiu ao padrão.

## Goals / Non-Goals

- **Goal**: toda rota exponha dados de aluno **apenas** com Vínculo (plano→unidade→tenant) resolvido
  no tenant do token; 404 quando ausente (não vaza existência).
- **Non-goal**: mudar o modelo de Student (coluna TenantId) — violaria o design global (mesma pessoa
  matriculada em escolas distintas) e tocaria schema/seeds.
- **Non-goal**: portais de responsável (rotas `/api/portal/**` têm escopo próprio).

## Decisions

- **Decisão — vínculo canônico = StudentPlan (via SchoolUnit.TenantId), igual a `ListByTenantAsync`**:
  single source of truth; classes/planos de turma continuam fora da leitura por CPF como já está
  documentado para listagens.
  - Alternativa considerada: "plano OU turma (StudentClass/ClassGroups)". Rejeitada por agora: cruza
    bounded contexts na consulta de repos (School + Academic), duplicando o padrão canônico doc'd e
    alterando a previsibilidade da listagem; pode entrar como follow-up se produto insistir.
- **Decisão — gate no service, não no controller**: `StudentService.GetStudentByCpfAsync(cpf,
  tenantId)` (variante) e `ListByTenantAsync` são os pontos únicos; controllers seguem finos.
  - Alternativa: gate no BaseRepository. Rejeitada — afetaria também os seeds/queries internas que
    o design preserva (não-expostas).
- **Decisão — alunos sem vínculo (recém-criados): 404 por CPF** (nem o tenant criador os lê por CPF
  até o vínculo) — EXATAMENTE igual à listagem atual (invisíveis até o plano). Fluxo real já cria o
  plano junto/atrás; pós-CREATE a tela usa a listagem.
- **404 (não 403)** nos ataques: não vazar existência de recurso de outro tenant.

## Risks / Trade-offs

- **Risco**: alguma chamada interna LEGÍTIMA ao `GetByCpfAsync` global que dependa de aluno sem
  vínculo (ex.: fluxos de importação/consenso). → Mitigação: grepping de todas as usages antes de
  implementar; as rotas HTTP todas passam pelo gate; usos internos explícitos permanecem na variante
  global com justificativa no código.
- **Risco**: UI com alunos "só em turma" sem plano perde a edição por CPF → comportamento já
  documentado (não aparecem na listagem); segue consistente.
- **Risco**: bulk/import (routes com `bulk-*`/import) — fora do corte inicial; usam validação por
  turma/ClassGroup filtrada (AcademicContext) — revisar no TODO follow-up se aparecer leitura
  cross-tenant nos testes.

## Migration Plan

Sem migration de schema. Rollback = reverter as mudanças de repos/service (sem efeito em dados).

## Open Questions

- Guardian `by-cpf` global está EXPLICITAMENTE por design (responsável multi-escolas) — confirmar
  com produto se o lookup administrativo aceita exposição global de PII ou se deve pedir vínculo
  (matrícula de algum filho no tenant).
- Alunos "só em turma" — produto quer o BY-CPF também por vínculo de turma (follow-up cross-context)?
