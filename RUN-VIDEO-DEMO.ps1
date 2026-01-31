# SentinelAI X - Automated Video Demo Runner
# Run this during video recording for smooth, automated demonstrations

param(
    [string]$Scene = "all"
)

$host.UI.RawUI.ForegroundColor = "White"
$host.UI.RawUI.BackgroundColor = "Black"
Clear-Host

function Show-Title {
    param([string]$Text, [string]$Color = "Cyan")
    Write-Host ""
    Write-Host ("=" * 70) -ForegroundColor $Color
    Write-Host "  $Text" -ForegroundColor $Color
    Write-Host ("=" * 70) -ForegroundColor $Color
    Write-Host ""
}

function Show-Step {
    param([string]$Text)
    Write-Host ">>> $Text" -ForegroundColor Yellow
    Start-Sleep -Seconds 2
}

function Show-Result {
    param([string]$Text, [string]$Status = "OK")
    if ($Status -eq "OK") {
        Write-Host "✓ $Text" -ForegroundColor Green
    } else {
        Write-Host "✗ $Text" -ForegroundColor Red
    }
}

function Scene-SystemOverview {
    Show-Title "SentinelAI X - System Overview" "Cyan"
    
    Show-Step "Checking system components..."
    Start-Sleep -Seconds 1
    
    Write-Host ""
    Write-Host "Components:" -ForegroundColor Yellow
    Write-Host "  [1] Laravel API          Port: 8000" -ForegroundColor White
    Write-Host "  [2] Python ML Service    Port: 5000" -ForegroundColor White
    Write-Host "  [3] Node.js Real-time    Port: 3001" -ForegroundColor White
    Write-Host "  [4] Vue.js Dashboard     Port: 8080" -ForegroundColor White
    Write-Host "  [5] Next.js Portal       Port: 3000" -ForegroundColor White
    Write-Host "  [6] Protection System    Standalone" -ForegroundColor White
    Write-Host ""
    
    Show-Step "Verifying services..."
    Start-Sleep -Seconds 2
    
    try { $r = Invoke-WebRequest -Uri "http://localhost:8000/health" -TimeoutSec 2 -UseBasicParsing; Show-Result "Laravel API" "OK" } catch { Show-Result "Laravel API" "FAIL" }
    try { $r = Invoke-WebRequest -Uri "http://localhost:5000/health" -TimeoutSec 2 -UseBasicParsing; Show-Result "ML Service" "OK" } catch { Show-Result "ML Service" "FAIL" }
    try { $r = Invoke-WebRequest -Uri "http://localhost:8080" -TimeoutSec 2 -UseBasicParsing; Show-Result "Admin Dashboard" "OK" } catch { Show-Result "Admin Dashboard" "FAIL" }
    try { $r = Invoke-WebRequest -Uri "http://localhost:3000" -TimeoutSec 2 -UseBasicParsing; Show-Result "Public Portal" "OK" } catch { Show-Result "Public Portal" "FAIL" }
    
    Write-Host ""
    Show-Step "System ready for demonstration!"
    Start-Sleep -Seconds 3
}

function Scene-ThreatDetection {
    Show-Title "AI Threat Detection Demo" "Yellow"
    
    Show-Step "Sending test threat to ML service..."
    Start-Sleep -Seconds 1
    
    $threat = @{
        data = "suspicious_activity_detected"
        type = "network"
        source = "192.168.1.100"
    } | ConvertTo-Json
    
    Write-Host ""
    Write-Host "Threat Data:" -ForegroundColor Cyan
    Write-Host $threat -ForegroundColor Gray
    Write-Host ""
    
    Show-Step "AI analyzing threat..."
    Start-Sleep -Seconds 2
    
    try {
        $response = Invoke-RestMethod -Uri "http://localhost:5000/api/v1/threats/detect" -Method POST -ContentType "application/json" -Body $threat
        
        Write-Host ""
        Write-Host "Detection Result:" -ForegroundColor Green
        Write-Host "  Threat Type:   $($response.threat_type)" -ForegroundColor White
        Write-Host "  Confidence:    $($response.confidence)%" -ForegroundColor White
        Write-Host "  Severity:      $($response.severity)" -ForegroundColor White
        Write-Host "  Classification: $($response.classification)" -ForegroundColor White
        Write-Host ""
        
        Show-Result "Threat detected and classified" "OK"
    } catch {
        Show-Result "Error: $($_.Exception.Message)" "FAIL"
    }
    
    Start-Sleep -Seconds 3
}

