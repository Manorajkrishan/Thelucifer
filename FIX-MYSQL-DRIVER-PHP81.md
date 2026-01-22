# 🔧 Fix MySQL Driver for PHP 8.1

## ❌ **Problem**

PHP 8.1 at `C:\php81` doesn't have MySQL extension DLL files. The standalone PHP 8.1 ZIP doesn't include them by default.

## ✅ **Solution: Download MySQL Extensions**

### Step 1: Check Current Status

```powershell
# Check what's in PHP 8.1 extensions folder
Get-ChildItem "C:\php81\ext" -Filter "*mysql*"
```

### Step 2: Download MySQL Extensions for PHP 8.1

**Option A: Download from PECL (Official)**
1. Go to: https://pecl.php.net/package/pdo_mysql
2. Download Windows DLL for PHP 8.1 Thread Safe (TS) x64
3. Extract `php_pdo_mysql.dll` to `C:\php81\ext\`

**Option B: Copy from PHP 8.1 Thread Safe Full Installation**
- If you have a full PHP 8.1 installation, copy:
  - `php_pdo_mysql.dll`
  - `php_mysqli.dll`
  - `libmysql.dll` (may be in PHP root, not ext folder)

**Option C: Use Precompiled Binaries**
- Download from: https://windows.php.net/downloads/pecl/releases/
- Look for: `pdo_mysql` or `mysqli` for PHP 8.1 TS x64

### Step 3: Enable in php.ini

After DLL files are in place, make sure these are uncommented in `C:\php81\php.ini`:

```ini
extension=pdo_mysql
extension=mysqli
```

### Step 4: Verify

```powershell
C:\php81\php.exe -m | Select-String "pdo_mysql|mysqli"
```

You should see:
- `pdo_mysql`
- `mysqli`
- `mysqlnd` (usually included)

---

## 🎯 **Quick Workaround: Use PHP 8.1 from Different Source**

**Download PHP 8.1 with Extensions:**

1. Go to: https://windows.php.net/download/
2. Download **"VS16 x64 Thread Safe (TS)"** ZIP (not Non Thread Safe)
3. Extract and replace your `C:\php81` folder
4. This version usually includes MySQL extensions

---

## 💡 **Alternative: Lower Laravel Requirement (Quick Fix)**

If MySQL extensions are hard to get, temporarily change Laravel version:

**Edit `backend/api/composer.json`:**
```json
"require": {
    "php": "^8.0",  // Change from ^8.1
    "laravel/framework": "^9.0",  // Change from ^10.10
}
```

Then:
```powershell
cd backend\api
composer update
```

Now you can use XAMPP's PHP 8.0 which has MySQL support!

---

## 🚀 **Recommended Quick Solution**

**Use SQLite for now** (no setup needed):

1. **Update `.env`** in `backend/api/.env`:
   ```
   DB_CONNECTION=sqlite
   DB_DATABASE=database/database.sqlite
   ```

2. **Create SQLite file**:
   ```powershell
   cd E:\Cyberpunck\backend\api
   New-Item -ItemType File -Path "database\database.sqlite" -Force
   ```

3. **Run migrations**:
   ```powershell
   C:\php81\php.exe artisan migrate
   C:\php81\php.exe artisan db:seed --class=UserSeeder
   ```

SQLite works without any extensions - perfect for development!

---

**Status**: Need MySQL DLLs for PHP 8.1, or use SQLite! 🚀
