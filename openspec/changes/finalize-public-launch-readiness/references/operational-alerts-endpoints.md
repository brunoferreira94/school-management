# Endpoints de Operacionalização — Task 7.3/7.4 Concluído

## Endpoints Criados

### Health Check
```
GET /api/operations/health
```
Retorna status da aplicação e conectividade com o banco.

### Alertas Críticos
```
GET /api/operations/alerts/critical
```
Verifica e retorna:
- Parcelas vencidas (billing failures)
- Assinaturas suspensas/canceladas
- Trials expirando em até 3 dias
- Falhas de notificação (CommunicationLog Failed)

### Métricas de Negócio
```
GET /api/operations/metrics/business
Header: X-Tenant-ID: {guid}
```
Retorna:
- tenantsActive
- MRR (Monthly Recurring Revenue)
- churn (placeholder)
- ttv (placeholder)
- billingFailures
- supportTickets (placeholder)
- studentCount
- activeStudents
- staffCount
- overdueAmount

## Integração Prometheus

Já existente em `/metrics` com:
- `school_retention_rate` — taxa de retenção por coorte
- `school_delinquency_rate` — taxa de inadimplência por período
- `school_students_enrolled` — alunos matriculados
- `school_overdue_amount` — valor vencido

## Integração Alertas

Configure estes alertas no Prometheus/Grafana:

```yaml
alerts:
- name: BillingFailures
  expr: school_delinquency_rate > 0.1
  severity: danger

- name: ApiUnavailable
  expr: up{job="school-mgmt-api"} == 0
  severity: critical

- name: TrialExpiring
  expr: trial_ending_count > 0
  severity: warning
```