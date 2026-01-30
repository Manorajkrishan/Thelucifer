# Fix MySQL Database Configuration

Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "  Fix MySQL Database Configuration" -ForegroundColor Cyan
Write-Host "========================================`n" -ForegroundColor Cyan

cd backend\api

Write-Host "Updating .env file for MySQL..." -ForegroundColor Yellow

# Read current .env
$envPath = ".env"
if (Test-Path $envPath) {
    $envContent = Get-Content $envPath
    
    # Update database configuration
    $newEnvContent = @()
    foreach ($line in $envContent) {
        if ($line -match "^DB_CONNECTION=") {
            $newEnvContent += "DB_CONNECTION=mysql"
        } elseif ($line -match "^DB_HOST=") {
            $newEnvContent += "DB_HOST=127.0.0.1"
        } elseif ($line -match "^DB_PORT=") {
            $newEnvContent += "DB_PORT=3306"
        } elseif ($line -match "^DB_DATABASE=") {
            $newEnvContent += "DB_DATABASE=sentinelai"
        } elseif ($line -match "^DB_USERNAME=") {
            $newEnvContent += "DB_USERNAME=root"
        } elseif ($line -match "^DB_PASSWORD=") {
            $newEnvContent += "DB_PASSWORD="
        } else {
            $newEnvContent += $line
        }
    }
    
    # Write updated .env
    $newEnvContent | Set-Content $envPath
    Write-Host "✅ .env file updated for MySQL" -ForegroundColor Green
} else {
    Write-Host "❌ .env file not found" -ForegroundColor Red
    exit 1
}

Write-Host "`nRunning migrations..." -ForegroundColor Yellow
try {
    C:\php81\php.exe artisan migrate --force
    Write-Host "✅ Migrations completed" -ForegroundColor Green
} catch {
    Write-Host "❌ Migration failed: $_" -ForegroundColor Red
}

Write-Host "`nSeeding database..." -ForegroundColor Yellow
try {
    C:\php81\php.exe artisan db:seed --force
    Write-Host "✅ Database seeded" -ForegroundColor Green
} catch {
    Write-Host "⚠️  Seeding failed or already done: $_" -ForegroundColor Yellow
}

Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "  Configuration Complete!" -ForegroundColor Green
Write-Host "========================================`n" -ForegroundColor Cyan

Write-Host "Next steps:" -ForegroundColor Yellow
Write-Host "  1. Restart Laravel server" -ForegroundColor White
Write-Host "  2. Check database: .\CHECK-DATABASE-CONNECTION.ps1" -ForegroundColor White
Write-Host "  3. Verify tables in phpMyAdmin" -ForegroundColor White

cd ..\..
