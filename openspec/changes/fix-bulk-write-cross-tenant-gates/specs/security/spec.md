## ADDED Requirements

### Requirement: Escritas em lote ancoradas em ClassGroup respeitam tenant

Toda escrita em lote que âncore em `ClassGroup` (matrícula em lote, atribuição de professor
em lote, avaliação de habilidades) SHALL verificar que a turma pertence ao tenant do
chamador antes de aplicar alterações; falhas SHALL se apresentar como recurso não
encontrado (mesma mensagem/página), sem vazar existência. A atualização em lote de alunos
por CPF SHALL usar o gate de vínculo por plano (mesmo gate da leitura/escrita singular).

#### Scenario: Bulk-update não aplica PII de aluno de outro tenant

- **WHEN** um principal autenticado envia `POST /api/students/bulk-update` com CPF de
  aluno vinculado a outro tenant
- **THEN** a resposta não aplica nenhuma alteração (`Updated = 0`) e marca o item como
  aluno não encontrado

#### Scenario: Bulk-enroll exige turma do próprio tenant

- **WHEN** um principal autenticado envia `POST /api/students/bulk-enroll` referenciando
  `classGroupId` de outro tenant
- **THEN** a resposta é 404 (turma não encontrada) e nenhum vínculo aluno-turma é criado

#### Scenario: Bulk-assign-teacher e skill-evaluate exigem turma do próprio tenant

- **WHEN** um principal autenticado envia atribuição em lote de professor ou avaliação de
  habilidade referenciando turma de outro tenant
- **THEN** nenhum horário/avaliação é escrito e a turma se apresenta como não encontrada
