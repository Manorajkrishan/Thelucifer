# Debug Drive Link Learning and Save Process

Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "  Debug Drive Learning & Save" -ForegroundColor Cyan
Write-Host "========================================`n" -ForegroundColor Cyan

# Check database
Write-Host "1. Checking Database Configuration..." -ForegroundColor Yellow
cd backend\api
if (Test-Path ".env") {
    $dbType = (Get-Content .env | Select-String -Pattern "^DB_CONNECTION=").ToString().Split('=')[1]
    $dbName = (Get-Content .env | Select-String -Pattern "^DB_DATABASE=").ToString().Split('=')[1]
    Write-Host "   Database Type: $dbType" -ForegroundColor Cyan
    Write-Host "   Database Name: $dbName" -ForegroundColor Cyan
    
    if ($dbType -eq "sqlite") {
        Write-Host "   ⚠️  Using SQLite - data saved to: $dbName" -ForegroundColor Yellow
        Write-Host "   💡 If checking phpMyAdmin (MySQL), switch to MySQL first!" -ForegroundColor Yellow
    } elseif ($dbType -eq "mysql") {
        Write-Host "   ✅ Using MySQL - data saved to: $dbName" -ForegroundColor Green
    }
} else {
    Write-Host "   ❌ .env file not found" -ForegroundColor Red
}

Write-Host "`n2. Checking Documents in Database..." -ForegroundColor Yellow
try {
    $docCount = C:\php81\php.exe artisan tinker --execute="echo App\Models\Document::count();" 2>&1
    if ($LASTEXITCODE -eq 0) {
        $count = ($docCount | Select-String -Pattern "^\d+").Matches.Value
        Write-Host "   Total Documents: $count" -ForegroundColor Cyan
        
        $driveDocs = C:\php81\php.exe artisan tinker --execute="echo App\Models\Document::whereJsonContains('metadata->source', 'google_drive')->count();" 2>&1
        if ($LASTEXITCODE -eq 0) {
            $driveCount = ($driveDocs | Select-String -Pattern "^\d+").Matches.Value
            Write-Host "   Drive Documents: $driveCount" -ForegroundColor Cyan
        }
    } else {
        Write-Host "   ⚠️  Could not check documents" -ForegroundColor Yellow
    }
} catch {
    Write-Host "   ⚠️  Error checking documents" -ForegroundColor Yellow
}

Write-Host "`n3. Checking Laravel Logs..." -ForegroundColor Yellow
$logFile = "storage\logs\laravel.log"
if (Test-Path $logFile) {
    Write-Host "   Recent document save attempts:" -ForegroundColor Cyan
    Get-Content $logFile -Tail 30 | Select-String -Pattern "document|Drive|save" | Select-Object -Last 10
} else {
    Write-Host "   ⚠️  Log file not found" -ForegroundColor Yellow
}

Write-Host "`n4. Testing API Endpoints..." -ForegroundColor Yellow

# Login first
Write-Host "   Logging in..." -ForegroundColor Gray
try {
    $loginBody = @{email="admin@sentinelai.com";password="admin123"} | ConvertTo-Json
    $response = Invoke-RestMethod -Uri "http://localhost:8000/api/login" -Method POST -Body $loginBody -ContentType "application/json" -TimeoutSec 5
    $token = $response.token
    Write-Host "   ✅ Login successful" -ForegroundColor Green
} catch {
    Write-Host "   ❌ Login failed: $_" -ForegroundColor Red
    $token = $null
}

if ($token) {
    Write-Host "`n   Testing document list..." -ForegroundColor Gray
    try {
        $docs = Invoke-RestMethod -Uri "http://localhost:8000/api/documents" -Method GET -Headers @{Authorization="Bearer $token"} -TimeoutSec 5
        if ($docs.success) {
            $docList = $docs.data.data
            if ($docList) {
                Write-Host "   ✅ Found $($docList.Count) documents via API" -ForegroundColor Green
                Write-Host "   Recent documents:" -ForegroundColor Cyan
                $docList | Select-Object -First 5 | ForEach-Object {
                    Write-Host "     - $($_.title) ($($_.status))" -ForegroundColor Gray
                }
            } else {
                Write-Host "   ⚠️  No documents found via API" -ForegroundColor Yellow
            }
        }
    } catch {
        Write-Host "   ❌ Failed to fetch documents: $_" -ForegroundColor Red
    }
}

Write-Host "`n5. Checking ML Service..." -ForegroundColor Yellow
try {
    $mlHealth = Invoke-RestMethod -Uri "http://localhost:5000/health" -Method GET -TimeoutSec 3
    Write-Host "   ✅ ML Service is online" -ForegroundColor Green
} catch {
    Write-Host "   ❌ ML Service is offline" -ForegroundColor Red
}

Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "  Recommendations" -ForegroundColor Cyan
Write-Host "========================================`n" -ForegroundColor Cyan

if ($dbType -eq "sqlite") {
    Write-Host "⚠️  Database Mismatch Detected!" -ForegroundColor Yellow
    Write-Host "   You're using SQLite but checking MySQL in phpMyAdmin" -ForegroundColor White
    Write-Host "`n   To fix:" -ForegroundColor Cyan
    Write-Host "   1. Run: .\SWITCH-TO-MYSQL.ps1" -ForegroundColor White
    Write-Host "   2. Restart Laravel server" -ForegroundColor White
    Write-Host "   3. Try Drive link again" -ForegroundColor White
} else {
    Write-Host "✅ Database configuration looks correct" -ForegroundColor Green
    Write-Host "`n   If documents still not saving:" -ForegroundColor Cyan
    Write-Host "   1. Check browser console for errors" -ForegroundColor White
    Write-Host "   2. Check Laravel logs: Get-Content storage\logs\laravel.log -Tail 50" -ForegroundColor White
    Write-Host "   3. Verify authentication token is valid" -ForegroundColor White
    Write-Host "   4. Test save manually with: .\TEST-DRIVE-SAVE.ps1" -ForegroundColor White
}

cd ..\..

Write-Host "`n========================================`n" -ForegroundColor Cyan
