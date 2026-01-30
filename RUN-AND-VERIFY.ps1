# Run SentinelAI X and verify system is working
# 1. Free port 8000, start Laravel API
# 2. Verify health + login
# 3. Optionally start Portal (and ML, Admin)

$ErrorActionPreference = "Stop"
$port = 8000
$root = $PSScriptRoot
$apiDir = if (Test-Path "$root\backend\api") { "$root\backend\api" } elseif (Test-Path "E:\Cyberpunck\backend\api") { "E:\Cyberpunck\backend\api" } else { $null }
$php = if (Get-Command "C:\php81\php.exe" -ErrorAction SilentlyContinue) { "C:\php81\php.exe" } else { "php" }

Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "  SentinelAI X - Run and Verify" -ForegroundColor Cyan
Write-Host "========================================`n" -ForegroundColor Cyan

# ---- 1. Free port 8000 ----
Write-Host "1. Freeing port $port..." -ForegroundColor Yellow
$lines = netstat -ano | findstr "LISTENING" | findstr ":$port "
$pids = @()
foreach ($l in @($lines)) {
    if (-not $l) { continue }
    $parts = ($l.Trim() -split '\s+', [System.StringSplitOptions]::RemoveEmptyEntries)
    $last = $parts[-1]
    if ($last -match '^\d+$') { $pids += [int]$last }
}
$pids = $pids | Sort-Object -Unique
foreach ($procId in $pids) {
    try {
        Stop-Process -Id $procId -Force -ErrorAction Stop
        Write-Host "   Killed PID $procId" -ForegroundColor Gray
    } catch {
        Write-Host "   Run as Admin or: taskkill /PID $procId /F" -ForegroundColor Red
    }
}
if ($pids.Count) { Start-Sleep -Seconds 2 }
else { Write-Host "   Port $port already free." -ForegroundColor Gray }

# ---- 2. Start Laravel API (new window) ----
if (-not $apiDir) {
    Write-Host "`nCannot find backend\api. Aborting." -ForegroundColor Red
    exit 1
}
Write-Host "`n2. Starting Laravel API on port $port (new window)..." -ForegroundColor Yellow
Start-Process powershell -ArgumentList "-NoExit", "-Command", "Set-Location '$apiDir'; Write-Host 'Laravel API - Port $port' -ForegroundColor Green; & '$php' artisan serve"
Start-Sleep -Seconds 5

# ---- 3. Verify health ----
Write-Host "`n3. Verifying API..." -ForegroundColor Yellow
$healthOk = $false
$loginOk = $false
try {
    $h = Invoke-RestMethod -Uri "http://127.0.0.1:$port/api/health" -Method GET -TimeoutSec 8
    if ($h.success -and $h.status -eq "online") {
        $healthOk = $true
        Write-Host "   Health: OK (database: $($h.database))" -ForegroundColor Green
    } else {
        Write-Host "   Health: Unexpected response" -ForegroundColor Red
    }
} catch {
    Write-Host "   Health: FAIL - $($_.Exception.Message)" -ForegroundColor Red
}

# ---- 4. Verify login ----
if ($healthOk) {
    try {
        $body = @{ email = "admin@sentinelai.com"; password = "admin123" } | ConvertTo-Json
        $r = Invoke-RestMethod -Uri "http://127.0.0.1:$port/api/login" -Method POST -Body $body -ContentType "application/json" -TimeoutSec 8
        if ($r.success -and $r.token) {
            $loginOk = $true
            Write-Host "   Login: OK (token received)" -ForegroundColor Green
        } else {
            Write-Host "   Login: Invalid response" -ForegroundColor Red
        }
    } catch {
        $msg = $_.Exception.Message
        if ($_.ErrorDetails.Message) {         $msg += " | $($_.ErrorDetails.Message)" }
        Write-Host "   Login: FAIL - $msg" -ForegroundColor Red
    }
}

# ---- 5. Summary ----
Write-Host "`n----------------------------------------" -ForegroundColor Gray
if ($healthOk -and $loginOk) {
    Write-Host "System OK. API running on http://localhost:$port" -ForegroundColor Green
    Write-Host "`nNext steps:" -ForegroundColor Cyan
    Write-Host "  - Portal:  cd frontend\portal ; npm run dev  -> http://localhost:3000" -ForegroundColor White
    Write-Host "  - Admin:   cd frontend\admin-dashboard ; npm run dev  -> http://localhost:5173" -ForegroundColor White
    Write-Host "  - Login:   admin@sentinelai.com / admin123" -ForegroundColor White
} else {
    Write-Host "API check failed. Ensure:" -ForegroundColor Red
    Write-Host "  - PHP 8.1 (C:\php81\php.exe) and Composer deps (backend\api)" -ForegroundColor White
    Write-Host "  - MySQL or SQLite configured (.env)" -ForegroundColor White
    Write-Host "  - Run: .\CREATE-ADMIN-USER.ps1 if no admin user" -ForegroundColor White
}
Write-Host "`nKeep the Laravel window open." -ForegroundColor Gray
