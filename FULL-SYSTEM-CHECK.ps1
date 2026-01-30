# Comprehensive System Check and Test
# Verifies all components and functionality

Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "  SentinelAI X - Full System Check" -ForegroundColor Cyan
Write-Host "========================================`n" -ForegroundColor Cyan

$allGood = $true

# ============================================
# 1. SERVICE STATUS
# ============================================
Write-Host "1. Service Status" -ForegroundColor Cyan
Write-Host "--------------------------------" -ForegroundColor Gray

$services = @(
    @{name = "Laravel API"; url = "http://localhost:8000"; required = $true}
    @{name = "ML Service"; url = "http://localhost:5000/health"; required = $true}
    @{name = "Portal"; url = "http://localhost:3000"; required = $true}
    @{name = "Admin Dashboard"; url = "http://localhost:5173"; required = $false}
)

foreach ($service in $services) {
    Write-Host "  Checking $($service.name)..." -ForegroundColor Yellow -NoNewline
    try {
        $response = Invoke-WebRequest -Uri $service.url -UseBasicParsing -TimeoutSec 3 -ErrorAction Stop
        Write-Host " ✅ Running" -ForegroundColor Green
    } catch {
        if ($service.required) {
            Write-Host " ❌ Not Running (REQUIRED)" -ForegroundColor Red
            $allGood = $false
        } else {
            Write-Host " ⚠️  Not Running (Optional)" -ForegroundColor Yellow
        }
    }
}

# ============================================
# 2. AUTHENTICATION
# ============================================
Write-Host "`n2. Authentication" -ForegroundColor Cyan
Write-Host "--------------------------------" -ForegroundColor Gray

try {
    Write-Host "  Testing login..." -ForegroundColor Yellow -NoNewline
    $loginBody = @{email="admin@sentinelai.com";password="admin123"} | ConvertTo-Json
    $response = Invoke-RestMethod -Uri "http://localhost:8000/api/login" -Method POST -Body $loginBody -ContentType "application/json" -TimeoutSec 5
    
    if ($response.token) {
        Write-Host " ✅ Working" -ForegroundColor Green
        $global:testToken = $response.token
    } else {
        Write-Host " ❌ Failed" -ForegroundColor Red
        $allGood = $false
    }
} catch {
    Write-Host " ❌ Failed" -ForegroundColor Red
    $allGood = $false
}

# ============================================
# 3. API ENDPOINTS
# ============================================
if ($global:testToken) {
    Write-Host "`n3. API Endpoints" -ForegroundColor Cyan
    Write-Host "--------------------------------" -ForegroundColor Gray
    
    $headers = @{Authorization = "Bearer $global:testToken"}
    
    $endpoints = @(
        @{name = "Documents"; url = "http://localhost:8000/api/documents"}
        @{name = "Threats"; url = "http://localhost:8000/api/threats"}
        @{name = "Threat Statistics"; url = "http://localhost:8000/api/threats/statistics"}
    )
    
    foreach ($endpoint in $endpoints) {
        Write-Host "  Testing $($endpoint.name)..." -ForegroundColor Yellow -NoNewline
        try {
            $response = Invoke-RestMethod -Uri $endpoint.url -Method GET -Headers $headers -TimeoutSec 5
            Write-Host " ✅ Working" -ForegroundColor Green
        } catch {
            Write-Host " ❌ Failed" -ForegroundColor Red
        }
    }
}

# ============================================
# 4. ML SERVICE
# ============================================
Write-Host "`n4. ML Service" -ForegroundColor Cyan
Write-Host "--------------------------------" -ForegroundColor Gray

$mlEndpoints = @(
    @{name = "Health"; url = "http://localhost:5000/health"}
    @{name = "Learning Summary"; url = "http://localhost:5000/api/v1/learning/summary"}
    @{name = "Threat Detection"; url = "http://localhost:5000/api/v1/threats/detect"}
)

