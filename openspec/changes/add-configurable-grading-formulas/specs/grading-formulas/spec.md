# Grading Formulas Specification (delta)

## ADDED Requirements

### Requirement: Períodos de avaliação configuráveis

O sistema MUST permitir que a secretaria da escola subdivida o ano letivo em períodos de avaliação (bimestres, trimestres, semestres ou períodos personalizados), cada um com nome, datas de início/fim e ordem. O sistema MUST atribuir cada avaliação a um período, automaticamente por data quando não informado.

#### Scenario: Gerar bimestres a partir do ano letivo

- **WHEN** a secretaria aplica o template de 4 bimestres sobre um ano letivo
- **THEN** o sistema cria 4 períodos ordenados e contíguos cobrindo todo o intervalo do ano, sem sobreposição

#### Scenario: Criar período personalizado

- **WHEN** a secretaria cria um período com nome e datas próprios (ex.: "Etapa suplementar")
- **THEN** o sistema o aceita como um período válido e ele fica disponível para lançamento de avaliações e fórmulas

#### Scenario: Avaliação atribuída por data

- **WHEN** uma avaliação é criada sem período informado
- **THEN** o sistema a atribui ao período cujo intervalo de datas contém a data da avaliação

#### Scenario: Mudança de data muda o período

- **WHEN** a data de uma avaliação muda para fora do intervalo do seu período atual
- **THEN** o sistema reatribui o período da avaliação e recalcula os resultados materializados do aluno afetado nos períodos envolvidos

### Requirement: Categorias de avaliação

O sistema MUST permitir que cada avaliação tenha uma categoria (ex.: Prova, Trabalho, Recuperação, Exame final, Ponto extra), com sugestões padrão e liberdade de criação de novas categorias pela escola. Fórmulas MUST poder referenciar categorias e notas de recuperação/exame.

#### Scenario: Criar avaliação com categoria

- **WHEN** a secretaria cria uma avaliação marcada como "Recuperação" de um período
- **THEN** a avaliação é lançada e as notas lançadas nela ficam disponíveis para fórmulas que referenciam a categoria

#### Scenario: Lançar nota de exame final

- **WHEN** o professor lança a nota do aluno em uma avaliação de categoria "Exame final"
- **THEN** a nota passa a compor o cálculo da média final de acordo com a fórmula vigente

### Requirement: Catálogo de fórmulas por escola

O sistema MUST permitir que a secretaria crie fórmulas de cálculo de nota por tipo de período (bimestral, semestral, anual ou período personalizado), com nome, estado (rascunho, ativa, arquivada) e versão. Deve existir exatamente uma fórmula ativa por tipo de período para a escola, com possibilidade de override por turma. A ativação MUST ser auditada.

#### Scenario: Criar fórmula a partir do zero

- **WHEN** a secretaria cria uma fórmula "Média bimestral" e a salva
- **THEN** o sistema a armazena como rascunho, validada e versionada, sem afetar cálculo nenhum até a ativação

#### Scenario: Ativar fórmula substitui a anterior

- **WHEN** a secretaria ativa uma nova fórmula bimestral quando já existe uma ativa
- **THEN** a nova passa a valer para todos os cálculos futuros, a anterior é arquivada automaticamente e a ativação fica registrada no audit log

#### Scenario: Override por turma

- **WHEN** a secretaria atribui uma fórmula específica a uma turma
- **THEN** os cálculos daquela turma passam a usar a fórmula da turma, e as demais turmas continuam na fórmula default da escola

#### Scenario: Arquivar não afeta boletins emitidos

- **WHEN** uma fórmula arquivada foi usada em boletins já emitidos
- **THEN** os boletins emitidos permanecem com os valores e a versão com que foram gerados

### Requirement: Templates de fórmulas comuns

O sistema MUST oferecer um catálogo de templates de fórmulas comuns às escolas brasileiras, com descrição em linguagem clara, utilizáveis como base para uma fórmula nova e ajustáveis no editor. O catálogo MUST cobrir, no mínimo, os padrões dos scenarios abaixo.

#### Scenario: Catálogo com os padrões comuns

- **WHEN** a secretaria abre a lista de templates no editor
- **THEN** o sistema oferece, no mínimo: média aritmética simples; média ponderada pelo peso da avaliação; média ponderada por categoria; recuperação substituindo a média do período; exame final `MF = (M + PF)/2`; exame final `MF = (MA×4 + NE×3)/7`; pontos por etapa com aprovação por pontuação; média anual ponderada dos períodos; descartar a menor nota

