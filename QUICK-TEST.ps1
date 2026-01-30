# Quick Test Script for SentinelAI X
# Tests all services and endpoints

Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "  SentinelAI X - System Test" -ForegroundColor Cyan
Write-Host "========================================`n" -ForegroundColor Cyan

$allGood = $true

# Test 1: Laravel API
Write-Host "1. Testing Laravel API (http://localhost:8000)..." -ForegroundColor Yellow
try {
    $response = Invoke-WebRequest -Uri "http://localhost:8000" -UseBasicParsing -TimeoutSec 5
    if ($response.StatusCode -eq 200) {
        Write-Host "   [OK] Laravel API is running" -ForegroundColor Green
    }
} catch {
    Write-Host "   [X] Laravel API is not running" -ForegroundColor Red
    Write-Host "   Tip: cd backend\api; C:\php81\php.exe artisan serve" -ForegroundColor Yellow
    $allGood = $false
}

# Test 2: ML Service
Write-Host "`n2. Testing ML Service (http://localhost:5000)..." -ForegroundColor Yellow
try {
    $response = Invoke-WebRequest -Uri "http://localhost:5000/health" -UseBasicParsing -TimeoutSec 5
    if ($response.StatusCode -eq 200) {
        Write-Host "   [OK] ML Service is running" -ForegroundColor Green
    }
} catch {
    Write-Host "   [X] ML Service is not running" -ForegroundColor Red
    Write-Host "   Tip: cd backend\ml-service; python app.py" -ForegroundColor Yellow
    $allGood = $false
}

# Test 3: Portal
Write-Host "`n3. Testing Portal (http://localhost:3000)..." -ForegroundColor Yellow
try {
    $response = Invoke-WebRequest -Uri "http://localhost:3000" -UseBasicParsing -TimeoutSec 5
    if ($response.StatusCode -eq 200) {
        Write-Host "   [OK] Portal is running" -ForegroundColor Green
    }
} catch {
    Write-Host "   [X] Portal is not running" -ForegroundColor Red
    Write-Host "   Tip: cd frontend\portal; npm run dev" -ForegroundColor Yellow
    $allGood = $false
}

# Test 4: API Login
Write-Host "`n4. Testing API Login..." -ForegroundColor Yellow
try {
    $body = @{
        email = "admin@sentinelai.com"
        password = "admin123"
    } | ConvertTo-Json

    $response = Invoke-RestMethod -Uri "http://localhost:8000/api/login" -Method POST -Body $body -ContentType "application/json" -TimeoutSec 5
    if ($response.token) {
        Write-Host "   [OK] Login works - Token received" -ForegroundColor Green
        $global:testToken = $response.token
    }
} catch {
    Write-Host "   [X] Login failed" -ForegroundColor Red
    Write-Host "   Tip: Run Laravel API and ensure admin user exists (CREATE-ADMIN-USER.ps1)" -ForegroundColor Yellow
    $allGood = $false
}

# Test 5: Learning Summary
Write-Host "`n5. Testing Learning Summary API..." -ForegroundColor Yellow
try {
    $response = Invoke-RestMethod -Uri "http://localhost:5000/api/v1/learning/summary" -Method GET -TimeoutSec 5
    if ($response.success) {
        Write-Host "   [OK] Learning Summary API works" -ForegroundColor Green
        Write-Host "   Documents processed: $($response.summary.total_documents)" -ForegroundColor Cyan
    }
} catch {
    Write-Host "   [~] Learning Summary API not available (ML Service may need restart)" -ForegroundColor Yellow
}

# Summary
Write-Host "`n========================================" -ForegroundColor Cyan
if ($allGood) {
    Write-Host "  All Core Services Running!" -ForegroundColor Green
    Write-Host "`nAccess:" -ForegroundColor Cyan
    Write-Host "   Portal: http://localhost:3000" -ForegroundColor White
    Write-Host "   Admin: http://localhost:5173" -ForegroundColor White
    Write-Host "   API: http://localhost:8000" -ForegroundColor White
    Write-Host "   ML Service: http://localhost:5000" -ForegroundColor White
} else {
    Write-Host "  Some services are not running" -ForegroundColor Yellow
    Write-Host "`nStart missing services and run this script again." -ForegroundColor Yellow
}
Write-Host "========================================`n" -ForegroundColor Cyan
