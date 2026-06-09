# Tasks — Add Academic Year Aggregate

## 1. Domain and Persistence

- [x] 1.1 Modelar entidade `AcademicYear` (domínio) com validações de intervalo de datas e tenant.
- [x] 1.2 Atualizar `SchoolContext` e configurações EF para incluir relacionamentos com cursos, turmas, planos, timetables, assessments e calendários.
- [x] 1.3 Criar migrations para adicionar tabela de anos letivos e colunas de FK nas tabelas dependentes, com defaults seguros.
- [x] 1.4 Implementar migração de dados para atribuir anos existentes (script + job temporário).

## 2. Aplicação e APIs

- [x] 2.1 Adicionar use cases/repositórios para CRUD de anos letivos e seleção corrente.
- [x] 2.2 Atualizar use cases existentes (course, classgroup, plan, timetable etc.) para exigir `academicYearId`.
- [x] 2.3 Expor endpoints REST (`/api/academic-years`) e ajustar DTOs para incluir o novo campo.
- [x] 2.4 Garantir autorização/permissões apropriadas e validações de escopo de tenant.

## 3. Frontend

- [x] 3.1 Criar serviço e componentes para gerenciamento/seleção de ano letivo.
- [x] 3.2 Atualizar formulários e listagens relevantes para persistir `academicYearId`.
- [x] 3.3 Adicionar guards ou contextos compartilhados para manter o ano selecionado na sessão.

## 4. Qualidade e Documentação

- [x] 4.1 Cobertura de testes unitários e integração (backend) para novos fluxos e migração.
- [x] 4.2 Atualizar testes frontend (componentes e serviços) com o contexto de ano.
- [x] 4.3 Atualizar documentação (README, guias operacionais) e playbook de migração.
- [x] 4.4 Validar métricas/telemetria para acompanhar operações por ano letivo.
