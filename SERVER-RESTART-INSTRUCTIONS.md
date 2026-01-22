# 🔄 Server Restart Instructions

## ❌ **Current Issue:**
The HTTP server is still returning 500 errors because it's using an old PHP process that doesn't have SQLite extensions loaded.

## ✅ **Solution: Properly Restart the Server**

### **Step 1: Find and Stop ALL PHP Processes**

```powershell
# Find all PHP processes
Get-Process | Where-Object { $_.ProcessName -like "*php*" } | Stop-Process -Force

# Or manually:
# Press Ctrl+C in the terminal where artisan serve is running
```

### **Step 2: Verify PHP Extensions**

```powershell
C:\php81\php.exe -m | Select-String "pdo_sqlite|sqlite3"
```

Should show:
- `pdo_sqlite`
- `sqlite3`

### **Step 3: Start Server with Correct PHP**

```powershell
cd E:\Cyberpunck\backend\api
C:\php81\php.exe artisan serve --port=8000
```

**IMPORTANT:** Make sure you're using `C:\php81\php.exe` (not just `php` which might point to a different version)

### **Step 4: Test Login**

In a **NEW** PowerShell window:

```powershell
$body = @{
    email = "admin@sentinelai.com"
    password = "admin123"
} | ConvertTo-Json

Invoke-RestMethod -Uri "http://localhost:8000/api/login" -Method POST -Body $body -ContentType "application/json"
```

---

## 🔍 **Why This Happens:**

1. PHP extensions load when PHP starts
2. If the server was started before extensions were enabled, it won't have them
3. The server process needs to be completely stopped and restarted
4. Make sure you're using the correct PHP executable (`C:\php81\php.exe`)

---

## ✅ **Verification:**

After restarting, you should see:
- ✅ Server starts without errors
- ✅ Login endpoint returns 200 OK (not 500)
- ✅ Token is returned in response

---

## 🚨 **If Still Not Working:**

1. **Check which PHP the server is using:**
   ```powershell
   # In the server terminal, check:
   php -v
   php -m | Select-String "sqlite"
   ```

2. **Kill all PHP processes and restart:**
   ```powershell
   Get-Process php* | Stop-Process -Force
   cd E:\Cyberpunck\backend\api
   C:\php81\php.exe artisan serve --port=8000
   ```

3. **Verify the server is using PHP 8.1:**
   - The server should show: `PHP 8.1.27` when it starts
   - If it shows a different version, you're using the wrong PHP

---

**Status:** Everything is configured correctly - just need to ensure the server is restarted with the correct PHP! 🚀
