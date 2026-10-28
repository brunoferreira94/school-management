## ADDED Requirements

### Requirement: Integrar gateway de pagamentos e conciliação financeira

O sistema SHALL suportar um gateway de pagamento com transações de Pix, boleto e cartão, e MUST permitir a conciliação automática de recebíveis.

#### Scenario: Registrar pagamento bem-sucedido

- **GIVEN** uma matrícula ou parcela financeira criada no sistema
- **WHEN** a transação é processada com sucesso pelo gateway de pagamento
- **THEN** o sistema marca o recebível como pago e atualiza o status financeiro associado

#### Scenario: Tratar falha de pagamento

- **GIVEN** uma transação iniciada no gateway
- **WHEN** o retorno é rejeitado ou expirado
- **THEN** o sistema mantém o status não pago e cria um evento de alerta para conciliação

#### Scenario: Reconciliar pagamentos via webhook

- **GIVEN** um webhook de notificação de pagamento recebido
- **WHEN** o evento corresponde a uma parcela existente
- **THEN** o sistema atualiza o status de conciliação e registra o processamento do webhook

### Requirement: Disponibilizar portal familiar e mobile-friendly

O sistema SHALL oferecer um portal de self-service para responsáveis e alunos acessarem boletos, notas, frequência, comunicados e perfil.

#### Scenario: Acessar portal familiar

- **GIVEN** um usuário autenticado como responsável ou aluno
- **WHEN** ele navega para a área de "Minha Área"
- **THEN** o sistema exibe informações pessoais, histórico de pagamentos, notas e frequência de forma responsiva

#### Scenario: Consulta de boleto e parcela

- **GIVEN** um responsável acessa o portal
- **WHEN** ele visualiza a seção de pagamentos
- **THEN** o sistema permite visualizar status de parcelas e baixar ou copiar informações de pagamento

### Requirement: Entregar dashboards e BI básico

O system SHALL exibir dashboards gerenciais com indicadores de inadimplência, retenção, matrícula e presença.

#### Scenario: Visualizar dashboard de inadimplência

- **GIVEN** um usuário com permissão administrativa
- **WHEN** ele abre a página de dashboard
- **THEN** o sistema mostra indicadores agregados de inadimplência e aging buckets

#### Scenario: Filtrar retenção por período

- **GIVEN** um administrador seleciona um intervalo de datas
- **WHEN** aplica o filtro no dashboard
- **THEN** o sistema atualiza os valores de retenção de coorte e evolução de matrícula

### Requirement: Suportar avaliação pedagógica avançada

O sistema SHALL suportar avaliação baseada em competências, gestão de tarefas e relatórios pedagógicos básicos.

#### Scenario: Criar avaliação por competências

- **GIVEN** um professor cria uma avaliação
- **WHEN** define competências e pesos associados
- **THEN** o sistema persiste a avaliação e a torna disponível para lançamento de notas

#### Scenario: Gerar relatório pedagógico de progresso

- **GIVEN** uma turma com avaliações lançadas
- **WHEN** o professor solicita o relatório de progresso
- **THEN** o sistema apresenta evolução de desempenho por competência e aluno

### Requirement: Expor APIs para integrações externas

O sistema SHALL fornecer APIs públicas documentadas para integração com sistemas legados e parceiros.

#### Scenario: Consultar dados de aluno via API

- **GIVEN** um token válido de API
- **WHEN** uma aplicação externa solicita dados de alunos autorizados
- **THEN** o sistema retorna dados filtrados conforme permissões e tenant

#### Scenario: Importar dados legados

- **GIVEN** um payload de importação de aluno/turma legados
- **WHEN** o backend processa o carregamento
- **THEN** o sistema valida, vincula e registra eventuais divergências

### Requirement: Estabelecer maturidade de produto e operação

O sistema SHALL incluir documentação de onboarding, pacote comercial mínimo e suporte operacional para piloto.

#### Scenario: Entregar material de onboarding

- **GIVEN** um cliente piloto aprovado
- **WHEN** a equipe de implantação inicia o onboarding
- **THEN** há um guia de passos, checklist e papéis claramente definidos

#### Scenario: Publicar modelo de cobrança SaaS

- **GIVEN** uma proposta comercial para escola
- **WHEN** o time apresenta o produto
- **THEN** existe um modelo de preço básico por aluno e módulos opcionais definido
