# offline-draft-recovery

## ADDED Requirements

### Requirement: Captura automática de rascunho local

O sistema SHALL salvar automaticamente um rascunho local do conteúdo em edição em formulários longos, sem depender de conexão com a API, com atraso máximo de 2 segundos após a última alteração e também ao ocultar ou fechar a aba.

#### Scenario: Rascunho é gravado enquanto digita

- **GIVEN** um usuário autenticado com um comunicado aberto no editor
- **WHEN** ele digita um parágrafo e para de digitar por 2 segundos
- **THEN** o sistema grava o conteúdo em armazenamento local
- **AND** exibe "salvo neste dispositivo às HH:MM"

#### Scenario: Rascunho é gravado ao fechar a aba

- **GIVEN** um usuário editando um comunicado com alterações não persistidas
- **WHEN** ele fecha a aba ou troca de aplicativo
- **THEN** o sistema grava o rascunho antes de a página ser descarregada

#### Scenario: Rascunho não é gravado em formulários efêmeros

- **GIVEN** um usuário usando filtros de listagem, busca global ou a tela de login
- **WHEN** ele altera esses campos
- **THEN** o sistema não cria rascunho para essas telas

### Requirement: Cobertura de formulários com trabalho em andamento

O sistema SHALL aplicar o rascunho local, no mínimo, aos seguintes formulários de conteúdo longo: composição de comunicado/documento, editor de template de relatório, cadastro de aluno, cadastro de responsável, lançamento de notas, registro de diário/observação, formulário de horário e cadastro do portal de matrícula.

#### Scenario: Cada formulário coberto declara seu escopo de rascunho

- **GIVEN** um formulário coberto pela capability
- **WHEN** o usuário o abre
- **THEN** o formulário informa ao serviço de rascunho uma chave de formulário e um escopo (registro existente ou novo)
- **AND** o rascunho é recuperável individualmente por esse escopo

#### Scenario: Dois rascunhos distintos do mesmo formulário

- **GIVEN** rascunhos pendentes para o aluno A e para o aluno B no cadastro de aluno
- **WHEN** o usuário abre o cadastro do aluno B
- **THEN** o sistema oferece somente o rascunho correspondente ao aluno B

### Requirement: Isolamento de rascunho por tenant e usuário

O sistema SHALL associar cada rascunho ao tenant e ao usuário que o criou e MUST NOT exibir ou restaurar um rascunho em sessão de outro usuário ou de outro tenant, mesmo no mesmo navegador.

#### Scenario: Rascunho não vaza entre usuários do mesmo computador

- **GIVEN** o usuário X deixou um rascunho de comunicado neste navegador
- **WHEN** o usuário Y faz login na mesma máquina e abre a composição de comunicado
- **THEN** o sistema não oferece o rascunho do usuário X

#### Scenario: Rascunho não vaza entre tenants

- **GIVEN** um usuário com acesso a duas escolas
- **WHEN** ele alterna para a segunda escola e reabre o formulário
- **THEN** o sistema só considera rascunhos criados no tenant ativo

### Requirement: Recuperação assistida ao reabrir o formulário

O sistema SHALL, ao abrir um formulário que possui rascunho válido, exibir um aviso com a data e a hora do rascunho e as ações de restaurar ou descartar, sem aplicar o rascunho sobre o formulário sem confirmação do usuário.

#### Scenario: Recuperação após queda de conexão

- **GIVEN** um rascunho de comunicado gravado às 14:32 e a sessão anterior encerrada sem envio
- **WHEN** o usuário reabre a composição de comunicado
- **THEN** o sistema mostra o aviso "rascunho de 14:32" com as ações restaurar e descartar

#### Scenario: Usuário restaura o rascunho

- **GIVEN** o aviso de recuperação está visível
- **WHEN** o usuário escolhe restaurar
- **THEN** o formulário é preenchido com o conteúdo do rascunho
- **AND** o aviso deixa de ser exibido

#### Scenario: Usuário descarta o rascunho

- **GIVEN** o aviso de recuperação está visível
- **WHEN** o usuário escolhe descartar
- **THEN** o rascunho é removido do armazenamento local
- **AND** o formulário permanece com os dados atuais do servidor

### Requirement: Indicador de conexão e de persistência local

O sistema SHALL informar de forma visível quando a conexão estiver indisponível e quando as alterações estiverem salvas apenas localmente, distinguindo "salvo no servidor" de "salvo neste dispositivo, aguardando envio".

#### Scenario: Queda de conexão durante a edição

- **GIVEN** o usuário está editando um comunicado com conexão ativa
- **WHEN** a conexão cai
- **THEN** o sistema exibe estado "sem conexão — rascunho salvo neste dispositivo"

#### Scenario: Retorno da conexão sem envio pendente

- **GIVEN** o sistema está em estado sem conexão e sem envio pendente
- **WHEN** a conexão volta
- **THEN** o indicador de falta de conexão desaparece sem solicitar ação do usuário

### Requirement: Reenvio de submissão pendente ao reconectar

O sistema SHALL enfileirar localmente a submissão que falhou por falta de conexão, reenviá-la automaticamente quando a conexão voltar ou quando a aba receber foco, e MUST enviar uma chave de idempotência por submissão para que o reenvio não gere registro duplicado.

#### Scenario: Envio enfileirado e concluído ao reconectar

