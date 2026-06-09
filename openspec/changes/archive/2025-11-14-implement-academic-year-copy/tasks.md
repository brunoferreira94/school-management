# Tasks — Implementar Cópia de Ano Letivo Completo

## 1. Domain and DTOs

- [x] 1.1 Criar DTOs de request/response (CopyAcademicYearRequest, CopyAcademicYearResponse, CopyOptions, CopyStatistics)
- [x] 1.2 Adicionar validações aos DTOs

## 2. Application Layer (Completo ✅)

- [x] 2.1 Criar CopyAcademicYearUseCase com estrutura básica
- [x] 2.2 Implementar validações (ano origem existe, ano destino slug único)
- [x] 2.3 Implementar criação do novo ano letivo
- [x] 2.4 Implementar cópia de ClassGroups ✅
- [x] 2.5 Implementar cópia de Plans (com ajuste de valor opcional) ✅
- [x] 2.6 Implementar cópia de Courses ✅ (N/A - Courses não têm AcademicYearId direto)
- [x] 2.7 Implementar cópia de Events (com ajuste de datas) ✅
- [x] 2.8 Implementar cópia de Notices ✅
- [x] 2.9 Implementar cópia de LessonPlans ✅
- [x] 2.10 Adicionar suporte a transações e rollback (Unit of Work implementado) ✅
- [x] 2.11 Adicionar suporte a dry-run
- [x] 2.12 Instrumentar com métricas e logging

## 3. API Layer

- [x] 3.1 Criar endpoint POST `/api/academic-years/{id}/copy` no AcademicYearsController
- [x] 3.2 Adicionar autorização (academic-years.write)
- [x] 3.3 Adicionar Swagger annotations (XML comments + ProducesResponseType)
- [x] 3.4 Tratar erros e retornar status codes apropriados

## 4. Tests

- [x] 4.1 Testes unitários do CopyAcademicYearUseCase (8 testes, todos passando) ✅
- [x] 4.2 Testes de integração do endpoint (8 testes, todos passando) ✅
- [x] 4.3 Testes de cenários de dry-run ✅
- [x] 4.4 Testes de validações e conflitos ✅
- [x] 4.5 Testes de rollback em caso de erro (Unit of Work com transações) ✅
- [x] 4.6 Testes unitários do UnitOfWork (15 testes) ✅
- [x] 4.7 Testes de integração do UnitOfWork com SQLite (8 testes) ✅

## 5. Frontend (Completo ✅)

- [x] 5.1 Criar modelo TypeScript (CopyAcademicYearRequest, CopyAcademicYearResponse) ✅
- [x] 5.2 Adicionar método copy() ao AcademicYearService ✅
- [x] 5.3 Criar componente wizard (AcademicYearCopyWizardComponent) ✅
- [x] 5.4 Implementar Step 1: Seleção de anos ✅
- [x] 5.5 Implementar Step 2: Opções de cópia ✅
- [x] 5.6 Implementar Step 3: Preview (dry-run) ✅
- [x] 5.7 Implementar Step 4: Resultado ✅
- [x] 5.8 Adicionar validações e feedback visual ✅
- [x] 5.9 Testes do frontend (115 testes passando) ✅
- [x] 5.10 Adicionar rota e integração com menu ✅
- [x] 5.11 Build do frontend concluído com sucesso ✅

## 6. Documentation (Completo ✅)

- [x] 6.1 Atualizar ACADEMIC_YEAR_SUMMARY.md com feature de cópia ✅
- [x] 6.2 Criar guia de uso em docs/academic-year-copy-guide.md ✅
- [x] 6.3 Atualizar README.md com seção sobre cópia de ano letivo ✅
- [x] 6.4 Adicionar exemplos de API no Postman/Insomnia collections ✅
