# Kodus API (REST backend behind the web app). Only this service runs the database migrations and seeds on start.
FROM ghcr.io/kodustech/kodus-ai-api:2.2.11@sha256:873ae14987d3fc7f4710e767272149cb421830112e4a153aa0a7a3d8b4dfae37

# Fixed Kodus settings for a single Railway deployment. Anything that differs
# per deployment (database credentials, secrets, URLs) comes from Railway
# variables set in the template.
ENV API_NODE_ENV=production \
    API_DATABASE_ENV=production \
    API_DATABASE_DISABLE_SSL=true \
    API_LOG_LEVEL=error \
    API_LOG_PRETTY=false \
    BETA_FEATURES=false \
    API_HOST=:: \
    API_PORT=3001 \
    API_WEBHOOKS_PORT=3332 \
    API_RATE_MAX_REQUEST=100 \
    API_RATE_INTERVAL=1000 \
    API_DOCS_ENABLED=false \
    API_MG_DB_DATABASE=kodus_db \
    API_RABBITMQ_ENABLED=true \
    WORKER_ROLE=code-review \
    API_JWT_EXPIRES_IN=365d \
    API_JWT_REFRESH_EXPIRES_IN=7d \
    API_LLM_PROVIDER_MODEL=auto \
    SANDBOX_PROVIDER=local \
    API_MCP_SERVER_ENABLED=false \
    API_AGENT_REVIEW_ENABLED=true \
    OBSERVABILITY_MONGO_ENABLED=false \
    API_CRON_SYNC_CODE_REVIEW_REACTIONS="0 0 * * *" \
    API_CRON_KODY_LEARNING="0 0 * * 6" \
    API_CRON_CHECK_IF_PR_SHOULD_BE_APPROVED="*/2 * * * *" \
    API_CRON_ORG_REPORT="0 9 1 * *" \
    API_CRON_REPO_REPORT="0 9 1,16 * *" \
    API_CRON_KODY_RULES_AUTO_PAUSE="0 6 * * *" \
    API_CRON_KODY_RULES_AUTO_PAUSE_DIGEST="0 9 * * 1" \
    API_CRON_SPEND_LIMIT_ALERT="0 * * * *" \
    API_CRON_CLASSIFY_ORPHANED_SESSIONS="0 */15 * * * *" \
    API_CRON_STALE_REVIEW_WATCHDOG="*/30 * * * *" \
    API_CRON_PRUNE_LICENSE_SEATS="0 4 * * *" \
    API_CRON_SYNC_ALL_REPOSITORIES="*/10 * * * *" \
    WORKFLOW_STALE_JOB_REAPER_CRON="0 */10 * * * *" \
    WORKFLOW_STALE_JOB_TIMEOUT_MINUTES=180

ENV RUN_MIGRATIONS=true \
    RUN_SEEDS=true

COPY --chmod=755 railway-start.sh /usr/local/bin/railway-start.sh

EXPOSE 3001
ENTRYPOINT ["/usr/local/bin/railway-start.sh"]
CMD ["node", "dist/apps/api/main.js"]
