# Start Laravel API Server

Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "  Starting Laravel API Server" -ForegroundColor Cyan
Write-Host "========================================`n" -ForegroundColor Cyan

# Check if already running
Write-Host "Checking if API server is already running..." -ForegroundColor Yellow
try {
    $check = Invoke-WebRequest -Uri "http://localhost:8000/api/health" -UseBasicParsing -TimeoutSec 2
    Write-Host "✅ API server is already running!" -ForegroundColor Green
    Write-Host "   URL: http://localhost:8000" -ForegroundColor Cyan
    exit 0
} catch {
    Write-Host "   API server is not running, starting now..." -ForegroundColor Yellow
}

# Navigate to API directory
if (Test-Path "backend\api") {
    cd backend\api
} elseif (Test-Path "E:\Cyberpunck\backend\api") {
    cd E:\Cyberpunck\backend\api
} else {
    Write-Host "❌ Cannot find backend\api directory" -ForegroundColor Red
    Write-Host "   Current directory: $PWD" -ForegroundColor Yellow
    exit 1
}

Write-Host "`nStarting server..." -ForegroundColor Yellow
Write-Host "   URL: http://localhost:8000" -ForegroundColor Cyan
Write-Host "   Press Ctrl+C to stop`n" -ForegroundColor Gray

# Start the server
C:\php81\php.exe artisan serve
