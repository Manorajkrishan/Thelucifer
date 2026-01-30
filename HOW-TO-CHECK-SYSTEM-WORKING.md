# 🔍 How to Check if System is Working

## 🎯 **Quick System Check**

### **Run the Check Script:**
```powershell
.\SYSTEM-CHECK-AND-DEBUG.ps1
```

This will check:
- ✅ All services (API, ML, Portal, Admin)
- ✅ Database connection
- ✅ Data in database
- ✅ Learning system
- ✅ Counter-offensive system
- ✅ Error logs

---

## 📊 **Manual Checks**

### **1. Check Services Are Running**

#### **API Server:**
```powershell
Invoke-WebRequest -Uri "http://localhost:8000/api/health" -UseBasicParsing
```
**Should return:** `{"success":true,"status":"online","database":"connected"}`

#### **ML Service:**
```powershell
Invoke-WebRequest -Uri "http://localhost:5000/health" -UseBasicParsing
```
**Should return:** `{"status":"healthy"}`

#### **Portal:**
```powershell
Invoke-WebRequest -Uri "http://localhost:3000" -UseBasicParsing
```
**Should return:** Status 200

#### **Admin Dashboard:**
```powershell
Invoke-WebRequest -Uri "http://localhost:5173" -UseBasicParsing
```
**Should return:** Status 200

---

### **2. Check Database**

```powershell
cd backend\api
C:\php81\php.exe artisan tinker
```

Then in tinker:
```php
// Check connection
DB::connection()->getPdo()

// Check data
App\Models\User::count()
App\Models\Threat::count()
App\Models\Document::count()
App\Models\Document::where('status', 'processed')->count()
```

---

### **3. Check Learning System**

```powershell
Invoke-RestMethod -Uri "http://localhost:5000/api/v1/learning/summary" -Method GET
```

**Should return:**
```json
{
  "success": true,
  "summary": {
    "total_documents": 4,
    "total_patterns_learned": 50,
    "unique_attack_techniques": 10,
    ...
  }
}
```

**If shows 0:**
- Documents need to be processed
- Run: `.\QUICK-FIX-LEARNING.ps1`

---

### **4. Test Counter-Offensive System**

```powershell
$testData = @{
    attack_data = @{
        source_ip = "192.168.1.100"
        target_ip = "192.168.1.50"
        attack_type = "trojan"
        severity = 8
        description = "Test attack"
    }
} | ConvertTo-Json

Invoke-RestMethod -Uri "http://localhost:5000/api/v1/counter-offensive/execute" -Method POST -Body $testData -ContentType "application/json"
```

**Should return:**
```json
{
  "success": true,
  "attacker_profile": {...},
  "validation": {...},
  "counter_offensive": {...},
  "war_loop": {...}
}
```

---

## 🐛 **Common Issues & Fixes**

### **Issue 1: Nothing Shows in System**

#### **Symptoms:**
- Dashboard shows 0 threats
- Learning shows 0 documents
- No data anywhere

#### **Causes:**
1. **No data in database** - Need to create threats/documents
2. **Documents not processed** - Need to process documents
3. **Services not running** - Need to start services

#### **Fixes:**

**A. Create Test Data:**
```powershell
# Login first
$login = Invoke-RestMethod -Uri "http://localhost:8000/api/login" -Method POST -Body (@{email="admin@sentinelai.com";password="admin123"} | ConvertTo-Json) -ContentType "application/json"
$token = $login.token

# Create a threat
$threat = @{
    type = "malware"
    severity = 7
    source_ip = "192.168.1.100"
    description = "Test threat"
} | ConvertTo-Json

Invoke-RestMethod -Uri "http://localhost:8000/api/threats" -Method POST -Body $threat -ContentType "application/json" -Headers @{Authorization="Bearer $token"}
```

**B. Process Documents:**
```powershell
.\QUICK-FIX-LEARNING.ps1
```

