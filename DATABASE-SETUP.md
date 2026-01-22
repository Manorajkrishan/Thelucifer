# 🗄️ Database Setup Guide

## ✅ PostgreSQL Extension Fixed

The PostgreSQL PDO extension has been enabled in PHP 8.1. You should now be able to connect to PostgreSQL.

## 🔍 Verify PostgreSQL Extension

Run this command to verify:
```powershell
C:\php81\php.exe -m | Select-String "pdo_pgsql|pgsql"
```

You should see:
- `pdo_pgsql`
- `pgsql`

## 📋 Database Setup Steps

### Option 1: Using Docker (Recommended)

Start PostgreSQL with Docker:
```powershell
docker run -d --name sentinelai-postgres `
  -p 5432:5432 `
  -e POSTGRES_DB=sentinelai `
  -e POSTGRES_USER=sentinelai_user `
  -e POSTGRES_PASSWORD=sentinelai_password `
  postgres:15
```

### Option 2: Install PostgreSQL Locally

1. **Download PostgreSQL**: https://www.postgresql.org/download/windows/
2. **Install PostgreSQL** (remember the password you set!)
3. **Create Database**:
   ```sql
   CREATE DATABASE sentinelai;
   CREATE USER sentinelai_user WITH PASSWORD 'sentinelai_password';
   GRANT ALL PRIVILEGES ON DATABASE sentinelai TO sentinelai_user;
   ```

### Option 3: Use XAMPP (If installed)

XAMPP doesn't include PostgreSQL by default, so you'll need to:
- Install PostgreSQL separately, OR
- Use Docker (Option 1), OR
- Switch to MySQL (requires changing Laravel config)

## ✅ Test Database Connection

### Check if PostgreSQL is Running

```powershell
# Check if port 5432 is open
Test-NetConnection -ComputerName 127.0.0.1 -Port 5432
```

### Test Connection with PHP

```powershell
C:\php81\php.exe -r "try { `$pdo = new PDO('pgsql:host=127.0.0.1;port=5432;dbname=sentinelai', 'sentinelai_user', 'sentinelai_password'); echo 'Connection successful!'; } catch (Exception `$e) { echo 'Error: ' . `$e->getMessage(); }"
```

## 🚀 Run Migrations

Once PostgreSQL is running:

```powershell
cd E:\Cyberpunck\backend\api

# Run migrations
C:\php81\php.exe artisan migrate

# Seed users
C:\php81\php.exe artisan db:seed --class=UserSeeder
```

## 🔧 Troubleshooting

### Error: "could not find driver"

✅ **Fixed!** PostgreSQL extensions are now enabled in PHP 8.1.

### Error: "Connection refused" or "could not connect"

This means PostgreSQL is not running. Options:
1. Start PostgreSQL service (if installed locally)
2. Use Docker: `docker start sentinelai-postgres`
3. Check if port 5432 is being used by another service

### Error: "Authentication failed"

Check your `.env` file in `backend/api/.env`:
```
DB_CONNECTION=pgsql
DB_HOST=127.0.0.1
DB_PORT=5432
DB_DATABASE=sentinelai
DB_USERNAME=sentinelai_user
DB_PASSWORD=sentinelai_password
```

### Alternative: Use MySQL

If you prefer MySQL (which comes with XAMPP):

1. **Update `.env`**:
   ```
   DB_CONNECTION=mysql
   DB_HOST=127.0.0.1
   DB_PORT=3306
   DB_DATABASE=sentinelai
   DB_USERNAME=root
   DB_PASSWORD=
   ```

2. **Create database** in phpMyAdmin or MySQL:
   ```sql
   CREATE DATABASE sentinelai;
   ```

3. **Run migrations**:
   ```powershell
   C:\php81\php.exe artisan migrate
   ```

## 📝 Quick Start Commands

```powershell
# 1. Start PostgreSQL (Docker)
docker run -d --name sentinelai-postgres -p 5432:5432 -e POSTGRES_DB=sentinelai -e POSTGRES_USER=sentinelai_user -e POSTGRES_PASSWORD=sentinelai_password postgres:15

# 2. Run migrations
cd E:\Cyberpunck\backend\api
C:\php81\php.exe artisan migrate

# 3. Seed users
C:\php81\php.exe artisan db:seed --class=UserSeeder

# 4. Verify users were created
C:\php81\php.exe artisan tinker
# Then in tinker:
# User::all();
```

---

**Next Steps**: Start PostgreSQL, then run migrations! 🚀
