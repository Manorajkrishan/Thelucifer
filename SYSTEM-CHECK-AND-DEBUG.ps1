# Comprehensive System Check and Debug Script

Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "  SentinelAI X - System Check & Debug" -ForegroundColor Cyan
Write-Host "========================================`n" -ForegroundColor Cyan

$errors = @()
$warnings = @()
$info = @()

# 1. Check Services
Write-Host "1. SERVICE STATUS" -ForegroundColor Yellow
Write-Host "--------------------------------" -ForegroundColor Gray

# API Server
Write-Host "`n[API Server]" -ForegroundColor Cyan
try {
    $api = Invoke-WebRequest -Uri "http://localhost:8000/api/health" -UseBasicParsing -TimeoutSec 3
    $apiData = $api.Content | ConvertFrom-Json
    Write-Host "   Status: ✅ Online" -ForegroundColor Green
    Write-Host "   Database: $($apiData.database)" -ForegroundColor $(if ($apiData.database -eq "connected") { "Green" } else { "Red" })
    if ($apiData.database -ne "connected") { $errors += "Database not connected" }
} catch {
    Write-Host "   Status: ❌ Offline" -ForegroundColor Red
    Write-Host "   Error: $_" -ForegroundColor Yellow
    $errors += "API Server offline"
}

# ML Service
Write-Host "`n[ML Service]" -ForegroundColor Cyan
try {
    $ml = Invoke-WebRequest -Uri "http://localhost:5000/health" -UseBasicParsing -TimeoutSec 3
    $mlData = $ml.Content | ConvertFrom-Json
    Write-Host "   Status: ✅ Online" -ForegroundColor Green
    Write-Host "   Status: $($mlData.status)" -ForegroundColor Cyan
} catch {
    Write-Host "   Status: ❌ Offline" -ForegroundColor Red
    Write-Host "   Error: $_" -ForegroundColor Yellow
    $errors += "ML Service offline"
}

# Portal
Write-Host "`n[Portal]" -ForegroundColor Cyan
try {
    $portal = Invoke-WebRequest -Uri "http://localhost:3000" -UseBasicParsing -TimeoutSec 3
    Write-Host "   Status: ✅ Online" -ForegroundColor Green
} catch {
    Write-Host "   Status: ❌ Offline" -ForegroundColor Red
    $warnings += "Portal offline"
}

# Admin Dashboard
Write-Host "`n[Admin Dashboard]" -ForegroundColor Cyan
try {
    $admin = Invoke-WebRequest -Uri "http://localhost:5173" -UseBasicParsing -TimeoutSec 3
    Write-Host "   Status: ✅ Online" -ForegroundColor Green
} catch {
    Write-Host "   Status: ❌ Offline" -ForegroundColor Red
    $warnings += "Admin Dashboard offline"
}

# 2. Check Database
Write-Host "`n2. DATABASE STATUS" -ForegroundColor Yellow
Write-Host "--------------------------------" -ForegroundColor Gray

cd backend\api
try {
    $dbCheck = C:\php81\php.exe artisan tinker --execute="echo DB::connection()->getPdo() ? 'connected' : 'failed';" 2>&1
    if ($dbCheck -match "connected") {
        Write-Host "   Status: ✅ Connected" -ForegroundColor Green
        
        # Check data
        Write-Host "`n   Data Counts:" -ForegroundColor Cyan
        $users = C:\php81\php.exe artisan tinker --execute="echo App\Models\User::count();" 2>&1 | Select-String -Pattern "^\d+"
        Write-Host "     Users: $users" -ForegroundColor White
        
        $threats = C:\php81\php.exe artisan tinker --execute="echo App\Models\Threat::count();" 2>&1 | Select-String -Pattern "^\d+"
        Write-Host "     Threats: $threats" -ForegroundColor White
        
        $docs = C:\php81\php.exe artisan tinker --execute="echo App\Models\Document::count();" 2>&1 | Select-String -Pattern "^\d+"
        Write-Host "     Documents: $docs" -ForegroundColor White
        
        $processed = C:\php81\php.exe artisan tinker --execute="echo App\Models\Document::where('status', 'processed')->count();" 2>&1 | Select-String -Pattern "^\d+"
        Write-Host "     Processed Documents: $processed" -ForegroundColor White
        
        if ([int]$processed -eq 0 -and [int]$docs -gt 0) {
            $warnings += "Documents uploaded but not processed"
        }
    } else {
        Write-Host "   Status: ❌ Not Connected" -ForegroundColor Red
        $errors += "Database not connected"
    }
} catch {
    Write-Host "   Status: ❌ Check Failed" -ForegroundColor Red
    $errors += "Database check failed"
}
cd ..\..

# 3. Check Learning System
Write-Host "`n3. LEARNING SYSTEM" -ForegroundColor Yellow
Write-Host "--------------------------------" -ForegroundColor Gray

