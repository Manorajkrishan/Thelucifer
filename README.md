# SentinelAI X

**AI-powered cybersecurity platform** for autonomous threat detection, analysis, and response with document-based learning and simulated counter-offensive modeling.

---

## Overview

SentinelAI X is a full-stack cybersecurity platform that:

- **Detects** threats using ML-based anomaly detection, signature matching, and behavioral analysis
- **Learns** from documents (PDF, DOCX, TXT), Google Drive links, datasets (CICIDS2017, UNSW-NB15, NSL-KDD, EMBER), and real threat incidents
- **Manages** threats, incidents, documents, and automated threat actions in one place
- **Simulates** defensive and counter-offensive scenarios in a sandbox (no real attacks)
- **Demonstrates** real protection components (packet capture, IDS, firewall) via an optional demo dashboard

All offensive/counter-offensive behavior is **simulated only**. The system is intended for ethical research, training, and defense.

---

## Architecture

| Component | Tech | Port | Description |
|-----------|------|------|-------------|
| **Laravel API** | PHP 8.1+, MySQL | 8000 | Auth (Sanctum), CRUD for threats, documents, incidents, threat actions; orchestrates ML calls |
| **ML Service** | Python 3.10+, Flask | 5000 | Document processing, self-learning, threat detection, knowledge graph (Neo4j), simulations |
| **Public Portal** | Next.js | 3000 | User UI: dashboard, documents, threats, simulations, analytics, learning |
| **Admin Dashboard** | Vue.js | 5173 | Admin UI: full management, settings, system status |
| **Protection Demo** | Python, Flask | 5050 | Optional: proves real protection (IDS, firewall, etc.) via CLI or web demo |

```
┌─────────────────┐     ┌─────────────────┐
│  Portal (3k)    │     │  Admin (5173)   │
│  Next.js        │     │  Vue.js          │
└────────┬────────┘     └────────┬────────┘
         │                        │
         └────────────┬───────────┘
                      ▼
         ┌────────────────────────┐
         │  Laravel API (:8000)    │
         │  MySQL                 │
         └────────────┬───────────┘
                      │
                      ▼
         ┌────────────────────────┐
         │  ML Service (:5000)    │
         │  Learning, Detection,  │
         │  Simulation, Neo4j     │
         └────────────────────────┘
```

---

## Prerequisites

- **PHP 8.1+** (Laravel API)
- **Python 3.10+** (ML service)
- **Node.js 18+** (frontends)
- **MySQL** (or use Docker for DB)
- **Composer** (PHP)

---

## Quick Start

### Option 1: Start all main services (PowerShell)

From the project root:

```powershell
.\START-ALL-SERVICES.ps1
```

Then open:

- **Portal:** http://localhost:3000  
- **Admin:** http://localhost:5173  
- **API:** http://localhost:8000  
- **ML Service:** http://localhost:5000  

### Option 2: Manual start

1. **Database:** Ensure MySQL is running and create a database. Copy `backend/api/.env.example` to `backend/api/.env`, set `DB_*` values, then:

   ```bash
   cd backend/api
   composer install
   php artisan migrate
   php artisan db:seed
   ```

2. **API:** `php artisan serve` (from `backend/api`) → http://127.0.0.1:8000  

3. **ML Service:** From `backend/ml-service`: `pip install -r requirements.txt` then `python app.py` → http://127.0.0.1:5000  

4. **Portal:** From `frontend/portal`: `npm install` then `npm run dev` → http://localhost:3000  

5. **Admin:** From `frontend/admin-dashboard`: `npm install` then `npm run dev` → http://localhost:5173  

Configure the API and ML base URLs in the frontend (e.g. Admin Settings) if they differ from the defaults.

---

## Project Structure

```
Cyberpunck/
├── backend/
│   ├── api/                 # Laravel API (auth, threats, documents, incidents)
│   ├── ml-service/           # Python ML: learning, detection, simulation, knowledge graph
│   └── realtime-service/     # Node.js WebSocket (optional)
├── frontend/
│   ├── admin-dashboard/      # Vue.js admin UI
│   └── portal/               # Next.js public portal
├── protection-dashboard/     # Optional Flask app for real protection demo
├── infrastructure/           # Docker / configs
├── START-ALL-SERVICES.ps1    # Start API, ML, Portal, Admin
└── README.md
```

---

## Features

### Backend API (Laravel)

- **Auth:** Register, login, logout; token-based (Sanctum)
- **Threats:** CRUD, statistics, classification, severity; auto-creation of threat actions
- **Documents:** Upload (PDF, DOCX, DOC, TXT), list, search, download, process (sent to ML), learn from Google Drive links (single/batch)
- **Incidents:** CRUD, link to threats, status/priority/severity
- **Threat actions:** CRUD; types include block_ip, isolate_host, firewall_rule, alert_security_team

### ML Service (Python)

- **Document processing:** Extract text and knowledge (attack techniques, exploit patterns, defense strategies)
- **Self-learning:** From datasets, documents, Drive links, real threats; hybrid learning and continuous improvement
- **Threat detection:** Anomaly detection, signatures, behavioral analysis, severity scoring
- **Knowledge graph:** Neo4j (or in-memory); store and query extracted knowledge
- **Simulations:** Defensive and counter-offensive (simulated only; no real attacks)
- **Datasets:** Support for CICIDS2017, UNSW-NB15, NSL-KDD, EMBER; custom datasets

### Frontends

- **Portal (Next.js):** Dashboard, documents (upload, process, Drive learning), threats, incidents, simulations, analytics, learning summary
- **Admin (Vue.js):** Full management, settings (API/ML URLs, learning mode), system status checks

### Protection demo (optional)

- **CLI:** `python demo_protection.py` — runs safe checks for packet capture, process control, malware scan, IDS (SQLi, XSS, port scan), Windows firewall
- **Web:** `cd protection-dashboard && python app.py` → http://localhost:5050 — “Run Demo” shows same checks in the browser  
Firewall test may require Administrator.

---

## Environment

- **Laravel API:** `backend/api/.env` — set `APP_*`, `DB_*`, and optionally ML service URL for document processing
- **ML Service:** `backend/ml-service/.env` (if used) — Redis, Neo4j, PostgreSQL, dataset paths as needed

---

## Testing

- **Laravel:** `cd backend/api && php artisan test`
- **ML Service:** `cd backend/ml-service && pytest`

---

## License

MIT — see [LICENSE](LICENSE).

---

## Disclaimer

This system is for **ethical cybersecurity research, training, and defense** only. All offensive and counter-offensive simulations run in controlled, sandboxed environments. No real attacks are performed. Use only in compliance with applicable laws and with proper authorization.
