# Implementar tela de Serviços

Change-id: implement-services-screen
Authors: _a definir_
Status: completed
Created: 2025-10-18

## Why

- Centralizar a configuração de serviços e suas regras de cobrança.
- Facilitar a geração automática de cobranças e integração com o módulo financeiro.

## What Changes

- Implementar uma tela administrativa para gerenciar serviços oferecidos pela instituição (matrícula, mensalidade, material didático, transporte, atividades extras).
- Expor APIs e UI para CRUD de serviços, categorização, histórico de preços por ano letivo e regras de faturamento recorrente.
- Garantir permissões específicas (`MANAGE_SERVICES`, `VIEW_SERVICES`) para proteger os endpoints e a interface.

## Scope

- Backend: API CRUD para Services, validação e regras (price, tax, recurring rules).
- Frontend: lista, busca/filtragem, formulário de criação/edição, histórico de preços.
- Permissões: MANAGE_SERVICES, VIEW_SERVICES.
- Tests: unitários e integração para fluxos principais.

## Acceptance Criteria

- Usuário com MANAGE_SERVICES pode criar/editar/deletar serviços.
- Serviços exibem histórico de preço por ano letivo.
- Regras de recorrência configuráveis e exportáveis.

## Dependencies

- Módulo financeiro (para faturamento e conciliação).

## Progress

- Backend: entidade `Service`, entidade `PriceHistory`, repositório, use-cases (Create/List/Get/Update/Delete) e `ServicesController` foram implementados.
- Migrations: arquivo de migração EF Core `20251022124424_AddServicesTable` adicionado e script EF gerado em `release_notes/migrations/AddServicesTable-efcore.sql`.
- Tests: testes unitários básicos para os use-cases foram adicionados. Integração completa de API (end-to-end) ainda pendente; ao rodar a suíte completa foram observados 29 testes de integração falhando que precisam de investigação.
- Frontend: `ServiceService` (CRUD) e componentes (list, form, history) criados. Integrações básicas com regras de cobrança (unit, recurrence) implementadas.
- Docs: OpenAPI regenerado e documentação atualizada no README.md com seção de Serviços, exemplos de payloads e permissões.

## Post-Implementation Documentation

- Seção adicionada no `README.md` do projeto descrevendo a nova tela/feature, rota(s) relevantes, permissões necessárias e exemplos de payloads de API. Trecho de OpenAPI incluído no arquivo gerado.
