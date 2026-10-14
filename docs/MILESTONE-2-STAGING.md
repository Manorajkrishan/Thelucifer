# Lucifer X — Milestone 2 private staging gate

**Status: PREPARED, NOT DEPLOYED.** No publicly accessible backend is safe yet.
The Vercel analyst site uses **synthetic data only** and is not connected here.

## Repository cleanup decision

Removed in the staging branch:
- `frontend/package-lock.json`: an empty lockfile for a non-package root folder.
- `backend/api/public/favicon.ico`: zero-byte placeholder, not a usable icon.
- `backend/api/resources/css/app.css`: zero-byte scaffolding file with no CSS.

Retained intentionally:
- `backend/ml-service/downloads/Module*.pdf` (22 PDF assets): may be important
  reference/training data. Keep until owner confirms they can be archived to
  managed dataset storage. Adding ignore rules does **not** remove tracked files.
- ~40 PowerShell scripts: some still manage local Windows startup and tests.
  `backend/api/composer.phar` is called by `backend/api/composer.bat`.
  Removing these without replacing their callers could break offline tooling.

## Private stack

`infrastructure/compose.staging.yaml` is an isolated, no-published-port
configuration. It connects Laravel, PostgreSQL and the token-protected ML service
inside one Docker `internal: true` network. It is for smoke/integration testing
only; access needs an explicit, authenticated diagnostic connector.

`infrastructure/render.staging.yaml` defines a **proposed**, not provisioned,
Render Blueprint: two private services (`pserv`) and a new isolated PostgreSQL
instance with `ipAllowList: []`. It must be synchronized manually after cost,
secrets and region review. Render private services need paid compute; the free
database has an expiry limit. The current Render workspace already contains
an unrelated suspended database; it is **not** reused.

The secure Vercel demo **cannot** call Render private addresses directly.
A separately designed, identity-verified gateway with end-to-end authorization
and rate limiting is required before a real interactive frontend can be linked.
Do not change `pserv` to public web services to work around this.

## Security and secret checklist (blocking)

- [ ] Inventory revoked historical GitGuardian findings, especially the leaked
      database username/password, `.env.mysql.backup`, and legacy admin defaults.
      Old values may remain in old Git commits and clones. Rotate/revoke wherever
      used. A new staging database provides **new** credentials, but does not
      rotate any existing active external service's credential.
- [ ] Generate a fresh Laravel app key and set `APP_KEY` through the hosting
      dashboard as a secret, not a repository variable. Example:
      `php artisan key:generate --show` in a trusted local environment.
      Rotate a formerly used key carefully; old encrypted data/sessions can break.
- [ ] Confirm `ML_INTERNAL_TOKEN` is unique/random and at least 32 bytes.
      Render generates it on API service and references it on ML privately.
- [ ] Leave public registration disabled; create the first user via a protected
      admin/CLI workflow using a unique, manually supplied password.
- [ ] Configure exact CORS origins only after the approved host is ready. Empty
      origins by default; no wildcard.
- [ ] Confirm Render charges and resource sizes before syncing private services.
- [ ] Validate Docker network: `docker compose -f infrastructure/compose.staging.yaml
      --env-file .env config`; no published host ports.
- [ ] Run PostgreSQL-backed Laravel tests, per-user resource isolation, ML auth,
      malicious-path regression, and real app-to-ML communication in a disposable
      environment. Keep outbound downloads and unreviewed ingest disabled.
- [ ] Review backend RBAC, threat action audit, ingress TLS, backup strategy and
      secret manager before any deployment exposing real data.
- [ ] Approve and validate a trusted ML model artifact; **unavailable HTTP 503**
      is expected without it. Never present the stub as live detection.

## Developer notes

For local tests, supply the root `.env` values (never commit them):
`POSTGRES_USER`, `POSTGRES_PASSWORD`, `APP_KEY`, `ML_INTERNAL_TOKEN`.
Nothing listens on public host ports in staging Compose. To test from a local
terminal use authenticated `docker compose exec` checks, not port publishing.

On Render, application code reads `DATABASE_URL` privately; Laravel accepts
the URL and Python uses `psycopg2.connect`. The API resolves the private ML
`hostport` via `ML_SERVICE_HOSTPORT` and prefixes `http://` server-side.

Do not merge the staging branch or sync the Blueprint before review.
