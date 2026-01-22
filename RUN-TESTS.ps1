# Comprehensive Test Suite for SentinelAI X
# Tests all services and functionality

Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "  SentinelAI X - Test Suite" -ForegroundColor Cyan
Write-Host "========================================`n" -ForegroundColor Cyan

$API_URL = "http://localhost:8000"
$ML_SERVICE_URL = "http://localhost:5000"
$PORTAL_URL = "http://localhost:3000"
$ADMIN_URL = "http://localhost:5173"

$allTestsPassed = $true
$testResults = @()

function Test-Service {
    param($name, $url, $expectedStatus = 200)
    
    Write-Host "Testing $name..." -ForegroundColor Yellow -NoNewline
    try {
        $response = Invoke-WebRequest -Uri $url -UseBasicParsing -TimeoutSec 5 -ErrorAction Stop
        if ($response.StatusCode -eq $expectedStatus) {
            Write-Host " ✅ PASS" -ForegroundColor Green
            return $true
        } else {
            Write-Host " ❌ FAIL (Status: $($response.StatusCode))" -ForegroundColor Red
            return $false
        }
    } catch {
        Write-Host " ❌ FAIL ($($_.Exception.Message))" -ForegroundColor Red
        return $false
    }
}

function Test-APIEndpoint {
    param($name, $method, $url, $headers = @{}, $body = $null, $expectedStatus = 200)
    
    Write-Host "Testing $name..." -ForegroundColor Yellow -NoNewline
    try {
        $params = @{
            Uri = $url
            Method = $method
            Headers = $headers
            UseBasicParsing = $true
            TimeoutSec = 10
            ErrorAction = 'Stop'
        }
        
        if ($body) {
            $params.Body = ($body | ConvertTo-Json)
            $params.ContentType = "application/json"
        }
        
        $response = Invoke-WebRequest @params
        if ($response.StatusCode -eq $expectedStatus) {
            Write-Host " ✅ PASS" -ForegroundColor Green
            return @{success = $true; data = ($response.Content | ConvertFrom-Json)}
        } else {
            Write-Host " ❌ FAIL (Status: $($response.StatusCode))" -ForegroundColor Red
            return @{success = $false; error = "Status: $($response.StatusCode)"}
        }
    } catch {
        Write-Host " ❌ FAIL ($($_.Exception.Message))" -ForegroundColor Red
        return @{success = $false; error = $_.Exception.Message}
    }
}

# ============================================
# 1. SERVICE AVAILABILITY TESTS
# ============================================
Write-Host "`n1. Service Availability Tests" -ForegroundColor Cyan
Write-Host "--------------------------------" -ForegroundColor Gray

$testResults += @{category = "Services"; name = "Laravel API"; result = Test-Service "Laravel API" "$API_URL" }
$testResults += @{category = "Services"; name = "ML Service"; result = Test-Service "ML Service" "$ML_SERVICE_URL/health" }
$testResults += @{category = "Services"; name = "Portal"; result = Test-Service "Portal" "$PORTAL_URL" }
$testResults += @{category = "Services"; name = "Admin Dashboard"; result = Test-Service "Admin Dashboard" "$ADMIN_URL" }

# ============================================
# 2. AUTHENTICATION TESTS
# ============================================
Write-Host "`n2. Authentication Tests" -ForegroundColor Cyan
Write-Host "--------------------------------" -ForegroundColor Gray

$loginBody = @{
    email = "admin@sentinelai.com"
    password = "admin123"
} | ConvertTo-Json

$loginResult = Test-APIEndpoint "Login" "POST" "$API_URL/api/login" @{} $loginBody 200
$testResults += @{category = "Auth"; name = "Login"; result = $loginResult.success}

if ($loginResult.success -and $loginResult.data.token) {
    $global:testToken = $loginResult.data.token
    Write-Host "Token obtained: $($global:testToken.Substring(0, 20))..." -ForegroundColor Gray
    
    # Test Get User
    $userHeaders = @{Authorization = "Bearer $global:testToken"}
    $userResult = Test-APIEndpoint "Get User" "GET" "$API_URL/api/user" $userHeaders
    $testResults += @{category = "Auth"; name = "Get User"; result = $userResult.success}
} else {
    Write-Host "⚠️  Cannot continue API tests without authentication token" -ForegroundColor Yellow
    $global:testToken = $null
}

# ============================================
# 3. DOCUMENTS API TESTS
# ============================================
if ($global:testToken) {
    Write-Host "`n3. Documents API Tests" -ForegroundColor Cyan
    Write-Host "--------------------------------" -ForegroundColor Gray
    
    $docHeaders = @{Authorization = "Bearer $global:testToken"}
    
    # List Documents
    $listResult = Test-APIEndpoint "List Documents" "GET" "$API_URL/api/documents" $docHeaders
    $testResults += @{category = "Documents"; name = "List Documents"; result = $listResult.success}
    
    # Create Document (JSON - Drive download style)
    $docBody = @{
        title = "Test Document"
        filename = "test_document.pdf"
        file_path = "downloaded/test_document.pdf"
        file_type = "pdf"
        file_size = 1024
        status = "processed"
        metadata = @{
            source = "test"
            test = $true
        }
    }
    
    $createResult = Test-APIEndpoint "Create Document (JSON)" "POST" "$API_URL/api/documents" $docHeaders $docBody 201
    $testResults += @{category = "Documents"; name = "Create Document"; result = $createResult.success}
    
    if ($createResult.success -and $createResult.data.data.id) {
        $testDocId = $createResult.data.data.id
        
        # Get Document
        $getResult = Test-APIEndpoint "Get Document" "GET" "$API_URL/api/documents/$testDocId" $docHeaders
        $testResults += @{category = "Documents"; name = "Get Document"; result = $getResult.success}
        
        # Delete Document
        $deleteResult = Test-APIEndpoint "Delete Document" "DELETE" "$API_URL/api/documents/$testDocId" $docHeaders
        $testResults += @{category = "Documents"; name = "Delete Document"; result = $deleteResult.success}
    }
}

