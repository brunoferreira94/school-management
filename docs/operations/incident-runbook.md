# Runbook de Incidente e Simulado (Game Day)

Guia operacional para resposta a incidentes em produção. Parte do critério de
lançamento **8.6 — Simulado de incidente (runbook de rollback)** do change
`finalize-public-launch-readiness`.

> Pré-requisito: os health checks (`/api/support/health|ready|live`) e o
> endpoint `/metrics` (prometheus-net) devem estar publicados, e as regras de
> alerta em `observability/prometheus-*.yml` carregadas no Prometheus/Alertmanager.

---

## 1. Princípios de resposta

| Fase | Ação | Dono |
|------|------|------|
| **Detect** | Alerta no Alertmanager / chamado | On-call |
| **Acknowledge** | Reconhecer em ≤ 5 min (SLA crítico) | On-call |
| **Mitigate** | Estancar o impacto (rollback/scale/feature-flag) | On-call + Eng |
| **Communicate** | Avisar canal #incidentes + status page | Incident Commander |
| **Resolve** | Causa raiz corrigida + verificação de saúde | Eng |
| **Postmortem** | Documento em 48h (sem blame) | IC + time |

---

## 2. Catálogo de alertas cobertos por este runbook

| Alerta | Severidade | Gatilho | Runbook |
|--------|-----------|---------|---------|
| `HealthEndpointDown` | critical | `/api/support/health` fora por 30s | §3.1 |
| `ApiEndpointDown` | critical | scrape `school-management` = 0 por 1m | §3.1 |
| `ApiHighErrorRate` | critical | > 5% de 5xx por 5m | §3.2 |
| `ApiResponseTimeCritical` | critical | p95 > 5s por 5m | §3.2 |
| `ApiMemoryCritical` | critical | RSS > 1GB por 5m | §3.3 |
| `BillingCheckoutFailures` | critical | ≥5 falhas de checkout/10m | §3.4 |
| `BillingWebhookFailures` | warning | ≥10 webhooks rejeitados/10m | §3.5 |
| `BillingReconciliationDiscrepancies` | warning | ≥3 discrepâncias/1h | §3.5 |
| `BillingProviderLatencyHigh` | warning | p95 Asaas > 3s/10m | §3.4 |

Métricas expostas em `/metrics` (job `school-management` / `support-health`):
`billing_checkout_success`, `billing_checkout_failure`, `billing_webhook_received`,
`billing_webhook_failure`, `billing_reconciliation_discrepancies`,
`billing_provider_latency_ms`.

---

## 3. Procedimentos de mitigação

### 3.1 API fora (HealthEndpointDown / ApiEndpointDown)
1. `kubectl get pods -l app=school-management-api` (ou `docker ps` no host).
2. Se `CrashLoopBackOff`: `kubectl logs <pod> --previous` → buscar `OutOfMemory` / exceção de migração.
3. Rollback rápido: `kubectl rollout undo deployment/school-management-api`.
4. Se banco: checar `pg_isready` no container `postgres` (porta 5433 host / 5432 container).
5. Validar recovery: `curl -fsS http://api:5000/api/support/live` deve retornar 200.

### 3.2 Erro/latência alta (ApiHighErrorRate / ApiResponseTimeCritical)
1. Isolar via logs: `kubectl logs -l app=school-management-api --since=10m | grep -i ' error\|exception'`.
2. picos de 5xx + latência → provável lock de DB ou job em background.
3. Mitigar: `kubectl scale deployment/school-management-api --replicas=2` (se não estiver) e/ou desligar background via `DISABLE_BACKGROUND_SERVICES=1` (variável de ambiente).
4. Se persistir > 15 min: rollback de deploy.

### 3.3 Memória crítica (ApiMemoryCritical)
1. `kubectl top pod -l app=school-management-api`.
2. Suspeita de leak: coletar dump `dotnet-dump collect -p <pid>` (se possível) para postmortem.
3. Mitigação imediata: restart do pod (`kubectl rollout restart`).
4. Registrar no postmortem para investigação de `GC` / cache em memória.

### 3.4 Falhas de checkout (BillingCheckoutFailures / BillingProviderLatencyHigh)
1. **Não** é problema da nossa API necessariamente — checar status do Asaas (status.asaas.com).
2. `curl -fsS http://api:5000/metrics | grep billing_checkout_failure` para taxa atual.
3. Validar credenciais: `Asaas:ApiKey` e `Asaas:ApiBaseUrl` no secret de produção.
4. Se latência alta do Asaas sem nosso erro: comunicar usuários (banner "pagamentos podem demorar") e aguardar recovery do provedor.
5. Se `ApiKey` inválida: rotacionar secret → trigger de redeploy (sem downtime, config via InMemory provider).

### 3.5 Webhook / reconciliação (BillingWebhookFailures / BillingReconciliationDiscrepancies)
1. Webhook falhando: checar `Asaas:WebhookToken` — o header `asaas-access-token` deve bater.
2. Reconciliar manualmente no relatório **Conciliação > Divergências** (endpoint `/api/finance/reconciliation`).
3. Discrepância > 0 com assinatura `Active` sem parcela paga: investigar se webhook deixou de atualizar status (§3.5.1).
4. Reprocessar eventos perdidos via reenvio manual no painel Asaas (idempotente via `asaas-event:{EventId}`).

---

## 4. Plano de Game Day (simulado obrigatório pré-lançamento)

Executar **uma vez** antes do go/no-go e trimestralmente depois.

### Roteiro (tempo estimado: 45 min)
1. **Briefing** (5 min): definir IC (Incident Commander) e On-call; avisar #incidentes que é treino.
2. **Injetar falha A — checkout** (10 min):
   - Temporariamente apontar `Asaas:ApiBaseUrl` para URL inválida em ambiente de staging.
   - Observar `billing_checkout_failure` subir e `BillingCheckoutFailures` disparar em ≤10 min.
   - Validar que o time segue §3.4 e restaura a URL.
3. **Injetar falha B — health** (10 min):
   - Derrubar o container `postgres` por 1 min (`docker stop ...`).
   - Confirmar `HealthEndpointDown` + `ApiEndpointDown` e o rollback/restart de §3.1.
4. **Injetar falha C — reconciliação** (10 min):
   - Criar assinatura `Active` no Asaas sem parcela paga no staging.
   - Confirmar `BillingReconciliationDiscrepancies` e o procedimento §3.5.
5. **Comunicação** (5 min): praticar aviso no status page + atualização a cada 10 min.
6. **Encerramento + postmortem** (5 min): documentar achados, ajustar runbook se necessário.

### Critérios de sucesso do simulado
- [ ] Todos os 3 alertas dispararam dentro das janelas `for:` definidas.
- [ ] Tempo de acknowledge ≤ 5 min.
- [ ] Rollback/mitigação executado com sucesso em ≤ 15 min.
- [ ] Postmortem criado em 48h com pelo menos 1 action item.

---

## 5. Contatos e referências
- Alertmanager: `alertmanager:9093` · Prometheus: `prometheus:9090`
- Regras: `observability/prometheus-health-alerts.yml`, `prometheus-billing-alerts.yml`
- Scrape config: `observability/prometheus.yml`
- SLA detalhado: [support-sla.md](../support-sla.md)
