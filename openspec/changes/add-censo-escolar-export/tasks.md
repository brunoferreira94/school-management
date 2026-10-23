## 1. Backend
- [ ] 1.1 Estender cadastros (Student, Guardian, Staff, ClassGroup, SchoolUnit) com campos censitários do INEP (migrations + DTOs)
- [ ] 1.2 `GET /api/censo/readiness`: % de completude por entidade + lista de registros com campos faltantes
- [ ] 1.3 `POST /api/censo/export/{academicYearId}`: gera arquivo no layout oficial de importação do Censo Escolar
- [ ] 1.4 Validação pré-export: bloqueia exportação com dados obrigatórios faltando, apontando os registros

## 2. Frontend
- [ ] 2.1 Página "Censo Escolar" na área de secretaria: barra de prontidão por entidade
- [ ] 2.2 Lista de registros com campos faltantes, linkando direto para a edição do cadastro
- [ ] 2.3 Botão "Exportar para o Censo" com resultado da validação e download

## 3. Testes
- [ ] 3.1 API: readiness calcula % corretamente com dados incompletos
- [ ] 3.2 API: exportação bloqueada com campos obrigatórios faltando; completa gera arquivo no layout
- [ ] 3.3 E2E: secretária corrige campos apontados e exporta com sucesso
