# 🚀 Quick Start Guide - SentinelAI X

## 📋 **Current Directory Issue**

**You're already in:** `E:\Cyberpunck\backend\api`

**So you DON'T need to:** `cd backend\api` (that would try to go to `E:\Cyberpunck\backend\api\backend\api` which doesn't exist)

**Just run:**
```powershell
C:\php81\php.exe artisan serve
```

---

## 🚀 **How to Start All Services**

### **Option 1: Use Scripts (Easiest)**

```powershell
# Start API Server
.\START-API-SERVER.ps1

# Or start all services
.\START-ALL-SERVICES.ps1
```

### **Option 2: Manual Start**

#### **Terminal 1: API Server**
```powershell
cd E:\Cyberpunck\backend\api
C:\php81\php.exe artisan serve
```

#### **Terminal 2: ML Service**
```powershell
cd E:\Cyberpunck\backend\ml-service
python app.py
```

#### **Terminal 3: Portal (Next.js)**
```powershell
cd E:\Cyberpunck\frontend\portal
npm run dev
```

#### **Terminal 4: Admin Dashboard (Vue.js)**
```powershell
cd E:\Cyberpunck\frontend\admin-dashboard
npm run dev
```

---

## ✅ **Verify Services Are Running**

### **Check API Server:**
```powershell
Invoke-WebRequest -Uri "http://localhost:8000/api/health" -UseBasicParsing
```

### **Check ML Service:**
```powershell
Invoke-WebRequest -Uri "http://localhost:5000/health" -UseBasicParsing
```

### **Check Portal:**
```powershell
Invoke-WebRequest -Uri "http://localhost:3000" -UseBasicParsing
```

### **Check Admin Dashboard:**
```powershell
Invoke-WebRequest -Uri "http://localhost:5173" -UseBasicParsing
```

---

## 🔧 **If MySQL is Down**

**Quick Fix - Use SQLite:**
```powershell
.\SWITCH-TO-SQLITE.ps1
```

Then restart API server:
```powershell
cd E:\Cyberpunck\backend\api
C:\php81\php.exe artisan serve
```

---

## 📊 **Service URLs**

- **API:** http://localhost:8000
- **ML Service:** http://localhost:5000
- **Portal:** http://localhost:3000
- **Admin Dashboard:** http://localhost:5173

---

## 🎯 **Quick Checklist**

- [ ] MySQL running (or use SQLite)
- [ ] API server running (http://localhost:8000)
- [ ] ML service running (http://localhost:5000)
- [ ] Portal running (http://localhost:3000)
- [ ] Admin Dashboard running (http://localhost:5173)

---

**Remember:** If you're already in `backend\api`, just run `C:\php81\php.exe artisan serve` directly! 🚀
