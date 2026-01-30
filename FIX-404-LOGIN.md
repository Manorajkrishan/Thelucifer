# Fix: 404 on `/api/login`

## What’s going on

- **404 on `http://localhost:8000/api/login`** means the request reaches something on port 8000, but that app has no `/api/login` route.
- **`admin123` is correct** — the login form uses `admin@sentinelai.com` / `admin123`. You never get “wrong password” because the login request doesn’t hit the SentinelAI API.

## Root cause

**Port 8000 is used by a different app** (e.g. “Smart Function Recommender” or another API).  
The SentinelAI **Laravel API** must run on 8000 (or whatever URL the frontend uses). If another process is on 8000, the frontend talks to that app instead, which returns 404 for `/api/login`.

**Portal proxy (default):** The Next.js Portal rewrites `/api/*` to `http://localhost:8000/api/*`. Login uses same-origin `/api/login`, so no CORS. **Restart the Portal** after config changes (`npm run dev` in `frontend/portal`).

## Fix

### 1. Stop whatever is on port 8000

Find and stop the process using port 8000:

```powershell
# See what’s on 8000 (Windows)
netstat -ano | findstr :8000
# Kill the PID (replace 12345 with the PID from above)
taskkill /PID 12345 /F
```

### 2. Start the SentinelAI Laravel API

From the project root:

```powershell
cd E:\Cyberpunck\backend\api
C:\php81\php.exe artisan serve
```

Or use the script:

```powershell
.\START-API-SERVER.ps1
```

Keep this terminal open. The API should be at `http://localhost:8000`.

### 3. Check the API

```powershell
Invoke-RestMethod -Uri "http://localhost:8000/api/health"
# Expect: success, status "online", database "connected"

$body = @{ email = "admin@sentinelai.com"; password = "admin123" } | ConvertTo-Json
Invoke-RestMethod -Uri "http://localhost:8000/api/login" -Method POST -Body $body -ContentType "application/json"
# Expect: success, token, user (no 404)
```

### 4. Log in again from the app

- **Portal:** http://localhost:3000 → Login  
- **Admin:** http://localhost:5173 → Login  

Use **admin@sentinelai.com** / **admin123** (after the admin user exists; run `.\CREATE-ADMIN-USER.ps1` if needed).

## Using a different port (e.g. 8001)

If you must keep the other app on 8000:

1. Start Laravel on 8001:
   ```powershell
   cd E:\Cyberpunck\backend\api
   C:\php81\php.exe artisan serve --port=8001
   ```

2. Point the frontend at 8001:
   - **Portal:** set `NEXT_PUBLIC_API_URL=http://localhost:8001` (e.g. in `.env.local`) and restart `npm run dev`.
   - **Admin:** set `VITE_API_URL=http://localhost:8001` and restart `npm run dev`.

## Summary

| Issue | Cause | Fix |
|-------|--------|-----|
| 404 on `/api/login` | Wrong app on port 8000 | Stop it, start Laravel API on 8000 |
| “Wrong password” | N/A for 404 | Check credentials only after 404 is fixed |
| Password | `admin123` | Correct for `admin@sentinelai.com` |

After the Laravel API is the only thing on 8000 (or the frontend uses its actual URL), login should work with **admin@sentinelai.com** / **admin123**.
