# Switch to SQLite (when MySQL is not running)
param([switch]$Force)

Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "  Switch to SQLite" -ForegroundColor Cyan
Write-Host "========================================`n" -ForegroundColor Cyan

if (-not $Force) {
    Write-Host "This switches Laravel to SQLite when MySQL is down.`n" -ForegroundColor Yellow
    $confirm = Read-Host "Continue? (y/n)"
    if ($confirm -ne 'y') {
        Write-Host "Cancelled." -ForegroundColor Yellow
        exit
    }
}

$apiDir = Join-Path $PSScriptRoot "backend\api"
if (-not (Test-Path $apiDir)) { $apiDir = "E:\Cyberpunck\backend\api" }
Set-Location $apiDir

$php = "C:\php81\php.exe"
if (-not (Get-Command $php -ErrorAction SilentlyContinue)) { $php = "php" }

# Backup .env
if (Test-Path ".env") {
    Copy-Item ".env" ".env.mysql.backup" -Force
    Write-Host "[OK] Backed up .env to .env.mysql.backup" -ForegroundColor Green
}

Write-Host "`nUpdating .env for SQLite..." -ForegroundColor Yellow
$envContent = Get-Content ".env" -Raw
$dbPath = Join-Path (Get-Location) "database\database.sqlite"
$envContent = $envContent -replace "DB_CONNECTION=mysql", "DB_CONNECTION=sqlite"
$envContent = $envContent -replace "DB_HOST=.*", "DB_HOST="
$envContent = $envContent -replace "DB_PORT=.*", "DB_PORT="
$envContent = $envContent -replace "DB_DATABASE=.*", "DB_DATABASE=$dbPath"
$envContent = $envContent -replace "DB_USERNAME=.*", "DB_USERNAME="
$envContent = $envContent -replace "DB_PASSWORD=.*", "DB_PASSWORD="
Set-Content ".env" -Value $envContent
Write-Host "[OK] .env updated" -ForegroundColor Green

# Create SQLite file
$dbFile = "database\database.sqlite"
if (-not (Test-Path $dbFile)) {
    New-Item -Path $dbFile -ItemType File -Force | Out-Null
    Write-Host "[OK] Created database\database.sqlite" -ForegroundColor Green
}

# Migrate
Write-Host "`nRunning migrations..." -ForegroundColor Yellow
& $php artisan migrate:fresh --force 2>&1
if ($LASTEXITCODE -eq 0) { Write-Host "[OK] Migrations done" -ForegroundColor Green } else { Write-Host "[!] Migration had errors" -ForegroundColor Yellow }

# Seed
Write-Host "`nSeeding..." -ForegroundColor Yellow
& $php artisan db:seed --force 2>&1
if ($LASTEXITCODE -eq 0) { Write-Host "[OK] Seeding done" -ForegroundColor Green } else { Write-Host "[!] Seeding had errors (run CREATE-ADMIN-USER.ps1 if needed)" -ForegroundColor Yellow }

Set-Location $PSScriptRoot
Write-Host "`nDone. Using SQLite. Restart API: RUN-AND-VERIFY.ps1 or cd backend\api; $php artisan serve" -ForegroundColor Cyan
Write-Host ""
