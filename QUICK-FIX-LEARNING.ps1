# Quick Fix: Process Documents and Trigger Learning

Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "  Quick Fix: Process Documents & Learn" -ForegroundColor Cyan
Write-Host "========================================`n" -ForegroundColor Cyan

# Check services
Write-Host "1. Checking services..." -ForegroundColor Yellow
try {
    $api = Invoke-WebRequest -Uri "http://localhost:8000" -UseBasicParsing -TimeoutSec 3
    Write-Host "   ✅ API Server: Online" -ForegroundColor Green
} catch {
    Write-Host "   ❌ API Server: Offline - Start it first!" -ForegroundColor Red
    exit 1
}

try {
    $ml = Invoke-WebRequest -Uri "http://localhost:5000/health" -UseBasicParsing -TimeoutSec 3
    Write-Host "   ✅ ML Service: Online" -ForegroundColor Green
} catch {
    Write-Host "   ❌ ML Service: Offline - Start it first!" -ForegroundColor Red
    exit 1
}

# Login
Write-Host "`n2. Logging in..." -ForegroundColor Yellow
try {
    $loginBody = @{email="admin@sentinelai.com";password="admin123"} | ConvertTo-Json
    $login = Invoke-RestMethod -Uri "http://localhost:8000/api/login" -Method POST -Body $loginBody -ContentType "application/json" -TimeoutSec 10
    $token = $login.token
    $headers = @{Authorization = "Bearer $token"}
    Write-Host "   ✅ Login successful" -ForegroundColor Green
} catch {
    Write-Host "   ❌ Login failed: $_" -ForegroundColor Red
    exit 1
}

# Get documents
Write-Host "`n3. Getting documents..." -ForegroundColor Yellow
try {
    $docs = Invoke-RestMethod -Uri "http://localhost:8000/api/documents?per_page=100" -Method GET -Headers $headers -TimeoutSec 10
    $docList = $docs.data.data
    Write-Host "   Found $($docList.Count) documents" -ForegroundColor Cyan
} catch {
    Write-Host "   ❌ Failed to get documents: $_" -ForegroundColor Red
    exit 1
}

if ($docList.Count -eq 0) {
    Write-Host "   ⚠️  No documents to process" -ForegroundColor Yellow
    exit 0
}

# Process each document
Write-Host "`n4. Processing documents..." -ForegroundColor Yellow
$processed = 0
$failed = 0

foreach ($doc in $docList) {
    Write-Host "   [$($doc.id)] $($doc.title)..." -ForegroundColor Gray -NoNewline
    
    try {
        $result = Invoke-RestMethod -Uri "http://localhost:8000/api/documents/$($doc.id)/process" -Method POST -Headers $headers -TimeoutSec 60 -ErrorAction Stop
        
        if ($result.success) {
            Write-Host " ✅" -ForegroundColor Green
            $processed++
            Start-Sleep -Milliseconds 1000
        } else {
            Write-Host " ⚠️" -ForegroundColor Yellow
            $failed++
        }
    } catch {
        Write-Host " ❌" -ForegroundColor Red
        $failed++
    }
}

Write-Host "`n5. Summary:" -ForegroundColor Cyan
Write-Host "   Processed: $processed" -ForegroundColor Green
Write-Host "   Failed: $failed" -ForegroundColor $(if ($failed -gt 0) { "Red" } else { "Gray" })

# Check learning
Write-Host "`n6. Checking learning..." -ForegroundColor Yellow
Start-Sleep -Seconds 3
try {
    $summary = Invoke-RestMethod -Uri "http://localhost:5000/api/v1/learning/summary" -Method GET -TimeoutSec 5
    if ($summary.success) {
        $s = $summary.summary
        Write-Host "   Documents processed: $($s.total_documents)" -ForegroundColor Cyan
        Write-Host "   Patterns learned: $($s.total_patterns_learned)" -ForegroundColor Cyan
        Write-Host "   Attack techniques: $($s.unique_attack_techniques)" -ForegroundColor Cyan
        
        if ($s.total_documents -gt 0) {
            Write-Host "`n   ✅ Learning is working!" -ForegroundColor Green
        } else {
            Write-Host "`n   ⚠️  Learning shows 0 - documents may need reprocessing" -ForegroundColor Yellow
        }
    }
} catch {
    Write-Host "   ⚠️  Could not get learning summary" -ForegroundColor Yellow
}

Write-Host "`n========================================`n" -ForegroundColor Cyan
