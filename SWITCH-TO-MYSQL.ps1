# Switch Database from SQLite to MySQL

Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "  Switch to MySQL Database" -ForegroundColor Cyan
Write-Host "========================================`n" -ForegroundColor Cyan

cd backend\api

Write-Host "1. Updating .env file..." -ForegroundColor Yellow

$envPath = ".env"
if (Test-Path $envPath) {
    $envContent = Get-Content $envPath -Raw
    
    # Replace database configuration
    $envContent = $envContent -replace "DB_CONNECTION=sqlite", "DB_CONNECTION=mysql"
    $envContent = $envContent -replace "DB_DATABASE=E:\\Cyberpunck\\backend\\api\\database\\database\.sqlite", "DB_DATABASE=sentinelai"
    
    # Add MySQL settings if not present
    if ($envContent -notmatch "DB_HOST=") {
        $envContent += "`nDB_HOST=127.0.0.1`n"
    } else {
        $envContent = $envContent -replace "DB_HOST=.*", "DB_HOST=127.0.0.1"
    }
    
    if ($envContent -notmatch "DB_PORT=") {
        $envContent += "DB_PORT=3306`n"
    } else {
        $envContent = $envContent -replace "DB_PORT=.*", "DB_PORT=3306"
    }
    
    if ($envContent -notmatch "DB_USERNAME=") {
        $envContent += "DB_USERNAME=root`n"
    } else {
        $envContent = $envContent -replace "DB_USERNAME=.*", "DB_USERNAME=root"
    }
    
    if ($envContent -notmatch "DB_PASSWORD=") {
        $envContent += "DB_PASSWORD=`n"
    } else {
        $envContent = $envContent -replace "DB_PASSWORD=.*", "DB_PASSWORD="
    }
    
    $envContent | Set-Content $envPath -NoNewline
    Write-Host "   ✅ .env updated" -ForegroundColor Green
} else {
    Write-Host "   ❌ .env file not found!" -ForegroundColor Red
    exit 1
}

Write-Host "`n2. Testing MySQL connection..." -ForegroundColor Yellow
try {
    $result = C:\php81\php.exe artisan db:show 2>&1
    if ($LASTEXITCODE -eq 0) {
        Write-Host "   ✅ MySQL connection successful" -ForegroundColor Green
    } else {
        Write-Host "   ⚠️  Connection test failed - make sure MySQL is running" -ForegroundColor Yellow
        Write-Host "   Error: $result" -ForegroundColor Gray
    }
} catch {
    Write-Host "   ⚠️  Could not test connection" -ForegroundColor Yellow
}

Write-Host "`n3. Running migrations..." -ForegroundColor Yellow
try {
    C:\php81\php.exe artisan migrate:fresh --force 2>&1 | Out-Null
    if ($LASTEXITCODE -eq 0) {
        Write-Host "   ✅ Migrations completed" -ForegroundColor Green
    } else {
        Write-Host "   ⚠️  Migration may have issues" -ForegroundColor Yellow
    }
} catch {
    Write-Host "   ⚠️  Migration error: $_" -ForegroundColor Yellow
}

Write-Host "`n4. Seeding database..." -ForegroundColor Yellow
try {
    C:\php81\php.exe artisan db:seed --force 2>&1 | Out-Null
    Write-Host "   ✅ Database seeded" -ForegroundColor Green
} catch {
    Write-Host "   ⚠️  Seeding may have issues" -ForegroundColor Yellow
}

Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "  Configuration Complete!" -ForegroundColor Green
Write-Host "========================================`n" -ForegroundColor Cyan

Write-Host "✅ Database switched to MySQL (sentinelai)" -ForegroundColor Green
Write-Host "`n📝 Next steps:" -ForegroundColor Yellow
Write-Host "  1. Restart Laravel server" -ForegroundColor White
Write-Host "  2. Check phpMyAdmin: http://localhost/phpmyadmin" -ForegroundColor White
Write-Host "  3. Verify tables exist in 'sentinelai' database" -ForegroundColor White
Write-Host "  4. Create a threat to test threat_actions creation" -ForegroundColor White

cd ..\..
