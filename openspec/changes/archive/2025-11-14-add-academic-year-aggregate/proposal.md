# Add Academic Year Aggregate

Autor: _a definir_
Data: 2025-11-11
Status: draft

## Why

- Hoje não existe uma entidade de ano letivo; cursos, turmas, planos e calendários ficam implicitamente vinculados apenas por datas ou unidades escolares, dificultando cópia, relatórios e governança multi-tenant.
- As iniciativas planejadas (cópia de ano letivo, duplicação de turmas/cursos, relatórios temporais) dependem de um identificador consistente de ano para garantir escopo e isolamento de dados.

## What Changes

- Introduzir a entidade agregadora `AcademicYear` no domínio, com chave por tenant, janelas de vigência e metadados administrativos.
- Acrescentar relacionamentos obrigatórios entre `AcademicYear` e entidades dependentes (Cursos, Turmas, Planos, Timetables, Calendários, Assessments, etc.), atualizando migrations, repositórios e use cases.
- Criar APIs e DTOs para CRUD básico de anos letivos e expor o contexto de ano em endpoints existentes (filtros, validação).
- Definir políticas de transição e migração para registros existentes, atribuindo um ano padrão e ferramenta de reclassificação.

## Impact

- **Backend**: novas classes de domínio, atualizações de `SchoolContext`, repositórios, handlers e validações; migração de dados e seeds.
- **API**: novos endpoints e ajustes em contratos para exigir `academicYearId`/`yearSlug` em operações críticas.
- **Frontend**: componentes compartilhados para seleção de ano, atualizações de formulários/listas que agora dependem desse contexto.
- **Operações**: scripts de migração e playbooks para atribuir anos retroativos e validar integridade antes de habilitar cópia de ano letivo.
