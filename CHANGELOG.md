# Changelog

## 2.2.11 (2026-11-18)

First release of this template.

- Kodus self-hosted `2.2.11` (`kodus-ai-web`, `kodus-ai-api`, `kodus-ai-worker`, `kodus-ai-webhook`), pinned by digest.
- RabbitMQ `4.2.2-kodus.1` (Kodus's build with the delayed-message plugin) and MongoDB `8.2.12`, pinned by digest, both on volumes. Postgres is Railway's (pgvector).
- README: Deploy on Railway button.
- Health checks on `web`, `api`, `webhooks` and `worker`. The MCP manager is not deployed (`API_MCP_SERVER_ENABLED=false`).
