# How to Run the Full SentinelAI X Project

## Prerequisites

Install these first:

| Tool | Purpose |
|------|---------|
| **PHP 8.1** | Laravel API (use `C:\php81\php.exe` or set `php` in PATH) |
| **Node.js + npm** | Portal (Next.js) and Admin (Vue) |
| **Python 3** | ML service |
| **Database** | **SQLite** (default, no setup) or **MySQL** (XAMPP) |

**If MySQL/XAMPP keeps failing:** Use SQLite. No extra setup.

---

## First-Time Setup (Do Once)

### 1. Use SQLite (recommended if MySQL is not running)

```powershell
cd E:\Cyberpunck
.\SWITCH-TO-SQLITE.ps1 -Force
```

This sets the Laravel API to use SQLite, runs migrations, and creates tables.

### 2. Create admin user (if you haven’t already)

```powershell
cd E:\Cyberpunck\backend\api
C:\php81\php.exe artisan tinker --execute="App\Models\User::updateOrCreate(['email'=>'admin@sentinelai.com'], ['name'=>'Admin','password'=>bcrypt('admin123')]); echo 'admin ok';"
```

### 3. Install frontend dependencies (if not done)

```powershell
cd E:\Cyberpunck\frontend\portal
npm install

cd E:\Cyberpunck\frontend\admin-dashboard
npm install
```

### 4. Install ML service dependencies (if not done)

```powershell
cd E:\Cyberpunck\backend\ml-service
pip install -r requirements.txt
```

---

## Run the Full Project

### Option A: One script (starts everything)

From the project root:

```powershell
cd E:\Cyberpunck
.\START-ALL-SERVICES.ps1
```

This opens **4 terminal windows**:

| Window | Service | Port | URL |
|--------|---------|------|-----|
| 1 | **Laravel API** | 8000 | http://localhost:8000 |
| 2 | **ML Service** | 5000 | http://localhost:5000 |
| 3 | **Portal** (Next.js) | 3000 | http://localhost:3000 |
| 4 | **Admin Dashboard** (Vue) | 5173 | http://localhost:5173 |

**Keep all 4 windows open.** Wait 10–15 seconds, then press a key when prompted to run the quick test.

---

### Option B: Step-by-step (manual)

Open **4 terminals** and run one command in each:

**Terminal 1 – Laravel API**
```powershell
cd E:\Cyberpunck\backend\api
C:\php81\php.exe artisan serve
```

**Terminal 2 – ML Service**
```powershell
cd E:\Cyberpunck\backend\ml-service
python app.py
```

**Terminal 3 – Portal**
```powershell
cd E:\Cyberpunck\frontend\portal
npm run dev
```

**Terminal 4 – Admin Dashboard**
```powershell
cd E:\Cyberpunck\frontend\admin-dashboard
npm run dev
```

Leave each terminal open while you use the app.

---

## Verify Everything Is Working

```powershell
cd E:\Cyberpunck
.\QUICK-TEST.ps1
```

You should see `[OK]` for API, ML, Portal, and Login. Learning Summary is `[OK]` only if the ML service is running and has processed documents.

---

## Log In and Use the App

**Login (same for both):**

- **Email:** `admin@sentinelai.com`  
- **Password:** `admin123`

**Portal (main app):** http://localhost:3000  
- Dashboard, Documents, Threats, Learning, Simulations, Analytics  

**Admin Dashboard:** http://localhost:5173  
- Dashboard, Threats, Documents, Incidents, Simulations, Settings  

---

## Quick Reference

| Task | Command |
|------|---------|
| **Start full project** | `.\START-ALL-SERVICES.ps1` |
| **Fix API / port 8000** | `.\RUN-AND-VERIFY.ps1` |
| **Switch to SQLite** | `.\SWITCH-TO-SQLITE.ps1 -Force` |
| **Create admin user** | See “First-Time Setup” step 2 |
| **Run quick test** | `.\QUICK-TEST.ps1` |

---

## Common Issues

| Problem | Fix |
|--------|-----|
| **404 on /api/login** | Run `.\RUN-AND-VERIFY.ps1` (frees port 8000, starts API) |
| **MySQL connection refused** | Use SQLite: `.\SWITCH-TO-SQLITE.ps1 -Force` |
| **Portal on 3001 instead of 3000** | Port 3000 in use; use http://localhost:3001 |
| **Learning Summary empty** | Start ML service; upload and process documents |
| **Invalid credentials** | Create admin user (see First-Time Setup step 2) |

---

## Summary

1. **First time:** Run `.\SWITCH-TO-SQLITE.ps1 -Force`, create admin user, `npm install` in portal and admin.  
2. **Every time:** Run `.\START-ALL-SERVICES.ps1` (or start the 4 services manually).  
3. **Check:** Run `.\QUICK-TEST.ps1`.  
4. **Use:** Open http://localhost:3000 (Portal) or http://localhost:5173 (Admin), log in with `admin@sentinelai.com` / `admin123`.