- **GIVEN** o usuário confirma o envio de um comunicado e a requisição falha por falta de conexão
- **WHEN** a conexão volta
- **THEN** o sistema reenvia a submissão automaticamente
- **AND** informa o usuário do resultado do envio

#### Scenario: Reenvio não duplica o registro

- **GIVEN** uma submissão enfileirada com chave de idempotência K que chegou ao servidor mas cuja resposta se perdeu
- **WHEN** o sistema reenvia a submissão com a chave K
- **THEN** o servidor devolve o resultado da submissão original
- **AND** permanece apenas um registro criado

#### Scenario: Submissão pendente sobrevive ao recarregamento

- **GIVEN** uma submissão enfileirada e uma aba recarregada
- **WHEN** o usuário reabre o sistema autenticado
- **THEN** o sistema reconhece a submissão pendente e a reenvia ao reconectar

#### Scenario: Falha não transitória não entra em loop de reenvio

- **GIVEN** uma submissão enfileirada cujo reenvio retorna erro de validação (4xx)
- **WHEN** o sistema processa a resposta
- **THEN** ele interrompe o reenvio automático e apresenta o erro para correção manual

### Requirement: Resolução explícita de conflito com o servidor

O sistema SHALL comparar a versão do registro usada como base do rascunho com a versão atual no servidor e, havendo divergência, MUST NOT sobrescrever o registro sem escolha explícita do usuário.

#### Scenario: Registro alterado por outro usuário

- **GIVEN** um rascunho de comunicado criado sobre a versão 3 e o registro já está na versão 5
- **WHEN** o usuário tenta enviar o rascunho
- **THEN** o sistema informa que o registro mudou e oferece manter meu rascunho ou descartar meu rascunho

#### Scenario: Usuário mantém o rascunho

- **GIVEN** o diálogo de conflito está visível
- **WHEN** o usuário escolhe manter meu rascunho
- **THEN** o sistema envia o conteúdo do rascunho sobre a versão atual e registra a revisão resultante

### Requirement: Proteção contra perda por navegação

O sistema SHALL avisar o usuário antes de descartar alterações não persistidas ao navegar para fora de um formulário coberto, oferecendo permanecer na tela.

#### Scenario: Sair do formulário com alterações

- **GIVEN** um formulário coberto com alterações ainda não enviadas
- **WHEN** o usuário aciona voltar ou fecha a tela de edição
- **THEN** o sistema pede confirmação
- **AND** mantém o rascunho local mesmo se o usuário confirmar a saída

### Requirement: Expiração e limpeza de rascunhos

O sistema SHALL expirar rascunhos não utilizados após 7 dias, removê-los ao concluir o envio com sucesso e removê-los no logout manual do usuário, preservando-os no logout automático por inatividade.

#### Scenario: Rascunho antigo é descartado

- **GIVEN** um rascunho gravado há 8 dias
- **WHEN** o sistema é aberto e executa a varredura
- **THEN** o rascunho é removido e não é oferecido para recuperação

#### Scenario: Envio bem-sucedido limpa o rascunho

- **GIVEN** um comunicado enviado com sucesso a partir de um rascunho restaurado
- **WHEN** o servidor confirma o envio
- **THEN** o rascunho correspondente é removido do armazenamento local

#### Scenario: Logout automático preserva o rascunho

- **GIVEN** uma sessão encerrada automaticamente por inatividade
- **WHEN** o mesmo usuário faz login novamente
- **THEN** o rascunho continua disponível para recuperação

#### Scenario: Logout manual apaga os rascunhos do usuário

- **GIVEN** um usuário com rascunhos pendentes
- **WHEN** ele executa logout manual
- **THEN** os rascunhos daquele usuário naquele tenant são removidos

### Requirement: Privacidade e limites do rascunho local

O sistema SHALL limitar o rascunho ao conteúdo textual digitado pelo usuário, MUST NOT armazenar arquivos anexados, credenciais ou tokens no rascunho, e SHALL informar que o rascunho existe apenas neste dispositivo.

#### Scenario: Anexo não é copiado para o rascunho

- **GIVEN** o usuário selecionou um arquivo em um formulário coberto e perdeu a conexão
- **WHEN** o rascunho é gravado
- **THEN** apenas o nome e o tipo do arquivo são guardados
- **AND** o sistema avisa que o arquivo precisa ser selecionado novamente

#### Scenario: Rascunho nunca é fonte de verdade

- **GIVEN** um rascunho local de notas
- **WHEN** outro dispositivo consulta as notas do aluno
- **THEN** o conteúdo do rascunho não é exibido, pois não foi enviado ao servidor

### Requirement: Degradação graciosa sem armazenamento local

O sistema SHALL continuar operando normalmente quando o armazenamento local estiver indisponível, bloqueado ou sem cota, exibindo um aviso único de que o rascunho automático não está ativo.

#### Scenario: Cota de armazenamento esgotada

- **GIVEN** o armazenamento local do navegador sem espaço disponível
- **WHEN** o sistema tenta gravar um rascunho
- **THEN** ele mantém o conteúdo na tela, exibe aviso de que o rascunho local não pôde ser salvo e continua permitindo o envio

#### Scenario: Navegação privada sem IndexedDB

- **GIVEN** um navegador que bloqueia o armazenamento local
- **WHEN** o usuário abre um formulário coberto
- **THEN** o formulário funciona normalmente sem oferecer recuperação de rascunho
