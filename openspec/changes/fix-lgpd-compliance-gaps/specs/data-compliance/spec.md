## ADDED Requirements

### Requirement: Exclusão integral de dados do titular

O sistema SHALL, ao receber solicitação de exclusão do próprio titular
(`DELETE /api/privacy/data-subject/me`), remover ou anonimizar de forma irreversível
todo identificador direto do solicitante (username, CPF, nome, contato, endereço,
e-mail, telefone) nas entidades account, student, guardian e staff; SHALL apagar o
histórico pessoal vinculado (histórico de busca, solicitações pendentes de perfil,
refresh tokens); e SHALL NÃO manter nenhum campo a partir do qual o titular possa ser
reidentificado. Dados que devem ser retidos por obrigação legal ou regulatória
(art. 16 da LGPD) SHALL permanecer sem identificadores diretos e com entrada
correspondente em um registro de retenção que documenta a base legal.

#### Scenario: Identificadores diretos são removidos na exclusão

- **GIVEN** um titular autenticado com conta, vínculo de aluno e perfil de responsável
- **WHEN** ele executa `DELETE /api/privacy/data-subject/me`
- **THEN** a conta fica inativa com username anonimizado, o CPF do aluno deixa de ser
  armazenado e consultável, o responsável perde e-mail/telefone/CPF e o registro de
  staff tem nome anonimizado

#### Scenario: Histórico pessoal do titular é apagado

- **GIVEN** o titular possui histórico de busca e uma solicitação de alteração de perfil pendente
- **WHEN** a exclusão é processada
- **THEN** o histórico de busca é removido, a solicitação pendente é descartada e os
  refresh tokens da conta são eliminados

#### Scenario: Retenção por obrigação legal fica registrada

- **GIVEN** a exclusão alcança registros acadêmicos que a instituição deve manter por
  obrigação legal (ex.: notas lançadas)
- **WHEN** o processamento termina
- **THEN** os registros permanecem sem identificadores diretos do titular e o registro
  de retenção contém uma entrada com a base legal e o prazo aplicável

### Requirement: Export completo e portável dos dados do titular

O sistema SHALL entregar, em `GET /api/privacy/data-subject/me/export`, um pacote em
JSON legível por máquina (portabilidade — art. 18, III da LGPD) contendo, no mínimo:
conta, perfis vinculados (aluno/staff/responsável), preferências e opt-outs de
notificações, histórico de consentimento de cookies com timestamps de concessão e
revogação, aceites de termos de uso com versão e data, histórico de busca e entradas
de auditoria que referenciem o titular.

#### Scenario: Export reúne todas as categorias obrigatórias

- **GIVEN** um titular autenticado com consentimento registrado e aceite de termos
- **WHEN** ele solicita `GET /api/privacy/data-subject/me/export`
- **THEN** a resposta inclui conta, perfis, preferências de notificação, histórico de
  consentimento, aceites de termos, histórico de busca e entradas de auditoria
  associadas

#### Scenario: Export em formato comum e legível por máquina

- **GIVEN** qualquer titular autenticado
- **WHEN** ele solicita o export
- **THEN** a resposta é JSON estruturado (mesmo contrato das versões anteriores da API,
  apenas com mais categorias) e não exige intervenção de suporte

### Requirement: Exercício de direitos independente de aceite de termos

O sistema SHALL processar requisições autenticadas a `/api/privacy/data-subject/*`
mesmo quando o titular tem aceite de termos de uso pendente ou desatualizado,
isentando esses caminhos no `TermsOfUseEnforcementMiddleware`.

#### Scenario: Export com termos pendentes não é bloqueado

- **GIVEN** um titular autenticado sem aceite da versão vigente de termos de uso
- **WHEN** ele solicita `GET /api/privacy/data-subject/me/export`
- **THEN** a API responde 200 com o pacote de dados, e não 428

#### Scenario: Exclusão com termos pendentes não é bloqueada

- **GIVEN** um titular autenticado sem aceite da versão vigente de termos de uso
- **WHEN** ele solicita `DELETE /api/privacy/data-subject/me`
- **THEN** a API processa a exclusão e responde 204, e não 428

### Requirement: Consentimento unificado e revogável

O sistema SHALL manter uma única decisão de consentimento por titular, persistida no
servidor, consumida tanto pelo banner de cookies quanto pelo gating de analytics;
SHALL refletir a decisão aceita/rejeitada imediatamente no disparo para provedores
externos; e SHALL permitir revogação a qualquer momento por superfície de preferências,
com efeito imediato (art. 8º e art. 18, IX da LGPD).

#### Scenario: Aceite habilita analytics a partir do mesmo registro

