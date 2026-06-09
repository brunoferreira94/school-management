# Validação E2E de Domain Events + Implementar Auth Flow do Self-Service Portal

**Autor:** TechOrchestrator  
**Data:** 2026-05-03  
**Status:** active

---

## Resumo

Validar que o padrão `IDomainEventDispatcher` implementado funciona corretamente E2E com um banco de dados real (não apenas Moq), garantindo que contadores de assinatura (`CurrentStudentCount`, `CurrentStaffCount`, `CurrentStorageMB`) são sincronizados automaticamente. Simultaneamente, implementar o fluxo de autenticação (Auth0 SSO + MFA opcional) para desbloquer o Self-Service Portal e permitir que responsáveis/alunos acessem dados sensíveis.

---

## Motivação

1. **Validação de infraestrutura**: 23 testes unitários passam com Moq, mas nunca testamos se handlers são realmente invocados quando entidades são persistidas via EF Core. Risk: padrão falha silenciosamente em produção.

2. **Desbloquear Self-Service Portal**: Auth flow é o último blocker para ativar o portal do responsável. Sem SSO + MFA, não podemos validar a value proposition do plano Premium.

3. **Desbloquear monetização**: Portal + Auth combinados são críticos para demonstrar ROI do plano Premium aos clientes.

---

## Escopo

### Domain Events Validation (E2E)

- Criar testes de integração que exercitam o fluxo completo: criar Tenant → criar Subscription → criar/deletar Student via `StudentCreationService`
- Confirmar que `CurrentStudentCount` é incrementado automaticamente **sem chamadas explícitas** ao repositório
- Repetir para Staff e Documents
- Validar que handlers não duplicam incrementos (idempotência)

### Auth Flow Implementation

- Configurar Auth0 (tenant já existe? ou criar novo app)
- Implementar login no portal via Auth0 + OIDC
- Implementar MFA opcional com TOTP (Time-based OTP)
- Criar guards para rotas protegidas (`PortalComponent`, `BoletoComponent`, etc.)
- Adicionar logout seguro (revogar tokens)

### Validação de DI

- Verificar que todos os handlers de domain events estão registrados no container
- Testar reflexão: `IServiceProvider.GetServices<IDomainEventHandler<StudentCreatedEvent>>()`

### Documentação

- Criar guia de padrão domain events para futuras extensões (alertas, notificações, analytics)

---

## Critérios de Aceitação

### Domain Events Validation

- ✅ 3 cenários de integração criados e passando (Student create, Staff delete, Document create)
- ✅ Contadores incrementam/decrementam sem race conditions
- ✅ Zero regressões em testes existentes
- ✅ DomainEventDispatcher registrado e acessível via DI

### Auth Flow Implementation

- ✅ Login via Auth0 funciona no portal local (localhost:4200)
- ✅ MFA opcional funciona (acesso com/sem TOTP conforme metadata do usuário)
- ✅ Rotas protegidas retornam 401 sem token válido
- ✅ Logout revoga refresh tokens
- ✅ Responsáveis conseguem visualizar dados de seus filhos

### Integration

- ✅ Testes E2E da integração (login → portal abre → dados carregam)
- ✅ Nenhuma vazamento de dados entre tenants (verificar autorização)

---

## Decisões de Design

1. **Domain Events via handlers desacoplados**: Mantém Students/Staff/Documents simples; contadores são sincronizados via padrão de eventos, não lógica acoplada.

2. **Auth0 como IdP único**: Reduz complexidade; MFA opcional via Auth0 rules + TOTP no client.

3. **DbContext em memória para E2E tests**: Rápido, determinístico, permite testar EF Core + handlers juntos.

4. **Handlers registrados no DI container (Scoped)**: Todos os handlers são resolvidos no dispatch; fácil adicionar novos sem modificar `StudentCreationService`.

---

## Próximos Passos

1. **Task 1 (E2E test)** — criar testes de integração e executar
2. **Task 2 (Auth flow)** — implementar login Auth0 + MFA
3. **Task 3 (Pagar.me spike)** — explorar sandbox e documentar contrato
4. **Task 4 (DI verify)** — validar reflexão de handlers
5. **Task 5 (Docs)** — documentar padrão para futuras extensões

---

## Documentação Pós-Implementação

- [x] Update `memories/repo/domain-events.md` com resultados E2E
- [x] Criar `docs/domain-events-pattern.md` — guia de extensão para novos eventos
- [x] Criar `docs/auth-flow-setup.md` — como configurar Auth0 e MFA para novos ambientes
- [x] Update `README.md` da UI com instruções de acesso ao portal
