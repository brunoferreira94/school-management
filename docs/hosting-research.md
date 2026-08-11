# Pesquisa de Provedores de Hospedagem — School Management SaaS

**Data:** 2026-08-05
**Stack:** Angular (frontend) · .NET 10 (backend API) · SQL Database · Observabilidade
**Objetivo:** Lançamento inicial com custo zero ou muito baixo

---

## 1. Resumo Executivo

| Camada | Provedor Recomendado (Free Tier) | Alternativa Low-Cost | Custo Estimado Inicial |
|--------|----------------------------------|----------------------|------------------------|
| Frontend Angular | **Vercel** (Hobby) | Netlify, Cloudflare Pages | $0/mês |
| Backend .NET 10 | **Render** (Free/Shared) | Railway, Fly.io | $0–$7/mês |
| SQL Database | **Supabase** (Free) | Neon, Render Postgres | $0/mês |
| Observabilidade | **Grafana Cloud** (Free) | InfluxDB Cloud, BetterStack | $0/mês |
| **Total** | | | **$0/mês** |

---

## 2. Frontend Angular — Hospedagem Estática

### Vercel (Hobby — Gratuito)
- **Custo:** $0/mês
- **Inclui:** 100 GB bandwidth/mês, deploy automático via Git, CDN global, SSL gratuito
- **Angular:** Suporte nativo via `vercel.json` com rewrites para SPA
- **Limitações:** Hobby é para projetos pessoais; não aceita domínio customizado customizado sem Pro ($20/mês)
- **Obs:** Se precisar de domínio customizado no lançamento, considerar Cloudflare Pages (gratuito, domínio customizado ilimitado)

### Cloudflare Pages (Gratuito)
- **Custo:** $0/mês (ilimitado)
- **Inclui:** 500 build requests/mês, 100k requests HTTP/dia, SSL universal, domínio customizado gratuito
- **Angular:** Suporte SPA via `_redirects` ou `vercel.json`-like config
- **Vantagem:** Sem limite de bandwidth, domínio customizado grátis, WAF incluso

### Netlify (Free Tier)
- **Custo:** $0/mês
- **Inclui:** 100 GB bandwidth/mês, 300 build minutes/mês, SSL, deploy contínuo
- **Limitações:** 100 GB bandwidth pode ser apertado para lançamento

**Recomendação:** Vercel para velocidade de deploy + Cloudflare Pages se precisar de domínio customizado no free tier.

---

## 3. Backend .NET 10 — API Server

### Render (Free Tier)
- **Custo:** $0/mês (Free) / $7/mês (Starter com 512MB/0.5 vCPU)
- **Inclui:** Deploy Git automático, SSL, ambientes de staging, private networking
- **Limitações:** Free servers spin down após 15 min de inatividade (cold start ~30s)
- **.NET 10:** Suporta Docker-based deployments; pode usar container com .NET 10 runtime
- **Recomendação:** Free para validação; Starter ($7/mês) para eliminar cold starts

### Railway (Free Tier → Low-Cost)
- **Custo:** $5/mês (Starter) com $5 de créditos free/mês
- **Inclui:** 512 MB RAM, 0.5 vCPU, deploy via GitHub/GitLab
- **Vantagem:** Interface amigável, suporte a Docker nativamente
- **.NET 10:** Funciona via Dockerfile ou imagem .NET SDK

### Fly.io (Starter)
- **Custo:** $29/mês (Shared CPU 1x = 256MB/1 vCPU)
- **Inclui:** Deploy via CLI, global edge, persistent storage
- **Limitações:** Sem free tier para compute; mínimo $29/mês
- **Vantagem:** Excelente para latency global, suporte a .NET via Docker

### Azure App Service (Free Tier)
- **Custo:** $0/mês (Free F1)
- **Inclui:** 1 GB storage, 60 MB/day outbound data, 1 GB RAM
- **Limitações:** Apenas .NET Framework (não .NET 10/.NET Core) no free tier; limitado
- **Nota:** Não recomendado para .NET 10 — Azure free tier é para .NET Framework legado

**Recomendação:** Render Free para validação → Starter ($7/mês) quando necessário. Alternativa: Railway ($5/mês).

---

## 4. SQL Database

### Supabase (Free Tier)
- **Custo:** $0/mês
- **Inclui:** 500 MB database, 50,000 MAU, 5 GB egress, 1 GB file storage, PostgreSQL 16
- **Vantagens:** API REST auto-generated, Auth integrado, Realtime subscriptions, Row Level Security
- **Limitações:** Free projects pausam após 1 semana de inatividade; limite de 2 projetos ativos
- **.NET 10:** Conexão via Npgsql (PostgreSQL driver), ou HTTP REST API

### Neon (Free Tier)
- **Custo:** $0/mês (Neon Free)
- **Inclui:** 0.5 GB storage, 1 GB egress/mês, auto-suspend após 72h inatividade
- **Vantagens:** Serverless Postgres, branching de database, conexão via HTTP ou WebSocket
- **Limitações:** Egress limitado, storage pequeno para dados de escola

### Render Postgres (Free Tier)
- **Custo:** $0/mês (30-day limit)
- **Inclui:** 90 dias grátis, depois $7/mês (Basic-256mb)
- **Limitações:** Free expira em 30 dias — não ideal para lançamento de longo prazo

