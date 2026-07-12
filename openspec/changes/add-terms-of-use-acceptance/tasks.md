# Tasks — add-terms-of-use-acceptance

## 1. Planejamento e requisitos legais

- [ ] 1.1 Consolidar versão inicial do Termo de Uso com jurídico e produto (owner: legal/product).
- [ ] 1.2 Definir política de versionamento (major/minor), gatilho de reaceite e janela de comunicação (owner: legal/product).
- [ ] 1.3 Definir artefatos mínimos B2B por tenant: contrato principal e DPA (owner: legal/sales).

## 2. Backend

- [x] 2.1 Criar modelo de dados para aceite: userId, tenantId, termVersion, acceptedAt, channel, ipHash e userAgentHash (owner: backend).
- [x] 2.2 Expor endpoint para consultar versão atual e status de aceite do usuário (owner: backend).
- [x] 2.3 Expor endpoint idempotente para registrar aceite explícito (owner: backend).
- [x] 2.4 Bloquear acesso funcional quando houver versão pendente de aceite, exceto endpoints de autenticação e documentos legais (owner: backend).
- [x] 2.5 Registrar trilha de auditoria para aceite e reaceite por mudança de versão (owner: backend).

## 3. Frontend Web e App

- [x] 3.1 Implementar tela/modal de primeiro acesso exigindo ação explícita de aceite (owner: frontend/mobile).
- [x] 3.2 Exibir links de Termo de Uso e Política de Privacidade no cadastro e login (owner: frontend/mobile).
- [x] 3.3 Exibir links de Termo de Uso e Política de Privacidade no rodapé em área pública e autenticada (owner: frontend/mobile).
- [x] 3.4 Implementar reaceite obrigatório quando backend sinalizar nova versão (owner: frontend/mobile).

## 4. Governança B2B

- [ ] 4.1 Definir checklist de ativação de escola exigindo contrato principal e DPA válidos (owner: legal/ops).
- [x] 4.2 Registrar referência documental por tenant (identificador de contrato e versão do DPA) para auditoria operacional (owner: backend/ops).

## 5. Qualidade e validação

- [ ] 5.1 Cobrir cenários de bloqueio sem aceite, aceite inicial, reaceite por versão e links legais no login/cadastro/rodapé (owner: qa).
- [ ] 5.2 Cobrir cenários de governança B2B no fluxo de ativação de tenant (owner: qa/ops).
- [ ] 5.3 Executar openspec validate add-terms-of-use-acceptance --strict (owner: product).
