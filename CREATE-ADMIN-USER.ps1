# No default password. Artisan prompts for a unique strong credential.
$ErrorActionPreference = "Stop"
$api = Join-Path $PSScriptRoot "backend\api"
if (-not (Test-Path $api)) { throw "backend/api not found" }
$php = "php"
if (Test-Path "C:\php81\php.exe") { $php = "C:\php81\php.exe" }
Push-Location $api
try {
    & $php artisan sentinelai:create-admin
    if ($LASTEXITCODE -ne 0) { throw "Admin creation failed" }
    Write-Host "Administrator configured." -ForegroundColor Green
} finally { Pop-Location }
