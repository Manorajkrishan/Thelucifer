# 🔧 Fix Database & Threat Actions - Complete Guide

## 🎯 **Problem Identified**

1. **Database Mismatch:**
   - System configured for **SQLite**
   - You're using **MySQL** (`sentinelai` database in phpMyAdmin)
   - Data is saving to SQLite, not MySQL!

2. **Threat Actions Not Created:**
   - `threat_actions` table exists but nothing is saved
   - No automatic creation when threats are detected
   - No API endpoint to create threat actions

---

## ✅ **Solution Implemented**

### **1. Database Switch to MySQL**

Created script: `SWITCH-TO-MYSQL.ps1`

**What it does:**
- Updates `.env` to use MySQL
- Sets database to `sentinelai`
- Runs migrations on MySQL
- Seeds database

### **2. Threat Actions Auto-Creation**

**Added:**
- `ThreatActionController.php` - Full CRUD for threat actions
- Auto-create threat actions when threats are detected
- API endpoints for manual creation

**Auto-creation logic:**
- **Severity >= 8 (Critical):** Block IP + Isolation + Alert
- **Severity >= 5 (High):** Firewall Rule + Alert
- **All threats:** Alert action

---

## 🚀 **How to Fix**

### **Step 1: Switch to MySQL**

```powershell
.\SWITCH-TO-MYSQL.ps1
```

This will:
1. Update `.env` file
2. Test MySQL connection
3. Run migrations
4. Seed database

### **Step 2: Restart Laravel Server**

```powershell
# Stop current server (Ctrl+C)
cd backend\api
C:\php81\php.exe artisan serve
```

### **Step 3: Verify in phpMyAdmin**

1. Go to: http://localhost/phpmyadmin
2. Select database: `sentinelai`
3. Check tables:
   - ✅ `threats`
   - ✅ `threat_actions`
   - ✅ `documents`
   - ✅ `incidents`
   - ✅ `users`

### **Step 4: Test Threat Actions**

**Option A: Create a Threat (Auto-creates actions)**
```powershell
# Login first
$loginBody = @{email="admin@sentinelai.com";password="admin123"} | ConvertTo-Json
$response = Invoke-RestMethod -Uri "http://localhost:8000/api/login" -Method POST -Body $loginBody -ContentType "application/json"
$token = $response.token

# Create threat (will auto-create actions)
$threatBody = @{
    type = "SQL Injection"
    severity = 8
    source_ip = "192.168.1.100"
    description = "Test threat for threat_actions"
} | ConvertTo-Json

$threat = Invoke-RestMethod -Uri "http://localhost:8000/api/threats" -Method POST -Body $threatBody -ContentType "application/json" -Headers @{Authorization="Bearer $token"}

Write-Host "Threat created: $($threat.data.id)"
Write-Host "Check threat_actions table in phpMyAdmin!"
```

**Option B: Use Portal/Admin Dashboard**
- Create a threat via UI
- Threat actions will be created automatically
- Check `threat_actions` table in phpMyAdmin

**Option C: Manual Creation**
```powershell
# Create threat action manually
$actionBody = @{
    threat_id = 1
    action_type = "block_ip"
    action_details = @{ip = "192.168.1.100"}
    status = "pending"
} | ConvertTo-Json

Invoke-RestMethod -Uri "http://localhost:8000/api/threat-actions" -Method POST -Body $actionBody -ContentType "application/json" -Headers @{Authorization="Bearer $token"}
```

---

## 📊 **API Endpoints Added**

### **Threat Actions:**

- `GET /api/threat-actions` - List all actions
- `POST /api/threat-actions` - Create action
- `POST /api/threat-actions/auto-create` - Auto-create for threat
- `GET /api/threat-actions/{id}` - Get action
- `PUT /api/threat-actions/{id}` - Update action
- `DELETE /api/threat-actions/{id}` - Delete action

### **Query Parameters:**

- `?threat_id=1` - Filter by threat
- `?status=pending` - Filter by status
- `?action_type=block_ip` - Filter by type

---

## 🔍 **Verify It's Working**

### **1. Check Database Connection:**

```powershell
cd backend\api
C:\php81\php.exe artisan db:show
```

Should show MySQL connection.

### **2. Check Tables:**

```powershell
C:\php81\php.exe artisan tinker
```

```php
DB::table('threat_actions')->count()
DB::table('threats')->count()
```

### **3. Check in phpMyAdmin:**

1. Open: http://localhost/phpmyadmin
2. Select: `sentinelai` database
3. Check: `threat_actions` table
4. Should see records after creating threats!

---

## 🎯 **Expected Results**

After switching to MySQL and creating a threat:

1. **Threat saved** in `threats` table
2. **Threat actions auto-created** in `threat_actions` table:
   - For severity >= 8: 3 actions (block_ip, isolation, alert)
   - For severity >= 5: 2 actions (firewall_rule, alert)
   - For others: 1 action (alert)

3. **All data visible** in phpMyAdmin

---

## 🐛 **Troubleshooting**

### **Issue: MySQL connection failed**
- **Solution:** Make sure MySQL is running (XAMPP)
- Check MySQL port (3306)
- Verify username/password in `.env`

### **Issue: Migrations failed**
- **Solution:** Run manually:
  ```powershell
  cd backend\api
  C:\php81\php.exe artisan migrate:fresh --force
  ```

### **Issue: Threat actions still not created**
- **Solution:** Check Laravel logs:
  ```powershell
  Get-Content storage\logs\laravel.log -Tail 50
  ```
- Verify `ThreatAction` model exists
- Check foreign key constraints

---

## ✅ **Status**

- ✅ Database switch script created
- ✅ Threat actions auto-creation implemented
- ✅ API endpoints added
- ✅ Manual creation available

**Run `SWITCH-TO-MYSQL.ps1` and restart server!** 🚀
