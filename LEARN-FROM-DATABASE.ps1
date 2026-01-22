# Learn from all documents in database
# This script sends all unprocessed documents to ML service for learning

Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "  Learn from Database Documents" -ForegroundColor Cyan
Write-Host "========================================`n" -ForegroundColor Cyan

$API_URL = "http://localhost:8000"
$ML_SERVICE_URL = "http://localhost:5000"

# Login
Write-Host "Logging in..." -ForegroundColor Yellow
$loginBody = @{email="admin@sentinelai.com";password="admin123"} | ConvertTo-Json
$response = Invoke-RestMethod -Uri "$API_URL/api/login" -Method POST -Body $loginBody -ContentType "application/json"
$token = $response.token

if (!$token) {
    Write-Host "❌ Login failed" -ForegroundColor Red
    exit 1
}

Write-Host "✅ Logged in`n" -ForegroundColor Green

# Get all documents
Write-Host "Fetching documents from database..." -ForegroundColor Yellow
$headers = @{Authorization = "Bearer $token"}
$docsResponse = Invoke-RestMethod -Uri "$API_URL/api/documents?per_page=100" -Method GET -Headers $headers

$documents = @()
if ($docsResponse.success -and $docsResponse.data) {
    if ($docsResponse.data.data) {
        $documents = $docsResponse.data.data
    } elseif ($docsResponse.data) {
        $documents = $docsResponse.data
    }
}

Write-Host "Found $($documents.Count) documents`n" -ForegroundColor Cyan

# Process each document
$processed = 0
$failed = 0

foreach ($doc in $documents) {
    Write-Host "Processing: $($doc.title)..." -ForegroundColor Yellow -NoNewline
    
    try {
        $processResponse = Invoke-RestMethod -Uri "$API_URL/api/documents/$($doc.id)/process" -Method POST -Headers $headers -TimeoutSec 30
        
        if ($processResponse.success) {
            Write-Host " ✅" -ForegroundColor Green
            $processed++
        } else {
            Write-Host " ❌ ($($processResponse.message))" -ForegroundColor Red
            $failed++
        }
    } catch {
        Write-Host " ❌ ($($_.Exception.Message))" -ForegroundColor Red
        $failed++
    }
}

Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "  Summary" -ForegroundColor Cyan
Write-Host "========================================`n" -ForegroundColor Cyan
Write-Host "Total documents: $($documents.Count)" -ForegroundColor White
Write-Host "Processed: $processed" -ForegroundColor Green
Write-Host "Failed: $failed" -ForegroundColor $(if ($failed -gt 0) { "Red" } else { "Green" })

Write-Host "`n✅ Learning from database complete!`n" -ForegroundColor Green
