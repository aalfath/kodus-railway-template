# Kodus worker: runs the code reviews queued in RabbitMQ. Its health probe (/health) answers 503 while RabbitMQ is unreachable.
FROM ghcr.io/kodustech/kodus-ai-worker:2.2.11@sha256:7c54c1c7dd78166864174a7859e2d027090e4117a3594df16cdc8d9288fb6c21

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

ENV RUN_MIGRATIONS=false \
    RUN_SEEDS=false

COPY --chmod=755 railway-start.sh /usr/local/bin/railway-start.sh

EXPOSE 3334
ENTRYPOINT ["/usr/local/bin/railway-start.sh"]
CMD ["node", "dist/apps/worker/main.js"]