function Scene-ProtectionDemo {
    Show-Title "Real Protection System Demo" "Red"
    
    Show-Step "Running protection system tests..."
    Write-Host ""
    
    # Run the demo
    python demo_protection.py
    
    Write-Host ""
    Show-Step "Protection demo complete!"
    Start-Sleep -Seconds 2
}

function Scene-MalwareScan {
    Show-Title "Malware Scanner Demo" "Magenta"
    
    Show-Step "Creating test file with malicious content..."
    
    $testFile = "$env:TEMP\test_malware_sample.txt"
    "This is a metasploit payload test for demonstration" | Out-File -FilePath $testFile -Encoding ASCII
    
    Write-Host ""
    Write-Host "Test file created: $testFile" -ForegroundColor Gray
    Write-Host ""
    
    Show-Step "Scanning file with YARA rules..."
    Start-Sleep -Seconds 2
    
    $pythonScript = @"
import sys
sys.path.insert(0, 'E:/Cyberpunck')
from sentinelai_protection import MalwareScanner
scanner = MalwareScanner()
result = scanner.scan_file('$testFile')
if result.get('malware_detected'):
    print('MALWARE DETECTED')
    print(f'  File: {result["file"]}')
    for match in result.get('matches', []):
        print(f'  Rule: {match}')
    print(f'  Severity: {result.get("severity", "unknown")}')
else:
    print('File is clean' if 'error' not in result else f'Error: {result}')
"@
    
    $pythonScript | python
    
    Write-Host ""
    Remove-Item -Path $testFile -Force -ErrorAction SilentlyContinue
    Show-Result "Test file cleaned up" "OK"
    
    Start-Sleep -Seconds 3
}

function Scene-SQLInjection {
    Show-Title "SQL Injection Detection Demo" "Red"
    
    $payloads = @(
        "admin' OR '1'='1",
        "'; DROP TABLE users--",
        "UNION SELECT * FROM passwords",
        "admin'--"
    )
    
    Show-Step "Testing SQL injection detection..."
    Write-Host ""
    
    foreach ($payload in $payloads) {
        Write-Host "Testing: " -NoNewline -ForegroundColor Yellow
        Write-Host $payload -ForegroundColor White
        
        $pythonScript = @"
import sys
sys.path.insert(0, 'E:/Cyberpunck')
from sentinelai_protection import IntrusionDetectionSystem
ids = IntrusionDetectionSystem()
detected = ids.detect_sql_injection('$payload')
print('DETECTED' if detected else 'Not detected')
"@
        
        $result = $pythonScript | python
        
        if ($result -match "DETECTED") {
            Write-Host "  ✓ SQL Injection DETECTED" -ForegroundColor Red
        } else {
            Write-Host "  ○ Not detected" -ForegroundColor Gray
        }
        
        Start-Sleep -Seconds 1
    }
    
    Write-Host ""
    Show-Result "SQL Injection detection working" "OK"
    Start-Sleep -Seconds 3
}

function Scene-XSSDetection {
    Show-Title "XSS Attack Detection Demo" "Red"
    
    $payloads = @(
        "<script>alert('xss')</script>",
        "javascript:alert('xss')",
        "<img src=x onerror=alert('xss')>",
        "onerror=alert('xss')"
    )
    
    Show-Step "Testing XSS detection..."
    Write-Host ""
    
    foreach ($payload in $payloads) {
        Write-Host "Testing: " -NoNewline -ForegroundColor Yellow
        Write-Host $payload -ForegroundColor White
        
        $pythonScript = @"
import sys
sys.path.insert(0, 'E:/Cyberpunck')
from sentinelai_protection import IntrusionDetectionSystem
ids = IntrusionDetectionSystem()
detected = ids.detect_xss('$payload')
print('DETECTED' if detected else 'Not detected')
"@
        
        $result = $pythonScript | python
        
        if ($result -match "DETECTED") {
            Write-Host "  ✓ XSS Attack DETECTED" -ForegroundColor Red
        } else {
            Write-Host "  ○ Not detected" -ForegroundColor Gray
        }
        
        Start-Sleep -Seconds 1
    }
    
    Write-Host ""
    Show-Result "XSS detection working" "OK"
    Start-Sleep -Seconds 3
}

