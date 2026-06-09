# Design — Add Academic Year Aggregate

## Context

Atualmente cursos, turmas, planos financeiros, agendas e avaliações não possuem um identificador explícito de ano letivo. O escopo temporal é inferido por datas ou por duplicação manual de registros. Isso impede funcionalidades planejadas como cópia automatizada de ano letivo, relatórios comparativos entre anos e políticas de arquivamento consistentes.

## Goals / Non-Goals

- **Goals:**
  - Introduzir a entidade `AcademicYear` com ciclo de vida completo (criação, ativação, encerramento) por tenant.
  - Garantir que entidades de contexto anual referenciem explicitamente o ano letivo.
  - Fornecer APIs e componentes para seleção e filtro pelo ano vigente.
  - Facilitar migração de dados históricos com mínima indisponibilidade.
- **Non-Goals:**
  - Reescrever o mecanismo de calendário escolar (continua usando timetables existentes).
  - Automatizar políticas fiscais ou integração financeira por ano (tratado em mudanças futuras).

## Decisions

- **Aggregate root:** `AcademicYear` conterá atributos `tenantId`, `name`, `slug`, `startsOn`, `endsOn`, `status` (Draft/Active/Archived) e metadados de bloqueio.
- **Referential integrity:** Tabelas `Courses`, `ClassGroups`, `Plans`, `Timetables`, `Assessments`, `Events`, `Notice`, `LessonPlans` e outras entidades anuais receberão coluna `AcademicYearId` not-null (com default temporário durante migração).
- **Tenant scoping:** filtros multi-tenant existentes serão expandidos para incluir o join com `AcademicYear` quando necessário; a seleção padrão virá de contexto (header `X-Academic-Year` ou sessão).
- **API surface:** novo controller `AcademicYearsController` expõe CRUD; endpoints atuais exigem parâmetro/cabeçalho de ano ou derivam do payload.
- **Migration strategy:** criar ano "Histórico" por tenant para dados antigos, depois fornecer ferramenta interativa para reatribuição.

## Risks / Trade-offs

- **Migração complexa:** dados volumosos podem exigir migração por lotes e janela de manutenção.
- **Quebra de compatibilidade:** clientes existentes precisarão enviar `academicYearId`; será necessário período de tolerância com fallback.
- **Desempenho:** novos joins podem impactar queries pesadas; revisar índices (`AcademicYearId`, `TenantId`).

## Migration Plan

1. Deploy migrations com colunas nullable e tabela `AcademicYears`.
2. Popular ano padrão por tenant e atualizar registros existentes.
3. Executar job para tornar colunas not-null após saneamento.
4. Atualizar serviços/API para exigir o campo e remover fallback.
5. Comunicar clientes/frontend durante o rollout.

## Open Questions

- Quais entidades adicionais (ex.: financeiros, communications) também devem referenciar ano letivo?
- Será necessário permitir múltiplos anos ativos simultaneamente?
- Como lidar com calendários que atravessam dois anos civis (ex.: 2025/2026)?
