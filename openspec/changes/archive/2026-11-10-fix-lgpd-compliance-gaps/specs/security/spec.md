## ADDED Requirements

### Requirement: Minimização de dados pessoais em logs

O sistema MUST armazenar e emitir IP e user-agent apenas de forma irreversível
(hash com salt ou truncamento) em logs de acesso e de limite de requisições, e MUST
evitar logar headers arbitrários e identificadores pessoais em texto claro fora de
ambiente de teste, respeitando o cronograma de retenção de logs.

#### Scenario: Rejeição de rate limit não registra IP cru

- **GIVEN** uma requisição excede o limite de taxa
- **WHEN** a rejeição é registrada em log
- **THEN** o endereço IP aparece truncado ou como hash com salt, nunca em texto claro

#### Scenario: Depuração de headers só em ambiente de teste

- **GIVEN** o middleware de auditoria processa requisições a `/api/assets` em produção
- **WHEN** o log é gravado
- **THEN** os headers da requisição não são emitidos; o volcamento de headers está
  restrito a ambiente de teste

#### Scenario: Hash de IP usa salt

- **GIVEN** o consentimento de cookies é registrado para um visitante não autenticado
- **WHEN** o subject anônimo é derivado de IP + user-agent
- **THEN** o valor persistido usa SHA-256 com salt (ou HMAC), e não hash puro
  do IP, impedindo recuperação por força bruta
