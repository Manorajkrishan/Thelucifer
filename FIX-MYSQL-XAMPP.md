# 🔧 Fix MySQL Shutdown in XAMPP

## 🎯 **Problem**

MySQL in XAMPP is shutting down unexpectedly with error:
```
Error: MySQL shutdown unexpectedly.
This may be due to a blocked port, missing dependencies, 
improper privileges, a crash, or a shutdown by another method.
```

---

## ✅ **Quick Fixes**

### **Fix 1: Port 3306 Already in Use**

**Most common cause:** Another MySQL instance or service is using port 3306.

**Solution:**
```powershell
# Check what's using port 3306
Get-NetTCPConnection -LocalPort 3306

# Kill the process (if safe to do so)
# Find the process ID from above, then:
Stop-Process -Id <PID> -Force
```

**Or use the script:**
```powershell
.\FIX-MYSQL-SHUTDOWN.ps1
```

---

### **Fix 2: Stop Conflicting MySQL Services**

**Check Windows Services:**
```powershell
Get-Service | Where-Object {$_.Name -like "*mysql*"}
```

**Stop conflicting services:**
```powershell
Stop-Service -Name "MySQL80" -Force  # If exists
Stop-Service -Name "MySQL" -Force     # If exists
```

---

### **Fix 3: Check MySQL Error Log**

1. **Open XAMPP Control Panel**
2. **Click "Logs" button** next to MySQL
3. **Check the error log** for specific errors

**Common errors:**
- Port already in use
- Data directory corruption
- Permission issues
- Missing dependencies

---

### **Fix 4: Repair MySQL Data Directory**

**If data directory is corrupted:**

1. **Stop XAMPP**
2. **Backup data:**
   ```powershell
   Copy-Item "C:\xampp\mysql\data" "C:\xampp\mysql\data.backup" -Recurse
   ```
3. **Delete data directory:**
   ```powershell
   Remove-Item "C:\xampp\mysql\data" -Recurse -Force
   ```
4. **Restart XAMPP** - It will recreate the data directory
5. **Restore your databases** from backup if needed

---

### **Fix 5: Check XAMPP MySQL Configuration**

**Check `my.ini` file:**
- Location: `C:\xampp\mysql\bin\my.ini`
- Check port setting: `port=3306`
- Check data directory: `datadir="C:/xampp/mysql/data"`

**Common issues:**
- Wrong port number
- Wrong data directory path
- Invalid configuration

---

### **Fix 6: Use SQLite (Temporary Solution)**

**If MySQL keeps failing, switch to SQLite:**

```powershell
.\SWITCH-TO-SQLITE.ps1
```

This will:
- Switch Laravel to use SQLite
- Create SQLite database
- Run migrations
- Seed database

**To switch back to MySQL later:**
```powershell
cd backend\api
Copy-Item ".env.mysql.backup" ".env" -Force
cd ..\..
```

---

## 🔍 **Diagnostic Steps**

### **Step 1: Check Port 3306**
```powershell
Get-NetTCPConnection -LocalPort 3306
```

### **Step 2: Check MySQL Processes**
```powershell
Get-Process -Name "mysqld","mysql" -ErrorAction SilentlyContinue
```

### **Step 3: Check MySQL Logs**
```powershell
Get-Content "C:\xampp\mysql\data\*.err" -Tail 20
```

### **Step 4: Check Windows Services**
```powershell
Get-Service | Where-Object {$_.Name -like "*mysql*"}
```

---

## 🚀 **Quick Fix Script**

Run this to automatically diagnose and fix:
```powershell
.\FIX-MYSQL-SHUTDOWN.ps1
```

This will:
- Check port 3306
- Find conflicting processes
- Check MySQL logs
- Provide solutions

---

## 📋 **Step-by-Step Fix**

### **Method 1: Kill Conflicting Processes**

1. **Check what's using port 3306:**
   ```powershell
   Get-NetTCPConnection -LocalPort 3306
   ```

2. **Kill the process:**
   ```powershell
   Stop-Process -Id <PID> -Force
   ```

3. **Restart XAMPP MySQL**

### **Method 2: Stop Windows MySQL Service**

1. **Open Services:**
   ```powershell
   services.msc
   ```

2. **Find MySQL services:**
   - MySQL80
   - MySQL
   - Any other MySQL service

3. **Stop them:**
   ```powershell
   Stop-Service -Name "MySQL80" -Force
   ```

4. **Set to Manual (so it doesn't auto-start):**
   ```powershell
   Set-Service -Name "MySQL80" -StartupType Manual
   ```

5. **Restart XAMPP MySQL**

### **Method 3: Reinstall MySQL in XAMPP**

1. **Stop XAMPP**
2. **Backup databases:**
   ```powershell
   Copy-Item "C:\xampp\mysql\data" "C:\xampp\mysql\data.backup" -Recurse
   ```
3. **Delete data directory:**
   ```powershell
   Remove-Item "C:\xampp\mysql\data" -Recurse -Force
   ```
4. **Start XAMPP MySQL** (will recreate data directory)
5. **Restore databases** if needed

---

## ⚠️ **If Nothing Works**

### **Use SQLite Instead:**

```powershell
.\SWITCH-TO-SQLITE.ps1
```

This switches the system to SQLite, which:
- ✅ Doesn't require a separate service
- ✅ Works immediately
- ✅ No port conflicts
- ✅ Perfect for development

**Note:** You can switch back to MySQL later when it's fixed.

---

## ✅ **After Fixing MySQL**

1. **Verify MySQL is running:**
   - Check XAMPP Control Panel
   - Green "Running" status

2. **Test connection:**
   ```powershell
   cd backend\api
   C:\php81\php.exe artisan tinker
   ```
   ```php
   DB::connection()->getPdo()
   ```

3. **Restart API server:**
   ```powershell
   cd backend\api
   C:\php81\php.exe artisan serve
   ```

---

## 🎯 **Quick Checklist**

- [ ] Check port 3306 is free
- [ ] Stop conflicting MySQL processes
- [ ] Stop Windows MySQL services
- [ ] Check MySQL error logs
- [ ] Restart XAMPP
- [ ] If still failing, use SQLite

---

**Run `.\FIX-MYSQL-SHUTDOWN.ps1` for automated diagnosis!** 🚀
