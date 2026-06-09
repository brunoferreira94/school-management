# Proposta: adicionar Termo de Uso com aceite versionado

Autor: _a definir_
Data: 2026-05-15
Status: draft

## Por que

A plataforma já evoluiu em conformidade LGPD com política de privacidade e consentimentos, mas ainda precisa formalizar as regras contratuais e operacionais de uso do produto para web e app. Sem Termo de Uso com aceite rastreável, o risco jurídico e de disputas operacionais permanece alto.

## O que muda

- Publicar um Termo de Uso oficial do sistema para portal web e app.
- Exigir aceite explícito no primeiro acesso de cada usuário autenticado.
- Versionar o Termo de Uso e registrar auditoria de aceite por usuário, tenant, data/hora, versão e canal (web/app).
- Requerer novo aceite quando houver atualização relevante de versão.
- Vincular Termo de Uso e Política de Privacidade no cadastro, login e rodapé.
- Formalizar governança B2B por escola com contrato principal e DPA (aditivo de tratamento de dados).

## Escopo

- Fluxo de aceite e bloqueio de acesso até aceite.
- Persistência de aceite e versionamento.
- Exposição de links de documentos legais em pontos de entrada do produto.
- Requisitos de governança documental para clientes B2B.

## Fora de escopo

- Redação jurídica final assinada por escritório.
- Implementação de assinatura eletrônica avançada de contrato.
- Automação completa de ciclo comercial/CRM.

## Impacto

- Specs afetadas: legal-terms (nova capability).
- Sistemas afetados: portal web, app, backend de autenticação/perfil, trilha de auditoria, documentação jurídica.
- Dependências: Política de Privacidade e artefatos de compliance LGPD já existentes.

## Critérios de aceite

- Existe capability OpenSpec com requisitos testáveis para termo, aceite, versionamento e governança B2B.
- Há tarefas verificáveis cobrindo backend, frontend/app, QA e documentação.
- A change valida em modo estrito do OpenSpec.
