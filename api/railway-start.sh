#!/bin/sh
# Railway wrapper for the Kodus api service. It only fills in settings that
# Kodus wants as separate variables, then runs the image's own entrypoint.
set -e

# Listen on the port Railway routes and health-checks.
export API_PORT="${PORT:-3001}"

# Public URLs: KODUS_PUBLIC_URL is the web app, KODUS_WEBHOOKS_URL the
# webhooks service. Kodus registers the webhook URLs on your Git provider when
# you connect a repository.
if [ -n "$KODUS_PUBLIC_URL" ]; then
  : "${API_FRONTEND_URL:=$KODUS_PUBLIC_URL}"
  : "${API_USER_INVITE_BASE_URL:=$KODUS_PUBLIC_URL}"
  : "${NEXTAUTH_URL:=$KODUS_PUBLIC_URL}"
  export API_FRONTEND_URL API_USER_INVITE_BASE_URL NEXTAUTH_URL
fi
if [ -n "$KODUS_WEBHOOKS_URL" ]; then
  : "${API_GITHUB_CODE_MANAGEMENT_WEBHOOK:=$KODUS_WEBHOOKS_URL/github/webhook}"
  : "${API_GITLAB_CODE_MANAGEMENT_WEBHOOK:=$KODUS_WEBHOOKS_URL/gitlab/webhook}"
  : "${GLOBAL_BITBUCKET_CODE_MANAGEMENT_WEBHOOK:=$KODUS_WEBHOOKS_URL/bitbucket/webhook}"
  : "${GLOBAL_AZURE_REPOS_CODE_MANAGEMENT_WEBHOOK:=$KODUS_WEBHOOKS_URL/azure-repos/webhook}"
  : "${API_FORGEJO_CODE_MANAGEMENT_WEBHOOK:=$KODUS_WEBHOOKS_URL/forgejo/webhook}"
  export API_GITHUB_CODE_MANAGEMENT_WEBHOOK API_GITLAB_CODE_MANAGEMENT_WEBHOOK \
    GLOBAL_BITBUCKET_CODE_MANAGEMENT_WEBHOOK GLOBAL_AZURE_REPOS_CODE_MANAGEMENT_WEBHOOK \
    API_FORGEJO_CODE_MANAGEMENT_WEBHOOK
fi

# The main database connection uses DATABASE_URL, but the analytics schema
# reads host, port, user, password and database separately.
if [ -n "$DATABASE_URL" ] && [ -z "$API_PG_DB_HOST" ]; then
  eval "$(node -e '
    const u = new URL(process.env.DATABASE_URL);
    const q = (v) => "\x27" + String(v).replace(/\x27/g, "\x27\\\x27\x27") + "\x27";
    const out = {
      API_PG_DB_HOST: u.hostname.replace(/^\[|\]$/g, ""),
      API_PG_DB_PORT: u.port || "5432",
      API_PG_DB_USERNAME: decodeURIComponent(u.username),
      API_PG_DB_PASSWORD: decodeURIComponent(u.password),
      API_PG_DB_DATABASE: decodeURIComponent(u.pathname.slice(1)),
    };
    for (const [k, v] of Object.entries(out)) console.log("export " + k + "=" + q(v));
  ')"
fi

# On Railway every service starts at the same time, so wait (up to 3 minutes)
# until Postgres, MongoDB and RabbitMQ accept connections. Kodus exits instead
# of retrying when they are not there yet.
node -e '
  const net = require("net");
  const targets = ["DATABASE_URL", "MONGODB_URI", "API_RABBITMQ_URI"]
    .map((k) => process.env[k]).filter(Boolean)
    .map((u) => { const x = new URL(u); return [x.hostname.replace(/^\[|\]$/g, ""), Number(x.port) || 0]; })
    .filter(([h, p]) => h && p);
  const deadline = Date.now() + 180000;
  const probe = ([h, p]) => new Promise((ok) => {
    const s = net.connect({ host: h, port: p, timeout: 3000 });
    s.on("connect", () => { s.destroy(); ok(true); });
    s.on("error", () => ok(false)); s.on("timeout", () => { s.destroy(); ok(false); });
  });
  (async () => {
    for (const t of targets) {
      while (!(await probe(t))) {
        if (Date.now() > deadline) { console.log("railway-start: " + t[0] + ":" + t[1] + " still not reachable, starting anyway"); return; }
        console.log("railway-start: waiting for " + t[0] + ":" + t[1]);
        await new Promise((r) => setTimeout(r, 3000));
      }
    }
  })();
'

exec /usr/local/bin/prod-entrypoint "$@"
