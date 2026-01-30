# Check All Services Status

Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "  SentinelAI X - Service Status Check" -ForegroundColor Cyan
Write-Host "========================================`n" -ForegroundColor Cyan

$allGood = $true

# ============================================
# 1. Laravel API
# ============================================
Write-Host "1. Laravel API (http://localhost:8000)" -ForegroundColor Cyan
Write-Host "--------------------------------" -ForegroundColor Gray
try {
    $response = Invoke-WebRequest -Uri "http://localhost:8000" -UseBasicParsing -TimeoutSec 3 -ErrorAction Stop
    Write-Host "   Status: ✅ ONLINE" -ForegroundColor Green
    Write-Host "   Response: $($response.StatusCode)" -ForegroundColor Cyan
    
    # Test API endpoint
    try {
        $apiResponse = Invoke-RestMethod -Uri "http://localhost:8000/api/threats/statistics" -Method GET -TimeoutSec 3 -ErrorAction Stop
        Write-Host "   API: ✅ Working" -ForegroundColor Green
    } catch {
        Write-Host "   API: ⚠️  Endpoint may require auth" -ForegroundColor Yellow
    }
} catch {
    Write-Host "   Status: ❌ OFFLINE" -ForegroundColor Red
    Write-Host "   Error: $_" -ForegroundColor Red
    Write-Host "   Fix: Run .\START-API-SERVER.ps1" -ForegroundColor Yellow
    $allGood = $false
}

# ============================================
# 2. ML Service
# ============================================
Write-Host "`n2. ML Service (http://localhost:5000)" -ForegroundColor Cyan
Write-Host "--------------------------------" -ForegroundColor Gray
try {
    $response = Invoke-WebRequest -Uri "http://localhost:5000/health" -UseBasicParsing -TimeoutSec 3 -ErrorAction Stop
    Write-Host "   Status: ✅ ONLINE" -ForegroundColor Green
    Write-Host "   Response: $($response.StatusCode)" -ForegroundColor Cyan
} catch {
    Write-Host "   Status: ❌ OFFLINE" -ForegroundColor Red
    Write-Host "   Error: $_" -ForegroundColor Red
    Write-Host "   Fix: Start ML service (python app.py)" -ForegroundColor Yellow
    $allGood = $false
}

# ============================================
# 3. Portal (Next.js)
# ============================================
Write-Host "`n3. Portal (http://localhost:3000)" -ForegroundColor Cyan
Write-Host "--------------------------------" -ForegroundColor Gray
try {
    $response = Invoke-WebRequest -Uri "http://localhost:3000" -UseBasicParsing -TimeoutSec 3 -ErrorAction Stop
    Write-Host "   Status: ✅ ONLINE" -ForegroundColor Green
    Write-Host "   Response: $($response.StatusCode)" -ForegroundColor Cyan
} catch {
    Write-Host "   Status: ❌ OFFLINE" -ForegroundColor Red
    Write-Host "   Error: $_" -ForegroundColor Red
    Write-Host "   Fix: cd frontend\portal && npm run dev" -ForegroundColor Yellow
}

# ============================================
# 4. Admin Dashboard (Vue.js)
# ============================================
Write-Host "`n4. Admin Dashboard (http://localhost:5173)" -ForegroundColor Cyan
Write-Host "--------------------------------" -ForegroundColor Gray
try {
    $response = Invoke-WebRequest -Uri "http://localhost:5173" -UseBasicParsing -TimeoutSec 3 -ErrorAction Stop
    Write-Host "   Status: ✅ ONLINE" -ForegroundColor Green
    Write-Host "   Response: $($response.StatusCode)" -ForegroundColor Cyan
} catch {
    Write-Host "   Status: ❌ OFFLINE" -ForegroundColor Red
    Write-Host "   Error: $_" -ForegroundColor Red
    Write-Host "   Fix: cd frontend\admin-dashboard && npm run dev" -ForegroundColor Yellow
}

# ============================================
# 5. Database
# ============================================
Write-Host "`n5. Database Connection" -ForegroundColor Cyan
Write-Host "--------------------------------" -ForegroundColor Gray
cd backend\api
try {
    $dbCheck = C:\php81\php.exe artisan db:show 2>&1
    if ($LASTEXITCODE -eq 0) {
        Write-Host "   Status: ✅ CONNECTED" -ForegroundColor Green
        
        # Check tables
        $tables = @("threats", "documents", "incidents", "threat_actions", "users")
        $allTablesExist = $true
        foreach ($table in $tables) {
            $check = C:\php81\php.exe artisan tinker --execute="echo DB::table('$table')->count();" 2>&1
            if ($LASTEXITCODE -eq 0) {
                $count = ($check | Select-String -Pattern "^\d+").Matches.Value
                Write-Host "   $table : $count records" -ForegroundColor Gray
            } else {
                Write-Host "   $table : ❌ Missing" -ForegroundColor Red
                $allTablesExist = $false
            }
        }
        
        if ($allTablesExist) {
            Write-Host "   Tables: ✅ All exist" -ForegroundColor Green
        }
    } else {
        Write-Host "   Status: ❌ DISCONNECTED" -ForegroundColor Red
        Write-Host "   Error: $dbCheck" -ForegroundColor Red
        $allGood = $false
    }
} catch {
    Write-Host "   Status: ❌ ERROR" -ForegroundColor Red
    Write-Host "   Error: $_" -ForegroundColor Red
    $allGood = $false
}
cd ..\..

# ============================================
# SUMMARY
# ============================================
Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "  Summary" -ForegroundColor Cyan
Write-Host "========================================`n" -ForegroundColor Cyan

if ($allGood) {
    Write-Host "✅ All critical services are running!" -ForegroundColor Green
} else {
    Write-Host "⚠️  Some services need attention" -ForegroundColor Yellow
    Write-Host "`nQuick Fix:" -ForegroundColor Cyan
    Write-Host "  API Server: .\START-API-SERVER.ps1" -ForegroundColor White
    Write-Host "  ML Service: cd backend\ml-service && python app.py" -ForegroundColor White
    Write-Host "  Portal: cd frontend\portal && npm run dev" -ForegroundColor White
    Write-Host "  Admin: cd frontend\admin-dashboard && npm run dev" -ForegroundColor White
}

Write-Host "`n========================================`n" -ForegroundColor Cyan