#### Scenario: Template com descrição legível

- **WHEN** a secretaria consulta o template "Exame final MF = (M + PF)/2"
- **THEN** o sistema apresenta nome, descrição em linguagem clara e a estrutura de cálculo do template

#### Scenario: Criar fórmula a partir de template

- **WHEN** a secretaria escolhe um template como base de fórmula nova
- **THEN** o editor abre com a fórmula montada e pronta para ajustes (thresholds, arredondamento, categorias)

### Requirement: Editor amigável de fórmulas

O sistema MUST oferecer um editor visual de fórmulas dirigido a usuários da secretaria sem conhecimento técnico, onde a fórmula é montada por composição de blocos (operandos e operadores com rótulos em português claro), sem exigir escrita de código ou JSON, com validação em tempo real da estrutura.

#### Scenario: Montar fórmula ponderada por categoria sem código

- **WHEN** a secretaria monta uma fórmula que pondera "Prova" em 60% e "Trabalho" em 40% apenas usando blocos do editor
- **THEN** o sistema estrutura a fórmula e indica que ela é válida, sem que o usuário escreva qualquer código

#### Scenario: Validação em tempo real

- **WHEN** a fórmula em edição fica estruturalmente inválida (ex.: operador sem operando)
- **THEN** o editor indica o problema imediatamente e o salvamento fica bloqueado até a correção

### Requirement: Pré-visualização com dados reais

O editor MUST permitir pré-visualizar o cálculo com dados reais de uma turma/aluno/ período escolhidos, exibindo o resultado final (nota e status) e os valores intermediários de cada etapa da fórmula, calculados pelo mesmo motor usado nos boletins. Dados ausentes e erros de cálculo MUST aparecer na pré-visualização com indicação da causa.

#### Scenario: Preview passo a passo

- **WHEN** a secretaria pré-visualiza uma fórmula para um aluno real de uma turma
- **THEN** o sistema mostra cada operação intermediária com seus valores de entrada e saída, o resultado final e o status do aluno

#### Scenario: Preview com nota ausente

- **WHEN** o aluno escolhido no preview não tem nota em uma avaliação usada pela fórmula
- **THEN** o preview indica a ausência e mostra como a política de nota ausente configurada afeta o resultado

#### Scenario: Preview detecta referência inválida

- **WHEN** a fórmula referencia uma categoria que não existe em nenhuma avaliação da turma
- **THEN** o preview avisa que a referência não encontrou notas, sem quebrar o cálculo das demais

### Requirement: Desfazer e refazer no editor

O editor de fórmulas MUST manter histórico de ações de edição com as operações desfazer e refazer, acessíveis por botões e atalhos de teclado, restaurando qualquer estado intermediário da edição dentro da sessão.

#### Scenario: Desfazer última ação

- **WHEN** a secretaria remove um bloco da fórmula e aciona desfazer
- **THEN** o bloco removido volta exatamente na posição anterior

#### Scenario: Refazer ação desfeita

- **WHEN** a secretaria desfaz uma ação e aciona refazer
- **THEN** a ação desfeita é reaplicada

#### Scenario: Desfazer múltiplas ações

- **WHEN** a secretaria desfaz várias ações consecutivas
- **THEN** a fórmula retorna ao estado inicial da sessão de edição, ação por ação

### Requirement: Validação e segurança do cálculo

O sistema MUST persistir fórmulas como estruturas declarativas validadas no servidor, sem nunca executar código fornecido pelo usuário, com cálculo determinístico e limites de estrutura. Nota ausente e divisão por zero MUST ser tratadas conforme a política configurada na fórmula, sem propagar exceções ao boletim. O cálculo MUST respeitar a escala de cada avaliação e a escala do resultado configurada na fórmula.

#### Scenario: Salvar fórmula inválida é rejeitado

- **WHEN** a secretaria tenta salvar uma fórmula com referência impossível ou estrutura inválida
- **THEN** o sistema rejeita o salvamento com mensagem clara indicando o problema e onde ele está

#### Scenario: Avaliação com valor máximo diferente de 10

- **WHEN** uma avaliação vale 0–100 pontos e a fórmula expressa o resultado na escala 0–10
- **THEN** o cálculo converte as escalas corretamente sem distorcer a média

#### Scenario: Divisão por zero não quebra o boletim

