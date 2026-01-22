# SentinelAI X - Start All Services Script
# This script starts all services in separate windows

Write-Host "=== SentinelAI X - Starting All Services ===" -ForegroundColor Cyan
Write-Host ""

$projectRoot = "E:\Cyberpunck"

# Function to start a service in a new window
function Start-Service {
    param(
        [string]$Name,
        [string]$Directory,
        [string]$Command,
        [string]$Description
    )
    
    Write-Host "Starting $Description..." -ForegroundColor Yellow
    
    $scriptBlock = @"
cd '$Directory'
Write-Host 'Starting $Description...' -ForegroundColor Green
$Command
pause
"@
    
    Start-Process powershell -ArgumentList "-NoExit", "-Command", $scriptBlock
    Start-Sleep -Seconds 2
}

Write-Host "This will open 5 separate terminal windows for each service." -ForegroundColor Yellow
Write-Host ""
$confirm = Read-Host "Continue? (y/n)"
if ($confirm -ne 'y' -and $confirm -ne 'Y') {
    Write-Host "Cancelled." -ForegroundColor Red
    exit
}

Write-Host ""
Write-Host "Starting services..." -ForegroundColor Green
Write-Host ""

# 1. Laravel API
Start-Service -Name "LaravelAPI" `
    -Directory "$projectRoot\backend\api" `
    -Command "C:\php81\php.exe artisan serve" `
    -Description "Laravel API (Port 8000)"

# 2. Python ML Service
Start-Service -Name "MLService" `
    -Directory "$projectRoot\backend\ml-service" `
    -Command "python app.py" `
    -Description "Python ML Service (Port 5000)"

# 3. Node.js Real-time Service
Start-Service -Name "RealTimeService" `
    -Directory "$projectRoot\backend\realtime-service" `
    -Command "npm start" `
    -Description "Node.js Real-time Service (Port 3001)"

# 4. Vue.js Admin Dashboard
Start-Service -Name "AdminDashboard" `
    -Directory "$projectRoot\frontend\admin-dashboard" `
    -Command "npm run dev" `
    -Description "Vue.js Admin Dashboard (Port 5173)"

# 5. Next.js Public Portal
Start-Service -Name "PublicPortal" `
    -Directory "$projectRoot\frontend\portal" `
    -Command "npm run dev" `
    -Description "Next.js Public Portal (Port 3000)"

Write-Host ""
Write-Host "=== All services started! ===" -ForegroundColor Green
Write-Host ""
Write-Host "Access the services at:" -ForegroundColor Cyan
Write-Host "  - Laravel API: http://localhost:8000" -ForegroundColor White
Write-Host "  - ML Service: http://localhost:5000" -ForegroundColor White
Write-Host "  - Real-time Service: http://localhost:3001" -ForegroundColor White
Write-Host "  - Admin Dashboard: http://localhost:5173" -ForegroundColor White
Write-Host "  - Public Portal: http://localhost:3000" -ForegroundColor White
Write-Host ""
Write-Host "Note: Make sure databases (PostgreSQL, Redis, Neo4j) are running first!" -ForegroundColor Yellow
Write-Host ""
