# Verificação de Observabilidade (Grafana / OpenTelemetry Collector / Prometheus)

Este guia descreve os passos para levantar a stack de observabilidade localmente, gerar tráfego via testes de integração e verificar métricas/traces no Grafana e no coletor OpenTelemetry (OTel Collector).

Pré-requisitos

- Docker e Docker Compose instalados
- .NET SDK (mesma versão da solução)
- Ports livres (Grafana 3000, Prometheus 9090, OTLP gRPC 4317, OTLP HTTP 4318)

Passos

1. Subir a stack de observabilidade

Abra um terminal na raiz do repositório e execute:

```powershell
# Inicia a stack definida (se houver um compose dedicado à observabilidade, use-o)
# Caso a sua infra esteja em school-management-api/docker-compose.yml com serviços de observabilidade incluidos:
cd school-management-api
docker-compose up -d
```

Se você mantiver um compose separado (`observability/docker-compose.yml`), utilize:

```powershell
cd school-management-api
docker-compose -f docker-compose.yml -f observability/docker-compose.yml up -d
```

Observação: existe um exemplo de compose de observabilidade em `school-management-api/observability/docker-compose.observability.yml` que inclui `otel-collector`, `prometheus`, `tempo` e `grafana`.

2. Confirmar que os serviços subiram

- Grafana: http://localhost:3000 (usuário padrão: `admin` / `admin`)
- Prometheus: http://localhost:9090
- OpenTelemetry Collector (OTLP): gRPC `localhost:4317` / HTTP `localhost:4318` (ou o endpoint configurado no seu `observability` compose)

3. Gerar tráfego e traces (rodar testes de integração)

No terminal (ainda em `school-management-api`):

```powershell
# Executa apenas testes de integração para gerar traces/metrics
dotnet test "SchoolManagement.Tests" --filter "Category=Integration" --verbosity normal
```

Ou para toda a suíte (mais lento):

```powershell
dotnet test "SchoolManagement.Tests" --verbosity normal
```

4. Verificar métricas e traces

- Abra Grafana (`/dashboards`) e procure por dashboards predefinidos relacionados a `AcademicYears`, `UseCase durations` ou `HTTP server`.
- Em Grafana Explore (Traces): selecione o datasource de traces configurado (por exemplo, Tempo ou Jaeger backend) e filtre por serviço `SchoolManagement.Api`. Procure spans como `CopyAcademicYear` e `DeleteAcademicYear`.

- Observação sobre o `otel-collector`: o Collector normalmente recebe OTLP (ports 4317/4318) e exporta para um backend de traces (Tempo/Jaeger) ou diretamente para um observability backend configurado. Verifique a configuração do seu `otel-collector` para saber para onde os traces estão sendo enviados. Se você não tiver um backend de traces, posso gerar um `docker-compose.observability.yml` exemplo que inclui o `otel-collector` configurado para exportar para Tempo + Prometheus + Grafana.
- Em Prometheus, execute queries rápidas: `http_requests_total` ou `application_usecase_duration_seconds_count` (nomes variam; confira `school-management-api/metrics_names.json`).

5. Coleta rápida de logs

```powershell
# Ver logs docker compose
docker-compose logs -f --tail 200
```

6. Parar a stack (quando terminar)

```powershell
docker-compose down
```

Dicas

- Se os serviços não exporem Grafana/Prometheus/OTel Collector/backends de traces, verifique `school-management-api/docker-compose.yml` e `observability/`.
- Se precisar de dados persistentes para demonstração, ajuste os volumes do Docker Compose.

Se quiser, posso gerar um `docker-compose.observability.yml` de exemplo com Grafana/Prometheus/Jaeger e um dashboard provisório. Quer que eu crie esse arquivo também?
