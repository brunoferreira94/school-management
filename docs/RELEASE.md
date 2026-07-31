# 🚢 Release Checklist — School Management SaaS

Use este arquivo como checklist executável antes do go-live.

## P0 — Bloqueantes

- [ ] Definir destino de deploy (VM + Docker Compose / K8s / PaaS)
- [ ] Provisionar banco PostgreSQL de produção
- [ ] Configurar Auth0 ambiente de produção (tenant, client, audience, MFA)
- [ ] Subir secrets no destino: `DB_*`, `AUTH0_*`, `JWT_*`, `LEGAL__*`
- [ ] Validar CI/CD deploy: se usar GitHub Actions, adicionar secrets necessários
- [ ] Rodar migrations no banco de produção
- [ ] Testar health check (`/health`) em produção

## P1 — Importantes antes do go-live

- [ ] Criar `CHANGELOG.md` com versão inicial
- [ ] Marcar tag `v1.0.0` no git
- [ ] Validar E2E em staging/homologação
- [ ] Conferir PWA, i18n e portal do responsável em produção
- [ ] Confirmar logs estruturados e métricas (Prometheus/Grafana)
- [ ] Documentar skip do `UnitOfWorkTests.MultipleRepositories_ShareSameContext`

## P2 — Pós-lançamento

- [ ] Onboarding de tenant (cadastro, seed inicial, primeiro admin)
- [ ] Dashboard de uso (tenants ativos, erros, sessões)
- [ ] Runbook de troubleshooting e rollback
