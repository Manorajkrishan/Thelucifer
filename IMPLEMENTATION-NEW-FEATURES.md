# Newly Implemented Features

This document summarizes the features added: **download-your-own datasets**, **Neo4j knowledge graph (fully wired)**, **email alerts**, **more dashboards**, and **extra tests**.

---

## 1. Download your own datasets & put in project

- **Dataset Manager** (`backend/ml-service/services/dataset_manager.py`):
  - `download_from_url_to_project(url, dataset_id?)` – download any URL (CSV, JSON, ZIP) into `datasets/custom/<id>/`, extract archives, write `metadata.json`.
- **ML API** – `POST /api/v1/datasets` with `action: "download-url"`, `url`, optional `dataset_id`.
- **Admin Settings** – “Datasets – Download & store in project” section: URL + optional folder name, “Download to project” button, “List downloaded datasets”.
- **Script** – `DOWNLOAD-DATASET-TO-PROJECT.ps1 -Url <url> [-DatasetId <id>] [-UseApi]`. Uses ML API when available, else direct download to `backend/ml-service/datasets/custom/`.

**Usage:** Settings → Datasets, or `.\DOWNLOAD-DATASET-TO-PROJECT.ps1 -Url "https://example.com/data.csv"`

---

## 2. Neo4j knowledge graph fully wired and used

- **Knowledge Graph Service** (`backend/ml-service/services/knowledge_graph.py`):
  - Accepts `driver: Optional[Driver]`. Uses Neo4j when connected; **in-memory fallback** when Neo4j is down or not configured.
  - `store_document_knowledge`, `query_knowledge`, `get_attack_techniques`, `get_defense_strategies`, `create_threat_pattern` all work with either backend.
  - Cypher fix: technique–strategy relationships scoped to `document_id`.
- **ML app** (`app.py`): Neo4j driver init wrapped in try/except + `verify_connectivity()`; on failure, `neo4j_driver = None` and KG uses in-memory.
- **Auto-learner**: Always uses `KnowledgeGraphService` (Neo4j or in-memory).
- **New endpoint** – `GET /api/v1/knowledge/status` → `{ "neo4j": true|false, "backend": "neo4j"|"in-memory" }`.

**Usage:** Run Neo4j (e.g. Docker) for persistence; otherwise KG runs in-memory only.

---

## 3. Email alerts

- **Config** (`config/mail.php`): `mail.threat_alert` – `to` (from `THREAT_ALERT_EMAIL`), `enabled`, `min_severity` (default 7).
- **Mailable** – `App\Mail\ThreatAlertMail`, view `resources/views/emails/threat-alert.blade.php`.
- **ThreatController**: After creating a threat, `sendThreatAlertIfNeeded()` – if `enabled`, `severity >= min_severity`, and `to` non‑empty, sends alert to those addresses.

**Env (optional):**

- `THREAT_ALERT_EMAIL` – comma‑separated emails (e.g. `admin@example.com` or `a@x.com,b@y.com`).
- `THREAT_ALERT_ENABLED` – `true`/`false` (default `true`).
- `THREAT_ALERT_MIN_SEVERITY` – default `7`.

Use `MAIL_MAILER=log` during dev to log emails instead of sending.

---

## 4. More dashboards

- **Threat statistics API** – `GET /api/threats/statistics` now includes `by_date`: last 7 days `{ date, count }` for charts.
- **Admin Dashboard** (`frontend/admin-dashboard/src/views/Dashboard.vue`):
  - **Threats over time** – Line chart (last 7 days).
  - **By severity** – Doughnut chart.
  - **By type** – Bar chart.

Uses existing Chart.js + vue-chartjs.

---

## 5. Extra tests

**API (PHPUnit):**

- `tests/Feature/ApiHealthTest` – `GET /api/health`, `GET /api/`.
- `tests/Feature/ApiAuthTest` – `POST /api/login` (valid/invalid).
- `tests/Feature/ApiThreatsTest` – `GET /api/threats/statistics`, `GET /api/threats`, `POST /api/threats` (auth required), plus statistics structure including `by_date`.

Run: `php vendor/bin/phpunit tests/Feature/ApiHealthTest.php tests/Feature/ApiAuthTest.php tests/Feature/ApiThreatsTest.php`

**ML (pytest):**

- `tests/test_dataset_manager.py` – list available, download instructions, add custom, list downloaded.
- `tests/test_knowledge_graph.py` – store/query/get techniques/strategies/create threat pattern (in-memory).
- `tests/test_ml_app.py` – `GET /health`, `GET /api/v1/datasets?type=available`, `GET /api/v1/knowledge/status`.

Run: `python -m pytest tests/ -v` from `backend/ml-service`.

---

## Quick reference

| Feature            | Where to use / run                                      |
|--------------------|---------------------------------------------------------|
| Download datasets  | Admin → Settings → Datasets, or `DOWNLOAD-DATASET-TO-PROJECT.ps1` |
| Knowledge graph    | ML service; optional Neo4j, else in-memory              |
| Email alerts       | Set `THREAT_ALERT_EMAIL` (and mail config); create high‑severity threats |
| Dashboards         | Admin → Dashboard (charts + stats)                      |
| API tests          | `php vendor/bin/phpunit tests/Feature/`                 |
| ML tests           | `cd backend/ml-service && python -m pytest tests/ -v`   |