### Railway Postgres
- **Custo:** $5/mês (com créditos free)
- **Inclui:** PostgreSQL gerenciado, backup automático, 1 GB storage

**Recomendação:** Supabase Free — PostgreSQL robusto, API REST integrada, Auth incluído, egress generoso. Ideal para SaaS escolar.

---

## 5. Observabilidade

### Grafana Cloud (Free Tier)
- **Custo:** $0/mês
- **Inclui:** 10k métricas/mês (Prometheus), 50 GB logs/mês, 3 dashboards, 10k traces/mês (OTLP)
- **Vantagens:** Grafana dashboards, alertas, integração com .NET via OpenTelemetry
- **Limitações:** 10k métricas/mês pode ser suficiente para lançamento inicial
- **.NET 10:** SDK OpenTelemetry (.NET) → exporta para Grafana Cloud via OTLP endpoint

### InfluxDB Cloud (Free Tier)
- **Custo:** $0/mês
- **Inclui:** 1M writes/mês, 1 GB storage, 1 dashboard, retention policies
- **Vantagens:** Excelente para métricas de séries temporais, bom para monitorar API .NET
- **Limitações:** Menos integrado que Grafana para dashboards completos

### Better Stack (Free Tier)
- **Custo:** $0/mês
- **Inclui:** 1k events/mês, 1k log lines/mês, 1 dashboard
- **Vantagens:** Log management simples, bom para começar

### SigNoz (Open Source — Self-hosted)
- **Custo:** $0 (self-hosted)
- **Inclui:** OpenTelemetry nativo, métricas/logs/traces, dashboards
- **Vantagem:** Pode rodar no mesmo servidor do backend (Render/Railway)
- **Limitação:** Consome recursos do servidor

**Recomendação:** Grafana Cloud Free — métricas, logs e traces em uma plataforma, integração nativa com .NET via OpenTelemetry.

---

## 6. Arquitetura Recomendada (Custo Zero)

```
┌─────────────────────────────────────────────────────────┐
│  FRONTEND (Angular)                                     │
│  Vercel (Hobby - Free) ou Cloudflare Pages (Free)      │
│  Deploy: git push → CDN global + SSL                   │
├─────────────────────────────────────────────────────────┤
│  BACKEND (.NET 10 API)                                  │
│  Render (Free/Shared) ou Railway ($5/mês)              │
│  Container Docker com .NET 10 runtime                  │
│  Conecta ao Supabase PostgreSQL via Npgsql              │
├─────────────────────────────────────────────────────────┤
│  DATABASE (PostgreSQL)                                  │
│  Supabase (Free - 500 MB, 50k MAU)                     │
│  API REST auto-generated + Auth integrado              │
├─────────────────────────────────────────────────────────┤
│  OBSERVABILITY                                          │
│  Grafana Cloud (Free - 10k metrics, 50k logs)          │
│  OpenTelemetry .NET SDK → OTLP endpoint                │
│  Dashboards de métricas, logs e traces                 │
└─────────────────────────────────────────────────────────┘
```

---

## 7. Custo por Fase

### Fase 1 — Validação / MVP (0–3 meses)
| Serviço | Custo |
|---------|-------|
| Vercel (Hobby) | $0 |
| Render (Free) | $0 |
| Supabase (Free) | $0 |
| Grafana Cloud (Free) | $0 |
| **Total** | **$0/mês** |

### Fase 2 — Lançamento (3–6 meses)
| Serviço | Custo |
|---------|-------|
| Vercel (Hobby ou Pro $20) | $0–$20 |
| Render (Starter) | $7 |
| Supabase (Pro $25) | $25 |
| Grafana Cloud (Free → Starter) | $0–$29 |
| **Total** | **$32–$81/mês** |

### Fase 3 — Escala (6+ meses)
| Serviço | Custo |
|---------|-------|
| Vercel (Pro) | $20 |
| Render (Standard) | $25 |
| Supabase (Pro) | $25 |
| Grafana Cloud (Starter) | $29 |
| **Total** | **~$99/mês** |

---

## 8. Trade-offs e Riscos

| Provedor | Risco | Mitigação |
|----------|-------|-----------|
| Render Free | Cold starts (30s) aceitável para MVP | Upgrade para Starter quando necessário |
| Supabase Free | Projetos pausam após 1 semana sem uso | Manter tráfego mínimo ou usar cron job |
| Vercel Free | Limite de 100 GB bandwidth | Monitorar; Cloudflare Pages como fallback ilimitado |
| Grafana Cloud Free | 10k métricas/mês pode esgotar | Ajustar scrape interval para 1min → 5min |
| Todos Free | Vendor lock-in parcial | Usar Docker para portabilidade; abstrair via interfaces |

---

## 9. Próximos Passos

1. Criar repositório Docker para .NET 10 API (multi-stage build)
2. Configurar Vercel para Angular com rewrites SPA
3. Provisionar Supabase project (free tier)
4. Configurar OpenTelemetry no .NET 10 → Grafana Cloud
5. Configurar CI/CD com GitHub Actions (gratuito)
6. Definir domínio customizado (Cloudflare para DNS gratuito)
