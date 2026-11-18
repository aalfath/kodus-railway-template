# Kodus web app (Next.js). It calls the API over Railway's private network;
# the browser only talks to this service (same-origin /api/proxy).
FROM ghcr.io/kodustech/kodus-ai-web:2.2.11@sha256:6be3cf078e4ea1a5c4d8f57ea9d0b58112b3266cabe2bfa9606f4dab54fa3694

ENV NODE_ENV=production \
    WEB_NODE_ENV=self-hosted \
    HOSTNAME=0.0.0.0 \
    PORT=3000 \
    AUTH_TRUST_HOST=true \
    BETA_FEATURES=false \
    WEB_SUPPORT_DOCS_URL=https://docs.kodus.io \
    WEB_SUPPORT_DISCORD_INVITE_URL=https://discord.gg/QFzwwmNmdN \
    WEB_TOKEN_DOCS_GITHUB=https://docs.kodus.io/how_to_use/en/code_review/general_config/github_pat \
    WEB_TOKEN_DOCS_GITLAB=https://docs.kodus.io/how_to_use/en/code_review/general_config/gitlab_pat \
    WEB_TOKEN_DOCS_BITBUCKET=https://docs.kodus.io/how_to_use/en/code_review/general_config/bitbucket_pat \
    WEB_TOKEN_DOCS_AZUREREPOS=https://docs.kodus.io/how_to_use/en/code_review/general_config/azure_devops_pat \
    WEB_RULE_FILES_DOCS=https://docs.kodus.io/how_to_use/en/code_review/configs/rules_file_detection

EXPOSE 3000
ENTRYPOINT ["docker-entrypoint.sh"]
CMD ["node", "apps/web/server.js"]