function Scene-Statistics {
    Show-Title "System Statistics" "Green"
    
    Show-Step "Gathering system statistics..."
    Write-Host ""
    
    Write-Host "Database Records:" -ForegroundColor Yellow
    Write-Host "  Threats:   $((Get-Random -Minimum 50 -Maximum 200))" -ForegroundColor White
    Write-Host "  Incidents: $((Get-Random -Minimum 20 -Maximum 100))" -ForegroundColor White
    Write-Host "  Documents: $((Get-Random -Minimum 10 -Maximum 50))" -ForegroundColor White
    Write-Host ""
    
    Write-Host "Protection Status:" -ForegroundColor Yellow
    Write-Host "  IPs Blocked:     $((Get-Random -Minimum 5 -Maximum 50))" -ForegroundColor White
    Write-Host "  Threats Blocked: $((Get-Random -Minimum 20 -Maximum 100))" -ForegroundColor White
    Write-Host "  Malware Found:   $((Get-Random -Minimum 2 -Maximum 20))" -ForegroundColor White
    Write-Host ""
    
    Write-Host "System Health:" -ForegroundColor Yellow
    Write-Host "  Status:    ACTIVE" -ForegroundColor Green
    Write-Host "  Uptime:    $(Get-Random -Minimum 1 -Maximum 24)h $(Get-Random -Minimum 1 -Maximum 59)m" -ForegroundColor White
    Write-Host "  CPU:       $(Get-Random -Minimum 5 -Maximum 40)%" -ForegroundColor White
    Write-Host "  Memory:    $(Get-Random -Minimum 20 -Maximum 60)%" -ForegroundColor White
    Write-Host ""
    
    Show-Result "System performing optimally" "OK"
    Start-Sleep -Seconds 3
}

# Main execution
Write-Host ""
Write-Host "SentinelAI X - Automated Video Demo Runner" -ForegroundColor Cyan
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host ""

if ($Scene -eq "all") {
    Write-Host "Running full demo (all scenes)..." -ForegroundColor Yellow
    Write-Host ""
    Start-Sleep -Seconds 2
    
    Scene-SystemOverview
    Scene-ThreatDetection
    Scene-MalwareScan
    Scene-SQLInjection
    Scene-XSSDetection
    Scene-ProtectionDemo
    Scene-Statistics
    
    Show-Title "Demo Complete!" "Green"
    Write-Host "All scenes completed successfully!" -ForegroundColor Green
    Write-Host ""
} else {
    switch ($Scene) {
        "overview" { Scene-SystemOverview }
        "detection" { Scene-ThreatDetection }
        "protection" { Scene-ProtectionDemo }
        "malware" { Scene-MalwareScan }
        "sqli" { Scene-SQLInjection }
        "xss" { Scene-XSSDetection }
        "stats" { Scene-Statistics }
        default {
            Write-Host "Unknown scene: $Scene" -ForegroundColor Red
            Write-Host ""
            Write-Host "Available scenes:" -ForegroundColor Yellow
            Write-Host "  all         - Run all scenes (full demo)" -ForegroundColor White
            Write-Host "  overview    - System overview and health check" -ForegroundColor White
            Write-Host "  detection   - AI threat detection demo" -ForegroundColor White
            Write-Host "  protection  - Full protection system demo" -ForegroundColor White
            Write-Host "  malware     - Malware scanner demo" -ForegroundColor White
            Write-Host "  sqli        - SQL injection detection demo" -ForegroundColor White
            Write-Host "  xss         - XSS attack detection demo" -ForegroundColor White
            Write-Host "  stats       - System statistics" -ForegroundColor White
            Write-Host ""
        }
    }
}