- **WHEN** uma fórmula divide por um denominador que resulta em zero para um aluno
- **THEN** o cálculo aplica a política configurada (ex.: tratar como nota zero com aviso) e o boletim é gerado com a indicação do problema

### Requirement: Status, arredondamento e escala configuráveis

A fórmula MUST definir os limites de aprovação e recuperação, a regra de arredondamento e a escala de apresentação do resultado. O status do aluno (Aprovado/Recuperação/Reprovado ou equivalente) MUST ser calculado pelo motor a partir desses limites, e o sistema MUST eliminas os limites fixos de código (6.0/5.0).

#### Scenario: Escola com aprovação em 5.0

- **WHEN** a escola configura aprovação ≥ 5.0 e recuperação ≥ 3.0
- **THEN** um aluno com média 4.8 aparece como "Recuperação" e um aluno com 5.1 como "Aprovado" em todos os relatórios

#### Scenario: Arredondamento meio-a-meio para cima

- **WHEN** o resultado do cálculo é 5.55 e a fórmula define arredondamento de 1 casa para cima
- **THEN** o valor exibido e usado no status é 5.6

#### Scenario: Sistema de pontos

- **WHEN** a escola usa um template de pontos por etapa com aprovação em 60 pontos
- **THEN** o boletim apresenta o total de pontos e o status calculado sobre a pontuação, não sobre média 0–10

### Requirement: Motor único de cálculo

Todas as saídas de nota do sistema (relatório de notas da turma, boletim do aluno, portal do responsável, blocos de boletim do report-builder, exportações CSV e narrativa) MUST calcular médias e status pelo mesmo motor e pela fórmula ativa da escola, e o sistema MUST remover o cálculo duplicado existente no código da aplicação.

#### Scenario: Mudança de fórmula reflete em todas as saídas

- **WHEN** a escola ativa uma nova fórmula bimestral
- **THEN** o relatório da turma, o boletim do aluno, o portal do responsável e o PDF gerado a partir de então usam a nova fórmula consistentemente

#### Scenario: Paridade de valores entre telas

- **WHEN** o responsável consulta o boletim no portal e a secretaria gera o PDF do mesmo aluno no mesmo período
- **THEN** os valores de média e status são idênticos nas duas saídas

### Requirement: Performance na emissão massiva

O sistema MUST materializar os resultados por aluno, turma e período (com a versão da fórmula usada), de forma que a emissão de boletins em massa não recalcule nota a nota na renderização. O lançamento de uma nota MUST recalcular apenas o resultado do aluno e período afetados. O cálculo por turma MUST ser executado em lote, sem consultas por aluno. Relatórios emitidos MUST congelar os valores calculados no momento da geração.

#### Scenario: Lançar nota recalcula só o afetado

- **WHEN** o professor lança/altera a nota de um aluno em uma avaliação
- **THEN** o sistema recalcula o resultado materializado daquele aluno naquele período e invalida os caches de preview associados, sem recalcular a turma inteira

#### Scenario: Emissão de boletins de uma escola inteira

- **WHEN** a secretaria emite os boletins bimestrais de todas as turmas da escola (centenas de alunos)
- **THEN** a geração acontece em segundo plano por lotes, lendo os resultados materializados por turma, e a UI continua responsiva

#### Scenario: Boletim emitido não muda retroativamente

- **WHEN** uma fórmula é alterada depois da emissão de um boletim
- **THEN** o PDF já emitido mantém os valores originais, e novos boletins usam a nova versão da fórmula

#### Scenario: Histórico escolar não recalcula anos fechados

- **WHEN** a secretaria gera o histórico escolar de um aluno
- **THEN** o sistema usa os resultados materializados de cada ano/período em vez de recalcular todas as notas do histórico na geração

### Requirement: Permissões de secretaria

O acesso às fórmulas de cálculo MUST ser controlado pelas permissões `grading-formulas.read` e `grading-formulas.manage`, disponíveis para os papéis de Diretor e Coordenador (gestão) e Professor (somente leitura). Ativações e alterações de fórmula MUST ser registradas no audit log.

#### Scenario: Professor não edita fórmula

- **WHEN** um usuário com papel Professor tenta salvar ou ativar uma fórmula
- **THEN** o sistema responde 403 e a alteração não é aplicada

#### Scenario: Coordenador ativa fórmula com auditoria

- **WHEN** um Coordenador ativa uma fórmula
- **THEN** o sistema registra no audit log quem ativou, quando, qual fórmula e qual versão
