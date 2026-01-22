# Comprehensive System Check for SentinelAI X
# Verifies all components are working correctly

Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "  SentinelAI X - System Check" -ForegroundColor Cyan
Write-Host "========================================`n" -ForegroundColor Cyan

$allGood = $true

# ============================================
# 1. CHECK SERVICES
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
# 2. CHECK DATABASE
# ============================================
Write-Host "`n2. Database Status" -ForegroundColor Cyan
Write-Host "--------------------------------" -ForegroundColor Gray

try {
    cd backend\api
    Write-Host "  Checking database connection..." -ForegroundColor Yellow -NoNewline
    
    $dbInfo = C:\php81\php.exe artisan db:show 2>&1
    if ($LASTEXITCODE -eq 0) {
        Write-Host " ✅ Connected" -ForegroundColor Green
        
        # Check tables
        Write-Host "  Checking tables..." -ForegroundColor Yellow -NoNewline
        $tables = C:\php81\php.exe artisan db:table --table=documents 2>&1
        if ($LASTEXITCODE -eq 0) {
            Write-Host " ✅ Tables exist" -ForegroundColor Green
        } else {
            Write-Host " ⚠️  Some tables may be missing" -ForegroundColor Yellow
            Write-Host "     Run: C:\php81\php.exe artisan migrate" -ForegroundColor Yellow
        }
    } else {
        Write-Host " ❌ Connection failed" -ForegroundColor Red
        $allGood = $false
    }
    cd ..\..
} catch {
    Write-Host " ❌ Error checking database" -ForegroundColor Red
    $allGood = $false
}

# ============================================
# 3. CHECK AUTHENTICATION
# ============================================
Write-Host "`n3. Authentication" -ForegroundColor Cyan
Write-Host "--------------------------------" -ForegroundColor Gray

try {
    Write-Host "  Testing login..." -ForegroundColor Yellow -NoNewline
    
    $loginBody = @{
        email = "admin@sentinelai.com"
        password = "admin123"
    } | ConvertTo-Json
    
    $response = Invoke-RestMethod -Uri "http://localhost:8000/api/login" -Method POST -Body $loginBody -ContentType "application/json" -TimeoutSec 5
    
    if ($response.token) {
        Write-Host " ✅ Login works" -ForegroundColor Green
        $global:testToken = $response.token
    } else {
        Write-Host " ❌ Login failed" -ForegroundColor Red
        $allGood = $false
    }
} catch {
    Write-Host " ❌ Login failed: $($_.Exception.Message)" -ForegroundColor Red
    $allGood = $false
}

# ============================================
# 4. CHECK API ENDPOINTS
# ============================================
if ($global:testToken) {
    Write-Host "`n4. API Endpoints" -ForegroundColor Cyan
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
# 5. CHECK ML SERVICE
# ============================================
Write-Host "`n5. ML Service" -ForegroundColor Cyan
Write-Host "--------------------------------" -ForegroundColor Gray

$mlEndpoints = @(
    @{name = "Health"; url = "http://localhost:5000/health"}
    @{name = "Learning Summary"; url = "http://localhost:5000/api/v1/learning/summary"}
)

foreach ($endpoint in $mlEndpoints) {
    Write-Host "  Testing $($endpoint.name)..." -ForegroundColor Yellow -NoNewline
    try {
        $response = Invoke-RestMethod -Uri $endpoint.url -Method GET -TimeoutSec 5
        Write-Host " ✅ Working" -ForegroundColor Green
    } catch {
        Write-Host " ❌ Failed" -ForegroundColor Red
    }
}

# ============================================
# 6. CHECK FILE PERMISSIONS
# ============================================
Write-Host "`n6. File Permissions" -ForegroundColor Cyan
Write-Host "--------------------------------" -ForegroundColor Gray

$paths = @(
    @{path = "backend\api\storage"; name = "Laravel Storage"}
    @{path = "backend\api\storage\logs"; name = "Laravel Logs"}
    @{path = "backend\ml-service\downloads"; name = "ML Downloads"}
)

foreach ($pathInfo in $paths) {
    Write-Host "  Checking $($pathInfo.name)..." -ForegroundColor Yellow -NoNewline
    if (Test-Path $pathInfo.path) {
        Write-Host " ✅ Exists" -ForegroundColor Green
    } else {
        Write-Host " ⚠️  Missing (will be created)" -ForegroundColor Yellow
        try {
            New-Item -ItemType Directory -Path $pathInfo.path -Force | Out-Null
        } catch {
            Write-Host " ❌ Cannot create" -ForegroundColor Red
        }
    }
}

# ============================================
# SUMMARY
# ============================================
Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "  System Check Summary" -ForegroundColor Cyan
Write-Host "========================================`n" -ForegroundColor Cyan

if ($allGood) {
    Write-Host "✅ System is healthy!" -ForegroundColor Green
    Write-Host "`nAll required services are running and accessible." -ForegroundColor White
} else {
    Write-Host "⚠️  Some issues detected" -ForegroundColor Yellow
    Write-Host "`nPlease fix the issues above before proceeding." -ForegroundColor White
}

Write-Host "`nNext steps:" -ForegroundColor Cyan
Write-Host "1. Run tests: .\RUN-TESTS.ps1" -ForegroundColor White
Write-Host "2. Train models: .\TRAIN-MODELS.ps1" -ForegroundColor White
Write-Host "3. Start using the system!" -ForegroundColor White

Write-Host "`n========================================`n" -ForegroundColor Cyan
