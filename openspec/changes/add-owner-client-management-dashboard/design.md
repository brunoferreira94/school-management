## Context

O Owner é o administrador do SaaS. Ele precisa enxergar a saúde do negócio e dos clientes, mas sem expor dados pessoais desnecessários. O produto já possui conceitos de Tenant, TenantSubscription, relatórios acadêmicos e analytics de inadimplência/retensão.

## Goals / Non-Goals

- Goals:
  - Entregar uma visão executiva e operacional para o Owner.
  - Permitir gerenciar clientes/tenants de forma segura e auditável.
  - Criar base para relatórios interativos reutilizáveis.
- Non-Goals:
  - Não substituir o painel financeiro contábil completo.
  - Não expor dados pessoais sensíveis sem necessidade.
  - Não criar automações de cobrança nesta mudança.

## Decisions

- Decision: Criar endpoints próprios para Owner Dashboard e Tenant Management.
  - Reason: O Owner precisa de agregações cross-tenant que não cabem nos endpoints tenant-scoped atuais.
- Decision: Manter relatórios interativos como camada de consulta agregada com filtros e exportação.
  - Reason: Relatórios pesados devem ser paginados, cacheados e opcionais para background jobs.
- Decision: Separar permissões de Owner, Admin de tenant e demais roles.
  - Reason: O Owner pode acessar múltiplos tenants; Admin de tenant deve permanecer isolado.

## Risks / Trade-offs

- Cross-tenant queries podem ser pesadas; usar materialized views, índices e cache.
- Dashboards com muitos cards podem ficar ruidosos; priorizar KPIs acionáveis.
- Relatórios interativos exigem bom design de filtros para não gerar consultas caras.

## Security Notes

- Owner deve ter permissão explícita.
- Auditoria obrigatória para ações sensíveis: suspender tenant, alterar plano, exportar dados cross-tenant.
- Dados pessoais devem ser mascarados ou omitidos no dashboard.
