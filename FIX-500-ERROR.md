# 🔧 How to Fix 500 Internal Server Error

## ✅ **Issue Fixed: Missing Base Controller**

The base `Controller` class has been created. However, you're still getting 500 errors likely due to database connection issues.

## 🔍 **Most Likely Cause: Database Not Running**

### Step 1: Check if MySQL is Running

```powershell
# Check if MySQL port is open
Test-NetConnection -ComputerName 127.0.0.1 -Port 3306
```

If it returns `False`, MySQL is **not running**.

### Step 2: Start MySQL in XAMPP

1. Open **XAMPP Control Panel**
2. Find **MySQL** in the list
3. Click **"Start"** button
4. Wait until status shows **"Running"** (green)

### Step 3: Create Database

**Option A: Using phpMyAdmin (Easiest)**
1. Go to: http://localhost/phpmyadmin
2. Click **"New"** in left sidebar
3. Database name: `sentinelai`
4. Collation: `utf8mb4_unicode_ci`
5. Click **"Create"**

**Option B: Using MySQL Command Line**
```powershell
cd C:\xampp\mysql\bin
.\mysql.exe -u root -e "CREATE DATABASE sentinelai;"
```

### Step 4: Run Migrations

```powershell
cd E:\Cyberpunck\backend\api

# Clear any cached config
C:\php81\php.exe artisan config:clear

# Run migrations
C:\php81\php.exe artisan migrate

# Create default users
C:\php81\php.exe artisan db:seed --class=UserSeeder
```

### Step 5: Test API

```powershell
# Test threats endpoint
curl http://localhost:8000/api/threats

# Test login
curl -X POST http://localhost:8000/api/login `
  -H "Content-Type: application/json" `
  -d '{\"email\":\"admin@sentinelai.com\",\"password\":\"admin123\"}'
```

## 🐛 **Other Possible Causes**

### 1. Wrong Database Configuration

Check your `.env` file (`backend/api/.env`):
```
DB_CONNECTION=mysql
DB_HOST=127.0.0.1
DB_PORT=3306
DB_DATABASE=sentinelai
DB_USERNAME=root
DB_PASSWORD=
```

If MySQL password is set in XAMPP, update `DB_PASSWORD` in `.env`.

### 2. Missing Tables

If migrations haven't run:
```powershell
C:\php81\php.exe artisan migrate
```

### 3. Permission Issues

Make sure Laravel can write to storage:
```powershell
# Check permissions
cd E:\Cyberpunck\backend\api
# Windows doesn't need chmod, but make sure storage folder exists
Test-Path storage\logs
```

### 4. Check Logs for Exact Error

```powershell
cd E:\Cyberpunck\backend\api
Get-Content storage\logs\laravel.log -Tail 50
```

Look for the actual error message at the top of the stack trace.

## ✅ **Quick Diagnostic Commands**

Run these to diagnose:

```powershell
cd E:\Cyberpunck\backend\api

# 1. Check if MySQL is running
Test-NetConnection -ComputerName 127.0.0.1 -Port 3306

# 2. Test database connection
C:\php81\php.exe artisan tinker --execute="DB::connection()->getPdo();"

# 3. Check routes
C:\php81\php.exe artisan route:list

# 4. Check latest error
Get-Content storage\logs\laravel.log -Tail 30
```

## 🎯 **Most Common Solution**

**90% of the time, it's because MySQL is not running:**

1. ✅ Open XAMPP Control Panel
2. ✅ Start MySQL
3. ✅ Create database `sentinelai`
4. ✅ Run `php artisan migrate`
5. ✅ Test API again

---

**Status**: Routes are fixed, just need database running! 🚀
