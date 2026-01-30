# Quick System Fix - Process Documents and Create Test Data

Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "  Quick System Fix" -ForegroundColor Cyan
Write-Host "========================================`n" -ForegroundColor Cyan

# 1. Process Documents
Write-Host "1. Processing Documents..." -ForegroundColor Yellow
try {
    .\QUICK-FIX-LEARNING.ps1
} catch {
    Write-Host "   ⚠️  Document processing failed" -ForegroundColor Yellow
}

# 2. Create Test Threats
Write-Host "`n2. Creating Test Threats..." -ForegroundColor Yellow

try {
    $login = Invoke-RestMethod -Uri "http://localhost:8000/api/login" -Method POST -Body (@{email="admin@sentinelai.com";password="admin123"} | ConvertTo-Json) -ContentType "application/json" -TimeoutSec 5
    $token = $login.token
    $headers = @{Authorization = "Bearer $token"}
    
    $threats = @(
        @{
            type = "malware"
            severity = 8
            source_ip = "192.168.1.100"
            target_ip = "192.168.1.50"
            description = "Suspicious malware detected - trojan activity"
            classification = "trojan"
        },
        @{
            type = "ddos"
            severity = 7
            source_ip = "10.0.0.50"
            target_ip = "192.168.1.50"
            description = "DDoS attack detected"
            classification = "network_attack"
        },
        @{
            type = "phishing"
            severity = 6
            source_ip = "172.16.0.25"
            description = "Phishing attempt detected"
            classification = "social_engineering"
        }
    )
    
    $created = 0
    foreach ($threat in $threats) {
        try {
            $result = Invoke-RestMethod -Uri "http://localhost:8000/api/threats" -Method POST -Body ($threat | ConvertTo-Json) -ContentType "application/json" -Headers $headers -TimeoutSec 5
            if ($result.success) {
                $created++
                Write-Host "   ✅ Created: $($threat.type)" -ForegroundColor Green
            }
        } catch {
            Write-Host "   ⚠️  Failed: $($threat.type)" -ForegroundColor Yellow
        }
    }
    
    Write-Host "   Created $created threats" -ForegroundColor Cyan
} catch {
    Write-Host "   ❌ Failed to create threats: $_" -ForegroundColor Red
}

# 3. Test Counter-Offensive
Write-Host "`n3. Testing Counter-Offensive..." -ForegroundColor Yellow

try {
    $testAttack = @{
        attack_data = @{
            source_ip = "192.168.1.100"
            target_ip = "192.168.1.50"
            attack_type = "trojan"
            severity = 8
            description = "Test attack for counter-offensive"
            network = @{
                source_ip = "192.168.1.100"
                destination_ip = "192.168.1.50"
            }
        }
    } | ConvertTo-Json
    
    $counter = Invoke-RestMethod -Uri "http://localhost:5000/api/v1/counter-offensive/execute" -Method POST -Body $testAttack -ContentType "application/json" -TimeoutSec 10
    
    if ($counter.success) {
        Write-Host "   ✅ Counter-Offensive: Working" -ForegroundColor Green
        Write-Host "   Attacker ID: $($counter.attacker_profile.attacker_id)" -ForegroundColor Cyan
        Write-Host "   Validated: $($counter.validation.validated)" -ForegroundColor Cyan
    } else {
        Write-Host "   ⚠️  Counter-Offensive: Not successful" -ForegroundColor Yellow
    }
} catch {
    Write-Host "   ❌ Counter-Offensive: Failed" -ForegroundColor Red
    Write-Host "   Error: $_" -ForegroundColor Yellow
}

# 4. Summary
Write-Host "`n4. System Status:" -ForegroundColor Yellow

try {
    $learning = Invoke-RestMethod -Uri "http://localhost:5000/api/v1/learning/summary" -Method GET -TimeoutSec 5
    Write-Host "   Documents Processed: $($learning.summary.total_documents)" -ForegroundColor Cyan
    Write-Host "   Patterns Learned: $($learning.summary.total_patterns_learned)" -ForegroundColor Cyan
} catch {
    Write-Host "   ⚠️  Could not get learning summary" -ForegroundColor Yellow
}

cd backend\api
$threatCount = C:\php81\php.exe artisan tinker --execute="echo App\Models\Threat::count();" 2>&1 | Select-String -Pattern "^\d+"
Write-Host "   Threats in Database: $threatCount" -ForegroundColor Cyan
cd ..\..

Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "  Done!" -ForegroundColor Green
Write-Host "========================================`n" -ForegroundColor Cyan

Write-Host "Now check:" -ForegroundColor Yellow
Write-Host "  - Dashboard: http://localhost:5173" -ForegroundColor White
Write-Host "  - Portal: http://localhost:3000" -ForegroundColor White
Write-Host "  - Learning: http://localhost:3000/learning" -ForegroundColor White
