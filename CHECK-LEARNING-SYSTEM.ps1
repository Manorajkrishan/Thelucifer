# Check Why Learning Isn't Showing

Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "  Check Learning System" -ForegroundColor Cyan
Write-Host "========================================`n" -ForegroundColor Cyan

# 1. Check Documents
Write-Host "1. Checking Documents..." -ForegroundColor Yellow
cd backend\api
$docCount = C:\php81\php.exe artisan tinker --execute="echo App\Models\Document::count();" 2>&1 | Select-String -Pattern "^\d+"
Write-Host "   Total Documents: $docCount" -ForegroundColor Cyan

$processedCount = C:\php81\php.exe artisan tinker --execute="echo App\Models\Document::where('status', 'processed')->count();" 2>&1 | Select-String -Pattern "^\d+"
Write-Host "   Processed: $processedCount" -ForegroundColor Cyan

$withDataCount = C:\php81\php.exe artisan tinker --execute="echo App\Models\Document::whereNotNull('extracted_data')->count();" 2>&1 | Select-String -Pattern "^\d+"
Write-Host "   With extracted_data: $withDataCount" -ForegroundColor Cyan

cd ..\..

# 2. Check ML Service Learning
Write-Host "`n2. Checking ML Service Learning..." -ForegroundColor Yellow
try {
    $summary = Invoke-RestMethod -Uri "http://localhost:5000/api/v1/learning/summary" -Method GET -TimeoutSec 5
    Write-Host "   Learning Summary:" -ForegroundColor Cyan
    if ($summary.success) {
        $s = $summary.summary
        Write-Host "     Documents processed: $($s.total_documents)" -ForegroundColor White
        Write-Host "     Patterns learned: $($s.total_patterns_learned)" -ForegroundColor White
        Write-Host "     Attack techniques: $($s.attack_techniques_learned)" -ForegroundColor White
        Write-Host "     Defense strategies: $($s.defense_strategies_learned)" -ForegroundColor White
    } else {
        Write-Host "     ⚠️  No learning data yet" -ForegroundColor Yellow
    }
} catch {
    Write-Host "   ❌ Failed to get learning summary: $_" -ForegroundColor Red
}

# 3. Check if documents were sent to ML service
Write-Host "`n3. Checking Document Processing..." -ForegroundColor Yellow
cd backend\api
$docs = C:\php81\php.exe artisan tinker --execute="App\Models\Document::all()->each(function(`$d) { echo `$d->id . '|' . `$d->title . '|' . `$d->status . '|' . (!empty(`$d->extracted_data) ? 'YES' : 'NO') . PHP_EOL; });" 2>&1

if ($docs) {
    Write-Host "   Document Details:" -ForegroundColor Cyan
    $docs | ForEach-Object {
        if ($_ -match "^\d+") {
            $parts = $_ -split '\|'
            Write-Host "     ID $($parts[0]): $($parts[1]) - Status: $($parts[2]) - Has Data: $($parts[3])" -ForegroundColor White
        }
    }
}

cd ..\..

# 4. Trigger Learning for All Documents
Write-Host "`n4. Triggering Learning for All Documents..." -ForegroundColor Yellow
Write-Host "   This will process all documents and trigger learning" -ForegroundColor Gray

$loginBody = @{email="admin@sentinelai.com";password="admin123"} | ConvertTo-Json
try {
    $login = Invoke-RestMethod -Uri "http://localhost:8000/api/login" -Method POST -Body $loginBody -ContentType "application/json" -TimeoutSec 5
    $token = $login.token
    
    # Get all documents
    $docs = Invoke-RestMethod -Uri "http://localhost:8000/api/documents" -Method GET -Headers @{Authorization="Bearer $token"} -TimeoutSec 5
    
    if ($docs.success -and $docs.data.data.Count -gt 0) {
        $processed = 0
        foreach ($doc in $docs.data.data) {
            Write-Host "   Processing: $($doc.title)..." -ForegroundColor Gray -NoNewline
            try {
                $result = Invoke-RestMethod -Uri "http://localhost:8000/api/documents/$($doc.id)/process" -Method POST -Headers @{Authorization="Bearer $token"} -TimeoutSec 10
                if ($result.success) {
                    Write-Host " ✅" -ForegroundColor Green
                    $processed++
                } else {
                    Write-Host " ⚠️" -ForegroundColor Yellow
                }
            } catch {
                Write-Host " ❌" -ForegroundColor Red
            }
        }
        Write-Host "   Processed $processed documents" -ForegroundColor Cyan
    } else {
        Write-Host "   ⚠️  No documents to process" -ForegroundColor Yellow
    }
} catch {
    Write-Host "   ❌ Failed: $_" -ForegroundColor Red
}

# 5. Check Learning Again
Write-Host "`n5. Re-checking Learning Summary..." -ForegroundColor Yellow
Start-Sleep -Seconds 2
try {
    $summary = Invoke-RestMethod -Uri "http://localhost:5000/api/v1/learning/summary" -Method GET -TimeoutSec 5
    if ($summary.success) {
        $s = $summary.summary
        Write-Host "   Updated Learning Summary:" -ForegroundColor Cyan
        Write-Host "     Documents processed: $($s.total_documents)" -ForegroundColor White
        Write-Host "     Patterns learned: $($s.total_patterns_learned)" -ForegroundColor White
        Write-Host "     Attack techniques: $($s.attack_techniques_learned)" -ForegroundColor White
    }
} catch {
    Write-Host "   ⚠️  Could not get updated summary" -ForegroundColor Yellow
}

Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "  Recommendations" -ForegroundColor Cyan
Write-Host "========================================`n" -ForegroundColor Cyan

Write-Host "If learning shows 0:" -ForegroundColor Yellow
Write-Host "  1. Documents may not have been processed by ML service" -ForegroundColor White
Write-Host "  2. Run: .\LEARN-FROM-DATABASE.ps1" -ForegroundColor White
Write-Host "  3. Check ML service logs for errors" -ForegroundColor White
Write-Host "  4. Verify documents have extracted_data" -ForegroundColor White

Write-Host "`n========================================`n" -ForegroundColor Cyan
