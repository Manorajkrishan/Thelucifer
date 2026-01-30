# Fix Port 8000: Kill wrong app, start Laravel SentinelAI API
# Use this when you get 404 on /api/login (another app is on port 8000)

$ErrorActionPreference = "Stop"
$port = 8000
$apiRoot = "http://localhost:$port"

Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "  Fix Port 8000 & Start SentinelAI API" -ForegroundColor Cyan
Write-Host "========================================`n" -ForegroundColor Cyan

# Check if correct API (Laravel SentinelAI) is already running
try {
    $r = Invoke-RestMethod -Uri "$apiRoot/api/health" -Method GET -TimeoutSec 3
    if ($r.success -and $r.status -eq "online") {
        $root = Invoke-RestMethod -Uri $apiRoot -Method GET -TimeoutSec 2
        if ($root.message -match "SentinelAI" -or $root.success -eq $true) {
            Write-Host "SentinelAI Laravel API is already running on port $port." -ForegroundColor Green
            Write-Host "  $apiRoot" -ForegroundColor Cyan
            Write-Host "  Login: $apiRoot/api/login" -ForegroundColor Gray
            exit 0
        }
    }
} catch { }

# Something else on 8000 or not Laravel – find and kill all listeners
Write-Host "Port $port has wrong app or nothing. Freeing port..." -ForegroundColor Yellow
$lines = netstat -ano | findstr "LISTENING" | findstr ":$port "
$pids = @()
foreach ($l in @($lines)) {
    if (-not $l) { continue }
    $parts = ($l.Trim() -split '\s+', [System.StringSplitOptions]::RemoveEmptyEntries)
    $last = $parts[-1]
    if ($last -match '^\d+$') { $pids += [int]$last }
}
$pids = $pids | Sort-Object -Unique
foreach ($listenPid in $pids) {
    Write-Host "  Killing process PID $listenPid on port $port..." -ForegroundColor Yellow
    try {
        Stop-Process -Id $listenPid -Force -ErrorAction Stop
        Write-Host "  Done." -ForegroundColor Green
    } catch {
        Write-Host "  Run as Administrator or: taskkill /PID $listenPid /F" -ForegroundColor Red
        exit 1
    }
}
if ($pids.Count) { Start-Sleep -Seconds 2 }
else { Write-Host "  No process listening on $port." -ForegroundColor Gray }

# Start Laravel API
$apiDir = $PSScriptRoot
if (Test-Path "$apiDir\backend\api") { $apiDir = "$apiDir\backend\api" }
elseif (Test-Path "E:\Cyberpunck\backend\api") { $apiDir = "E:\Cyberpunck\backend\api" }
else {
    Write-Host "Cannot find backend\api." -ForegroundColor Red
    exit 1
}

$php = "C:\php81\php.exe"
if (-not (Get-Command $php -ErrorAction SilentlyContinue)) { $php = "php" }

Write-Host "`nStarting Laravel API on port $port..." -ForegroundColor Cyan
Write-Host "  URL: $apiRoot" -ForegroundColor White
Write-Host "  Login: $apiRoot/api/login  (admin@sentinelai.com / admin123)" -ForegroundColor Gray
Write-Host "  Press Ctrl+C to stop.`n" -ForegroundColor Gray

Set-Location $apiDir
& $php artisan serve
