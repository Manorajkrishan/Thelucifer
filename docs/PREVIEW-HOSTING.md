# Lucifer X – secure UI-only preview

This folder is the existing Vue admin dashboard frontend. On the dedicated
preview branch ONLY, its entrypoint is replaced with a **standalone synthetic
analyst dashboard**, so it makes **zero** API, ML, socket, or database requests.

## Access control (must be verified BEFORE assigning a live URL)

- Configure Vercel Deployment Protection: Vercel Authentication (SSO)
  on **all** targets, including the production deployment URL.
- Do NOT rely on obscurity of a *.vercel.app URL, robots.txt, CORS,
  client-side password prompts, or a GitHub-private repository as authentication.
- If the account cannot enforce the specified deployment protection,
  do not deploy, or stop/disable the deployment until protection is available.
- Root directory: frontend/admin-dashboard.
- Framework: Vite. Build: npm ci && npm run build. Output: dist.
- Deploy from preview/lucifer-x-protected-ui-20261014 as a *preview target*.
- Do not connect NEXT_PUBLIC_API_URL, VITE_API_URL, DATABASE_URL,
  ML_INTERNAL_TOKEN, or any other secret to this static demo.
- Host headers include noindex, CSP with connect-src 'none', no forms, and
  frame-ancestors 'none'. These are defense-in-depth, not login protection.
- All addresses displayed (192.0.2.0/24, 198.51.100.0/24, 203.0.113.0/24)
  are reserved documentation ranges, not real monitored assets.

## Deployment preflight

Verify Vercel project settings show ssoProtection.deploymentType=all before
creating any deployment. Then verify that the preview URL redirects an
unauthenticated visitor to Vercel sign-in and displays the correct preview to
an authorized user. If the access-control test fails, immediately disable the
deployment rather than publishing the demo publicly.

## Later full-stack deployment blockers

- Previous committed passwords and keys need rotation and history review.
- Laravel RBAC, API/ML private networking, trusted trained ML artifacts,
  monitoring and response/audit trails need staging verification.
- Full Redis/PostgreSQL/Neo4j integration remains unverified.
- No production data, arbitrary file ingestion, live detection,
  automated action or counteroffensive components may be hosted publicly
  from this branch.
