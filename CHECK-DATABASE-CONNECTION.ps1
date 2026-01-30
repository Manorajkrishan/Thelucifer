# Check Database Connection and Configuration

Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "  Database Connection Check" -ForegroundColor Cyan
Write-Host "========================================`n" -ForegroundColor Cyan

cd backend\api

Write-Host "1. Checking .env file..." -ForegroundColor Yellow
if (Test-Path ".env") {
    Write-Host "   ✅ .env file exists" -ForegroundColor Green
    
    $envContent = Get-Content .env
    $dbType = ($envContent | Select-String -Pattern "^DB_CONNECTION=").ToString().Split('=')[1]
    $dbName = ($envContent | Select-String -Pattern "^DB_DATABASE=").ToString().Split('=')[1]
    $dbHost = ($envContent | Select-String -Pattern "^DB_HOST=").ToString().Split('=')[1]
    
    Write-Host "   Database Type: $dbType" -ForegroundColor Cyan
    Write-Host "   Database Name: $dbName" -ForegroundColor Cyan
    Write-Host "   Database Host: $dbHost" -ForegroundColor Cyan
    
    if ($dbType -ne "mysql") {
        Write-Host "`n⚠️  WARNING: Database is set to $dbType, but you're using MySQL!" -ForegroundColor Yellow
        Write-Host "   You need to switch to MySQL in .env file" -ForegroundColor Yellow
    }
} else {
    Write-Host "   ❌ .env file not found" -ForegroundColor Red
}

Write-Host "`n2. Testing database connection..." -ForegroundColor Yellow
try {
    $result = C:\php81\php.exe artisan db:show 2>&1
    if ($LASTEXITCODE -eq 0) {
        Write-Host "   ✅ Database connection works" -ForegroundColor Green
    } else {
        Write-Host "   ❌ Database connection failed" -ForegroundColor Red
        Write-Host "   Error: $result" -ForegroundColor Red
    }
} catch {
    Write-Host "   ❌ Error: $_" -ForegroundColor Red
}

Write-Host "`n3. Checking migrations..." -ForegroundColor Yellow
try {
    $migrations = C:\php81\php.exe artisan migrate:status 2>&1
    if ($LASTEXITCODE -eq 0) {
        Write-Host "   ✅ Migrations check passed" -ForegroundColor Green
        Write-Host "`n   Migration Status:" -ForegroundColor Cyan
        $migrations | Select-Object -First 10
    } else {
        Write-Host "   ⚠️  Run migrations: C:\php81\php.exe artisan migrate" -ForegroundColor Yellow
    }
} catch {
    Write-Host "   ⚠️  Could not check migrations" -ForegroundColor Yellow
}

Write-Host "`n4. Checking tables..." -ForegroundColor Yellow
try {
    $tables = @("threats", "documents", "incidents", "threat_actions", "users")
    foreach ($table in $tables) {
        $check = C:\php81\php.exe artisan tinker --execute="echo DB::table('$table')->count();" 2>&1
        if ($LASTEXITCODE -eq 0) {
            $count = ($check | Select-String -Pattern "^\d+").Matches.Value
            Write-Host "   ✅ $table : $count records" -ForegroundColor Green
        } else {
            Write-Host "   ❌ $table : Table missing or error" -ForegroundColor Red
        }
    }
} catch {
    Write-Host "   ⚠️  Could not check tables" -ForegroundColor Yellow
}

Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "  Recommendations" -ForegroundColor Cyan
Write-Host "========================================`n" -ForegroundColor Cyan

Write-Host "If using MySQL (phpMyAdmin):" -ForegroundColor Yellow
Write-Host "  1. Update .env file:" -ForegroundColor White
Write-Host "     DB_CONNECTION=mysql" -ForegroundColor Gray
Write-Host "     DB_HOST=127.0.0.1" -ForegroundColor Gray
Write-Host "     DB_PORT=3306" -ForegroundColor Gray
Write-Host "     DB_DATABASE=sentinelai" -ForegroundColor Gray
Write-Host "     DB_USERNAME=root" -ForegroundColor Gray
Write-Host "     DB_PASSWORD=" -ForegroundColor Gray
Write-Host "`n  2. Run migrations:" -ForegroundColor White
Write-Host "     C:\php81\php.exe artisan migrate" -ForegroundColor Gray
Write-Host "`n  3. Restart Laravel server" -ForegroundColor White

cd ..\..

Write-Host "`n========================================`n" -ForegroundColor Cyan
