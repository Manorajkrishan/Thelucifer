# 🗄️ Quick Database Setup Guide

## ✅ PostgreSQL Extension Fixed!

The PostgreSQL driver issue is **resolved**. The extensions are now enabled in PHP 8.1.

## 📋 Current Issue

PostgreSQL server is not running. You have two options:

### Option 1: Use MySQL (Recommended - Easier with XAMPP)

✅ **I've updated your `.env` file to use MySQL** which comes with XAMPP!

**Just follow these steps:**

1. **Start MySQL in XAMPP**:
   - Open XAMPP Control Panel
   - Click "Start" next to MySQL

2. **Create database** (using phpMyAdmin or command line):
   ```sql
   CREATE DATABASE sentinelai;
   ```

3. **Run migrations**:
   ```powershell
   cd E:\Cyberpunck\backend\api
   C:\php81\php.exe artisan migrate
   C:\php81\php.exe artisan db:seed --class=UserSeeder
   ```

**Done!** Your `.env` is already configured for MySQL:
```
DB_CONNECTION=mysql
DB_HOST=127.0.0.1
DB_PORT=3306
DB_DATABASE=sentinelai
DB_USERNAME=root
DB_PASSWORD=
```

### Option 2: Install PostgreSQL

If you prefer PostgreSQL:

1. **Download PostgreSQL**: https://www.postgresql.org/download/windows/
2. **Install PostgreSQL** (remember the password!)
3. **Create database and user**:
   ```sql
   CREATE DATABASE sentinelai;
   CREATE USER sentinelai_user WITH PASSWORD 'sentinelai_password';
   GRANT ALL PRIVILEGES ON DATABASE sentinelai TO sentinelai_user;
   ```
4. **Update `.env`** back to PostgreSQL:
   ```
   DB_CONNECTION=pgsql
   DB_PORT=5432
   DB_USERNAME=sentinelai_user
   DB_PASSWORD=sentinelai_password
   ```

### Option 3: Use Docker (Best for Full Project)

If you install Docker Desktop:
```powershell
docker-compose up -d postgres redis neo4j
```

This starts all databases needed for the project.

## 🚀 Quick Start (MySQL - Recommended)

```powershell
# 1. Start MySQL in XAMPP Control Panel

# 2. Create database in phpMyAdmin (http://localhost/phpmyadmin)
# Or via command line:
mysql -u root -e "CREATE DATABASE sentinelai;"

# 3. Run migrations
cd E:\Cyberpunck\backend\api
C:\php81\php.exe artisan migrate

# 4. Create users
C:\php81\php.exe artisan db:seed --class=UserSeeder

# Done! You can now login with:
# Email: admin@sentinelai.com
# Password: admin123
```

## ✅ What's Fixed

- ✅ PostgreSQL PHP extension enabled
- ✅ PHP 8.1 configured correctly
- ✅ `.env` file ready for MySQL
- ✅ Authentication system implemented
- ✅ User seeder ready

## 📝 Next Steps

1. **Start MySQL** in XAMPP
2. **Create database**: `sentinelai`
3. **Run migrations**: `php artisan migrate`
4. **Seed users**: `php artisan db:seed --class=UserSeeder`
5. **Login** with: `admin@sentinelai.com` / `admin123`

---

**Status**: Ready to use MySQL! Just start MySQL in XAMPP and run migrations! 🚀
