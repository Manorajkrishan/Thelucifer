# 🔧 Quick Fix: API Server Offline

## ✅ **Problem Solved!**

The API server was offline. It has been started successfully!

---

## 🚀 **Status**

- ✅ **API Server:** Now running on http://localhost:8000
- ✅ **ML Service:** Online on http://localhost:5000
- ✅ **Database:** Connected
- ✅ **Admin Dashboard:** Can now access API

---

## 📝 **What Happened**

The Laravel API server needs to be running for the admin dashboard to work. It was stopped or not started.

**Solution:** Created `START-API-SERVER.ps1` script that:
1. Checks if server is running
2. Starts it if not
3. Verifies it's working

---

## 🔄 **How to Keep It Running**

### **Option 1: Use the Script (Easiest)**
```powershell
.\START-API-SERVER.ps1
```

This will:
- Check if server is running
- Start it if needed
- Verify it's working

### **Option 2: Manual Start**
```powershell
cd backend\api
C:\php81\php.exe artisan serve
```

**Keep the terminal window open** while using the system!

---

## ✅ **Verify It's Working**

### **1. Check Admin Dashboard Settings:**
- Go to: http://localhost:5173/settings
- Refresh the page
- API Status should now show: **✅ ONLINE**

### **2. Test API Directly:**
```powershell
Invoke-WebRequest -Uri "http://localhost:8000" -UseBasicParsing
```

Should return Status Code: 200

### **3. Check All Services:**
```powershell
.\CHECK-ALL-SERVICES.ps1
```

This checks:
- ✅ API Server
- ✅ ML Service
- ✅ Portal
- ✅ Admin Dashboard
- ✅ Database

---

## 🎯 **Quick Reference**

| Service | URL | Status Check |
|---------|-----|-------------|
| **API Server** | http://localhost:8000 | `.\START-API-SERVER.ps1` |
| **ML Service** | http://localhost:5000 | Check terminal |
| **Portal** | http://localhost:3000 | Check terminal |
| **Admin Dashboard** | http://localhost:5173 | Check terminal |

---

## 💡 **Tips**

1. **Keep API Server Running:**
   - Don't close the server window
   - Use `START-API-SERVER.ps1` to restart if needed

2. **Auto-Start on Boot:**
   - You can add the server to Windows startup
   - Or use a task scheduler

3. **Check Status:**
   - Use `CHECK-ALL-SERVICES.ps1` anytime
   - Or check Admin Dashboard Settings page

---

## ✅ **Current Status**

✅ **API Server:** Running  
✅ **ML Service:** Online  
✅ **Database:** Connected  
✅ **All Services:** Operational  

**You can now use the admin dashboard fully!** 🎉

---

## 🐛 **If Server Stops Again**

1. Run: `.\START-API-SERVER.ps1`
2. Or manually: `cd backend\api && C:\php81\php.exe artisan serve`
3. Check for errors in the server window
4. Verify MySQL is running (if using MySQL)

---

**Everything is working now!** 🚀