try {
    $learning = Invoke-RestMethod -Uri "http://localhost:5000/api/v1/learning/summary" -Method GET -TimeoutSec 5
    Write-Host "   Documents Processed: $($learning.summary.total_documents)" -ForegroundColor Cyan
    Write-Host "   Patterns Learned: $($learning.summary.total_patterns_learned)" -ForegroundColor Cyan
    Write-Host "   Attack Techniques: $($learning.summary.unique_attack_techniques)" -ForegroundColor Cyan
    Write-Host "   Exploit Patterns: $($learning.summary.unique_exploit_patterns)" -ForegroundColor Cyan
    
    if ($learning.summary.total_documents -eq 0) {
        $warnings += "No documents processed - learning shows 0"
    }
} catch {
    Write-Host "   ❌ Could not get learning summary" -ForegroundColor Red
    Write-Host "   Error: $_" -ForegroundColor Yellow
    $errors += "Learning system not accessible"
}

# 4. Test Counter-Offensive
Write-Host "`n4. COUNTER-OFFENSIVE SYSTEM" -ForegroundColor Yellow
Write-Host "--------------------------------" -ForegroundColor Gray

try {
    $testAttack = @{
        attack_data = @{
            source_ip = "192.168.1.100"
            target_ip = "192.168.1.50"
            attack_type = "trojan"
            severity = 8
            description = "Test attack for system check"
        }
    } | ConvertTo-Json
    
    $counter = Invoke-RestMethod -Uri "http://localhost:5000/api/v1/counter-offensive/execute" -Method POST -Body $testAttack -ContentType "application/json" -TimeoutSec 10
    
    if ($counter.success) {
        Write-Host "   ✅ Counter-Offensive: Working" -ForegroundColor Green
        Write-Host "   Attacker Profile: $($counter.attacker_profile.attacker_id)" -ForegroundColor Cyan
        Write-Host "   Validation: $($counter.validation.validated)" -ForegroundColor Cyan
        Write-Host "   Counter-Offensive: $($counter.counter_offensive.status)" -ForegroundColor Cyan
    } else {
        Write-Host "   ⚠️  Counter-Offensive: Response but not successful" -ForegroundColor Yellow
        $warnings += "Counter-offensive returned unsuccessful"
    }
} catch {
    Write-Host "   ❌ Counter-Offensive: Failed" -ForegroundColor Red
    Write-Host "   Error: $_" -ForegroundColor Yellow
    $errors += "Counter-offensive system not working"
}

# 5. Check Logs for Errors
Write-Host "`n5. ERROR LOGS" -ForegroundColor Yellow
Write-Host "--------------------------------" -ForegroundColor Gray

if (Test-Path "backend\api\storage\logs\laravel.log") {
    $logErrors = Get-Content "backend\api\storage\logs\laravel.log" -Tail 50 | Select-String -Pattern "ERROR|Exception|Failed" -CaseSensitive:$false
    if ($logErrors) {
        Write-Host "   ⚠️  Found errors in logs:" -ForegroundColor Yellow
        $logErrors | Select-Object -First 5 | ForEach-Object {
            Write-Host "     $_" -ForegroundColor Gray
        }
        $warnings += "Errors found in Laravel logs"
    } else {
        Write-Host "   ✅ No recent errors in logs" -ForegroundColor Green
    }
} else {
    Write-Host "   ⚠️  Log file not found" -ForegroundColor Yellow
}

# Summary
Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "  SUMMARY" -ForegroundColor Cyan
Write-Host "========================================`n" -ForegroundColor Cyan

if ($errors.Count -eq 0 -and $warnings.Count -eq 0) {
    Write-Host "✅ System is working correctly!" -ForegroundColor Green
} else {
    if ($errors.Count -gt 0) {
        Write-Host "❌ ERRORS FOUND:" -ForegroundColor Red
        $errors | ForEach-Object {
            Write-Host "   - $_" -ForegroundColor Red
        }
    }
    
    if ($warnings.Count -gt 0) {
        Write-Host "`n⚠️  WARNINGS:" -ForegroundColor Yellow
        $warnings | ForEach-Object {
            Write-Host "   - $_" -ForegroundColor Yellow
        }
    }
}

Write-Host "`n========================================`n" -ForegroundColor Cyan

# Recommendations
if ($warnings -contains "Documents uploaded but not processed") {
    Write-Host "💡 RECOMMENDATION:" -ForegroundColor Cyan
    Write-Host "   Process your documents to see learning data:" -ForegroundColor White
    Write-Host "   .\QUICK-FIX-LEARNING.ps1" -ForegroundColor Yellow
}

if ($errors -contains "API Server offline") {
    Write-Host "💡 RECOMMENDATION:" -ForegroundColor Cyan
    Write-Host "   Start API server:" -ForegroundColor White
    Write-Host "   cd backend\api && C:\php81\php.exe artisan serve" -ForegroundColor Yellow
}

if ($errors -contains "ML Service offline") {
    Write-Host "💡 RECOMMENDATION:" -ForegroundColor Cyan
    Write-Host "   Start ML service:" -ForegroundColor White
    Write-Host "   cd backend\ml-service && python app.py" -ForegroundColor Yellow
}

Write-Host "`n"