**C. Start Services:**
```powershell
# Terminal 1: API
cd backend\api
C:\php81\php.exe artisan serve

# Terminal 2: ML Service
cd backend\ml-service
python app.py

# Terminal 3: Portal
cd frontend\portal
npm run dev

# Terminal 4: Admin Dashboard
cd frontend\admin-dashboard
npm run dev
```

---

### **Issue 2: Learning Shows 0**

#### **Cause:**
Documents uploaded but not processed

#### **Fix:**
```powershell
.\QUICK-FIX-LEARNING.ps1
```

Or manually:
1. Go to: http://localhost:5173/documents
2. Click "Process" on each document
3. Wait for processing
4. Check learning page

---

### **Issue 3: Counter-Offensive Not Working**

#### **Check:**
```powershell
# Test endpoint
$test = @{attack_data = @{source_ip = "1.1.1.1"; attack_type = "trojan"; severity = 8}} | ConvertTo-Json
Invoke-RestMethod -Uri "http://localhost:5000/api/v1/counter-offensive/execute" -Method POST -Body $test -ContentType "application/json"
```

#### **If Fails:**
1. **Check ML service is running:**
   ```powershell
   Invoke-WebRequest -Uri "http://localhost:5000/health" -UseBasicParsing
   ```

2. **Check ML service logs:**
   - Look at ML service terminal
   - Check for errors

3. **Verify endpoint exists:**
   ```powershell
   Invoke-WebRequest -Uri "http://localhost:5000/api/v1/counter-offensive/execute" -Method OPTIONS -UseBasicParsing
   ```

---

## ✅ **System Health Checklist**

- [ ] API Server running (http://localhost:8000)
- [ ] ML Service running (http://localhost:5000)
- [ ] Portal running (http://localhost:3000)
- [ ] Admin Dashboard running (http://localhost:5173)
- [ ] Database connected
- [ ] At least 1 user in database
- [ ] Can login (admin@sentinelai.com / admin123)
- [ ] Can create threats
- [ ] Can upload documents
- [ ] Can process documents
- [ ] Learning system shows data (after processing)
- [ ] Counter-offensive endpoint works

---

## 🚀 **Quick Start Guide**

### **1. Start All Services:**
```powershell
.\START-ALL-SERVICES.ps1
```

### **2. Check System:**
```powershell
.\SYSTEM-CHECK-AND-DEBUG.ps1
```

### **3. Process Documents:**
```powershell
.\QUICK-FIX-LEARNING.ps1
```

### **4. Test Counter-Offensive:**
```powershell
# Via Portal: http://localhost:3000/simulations
# Or via API (see test above)
```

---

## 📊 **Expected Results**

### **After Processing Documents:**
- Learning summary shows: Documents processed > 0
- Learning summary shows: Patterns learned > 0
- Documents status: "processed" (not "uploaded")

### **After Creating Threats:**
- Dashboard shows threat count
- Threats page shows threats
- Statistics update

### **After Testing Counter-Offensive:**
- Returns attacker profile
- Returns validation result
- Returns counter-offensive result (simulated)
- Returns war loop status

---

## 🔍 **Debugging Steps**

1. **Run system check:**
   ```powershell
   .\SYSTEM-CHECK-AND-DEBUG.ps1
   ```

2. **Check logs:**
   ```powershell
   # Laravel logs
   Get-Content backend\api\storage\logs\laravel.log -Tail 50
   
   # ML service logs (check terminal)
   ```

3. **Test endpoints individually:**
   ```powershell
   # API health
   Invoke-RestMethod -Uri "http://localhost:8000/api/health"
   
   # ML health
   Invoke-RestMethod -Uri "http://localhost:5000/health"
   
   # Learning summary
   Invoke-RestMethod -Uri "http://localhost:5000/api/v1/learning/summary"
   ```

4. **Check database:**
   ```powershell
   cd backend\api
   C:\php81\php.exe artisan tinker
   # Then run queries (see above)
   ```

---

**Use the system check script for comprehensive diagnostics!** 🚀
