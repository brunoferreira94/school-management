# Tasks — Censo Escolar (INEP) em 1 clique

## 1. Backend
- [x] 1.1 Campos censitários INEP: `SchoolUnit.InepCode`, `Student.InepCode/MotherName/Gender/ColorRace`, `Staff.InepCode/Cpf/BirthDate` (migration `AddCensoEscolarFields`) e `ClassGroup.InepStage` (migration Academic `AddClassGroupInepStage`)
- [x] 1.2 `GET /api/censo/readiness?academicYearId=`: % de completude por entidade (unidades, turmas, alunos, docentes) + lista de registros com campos faltantes — **tenant-correct (unidades→turmas→alunos/docentes via horários) e escopado ao ano letivo**
- [x] 1.3 `POST /api/censo/export/{academicYearId}`: gera arquivo no layout de importação do Educacenso (TSV, registros 00=escola, 20=turma, 30=aluno, 50=docente) — **cobertura de colunas v1 essencial; expansão anual conforme layout oficial do ano**
- [x] 1.4 Validação pré-export: bloqueia com dados obrigatórios faltando e devolve a prontidão (o que falta, registro a registro)

## 2. Frontend
- [x] 2.1 `/censo`: painel de prontidão com barras de % por entidade
- [x] 2.2 Registros com campos faltantes expandíveis, campos traduzidos (Nome da mãe, Sexo, Cor/raça, Código INEP...) com link direto para a tela de edição da entidade
- [x] 2.3 Botão "Exportar para o Censo": download do arquivo quando liberado; bloqueio atualiza a prontidão apontando o que falta
- [x] 2.4 Formulário de aluno ganha os campos censitários (criação e edição) — payloads fluem por spread

## 3. Testes
- [x] 3.1 API: prontidão calcula % com dados incompletos e reflete edições imediatamente (6 testes: %, missing por campo, bloqueio, layout, isolamento tenant/ano)
- [x] 3.2 API: exportação bloqueada com campos faltando; completa gera arquivo com os registros 00/20/30/50
- [x] 3.3 Unitário frontend: barras de prontidão, banner bloqueio/pronto, download liberado, bloqueio parseado do 400 (5 testes)
- [ ] 3.4 E2E: secretária corrige campos apontados e exporta com sucesso
