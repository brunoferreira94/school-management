# Política de Retenção e Anonimização — Analytics

## Objetivo

Estabelecer regras de retenção de dados para analytics, logs e snapshots, alinhando-se com LGPD e boas práticas de privacidade.

## Retenção de Dados

| Dado | Período de Retenção | Justificativa |
|---|---|---|
| Snapshots de retenção (mv_retention_by_cohort) | 365 dias | Análise de churn ano-a-ano |
| Snapshots de inadimplência | 365 dias | Análise financeira histórica |
| Logs de auditoria | 180 dias | Compliance operacional |
| Logs de acesso | 90 dias | Segurança e detecção de intrusão |

## Anonimização

- Dados anonimizados são marcados com prefixo `anonymized-` ou `ANONIMIZADO`
- Campos sensíveis removidos: `ParentContact`, `Address`, `Email`, `Phone`
- Anonimização ocorre automaticamente no endpoint `/api/privacy/data-subject/me` (DELETE)

## Job de Cleanup

O `AuditLogCleanupService` executa limpeza automática diariamente:
- **AuditLogs**: removidos após 180 dias
- **Snapshots**: removidos após 365 dias via `SnapshotService.DeleteOldSnapshotsAsync(365)`

## Configuração

```json
{
  "Retention": {
    "AuditLogsDays": 180,
    "SnapshotsDays": 365,
    "AccessLogsDays": 90
  }
}
```

## Considerações LGPD

- Dados de analytics não são considerados dados pessoais sensíveis
- Agregação por coorte elimina identificação direta
- Retention snapshots são apenas agregações numéricas