# Spec Delta — support-chat

## ADDED Requirements

### Requirement: Escopo fechado no sistema

O assistente SHALL responder apenas perguntas sobre o School Management e o
próprio portal (operações, telas, conceitos do sistema); pergunta fora desse
escopo SHALL receber recusa simpática com redirecionamento ao assunto, e o
assistente SHALL NÃO executar ações de escrita (read-only no v1).

#### Scenario: Pergunta dentro do escopo é respondida

- **GIVEN** um usuário autenticado no portal ou staff
- **WHEN** ele pergunta "como matriculo um aluno em uma turma?"
- **THEN** recebe uma resposta baseada em artigo(s) de ajuda curados com citação clicável

#### Scenario: Pergunta fora do escopo é recusada

- **GIVEN** o mesmo usuário
- **WHEN** ele pergunta assuntos alheios (ex.: "quem ganhou o jogo ontem?")
- **THEN** recebe recusa simpática que reafirma o escopo e redireciona ao assunto,
  sem consumir geração do LLM além do necessário

### Requirement: Respostas grounded em base curada

O assistente SHALL responder exclusivamente a partir de artigos de ajuda curados
(`HelpArticle` — tabela tenant-global com área, audiência/papel, tags e ativo),
indexados por busca textual; resposta sem retrieval relevante (score abaixo do
threshold configurável) SHALL admitir desconhecimento e oferecer caminho para
suporte humano, e toda resposta SHALL citar os artigos utilizados.

#### Scenario: Sem artigo relevante, admite e escala

- **GIVEN** uma pergunta sem artigo com score acima do threshold
- **WHEN** o assistente processa a mensagem
- **THEN** responde "não tenho certeza" com flag needsHuman e botão de abrir ticket

#### Scenario: Resposta cita fontes

- **GIVEN** uma resposta gerada a partir de artigos recuperados
- **WHEN** a resposta é entregue
- **THEN** inclui referência(s) clicável(is) ao(s) artigo(s) usados

### Requirement: Acesso filtrado por audiência e papel

A recuperação de artigos SHALL considerar a audiência declarada (staff, guardian,
all) e as permissões do usuário — conteúdo de staff nunca é exposto a responsável.

#### Scenario: Responsável não recupera conteúdo de staff

- **GIVEN** um artigo de ajuda marcado como audiência "staff"
- **WHEN** um responsável faz pergunta que recupera esse artigo
- **THEN** o artigo é filtrado fora da recuperação e não influencia a resposta

### Requirement: Controle de custo e abuso

O uso do chat SHALL ser limitado por cota diária de mensagens por usuário/tenant
(configurável por plano), com rate limit dedicado; ao esgotar a cota o usuário
recebe aviso claro e mantém o caminho de suporte humano.

#### Scenario: Cota diária esgotada avisa o usuário

- **GIVEN** um usuário que esgotou a cota diária configurada
- **WHEN** ele envia nova mensagem
- **THEN** recebe aviso de cota esgotada com horário de reset, sem cobrança silenciosa

### Requirement: Fallback FAQ puro e reta final humana

Sem provedor LLM configurado o chat SHALL funcionar em modo busca pura (retorna
artigos relevantes ao invés de texto gerado); perguntas que o assistente marca
needsHuman SHALL permanecer auditáveis no AuditLog com tenant e usuário.

#### Scenario: Modo FAQ puro sem chave

- **GIVEN** `SupportChat:Provider` sem ApiKey configurada
- **WHEN** o usuário pergunta "como cadastrar um aluno?"
- **THEN** o chat retorna os artigos de cadastro com link, sem texto gerado

### Requirement: Persona amistosa e retenção configurável

O assistente SHALL adotar persona amistosa com nome configurável
(`SupportChat:BotName`) e conversas SHALL ter retenção configurável
(`SupportChat:ConversationRetentionDays`), compatível com a política LGPD vigente.

#### Scenario: Persona configurada aparece no widget

- **GIVEN** `SupportChat:BotName` definido como "Zeca"
- **WHEN** o widget abre
- **THEN** a saudação usa o nome configurado e tom simpático
