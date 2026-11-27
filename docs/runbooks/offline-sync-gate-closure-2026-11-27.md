# Fechamento da janela de observação do gate offline — 27/11/2026

Verificado em **2026-11-27 07:13 UTC** (janela aberta em 26/11 05:24 UTC, fechada em 27/11 05:24 UTC).

## Delta da janela (contra `offline-sync-gate-base-2026-11-26.json`)

```
== gate offline-sync | DELTA da janela | environment=staging
   base: snapshot carregado

  ✓ missing_key (batch): Δmissing=0 Δprovided=3390 (0.000%)
  ✓ revision_missing: Δ=0 de Δtotal=33570 (0.000%)
  ✓ conflitos: Δ=0 de Δtotal=33570 (0.000%)
  - DELETE /api/grading-formulas/{id}: sem tráfego na janela
  - POST /api/grading-formulas: sem tráfego na janela
  - PUT /api/grading-formulas/{id}: sem tráfego na janela
  ✓ alertas firing novos: 0

  totais da janela: 33570 ops | 33570 applied/success
```

## Leitura absoluta da janela (24h)

```
== gate offline-sync | environment=staging | janela=24h

  ✓ missing_key (batch): 0.000% (limite 1%)
  ✓ revision_missing: sem eventos na janela (0%)
  ✓ conflitos/total: sem eventos na janela (0%)
  adesão por rota:
    ✓ PUT /api/grading-formulas/{id}: 100.00% provided
  ✓ alertas firing: 0
```

## Veredito

**Janela limpa — aprovado para promover/ativar.** Nenhuma divergência contra a base versionada,
nenhum conflito, nenhum alerta novo. Com a ativação do `Entitlement:Enforce` (task 2.9) o deploy
reinicia os contadores em memória: uma nova base será gravada após o deploy em
`offline-sync-gate-base-2026-11-27.json`.
