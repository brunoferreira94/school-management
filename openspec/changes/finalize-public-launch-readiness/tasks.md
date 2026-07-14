# Tasks — Finalizar Prontidão para Lançamento Público

## 1. Release gates e decisão de lançamento

- [ ] 1.1 Definir critérios objetivos para piloto fechado, beta controlado e lançamento público. (owner: product)
- [x] 1.2 Criar dashboard/checklist de readiness com status P0/P1/P2 e evidências anexadas por item. (owner: product/engineering)
- [ ] 1.3 Registrar decisão de go/no-go antes de qualquer campanha pública. (owner: founder/product)
- [ ] 1.4 Formalizar política: nenhum P0 pode ser rebaixado para P1 sem aprovação do founder. (owner: founder/product)

## 2. Estabilidade backend e dados

- [x] 2.1 Corrigir `AuditLogCleanupService` para não parar o host por `TaskCanceledException`. (owner: backend)
- [x] 2.2 Resolver falha de persistência `checkInsertTargets` e validar migrations em banco limpo. (owner: backend)
- [x] 2.3 Criar smoke test de API protegendo rotas críticas: auth, owner dashboard, tenant, reports e teacher availability. (owner: qa/backend)
- [x] 2.4 Garantir que background services tenham retry, timeout e comportamento resiliente. (owner: backend)
- [x] 2.5 Publicar health checks operacionais (readiness/liveness) como evidência de gate de release. (owner: backend/infra)

## 3. Testes automatizados e CI como gate real

- [x] 3.1 Corrigir testes de Termos de Uso. (owner: backend/qa)
- [x] 3.2 Alinhar CI para .NET 10 (`net10.0`). (owner: infra)
- [x] 3.3 Remover `continue-on-error` de lint/test/unit/e2e críticos no pipeline de release. (owner: infra/frontend/backend)
- [x] 3.4 Definir matriz de checks bloqueantes vs informativos no CI. (owner: infra)
- [ ] 3.5 Publicar relatório de estabilidade semanal (pass rate, flaky rate, tempo médio de build/test). (owner: qa/infra)

## 4. Billing e monetização

- [x] 4.1 Validar idempotência do webhook e reconciliação de cobrança. (owner: backend/finance)
- [ ] 4.2 Validar fluxo ponta a ponta sandbox → produção com runbook de fallback. (owner: backend/finance/ops)
- [x] 4.3 Definir alertas operacionais para falhas de cobrança e reconciliação. (owner: infra/finance)

## 5. Portal do Responsável / Self-service (P0)

- [ ] 5.1 Validar fluxo ponta a ponta: cadastro/convite, login, MFA/SSO quando aplicável, dashboard e acesso a dados do responsável. (owner: product/qa)
- [x] 5.2 Garantir escopo de dados por responsável/aluno e auditoria de acesso. (owner: backend/qa)
- [ ] 5.3 Validar boletos, notas, frequência e comunicados no portal com dados reais. (owner: frontend/backend/qa)
- [ ] 5.4 Medir tempo até primeiro valor (TTV) e manter meta de até 10 minutos no piloto. (owner: product/analytics)
- [ ] 5.5 Ajustar mobile/PWA/acessibilidade para uso por responsáveis. (owner: frontend/qa)
- [ ] 5.6 Registrar evidências (vídeo/relatório de execução) para critério de saída do piloto. (owner: qa/product)

## 6. Relatórios e contratos front/back

- [x] 6.1 Remover fallback mock/TODO dos fluxos críticos de relatórios no frontend. (owner: frontend)
- [x] 6.2 Validar contratos de endpoint de relatórios com testes de integração e consumo UI. (owner: backend/frontend/qa)
- [ ] 6.3 Definir smoke de relatórios como gate de release. (owner: qa/backend)

## 7. Segurança, LGPD e Jurídico

- [x] 7.1 Finalizar texto jurídico do Termo de Uso e Política de Privacidade. (owner: legal/product)
- [x] 7.2 Criar checklist B2B com contrato principal e DPA por tenant. (owner: legal/ops)
- [x] 7.3 Validar fluxo de exportação, correção e exclusão de dados pessoais. (owner: backend/qa)
- [x] 7.4 Definir política de retenção e anonimização para analytics. (owner: security/product)
- [x] 7.5 Revisar permissões e acesso a dados sensíveis em Owner, Portal, Financeiro e Relatórios. (owner: security/backend)

## 8. Deploy, operação e observabilidade

- [x] 8.1 Criar runbook de deploy com migrações, health checks, rollback e backup. (owner: infra)
- [x] 8.2 Validar TLS, secrets e segregação de ambientes. (owner: infra/security)
- [x] 8.3 Criar alertas para erro crítico, falha de checkout, falha de notificação e indisponibilidade de API. (owner: infra/observability)
- [x] 8.4 Criar dashboard de saúde operacional e métricas de negócio: tenants ativos, MRR, churn, TTV, falhas de billing e suporte. (owner: product/observability)
- [x] 8.5 Documentar suporte mínimo, SLA e procedimento de incidente. (owner: ops)
- [x] 8.6 Executar simulado de incidente (tabletop + rollback) e registrar lições aprendidas. (owner: ops/infra)

## 9. Produto e lançamento

- [x] 9.1 Criar onboarding guiado para escola piloto. (owner: product/frontend)
- [x] 9.2 Criar material de treinamento para administrador escolar. (owner: product/docs)
- [ ] 9.3 Ajustar pricing page e FAQ somente após billing e portal validados. (owner: marketing/product)
- [x] 9.4 Definir critérios de saída do piloto fechado. (owner: founder/product)
- [ ] 9.5 Validar critérios de saída com dados reais do piloto (não apenas definição teórica). (owner: founder/product/analytics)

## 10. Definition of Done para o ciclo

- [ ] 10.1 Todos os P0 têm owner, evidência de teste e critério de aceite. (owner: product/engineering)
- [ ] 10.2 Scorecard semanal atualizado e salvo em Obsidian. (owner: founder/product)
- [ ] 10.3 Decisão de estágio de lançamento registrada: piloto fechado, beta controlado ou lançamento público. (owner: founder)
- [ ] 10.4 Nenhum item P0 rebaixado para P1 sem aprovação explícita do founder. (owner: founder/product)
- [ ] 10.5 Executar validação final `openspec validate finalize-public-launch-readiness --strict` com evidências anexadas. (owner: product)
