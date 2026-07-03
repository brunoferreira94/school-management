## Why

O usuário Owner precisa de uma visão centralizada para gerenciar clientes/tenants do SaaS sem navegar por telas fragmentadas. A informação operacional e financeira relevante está distribuída entre tenants, assinaturas, uso, unidades escolares, alunos, staff, inadimplência, retenção e relatórios acadêmicos/financeiros.

## What Changes

- Criar um dashboard exclusivo do Owner com cartões de saúde da base de clientes, crescimento, receita, inadimplência, retenção, uso de limites e alertas acionáveis.
- Criar gestão de clientes/tenants para listar, pesquisar, filtrar, visualizar detalhes, acompanhar status, assinatura, uso, unidades, alunos, staff e eventos críticos.
- Expandir a área de relatórios para relatórios interativos com filtros, drill-down, exportação, salvamento de views e visualizações gráficas.
- Adicionar permissões, auditoria e limites de acesso para proteger dados sensíveis de múltiplos tenants.

## Impact

- Affected specs: `tenant-management`, `owner-dashboard`, `reports`, `security`, `analytics`.
- Affected code:
  - Backend: novos endpoints/queries de Owner Dashboard, Tenant Management e Interactive Reports; agregações otimizadas; auditoria.
  - Frontend: novas telas Angular para dashboard do Owner, gestão de clientes e relatórios interativos.
  - Banco: novas materialized views/índices podem ser necessários para relatórios e dashboard agregado.
  - Segurança: nova role/permission de Owner e logs de ações sensíveis.
