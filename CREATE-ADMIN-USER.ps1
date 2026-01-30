# Create or update the default admin user (admin@sentinelai.com / admin123).
# Run from project root. Laravel API must be configured (DB, .env).

$ErrorActionPreference = "Stop"
$root = $PSScriptRoot
$api = Join-Path $root "backend\api"

if (-not (Test-Path $api)) {
    Write-Host "backend\api not found." -ForegroundColor Red
    exit 1
}

$php = "php"
if (Test-Path "C:\php81\php.exe") { $php = "C:\php81\php.exe" }

Write-Host ""
Write-Host "Create / update admin user..." -ForegroundColor Cyan
Push-Location $api

try {
    & $php artisan sentinelai:create-admin
    if ($LASTEXITCODE -ne 0) { throw "artisan failed" }
    Write-Host "Admin user ready." -ForegroundColor Green
} catch {
    Write-Host "Error: $_" -ForegroundColor Red
    Pop-Location
    exit 1
}

Pop-Location

Write-Host ""
Write-Host "Default credentials:" -ForegroundColor Yellow
Write-Host "  Email:    admin@sentinelai.com" -ForegroundColor White
Write-Host "  Password: admin123" -ForegroundColor White
Write-Host ""
Write-Host "If you get 401 on login, run this script from project root, then try again." -ForegroundColor Gray
Write-Host ""
