## ADDED Requirements

### Requirement: Publicar Termo de Uso para web e app

O sistema SHALL disponibilizar o Termo de Uso vigente para consulta em canais web e app, com conteúdo consistente entre plataformas e identificação de versão.

#### Scenario: Consulta do termo vigente

- **GIVEN** um usuário acessa o sistema via web ou app
- **WHEN** abre a área de documentos legais
- **THEN** o sistema exibe o Termo de Uso vigente com número de versão e data de vigência

### Requirement: Exigir aceite explícito no primeiro acesso

O sistema MUST exigir aceite explícito do Termo de Uso no primeiro acesso autenticado de cada usuário, antes de liberar funcionalidades além de autenticação e leitura de documentos legais.

#### Scenario: Primeiro acesso sem aceite

- **GIVEN** um usuário autenticado sem registro de aceite da versão vigente
- **WHEN** tenta navegar para funcionalidades protegidas
- **THEN** o sistema bloqueia o acesso funcional e apresenta ação explícita de aceite do termo

### Requirement: Versionamento e reaceite obrigatório

O sistema SHALL versionar o Termo de Uso e MUST exigir novo aceite quando a versão vigente for alterada conforme política definida.

#### Scenario: Nova versão publicada

- **GIVEN** um usuário possui aceite da versão anterior
- **WHEN** uma nova versão do Termo de Uso é publicada
- **THEN** o sistema marca o usuário como pendente de aceite e solicita reaceite antes do acesso completo

### Requirement: Auditoria de aceite por usuário e tenant

O sistema SHALL registrar trilha auditável de aceite e reaceite contendo, no mínimo, identificador de usuário, identificador de tenant, versão aceita, data/hora e canal de origem.

#### Scenario: Registro de evidência de aceite

- **GIVEN** um usuário confirma o aceite da versão vigente
- **WHEN** o backend persiste o evento
- **THEN** a trilha de auditoria fica disponível para consulta administrativa e investigação de conformidade

### Requirement: Vincular documentos legais em cadastro, login e rodapé

O sistema SHALL exibir links para Termo de Uso e Política de Privacidade no fluxo de cadastro, no login e no rodapé das interfaces relevantes.

#### Scenario: Transparência no login

- **GIVEN** um visitante acessa a tela de login
- **WHEN** visualiza a interface
- **THEN** encontra links navegáveis para Termo de Uso e Política de Privacidade

### Requirement: Governança B2B com contrato principal e DPA

Para clientes B2B (escolas), o processo de ativação do tenant MUST exigir vínculo de contrato principal e DPA válidos, com referência documental auditável.

#### Scenario: Ativação de tenant B2B

- **GIVEN** um novo tenant escolar em processo de ativação
- **WHEN** a operação tenta concluir a ativação
- **THEN** o sistema valida a existência de referências de contrato principal e DPA e impede conclusão sem esses requisitos
