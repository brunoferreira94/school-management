# Release Readiness — School Management SaaS

Data: 2026-07-31

## ✅ Pronto
- CI/CD com backend, frontend, E2E e deploy job
- 678/679 testes passing na API (1 skip documentado)
- Documentação de deploy (`DEPLOY.md`, `docs/RELEASE.md`)
- Dockerfiles de API e UI
- Variáveis de ambiente base (`.env.example`)

## ⚠️ Gaps identificados

### P0 — Bloqueantes
1. **Sem docker-compose.prod.yaml** — existe documentação, mas não achei o arquivo no repo.
2. **Sem destino de deploy real** — job atual publica artefatos, não faz rollout.
3. **Auth0 produção** — precisa tenant/client/audience/MFA configurados.
4. **Banco de produção** — precisa ser provisionado e migrations aplicadas.
5. **Secrets no CI** — se deploy for por GitHub Actions, falta configurar secrets no repo.

### P1 — Importantes
6. **E2E staging** — Cypress deve rodar contra ambiente de homologação.
7. **Observabilidade** — confirmar logs, métricas e health check em produção.
8. **Teste UnitOfWork skip** — já documentado no `CHANGELOG.md`.

### P2 — Pós-lançamento
9. Onboarding de tenant
10. Dashboard de uso
11. Runbook de troubleshooting

## Ação recomendada
Começar por P0: definir destino de deploy e provisionar banco + Auth0 produção.