# ============================================
# 4. THREATS API TESTS
# ============================================
if ($global:testToken) {
    Write-Host "`n4. Threats API Tests" -ForegroundColor Cyan
    Write-Host "--------------------------------" -ForegroundColor Gray
    
    $threatHeaders = @{Authorization = "Bearer $global:testToken"}
    
    # List Threats
    $threatsResult = Test-APIEndpoint "List Threats" "GET" "$API_URL/api/threats" $threatHeaders
    $testResults += @{category = "Threats"; name = "List Threats"; result = $threatsResult.success}
    
    # Get Statistics
    $statsResult = Test-APIEndpoint "Get Threat Statistics" "GET" "$API_URL/api/threats/statistics" $threatHeaders
    $testResults += @{category = "Threats"; name = "Get Statistics"; result = $statsResult.success}
    
    # Create Threat
    $threatBody = @{
        type = "Test Threat"
        severity = 5
        status = "detected"
        description = "Test threat for automated testing"
        source_ip = "192.168.1.100"
    }
    
    $createThreatResult = Test-APIEndpoint "Create Threat" "POST" "$API_URL/api/threats" $threatHeaders $threatBody 201
    $testResults += @{category = "Threats"; name = "Create Threat"; result = $createThreatResult.success}
}

# ============================================
# 5. ML SERVICE TESTS
# ============================================
Write-Host "`n5. ML Service Tests" -ForegroundColor Cyan
Write-Host "--------------------------------" -ForegroundColor Gray

# Health Check
$mlHealthResult = Test-APIEndpoint "ML Service Health" "GET" "$ML_SERVICE_URL/health" @{}
$testResults += @{category = "ML Service"; name = "Health Check"; result = $mlHealthResult.success}

# Learning Summary
$learningSummaryResult = Test-APIEndpoint "Learning Summary" "GET" "$ML_SERVICE_URL/api/v1/learning/summary" @{}
$testResults += @{category = "ML Service"; name = "Learning Summary"; result = $learningSummaryResult.success}

# Threat Detection
$detectionBody = @{
    source_ip = "192.168.1.100"
    attack_type = "SQL Injection"
    payload = "SELECT * FROM users"
}
$detectionResult = Test-APIEndpoint "Threat Detection" "POST" "$ML_SERVICE_URL/api/v1/threats/detect" @{} $detectionBody
$testResults += @{category = "ML Service"; name = "Threat Detection"; result = $detectionResult.success}

# ============================================
# 6. DATABASE TESTS
# ============================================
Write-Host "`n6. Database Tests" -ForegroundColor Cyan
Write-Host "--------------------------------" -ForegroundColor Gray

try {
    Write-Host "Checking database connection..." -ForegroundColor Yellow -NoNewline
    cd backend\api
    $dbCheck = C:\php81\php.exe artisan db:show 2>&1
    if ($LASTEXITCODE -eq 0) {
        Write-Host " ✅ PASS" -ForegroundColor Green
        $testResults += @{category = "Database"; name = "Connection"; result = $true}
    } else {
        Write-Host " ❌ FAIL" -ForegroundColor Red
        $testResults += @{category = "Database"; name = "Connection"; result = $false}
    }
    cd ..\..
} catch {
    Write-Host " ❌ FAIL" -ForegroundColor Red
    $testResults += @{category = "Database"; name = "Connection"; result = $false}
}

# ============================================
# SUMMARY
# ============================================
Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "  Test Summary" -ForegroundColor Cyan
Write-Host "========================================`n" -ForegroundColor Cyan

$categories = $testResults | Group-Object -Property category
$totalTests = $testResults.Count
$passedTests = ($testResults | Where-Object { $_.result -eq $true }).Count
$failedTests = $totalTests - $passedTests

foreach ($category in $categories) {
    $categoryTests = $category.Group
    $categoryPassed = ($categoryTests | Where-Object { $_.result -eq $true }).Count
    $categoryTotal = $categoryTests.Count
    
    Write-Host "$($category.Name):" -ForegroundColor Cyan
    Write-Host "  Passed: $categoryPassed/$categoryTotal" -ForegroundColor $(if ($categoryPassed -eq $categoryTotal) { "Green" } else { "Yellow" })
    
    $failed = $categoryTests | Where-Object { $_.result -eq $false }
    if ($failed) {
        foreach ($test in $failed) {
            Write-Host "    ❌ $($test.name)" -ForegroundColor Red
        }
    }
    Write-Host ""
}

Write-Host "Overall: $passedTests/$totalTests tests passed" -ForegroundColor $(if ($failedTests -eq 0) { "Green" } else { "Yellow" })

if ($failedTests -gt 0) {
    Write-Host "`n⚠️  Some tests failed. Check the errors above." -ForegroundColor Yellow
    $allTestsPassed = $false
} else {
    Write-Host "`n✅ All tests passed!" -ForegroundColor Green
}

Write-Host "`n========================================`n" -ForegroundColor Cyan

exit $(if ($allTestsPassed) { 0 } else { 1 })
