# Process All Documents and Trigger Learning

Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "  Process All Documents & Learn" -ForegroundColor Cyan
Write-Host "========================================`n" -ForegroundColor Cyan

# Login
Write-Host "1. Logging in..." -ForegroundColor Yellow
try {
    $loginBody = @{email="admin@sentinelai.com";password="admin123"} | ConvertTo-Json
    $response = Invoke-RestMethod -Uri "http://localhost:8000/api/login" -Method POST -Body $loginBody -ContentType "application/json" -TimeoutSec 5
    $token = $response.token
    Write-Host "   ✅ Login successful" -ForegroundColor Green
} catch {
    Write-Host "   ❌ Login failed: $_" -ForegroundColor Red
    exit 1
}

# Get all documents
Write-Host "`n2. Getting all documents..." -ForegroundColor Yellow
try {
    $docs = Invoke-RestMethod -Uri "http://localhost:8000/api/documents?per_page=100" -Method GET -Headers @{Authorization="Bearer $token"} -TimeoutSec 5
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
Write-Host "`n3. Processing documents..." -ForegroundColor Yellow
$processed = 0
$failed = 0

foreach ($doc in $docList) {
    Write-Host "   Processing: $($doc.title) (ID: $($doc.id))..." -ForegroundColor Gray -NoNewline
    
    try {
        # Process document
        $result = Invoke-RestMethod -Uri "http://localhost:8000/api/documents/$($doc.id)/process" -Method POST -Headers @{Authorization="Bearer $token"} -TimeoutSec 30 -ErrorAction Stop
        
        if ($result.success) {
            Write-Host " ✅" -ForegroundColor Green
            $processed++
            
            # Wait a bit for processing
            Start-Sleep -Milliseconds 500
        } else {
            Write-Host " ⚠️  ($($result.message))" -ForegroundColor Yellow
            $failed++
        }
    } catch {
        Write-Host " ❌ ($($_.Exception.Message))" -ForegroundColor Red
        $failed++
    }
}

Write-Host "`n4. Summary:" -ForegroundColor Cyan
Write-Host "   Processed: $processed" -ForegroundColor Green
Write-Host "   Failed: $failed" -ForegroundColor $(if ($failed -gt 0) { "Red" } else { "Gray" })
Write-Host "   Total: $($docList.Count)" -ForegroundColor Cyan

# Check learning summary
Write-Host "`n5. Checking learning summary..." -ForegroundColor Yellow
Start-Sleep -Seconds 3
try {
    $summary = Invoke-RestMethod -Uri "http://localhost:5000/api/v1/learning/summary" -Method GET -TimeoutSec 5
    if ($summary.success) {
        $s = $summary.summary
        Write-Host "   Documents processed: $($s.total_documents)" -ForegroundColor Cyan
        Write-Host "   Patterns learned: $($s.total_patterns_learned)" -ForegroundColor Cyan
        Write-Host "   Attack techniques: $($s.unique_attack_techniques)" -ForegroundColor Cyan
        Write-Host "   Exploit patterns: $($s.unique_exploit_patterns)" -ForegroundColor Cyan
    }
} catch {
    Write-Host "   ⚠️  Could not get learning summary" -ForegroundColor Yellow
}

Write-Host "`n========================================`n" -ForegroundColor Cyan
