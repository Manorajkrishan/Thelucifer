# How to Run SentinelAI X & Check the System Is Working

## Prerequisites

- **PHP 8.1** (at `C:\php81\php.exe` — or edit scripts to use your `php` path)
- **MySQL** (XAMPP or standalone) — or use **SQLite** via `.\SWITCH-TO-SQLITE.ps1`
- **Python 3** (for ML service)
- **Node.js & npm** (for frontends)

---

## Recommended: Run & Verify (fixes 404 on /api/login)

If you see **404 on /api/login**, **API not reachable**, or **login loading forever**, run this first:

```powershell
.\RUN-AND-VERIFY.ps1
```

This will:

1. **Free port 8000** (kill any wrong app using it)
2. **Start the Laravel API** in a new window
3. **Verify** health and login (admin@sentinelai.com / admin123)
4. Print **pass/fail** and next steps

**Keep the Laravel window open.** Then start the Portal:

```powershell
cd frontend\portal
npm run dev
```

Open **http://localhost:3000/login** and log in with **admin@sentinelai.com** / **admin123**.

---

## 1. Start All Services

From the project root (`E:\Cyberpunck`):

```powershell
.\START-ALL-SERVICES.ps1
```

This opens **4 PowerShell windows** and starts:

| Service         | Port | URL                      |
|-----------------|------|--------------------------|
| Laravel API     | 8000 | http://localhost:8000    |
| ML Service      | 5000 | http://localhost:5000    |
| Portal (Next.js)| 3000 | http://localhost:3000    |
| Admin (Vue.js)  | 5173 | http://localhost:5173    |

Wait **10–15 seconds** for everything to come up.

---

## 2. Check the System Is Working

From the project root:

```powershell
.\SYSTEM-CHECK-AND-DEBUG.ps1
```

This checks:

- API, ML, Portal, Admin are online  
- Database connection  
- User/threat/document counts  
- Learning system  
- Counter-offensive endpoint  

You can also run:

```powershell
.\CHECK-ALL-SERVICES.ps1
```

for a simpler service-only check.

---

## 3. Quick Manual Checks

**API + DB:**

```powershell
Invoke-RestMethod -Uri "http://localhost:8000/api/health"
```

Expected: `success: true`, `status: "online"`, `database: "connected"`

**ML Service:**

```powershell
Invoke-RestMethod -Uri "http://localhost:5000/health"
```

Expected: `status: "healthy"`

**Portals (in browser):**

- Admin: http://localhost:5173  
- Portal: http://localhost:3000  

---

## 4. Login & Use the App

**Default admin (if seeded):**

- **Email:** `admin@sentinelai.com`  
- **Password:** `admin123`  

Use **Admin** (http://localhost:5173) or **Portal** (http://localhost:3000) to log in, then:

- View dashboard, threats, documents  
- Upload & process documents  
- Run simulations (including counter-offensive)

---

## 5. If Something Fails

| Issue              | What to do                                                                 |
|--------------------|----------------------------------------------------------------------------|
| **404 on /api/login** | Another app is on port 8000. Run `.\RUN-AND-VERIFY.ps1` or `.\FIX-PORT-8000-AND-START-API.ps1` |
| **MySQL errors**   | Run `.\SWITCH-TO-SQLITE.ps1`, then restart API (`C:\php81\php.exe artisan serve` in `backend\api`) |
| **API offline**    | `.\RUN-AND-VERIFY.ps1` or `cd backend\api` then `C:\php81\php.exe artisan serve` |
| **ML offline**     | `cd backend\ml-service` then `python app.py`                               |
| **Learning = 0**   | Run `.\QUICK-FIX-LEARNING.ps1` to process documents                        |
| **No admin user**  | Run `.\CREATE-ADMIN-USER.ps1`                                              |

---

## 6. Manual Start (Alternative to Script)

Use **4 terminals**:

**Terminal 1 – API:**

```powershell
cd E:\Cyberpunck\backend\api
C:\php81\php.exe artisan serve
```

**Terminal 2 – ML:**

```powershell
cd E:\Cyberpunck\backend\ml-service
python app.py
```

**Terminal 3 – Portal:**

```powershell
cd E:\Cyberpunck\frontend\portal
npm run dev
```

**Terminal 4 – Admin:**

```powershell
cd E:\Cyberpunck\frontend\admin-dashboard
npm run dev
```

Then run `.\SYSTEM-CHECK-AND-DEBUG.ps1` again to confirm everything is working.

---

## Summary

1. Run `.\START-ALL-SERVICES.ps1`  
2. Wait ~15 seconds  
3. Run `.\SYSTEM-CHECK-AND-DEBUG.ps1`  
4. Open http://localhost:5173 or http://localhost:3000 and log in  

For more detail, see `HOW-TO-CHECK-SYSTEM-WORKING.md` and `QUICK-START-GUIDE.md`.
