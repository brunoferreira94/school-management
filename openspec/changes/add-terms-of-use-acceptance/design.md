# Design — add-terms-of-use-acceptance

## Contexto

A solução precisa estender a base de compliance LGPD já existente com governança contratual de uso, exigindo aceite explícito e rastreável em web e app, além de controle B2B por tenant (escola).

## Objetivos

- Garantir base jurídica operacional para uso da plataforma via Termo de Uso.
- Garantir prova de aceite por usuário e por versão.
- Reduzir risco de acesso sem aceite válido.
- Integrar exigências contratuais B2B (contrato + DPA) ao onboarding/ativação de tenant.

## Não objetivos

- Substituir assinatura contratual formal fora do produto.
- Implementar gestão documental completa de ciclo comercial.

## Decisões

### 1) Source of truth de versão do termo

A versão atual do Termo de Uso ficará centralizada no backend, com endpoint de leitura para web/app. O frontend não decide validade de versão localmente.

### 2) Aceite explícito e bloqueio fail-closed

Usuários autenticados sem aceite válido ficam em modo restrito até aceitar a versão vigente. Fluxos permitidos: autenticação, logout e leitura de documentos legais.

### 3) Evidência auditável mínima

Cada evento de aceite registra identificadores mínimos necessários para auditoria e investigação de disputa: usuário, tenant, versão, timestamp e canal. Dados de contexto de dispositivo/rede devem ser minimizados e/ou hash quando aplicável.

### 4) Vínculo legal em pontos críticos

Cadastro, login e rodapé devem sempre expor os links para Termo de Uso e Política de Privacidade para garantir transparência contínua.

### 5) Governança B2B por tenant

A ativação operacional de escolas exige rastreabilidade de contrato principal e DPA. O sistema registra referência documental por tenant para auditoria, sem armazenar necessariamente o documento completo dentro do produto.

## Alternativas consideradas

- Aceite apenas no cadastro: rejeitado porque não cobre usuários existentes nem reaceite por nova versão.
- Versionamento apenas no frontend: rejeitado por risco de inconsistência entre canais e falta de governança central.

## Riscos e trade-offs

- Bloqueio por versão pode elevar fricção de login; mitigação: UI clara e ação de aceite em um passo.
- Dependência de processo jurídico/comercial para B2B pode atrasar rollout; mitigação: checklist operacional e faseamento por tenant.
