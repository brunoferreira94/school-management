# Configurar monitoramento endpoint /api/support/health

Este pacote entrega a configuração pronta para monitorar o endpoint `api/support/health` usando a stack de observabilidade existente do projeto.

Estrutura:
- `observability/`
  - `docker-compose.observability.yml`
  - `prometheus.yml`
  - `prometheus-support-health-alerts.yml`
  - `prometheus-health-alerts.yml`
  - `alertmanager.yml`
  - `blackbox-exporter-config.yml`
  - `start-api-observability.sh`

Como usar:
1. Garanta que o `docker-compose.dev.yml` ou equivalente já traz a configuração correspondente.
2. Execute `observability/start-api-observability.sh`.
3. Acesse:
   - Prometheus: http://localhost:9090
   - Grafana: http://localhost:3000 ou http://localhost:3001 (mapeado no compose principal)
   - Alertmanager: http://localhost:9093
4. Probes configurados:
   - `GET /api/support/health`
   - `GET /api/support/ready`
   - `GET /api/support/live`
5. Valide o alerta `SupportServiceDown` no Prometheus > Alerts.
