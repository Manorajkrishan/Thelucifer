# Lucifer X — Milestone 1 Security Foundation

This branch is a **review-only security hardening change**. It is not a production
deployment or a complete security audit.

## Required configuration before running

1. Copy the repository root `.env.example` to `.env`.
2. Generate a unique Laravel `APP_KEY` (for example,
   `cd backend/api && php artisan key:generate --show`), a unique database `POSTGRES_USER`, a strong
   `POSTGRES_PASSWORD`, a strong `NEO4J_PASSWORD`, and a random
   `ML_INTERNAL_TOKEN` of at least 32 bytes. Keep the real values out of Git.
3. For non-Docker Laravel development, set `ML_INTERNAL_TOKEN` to the **same**
   value as the ML service. Set `ML_SERVICE_URL` appropriately.
4. Create an administrator with `php artisan sentinelai:create-admin`.
   A unique interactive password of at least 12 characters is now required.
   Dev seeding is opt-in via `DEV_SEED_PASSWORD`, local/testing only.
5. The ML service is internal-only: direct requests must include
   `Authorization: Bearer <ML_INTERNAL_TOKEN>`. Public health probes may call
   `GET /health`. CORS is disabled unless `ML_CORS_ORIGINS` is explicitly set.
6. To process local documents via the ML API, set `ML_DOCUMENT_ROOT` to a
   server-managed directory mounted read-only into the ML container.
   The Laravel API sends relative document paths, and the ML service refuses
   paths outside that root (including symlink escape). There is a Compose
   bind mount for `backend/api/storage/app/public`.
7. Configure `SOCKET_ALLOWED_ORIGINS` for browsers that use the realtime
   service. WebSocket clients must authenticate before entering threat rooms.
   The internal HTTP detect relay requires `X-Internal-Token`.

## Detection contract change

The deployed threat detector **does not train itself at inference time**.
Provision a *trusted* artifact using `THREAT_MODEL_PATH`: it must be a
pretrained, version-controlled scikit-learn pipeline/model compatible with the
nine-feature schema in `ThreatDetector.FEATURE_FIELDS`. Only load artifacts
built by your own controlled training pipeline; joblib/pickle can execute code
during deserialization. Until this artifact exists, inference returns
`status=unavailable`, `threat_detected=false`, and ML API HTTP 503. Invalid
telemetry returns HTTP 422. This is intentional: it prevents artificial
"successful detections" caused by missing or untrained models.

The legacy model-training module and its saved artifacts do **not** yet
implement an approved end-to-end training/promotion workflow. Treat heuristic
classification scores as uncalibrated indicators, not probabilities.

## Checks

- `cd backend/ml-service && python -m pytest -q tests/test_security.py tests/test_threat_detector_security.py`
- `cd backend/api && php artisan test --filter=ResourceIsolationTest`
  (requires a configured disposable test database and Composer dependencies)
- `docker compose config` to validate configuration after providing secrets.
- GitHub Actions: `milestone1-ci.yml` runs isolated Python regression tests
  and PHP syntax checks on pushes and pull requests.

## Known limitations and follow-up tickets

- **Urgent manual action:** the previous tracked environment backup and other
  committed credentials may remain accessible in Git history and clones.
  Rotate every exposed password and any used application key. Deleting a file
  on a feature branch does not purge Git history. Review historical exposures
  before considering a history rewrite, which requires coordination.
- This branch does not rotate existing production secrets, create admin roles
  or migrate existing sessions.
- The UI's "admin" concept still lacks independent server-side RBAC; current
  user data is scoped to its owner, not a multi-tenant organization.
- Some older PowerShell scripts, tests, and documentation may still reference
  development credentials. Audit these before a public release.
- Detection training, calibrated thresholds, evaluation datasets, and
  approved model promotion remain future work.
- Defensive response execution is not implemented as a verified audit worker;
  direct API attempts to mark actions as executed are blocked.
- Document registration from external sources needs a trust-reviewed ingestion
  design; never use arbitrary client-provided absolute file paths.
- The existing full application build, database integration suite, and complete
  Docker stack have **not** yet been verified end to end by this PR.

Do not merge until regression checks, manual review, and fresh-environment
integration tests pass. Do not deploy without rotating compromised secrets.

### GitGuardian check remediation (PR #1)

Docker Compose now reads both database username and password from environment
variables (`POSTGRES_USER`, `POSTGRES_PASSWORD`). The previous PR history
contained a username/password assignment that could trigger a generic
secret detector even with a variable substitution. The PR feature branch
was rebuilt as one commit to eliminate interim commit findings; this does
**not** remove secret-bearing commits from `master`, forks, or caches.
Never dismiss a genuine historical credential exposure as a false positive.
Rotate and invalidate previously committed database credentials and any
previously exposed application key, whether or not GitGuardian checks pass.
