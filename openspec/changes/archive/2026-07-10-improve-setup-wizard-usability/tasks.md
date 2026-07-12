# Tasks — improve-setup-wizard-usability

## Planejamento e alinhamento

- [x] Revisar contrato atual do Setup Wizard no frontend e backend.
- [x] Confirmar se o backend já aceita capacidade de salas/turmas e documento da unidade escolar.
- [x] Definir formato final do CSV de importação para cursos e turmas.
- [x] Validar o change via `openspec validate improve-setup-wizard-usability --strict`.

## Frontend — Setup Wizard

- [x] Adicionar validação inline de CPF/CNPJ no fluxo de dados da unidade escolar.
- [x] Adicionar tooltips explicativos nos campos de unidade, salas, cursos, turmas, capacidade e importação.
- [x] Implementar validação de capacidade de turmas entre 10 e 40 alunos.
- [x] Adicionar área de importação em lote para cursos e turmas.
- [x] Exibir preview dos registros importados antes de confirmar o envio.
- [x] Exibir relatório de erros por linha quando a importação falhar.
- [x] Disponibilizar download de template de exemplo compatível com o importador.

## Backend — Setup Wizard

- [x] Validar CPF/CNPJ da unidade escolar no endpoint de configuração inicial, quando aplicável.
- [x] Validar capacidade de turmas no intervalo 10–40 antes de persistir.
- [x] Validar payload de importação em lote com estrutura de cursos/turmas.
- [x] Garantir que falhas parciais não persistam registros inconsistentes.

## Qualidade

- [x] Criar testes unitários para validação de CPF/CNPJ.
- [x] Criar testes unitários para capacidade mínima/máxima de turmas.
- [x] Criar testes para parsing e validação do CSV de cursos e turmas.
- [ ] Criar testes E2E cobrindo importação bem-sucedida e importação com erros.
- [x] Executar build e testes relevantes após implementação.

## Encerramento

- [x] Atualizar documentação do Setup Wizard com instruções de uso da importação em lote.
- [x] Marcar tarefas concluídas somente após validação automática e revisão.

## Validações executadas

- `openspec validate improve-setup-wizard-usability --strict` passou antes da implementação.
- `npm run build` no `school-management-ui` passou.
- `dotnet build SchoolManagement.csproj` passou.
- `dotnet test SchoolManagement.Tests.csproj --filter FullyQualifiedName~SetupServiceTests` passou com 10 testes aprovados.
- `npm test -- --include='src/app/features/setup/utils/*.spec.ts' --watch=false --browsers=ChromeHeadless` compilou os specs de importação/validação, mas não executou por ambiente local: Karma informou ausência de ChromeHeadless (`CHROME_BIN` não definido) e falha em `rimraf` no cleanup.