foreach ($endpoint in $mlEndpoints) {
    Write-Host "  Testing $($endpoint.name)..." -ForegroundColor Yellow -NoNewline
    try {
        if ($endpoint.name -eq "Threat Detection") {
            $body = @{
                source_ip = "192.168.1.100"
                attack_type = "SQL Injection"
                payload = "SELECT * FROM users"
            } | ConvertTo-Json
            $response = Invoke-RestMethod -Uri $endpoint.url -Method POST -Body $body -ContentType "application/json" -TimeoutSec 5
        } else {
            $response = Invoke-RestMethod -Uri $endpoint.url -Method GET -TimeoutSec 5
        }
        Write-Host " ✅ Working" -ForegroundColor Green
    } catch {
        Write-Host " ❌ Failed" -ForegroundColor Red
    }
}

# ============================================
# 5. DATABASE
# ============================================
Write-Host "`n5. Database" -ForegroundColor Cyan
Write-Host "--------------------------------" -ForegroundColor Gray

try {
    cd backend\api
    Write-Host "  Checking connection..." -ForegroundColor Yellow -NoNewline
    $dbCheck = C:\php81\php.exe artisan db:show 2>&1
    if ($LASTEXITCODE -eq 0) {
        Write-Host " ✅ Connected" -ForegroundColor Green
        
        Write-Host "  Checking tables..." -ForegroundColor Yellow -NoNewline
        $tables = @("documents", "threats", "incidents", "users")
        $allTablesExist = $true
        foreach ($table in $tables) {
            $check = C:\php81\php.exe artisan tinker --execute="echo DB::table('$table')->count();" 2>&1
            if ($LASTEXITCODE -ne 0) {
                $allTablesExist = $false
                break
            }
        }
        if ($allTablesExist) {
            Write-Host " ✅ All tables exist" -ForegroundColor Green
        } else {
            Write-Host " ⚠️  Some tables missing" -ForegroundColor Yellow
        }
    } else {
        Write-Host " ❌ Connection failed" -ForegroundColor Red
        $allGood = $false
    }
    cd ..\..
} catch {
    Write-Host " ❌ Error" -ForegroundColor Red
    $allGood = $false
}

# ============================================
# 6. LEARNING SYSTEM
# ============================================
Write-Host "`n6. Learning System" -ForegroundColor Cyan
Write-Host "--------------------------------" -ForegroundColor Gray

try {
    Write-Host "  Checking learning summary..." -ForegroundColor Yellow -NoNewline
    $summary = Invoke-RestMethod -Uri "http://localhost:5000/api/v1/learning/summary" -Method GET -TimeoutSec 5
    if ($summary.success) {
        Write-Host " ✅ Working" -ForegroundColor Green
        Write-Host "    Documents processed: $($summary.summary.total_documents)" -ForegroundColor Cyan
        Write-Host "    Patterns learned: $($summary.summary.total_patterns_learned)" -ForegroundColor Cyan
    } else {
        Write-Host " ⚠️  No data yet" -ForegroundColor Yellow
    }
} catch {
    Write-Host " ❌ Failed" -ForegroundColor Red
}

# ============================================
# SUMMARY
# ============================================
Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "  System Check Summary" -ForegroundColor Cyan
Write-Host "========================================`n" -ForegroundColor Cyan

if ($allGood) {
    Write-Host "✅ System is operational!" -ForegroundColor Green
    Write-Host "`n🌐 Access URLs:" -ForegroundColor Cyan
    Write-Host "   Portal: http://localhost:3000" -ForegroundColor White
    Write-Host "   Admin: http://localhost:5173" -ForegroundColor White
    Write-Host "   API: http://localhost:8000" -ForegroundColor White
    Write-Host "   ML Service: http://localhost:5000" -ForegroundColor White
} else {
    Write-Host "⚠️  Some issues detected" -ForegroundColor Yellow
    Write-Host "`nPlease fix the issues above before proceeding." -ForegroundColor White
}

Write-Host "`n📚 Next Steps:" -ForegroundColor Cyan
Write-Host "  1. Process Drive folder files (see: .\BATCH-PROCESS-DRIVE-FILES.ps1)" -ForegroundColor White
Write-Host "  2. Train models: .\TRAIN-MODELS.ps1" -ForegroundColor White
Write-Host "  3. Learn from database: .\LEARN-FROM-DATABASE.ps1" -ForegroundColor White
Write-Host "  4. Run tests: .\RUN-TESTS.ps1" -ForegroundColor White

Write-Host "`n========================================`n" -ForegroundColor Cyan
