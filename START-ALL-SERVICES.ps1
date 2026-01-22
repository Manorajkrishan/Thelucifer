# Start All SentinelAI X Services
# This script starts all services in separate windows

Write-Host "Starting SentinelAI X Services..." -ForegroundColor Green
Write-Host ""

# Check if services are already running
Write-Host "Checking for running services..." -ForegroundColor Yellow

# Start Laravel API
Write-Host "`n1. Starting Laravel API (Port 8000)..." -ForegroundColor Cyan
Start-Process powershell -ArgumentList "-NoExit", "-Command", "cd '$PSScriptRoot\backend\api'; Write-Host 'Laravel API - Port 8000' -ForegroundColor Green; C:\php81\php.exe artisan serve"

Start-Sleep -Seconds 2

# Start ML Service
Write-Host "2. Starting ML Service (Port 5000)..." -ForegroundColor Cyan
Start-Process powershell -ArgumentList "-NoExit", "-Command", "cd '$PSScriptRoot\backend\ml-service'; Write-Host 'ML Service - Port 5000' -ForegroundColor Green; python app.py"

Start-Sleep -Seconds 2

# Start Portal
Write-Host "3. Starting Portal (Port 3000)..." -ForegroundColor Cyan
Start-Process powershell -ArgumentList "-NoExit", "-Command", "cd '$PSScriptRoot\frontend\portal'; Write-Host 'Portal - Port 3000' -ForegroundColor Green; npm run dev"

Start-Sleep -Seconds 2

# Start Admin Dashboard
Write-Host "4. Starting Admin Dashboard (Port 5173)..." -ForegroundColor Cyan
Start-Process powershell -ArgumentList "-NoExit", "-Command", "cd '$PSScriptRoot\frontend\admin-dashboard'; Write-Host 'Admin Dashboard - Port 5173' -ForegroundColor Green; npm run dev"

Write-Host "`n✅ All services starting in separate windows!" -ForegroundColor Green
Write-Host "`n🌐 Access:" -ForegroundColor Cyan
Write-Host "   Portal: http://localhost:3000" -ForegroundColor White
Write-Host "   Admin: http://localhost:5173" -ForegroundColor White
Write-Host "   API: http://localhost:8000" -ForegroundColor White
Write-Host "   ML Service: http://localhost:5000" -ForegroundColor White
Write-Host "`n⏳ Wait 10-15 seconds for services to start..." -ForegroundColor Yellow
Write-Host "`nPress any key to run quick test..." -ForegroundColor Yellow
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")

# Run quick test
& "$PSScriptRoot\QUICK-TEST.ps1"
