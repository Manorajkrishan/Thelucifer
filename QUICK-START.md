# 🚀 Quick Start Guide - SentinelAI X

## ⚡ **Fastest Way to Start Everything**

### **Option 1: Use the Automated Script (Easiest)**

```powershell
.\START-ALL-SERVICES.ps1
```

This will:
- ✅ Start all 4 services in separate windows
- ✅ Show you the access URLs
- ✅ Run a quick test to verify everything works

---

## 🖥️ **Option 2: Manual Start (Step by Step)**

### **Step 1: Start Laravel API** (Port 8000)

Open **Terminal 1:**
```powershell
cd backend\api
C:\php81\php.exe artisan serve
```

**Wait for:** `Laravel development server started: http://127.0.0.1:8000`

---

### **Step 2: Start ML Service** (Port 5000)

Open **Terminal 2:**
```powershell
cd backend\ml-service
python app.py
```

**Wait for:** `Running on http://127.0.0.1:5000`

---

### **Step 3: Start Portal** (Port 3000)

Open **Terminal 3:**
```powershell
cd frontend\portal
npm run dev
```

**Wait for:** `Ready on http://localhost:3000`

---

### **Step 4: Start Admin Dashboard** (Port 5173)

Open **Terminal 4:**
```powershell
cd frontend\admin-dashboard
npm run dev
```

**Wait for:** `Local: http://localhost:5173`

---

## 🌐 **Access URLs**

Once all services are running:

| Service | URL | Purpose |
|---------|-----|---------|
| **Portal** | http://localhost:3000 | Public user interface |
| **Admin Dashboard** | http://localhost:5173 | Admin control panel |
| **API** | http://localhost:8000 | Backend API |
| **ML Service** | http://localhost:5000 | Machine learning service |

---

## ✅ **Verify Everything is Running**

Run this quick test:
```powershell
.\QUICK-TEST.ps1
```

Or manually check:
1. **API:** Open http://localhost:8000 in browser
2. **Portal:** Open http://localhost:3000 in browser
3. **Admin:** Open http://localhost:5173 in browser
4. **ML Service:** Open http://localhost:5000/health in browser

---

## 🔐 **Login Credentials**

### **Admin Dashboard:**
- Email: `admin@sentinelai.com`
- Password: `admin123`

### **Portal:**
- Email: `admin@sentinelai.com`
- Password: `admin123`

---

## 📋 **Prerequisites Checklist**

Before starting, make sure you have:

- [x] **PHP 8.1** installed (at `C:\php81\php.exe`)
- [x] **Python** installed (for ML service)
- [x] **Node.js & npm** installed (for frontend)
- [x] **Composer** installed (for Laravel)
- [x] **Database** set up (SQLite is configured by default)

---

## 🐛 **Troubleshooting**

### **Port Already in Use?**

If a port is busy, you can change it:

**Laravel API:**
```powershell
C:\php81\php.exe artisan serve --port=8001
```

**Portal:**
Edit `frontend/portal/package.json` scripts or use:
```powershell
npm run dev -- -p 3001
```

**Admin Dashboard:**
Edit `frontend/admin-dashboard/vite.config.js` or use:
```powershell
npm run dev -- --port 5174
```

### **Service Won't Start?**

1. **Check if dependencies are installed:**
   ```powershell
   # Laravel
   cd backend\api
   composer install
   
   # ML Service
   cd backend\ml-service
   pip install -r requirements.txt
   
   # Frontend
   cd frontend\portal
   npm install
   
   cd ..\admin-dashboard
   npm install
   ```

2. **Check database:**
   ```powershell
   cd backend\api
   C:\php81\php.exe artisan migrate
   ```

3. **Check logs:**
   - Laravel: `backend\api\storage\logs\laravel.log`
   - ML Service: Check terminal output

---

## 🎯 **Quick Commands Reference**

```powershell
# Start all services (automated)
.\START-ALL-SERVICES.ps1

# Test all services
.\QUICK-TEST.ps1

# Start Laravel API only
cd backend\api
C:\php81\php.exe artisan serve

# Start ML Service only
cd backend\ml-service
python app.py

# Start Portal only
cd frontend\portal
npm run dev

# Start Admin Dashboard only
cd frontend\admin-dashboard
npm run dev
```

---

## 📊 **Service Status**

After starting, you should see:

✅ **Laravel API** - Running on port 8000  
✅ **ML Service** - Running on port 5000  
✅ **Portal** - Running on port 3000  
✅ **Admin Dashboard** - Running on port 5173  

---

## 🎉 **You're Ready!**

1. Open **Portal:** http://localhost:3000
2. Open **Admin Dashboard:** http://localhost:5173
3. Login and start using the system!

---

**Need help?** Check `TESTING-GUIDE.md` for detailed testing instructions.
