# 🔧 Troubleshooting Guide

## ✅ **500 Internal Server Error - FIXED!**

### What Was Wrong:
1. **Missing Base Controller Class** ✅ **FIXED**
   - Error: `Class "App\Http\Controllers\Controller" not found`
   - Solution: Created `backend/api/app/Http/Controllers/Controller.php`

2. **Database Connection Issues** ⚠️ **NEEDS SETUP**
   - Error: `could not connect to server: Connection refused`
   - Solution: Start MySQL in XAMPP and run migrations

### Current Status:
✅ All routes are now loading correctly:
- `/api/login` - Login endpoint
- `/api/register` - Registration endpoint
- `/api/threats` - Threat management
- `/api/documents` - Document management
- All other API endpoints

---

## 🔍 **Common 500 Errors & Solutions**

### 1. Database Connection Error

**Error:**
```
SQLSTATE[HY000] [2002] Connection refused
could not connect to server
```

**Solution:**
```powershell
# Start MySQL in XAMPP Control Panel
# Then test connection:
cd E:\Cyberpunck\backend\api
C:\php81\php.exe artisan migrate
```

### 2. Missing Controller Class

**Error:**
```
Class "App\Http\Controllers\Controller" not found
```

**Status:** ✅ **FIXED** - Base Controller created

### 3. Missing Model Classes

**Error:**
```
Class "App\Models\Threat" not found
```

**Solution:**
```powershell
cd E:\Cyberpunck\backend\api
C:\php81\php.exe artisan config:clear
C:\php81\php.exe artisan cache:clear
composer dump-autoload
```

### 4. Route Not Found (404)

**Error:**
```
404 Not Found
Route [api/login] not defined
```

**Solution:**
```powershell
cd E:\Cyberpunck\backend\api
C:\php81\php.exe artisan route:clear
C:\php81\php.exe artisan route:list
```

### 5. Authentication Token Issues

**Error:**
```
Unauthenticated
Invalid token
```

**Solution:**
- Make sure you're sending the token in the Authorization header:
  ```
  Authorization: Bearer YOUR_TOKEN_HERE
  ```
- Token should be obtained from `/api/login` endpoint

### 6. CORS Errors

**Error:**
```
Access to XMLHttpRequest blocked by CORS policy
```

**Solution:**
- Check `config/cors.php` configuration
- Ensure `allowed_origins` includes your frontend URL
- Check `.env` file for CORS settings

---

## 🐛 **Debugging Steps**

### 1. Check Laravel Logs
```powershell
cd E:\Cyberpunck\backend\api
Get-Content storage\logs\laravel.log -Tail 50
```

### 2. Enable Debug Mode
In `.env` file:
```
APP_DEBUG=true
```

### 3. Clear All Caches
```powershell
cd E:\Cyberpunck\backend\api
C:\php81\php.exe artisan config:clear
C:\php81\php.exe artisan route:clear
C:\php81\php.exe artisan cache:clear
C:\php81\php.exe artisan view:clear
```

### 4. Check Database Connection
```powershell
C:\php81\php.exe artisan tinker
# In tinker:
DB::connection()->getPdo();
# Should return PDO object or show error
```

### 5. Verify Routes
```powershell
C:\php81\php.exe artisan route:list
```

### 6. Check PHP Extensions
```powershell
C:\php81\php.exe -m | Select-String "pdo|mysql|pgsql|curl|openssl"
```

---

## ✅ **Quick Fix Checklist**

If you get a 500 error, try these in order:

1. ✅ **Check Base Controller** - Make sure `app/Http/Controllers/Controller.php` exists
2. ✅ **Clear Caches** - Run `php artisan config:clear && php artisan cache:clear`
3. ✅ **Check Database** - Make sure MySQL is running in XAMPP
4. ✅ **Check Logs** - Look at `storage/logs/laravel.log`
5. ✅ **Verify Routes** - Run `php artisan route:list`
6. ✅ **Check Environment** - Verify `.env` file has correct settings

---

## 🔍 **Test API Endpoints**

### Test Login Endpoint:
```powershell
curl -X POST http://localhost:8000/api/login `
  -H "Content-Type: application/json" `
  -d '{\"email\":\"admin@sentinelai.com\",\"password\":\"admin123\"}'
```

### Test API Health:
```powershell
curl http://localhost:8000/api/threats
```

### Test User Endpoint (after login):
```powershell
curl http://localhost:8000/api/user `
  -H "Authorization: Bearer YOUR_TOKEN_HERE"
```

---

## 📝 **Common Issues & Solutions**

| Error | Cause | Solution |
|-------|-------|----------|
| `500 Internal Server Error` | Missing Controller class | ✅ Fixed - Base Controller created |
| `Connection refused` | Database not running | Start MySQL in XAMPP |
| `Could not find driver` | PHP extension missing | ✅ Fixed - Extensions enabled |
| `Route not found` | Cache issue | Run `php artisan route:clear` |
| `Unauthenticated` | Missing/invalid token | Get token from `/api/login` |
| `Class not found` | Autoload issue | Run `composer dump-autoload` |

---

## ✅ **Current Status**

- ✅ Base Controller created
- ✅ All routes loading
- ✅ PostgreSQL/MySQL extensions enabled
- ⚠️ Need to start MySQL and run migrations

---

**Next Steps**: Start MySQL in XAMPP and run migrations! 🚀