- **GIVEN** o titular ainda não decidiu sobre cookies opcionais
- **WHEN** ele aceita no banner
- **THEN** a decisão é gravada no servidor como `accepted` e os eventos de analytics
  passam a ser disparados habilitando-se a partir dessa mesma decisão

#### Scenario: Recusa bloqueia disparo externo

- **GIVEN** o titular rejeita os cookies opcionais
- **WHEN** o portal emite eventos de navegação
- **THEN** nenhum evento é enviado a gtag/PostHog e o identificador de cliente usado é
  o anônimo, sem associação ao usuário

#### Scenario: Revogação posterior tem efeito imediato

- **GIVEN** o titular havia aceito os cookies opcionais
- **WHEN** ele revoga nas preferências
- **THEN** a decisão no servidor passa a `rejected` e os eventos seguintes deixam de ser
  disparados

### Requirement: Política de retenção configurável e aplicada

O sistema SHALL manter um cronograma de retenção documentado e configurável
(seção `Retention` de configuração) cobrindo, no mínimo: logs de auditoria, logs de
acesso, snapshots de analytics, consentimentos de cookies, aceites de termos de uso,
histórico de busca e dados de conta inativa; e SHALL aplicá-lo com job de limpeza
diário que remove ou anonimiza os registros vencidos.

#### Scenario: Toda categoria de dados tem prazo definido

- **GIVEN** a configuração `Retention` é carregada em ambiente de produção
- **WHEN** ela é inspecionada
- **THEN** cada uma das categorias listadas possui um prazo explícito em dias

#### Scenario: Registro vencido é removido pelo job diário

- **GIVEN** um consentimento de cookie e uma entrada de auditoria mais antigas que os
  prazos configurados
- **WHEN** o job diário de limpeza executa
- **THEN** esses registros são removidos ou anonimizados e o resultado é registrado em log

### Requirement: Canal e prazo de resposta a solicitações de titular

O sistema SHALL publicar o canal de contato do encarregado (DPO) na política de
privacidade (documentação e UI) e SHALL registrar, na trilha de auditoria, o recebimento
e a resolução de cada solicitação de titular, com prazo de resposta de até 15 dias úteis.

#### Scenario: Página de privacidade exibe o canal do encarregado

- **GIVEN** um titular consultando a política de privacidade na UI
- **WHEN** a página é renderizada
- **THEN** o contato do encarregado de proteção de dados está presente e identificado

#### Scenario: Solicitação fica registrada com data de atendimento

- **GIVEN** um titular envia uma solicitação de direitos
- **WHEN** a solicitação é recebida e resolvida
- **THEN** a trilha de auditoria contém eventos com o timestamp de recebimento e o de
  conclusão, permitindo verificar o prazo de 15 dias úteis

### Requirement: Aviso de privacidade com conteúdo mínimo da LGPD

O sistema SHALL disponibilizar aviso de privacidade (documentação e UI) contendo, no
mínimo: identidade e contato do controlador, contato do encarregado, finalidades do
tratamento com a base legal de cada uma, prazos de retenção, destinatários/compartilhamento,
direitos do titular e como exercê-los, e consequências da recusa de fornecer dados
(art. 9º da LGPD).

#### Scenario: UI apresenta as seções obrigatórias

- **GIVEN** um usuário acessa a página de política de privacidade
- **WHEN** o conteúdo é exibido
- **THEN** estão presentes controlador, encarregado, finalidades com base legal, prazos
  de retenção, compartilhamento de dados e direitos do titular

#### Scenario: Cada finalidade declara sua base legal

- **GIVEN** o texto do aviso
- **WHEN** é lida a seção de finalidades
- **THEN** cada finalidade aparece associada a uma base legal da LGPD (ex.: obrigação
  legal, execução de contrato, consentimento, legítimo interesse)

### Requirement: Resposta a incidente de segurança de dados

O sistema SHALL manter runbook de resposta a incidente que defina papéis, critérios de
avaliação de risco e passos de evidência, e SHALL prever notificação à ANPD e aos
titulares afetados quando o incidente puder acarretar risco ou dano relevante,
no prazo de até 48 horas do conhecimento (art. 48 da LGPD).

#### Scenario: Incidente com risco relevante dispara notificação

- **GIVEN** um vazamento de dados pessoais confirmado com risco relevante aos titulares
- **WHEN** a equipe toma conhecimento do incidente
- **THEN** o runbook é acionado e prevê notificação à ANPD e comunicação aos titulares
  afetados dentro de 48 horas do conhecimento

#### Scenario: Runbook documentado com papéis e evidências

- **GIVEN** a operação em produção
- **WHEN** o runbook é consultado
- **THEN** ele contém os papéis responsáveis, os passos de coleta de evidência e o
  checklist de notificação, versionado em `docs/`
