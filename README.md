[![Deploy on Railway](https://railway.com/button.svg)](https://railway.com/new/template/kodus?utm_medium=integration&utm_source=button&utm_campaign=kodus)

# Kodus on Railway

A one-click [Railway](https://railway.com) template for [Kodus](https://kodus.io), the open-source AI code reviewer ("Kody") that reviews pull requests on GitHub, GitLab, Bitbucket, Azure Repos and Forgejo with the LLM key you bring.

**Version:** Kodus self-hosted `2.2.11` (release `selfhosted-2.2.11`), from the official `ghcr.io/kodustech/*` images, each pinned by version and digest in its service's `Dockerfile`.

## What the template deploys

| Service | Built from | Role | Public | Volume |
|---|---|---|---|---|
| `web` | [`web/`](web/Dockerfile) (`kodus-ai-web:2.2.11`) | Web app (Next.js). The browser only talks to this service | yes | – |
| `api` | [`api/`](api/Dockerfile) (`kodus-ai-api:2.2.11`) | REST API. Runs the database migrations on start | no | – |
| `worker` | [`worker/`](worker/Dockerfile) (`kodus-ai-worker:2.2.11`) | Runs the code reviews from the queue | no | – |
| `webhooks` | [`webhooks/`](webhooks/Dockerfile) (`kodus-ai-webhook:2.2.11`) | Receives pull request events from your Git provider | yes | – |
| `RabbitMQ` | [`rabbitmq/`](rabbitmq/Dockerfile) (`kodus-rabbitmq:4.2.2-kodus.1`) | Job queue, with the delayed-message plugin Kodus needs | no | `/var/lib/rabbitmq` |
| `MongoDB` | [`mongodb/`](mongodb/Dockerfile) (`mongo:8.2.12`) | Pull request and review history | no | `/data/db` |
| `Postgres` | Railway's Postgres (with pgvector) | Users, organizations, settings, embeddings | no | Railway's |

- Every app service builds from this repository, so Railway tells deployers when a new version is merged here.
- All state lives on volumes or in Postgres, so it survives redeploys and restarts. RabbitMQ has a fixed node name, because Railway gives every deploy a new hostname.
- Health checks: `web` `/api/health`, `api` and `webhooks` `/health/live`, `worker` `/health` (503 while RabbitMQ is unreachable).
- MongoDB refuses to start without its root user and password, so it never comes up with access control off.
- Each service's `railway-start.sh` only maps Railway's `PORT` and URLs onto Kodus's settings, and waits for the databases on first boot. Fixed Kodus settings sit in the `Dockerfile`s as `ENV` lines.

## Variables

Nothing to fill in. Every value is a generated secret or a reference to another service:

| Variable | Service | Value |
|---|---|---|
| `API_JWT_SECRET`, `API_JWT_REFRESH_SECRET` | api (others reference it) | random, 48 characters |
| `API_CRYPTO_KEY`, `CODE_MANAGEMENT_SECRET` | api (others reference it) | random, 64 hex characters (AES-256 keys) |
| `CODE_MANAGEMENT_WEBHOOK_TOKEN` | api (others reference it) | random, 43 characters |
| `NEXTAUTH_SECRET`, `WEB_NEXTAUTH_SECRET` | web | random, 48 characters (the same value) |
| `MONGO_INITDB_ROOT_PASSWORD`, `RABBITMQ_DEFAULT_PASS` | MongoDB, RabbitMQ | random, 32 characters |
| `DATABASE_URL`, `MONGODB_URI`, `API_RABBITMQ_URI` | api, worker, webhooks | references to the database services |
| `KODUS_PUBLIC_URL`, `KODUS_WEBHOOKS_URL` | api, worker, webhooks | `https://` + the public domains of `web` and `webhooks` |
| `WEB_HOSTNAME_API`, `WEB_PORT_API` | web | the API's private address |

Change the database and queue passwords only before the first deploy: they are written into the volumes on first start.

## After deploying

1. Open the `web` service's URL and **sign up**. The first account creates your organization and becomes its owner.
2. Add your LLM key under **Settings → BYOK** (OpenAI, Anthropic, Google, or any OpenAI-compatible endpoint). Reviews don't run without one.
3. Connect a repository under **Git Settings**. Kodus registers the webhook (`https://<webhooks domain>/github/webhook` and so on) on your provider for you.
4. Open a pull request, or comment `@kody start-review` on one.

Sign-up stays open: anyone who finds the URL can create their own, separate organization (they can't see yours, and they need their own LLM key). If that matters to you, put the `web` domain behind your own access control or use a custom domain you don't publish.

Optional settings go on the `api`, `worker` and `webhooks` services, see [Kodus's environment reference](https://docs.kodus.io): e-mail (`API_SMTP_*` or `RESEND_API_KEY`), a server-wide LLM key (`API_OPEN_AI_API_KEY`, used by every organization on the instance), GitHub/GitLab OAuth login, and the MCP manager (`API_MCP_SERVER_ENABLED`, off here).

## Updates

When this repository bumps the Kodus version, Railway shows an "update available" notice on your project, and you choose when to apply it. Read [`CHANGELOG.md`](CHANGELOG.md) first: breaking changes are listed at the top of each entry. The `api` service runs the database migrations on start.

## License

Kodus is AGPL-3.0, with some enterprise features under its own license; see [kodustech/kodus-ai](https://github.com/kodustech/kodus-ai).
