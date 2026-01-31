# SentinelAI X - Real-Time Attack Detection & Auto-Response
# Start monitoring for attacks and auto-neutralize + counter-attack

Write-Host "`n" -NoNewline
Write-Host "=" * 70 -ForegroundColor Cyan
Write-Host "  SentinelAI X - Real-Time Attack Detection & Response" -ForegroundColor Cyan
Write-Host "  Monitors: Network, USB, Processes, System Behavior" -ForegroundColor Gray
Write-Host "=" * 70 -ForegroundColor Cyan
Write-Host ""

$ML_SERVICE = "http://localhost:5000"

# Check if ML Service is running
Write-Host "Checking ML Service..." -ForegroundColor Yellow
try {
    $health = Invoke-RestMethod -Uri "$ML_SERVICE/health" -TimeoutSec 5
    Write-Host "  ML Service: ONLINE" -ForegroundColor Green
} catch {
    Write-Host "  ML Service: OFFLINE" -ForegroundColor Red
    Write-Host "  Please start the ML service first using START-ALL-SERVICES.ps1" -ForegroundColor Yellow
    exit 1
}

Write-Host ""

# Get current monitor status
Write-Host "Checking current monitor status..." -ForegroundColor Yellow
try {
    $status = Invoke-RestMethod -Uri "$ML_SERVICE/api/v1/monitor/status" -TimeoutSec 5
    
    if ($status.monitoring) {
        Write-Host "  Monitor is ALREADY RUNNING" -ForegroundColor Green
        Write-Host "  Uptime: $($status.uptime)" -ForegroundColor Gray
        Write-Host ""
        Write-Host "  Statistics:" -ForegroundColor Cyan
        Write-Host "    Attacks Detected: $($status.stats.attacks_detected)" -ForegroundColor Yellow
        Write-Host "    Attacks Neutralized: $($status.stats.attacks_neutralized)" -ForegroundColor Green
        Write-Host "    Counter-Offensives: $($status.stats.counter_offensives_executed)" -ForegroundColor Red
        Write-Host ""
        
        $choice = Read-Host "Monitor is already running. Stop it? (y/n)"
        if ($choice -eq 'y') {
            Write-Host "`nStopping monitor..." -ForegroundColor Yellow
            $stop = Invoke-RestMethod -Uri "$ML_SERVICE/api/v1/monitor/stop" -Method POST -TimeoutSec 5
            Write-Host "  Monitor STOPPED" -ForegroundColor Red
            Write-Host ""
            Write-Host "  Final Statistics:" -ForegroundColor Cyan
            Write-Host "    Attacks Detected: $($stop.stats.attacks_detected)" -ForegroundColor Yellow
            Write-Host "    Attacks Neutralized: $($stop.stats.attacks_neutralized)" -ForegroundColor Green
            Write-Host "    Counter-Offensives: $($stop.stats.counter_offensives_executed)" -ForegroundColor Red
        }
        exit 0
    } else {
        Write-Host "  Monitor is NOT running" -ForegroundColor Gray
    }
} catch {
    Write-Host "  Could not check status: $($_.Exception.Message)" -ForegroundColor Red
}

Write-Host ""

# Start real-time monitoring
Write-Host "=" * 70 -ForegroundColor Cyan
Write-Host "  STARTING REAL-TIME ATTACK MONITORING" -ForegroundColor Green
Write-Host "=" * 70 -ForegroundColor Cyan
Write-Host ""

Write-Host "The system will now:" -ForegroundColor Cyan
Write-Host "  1. Monitor network connections for suspicious activity" -ForegroundColor White
Write-Host "  2. Monitor USB device connections" -ForegroundColor White
Write-Host "  3. Monitor system behavior (CPU, memory, bandwidth)" -ForegroundColor White
Write-Host "  4. Monitor processes for suspicious executables" -ForegroundColor White
Write-Host "  5. AUTOMATICALLY NEUTRALIZE detected threats" -ForegroundColor Yellow
Write-Host "  6. AUTOMATICALLY COUNTER-ATTACK critical threats" -ForegroundColor Red
Write-Host ""

Write-Host "  All actions are SIMULATED for safety" -ForegroundColor Gray
Write-Host ""

$confirm = Read-Host "Start real-time monitoring? (y/n)"
if ($confirm -ne 'y') {
    Write-Host "Cancelled." -ForegroundColor Yellow
    exit 0
}

Write-Host ""
Write-Host "Starting monitor..." -ForegroundColor Yellow

try {
    $start = Invoke-RestMethod -Uri "$ML_SERVICE/api/v1/monitor/start" -Method POST -TimeoutSec 5
    
    if ($start.success) {
        Write-Host ""
        Write-Host "=" * 70 -ForegroundColor Green
        Write-Host "  REAL-TIME MONITORING ACTIVE" -ForegroundColor Green
        Write-Host "=" * 70 -ForegroundColor Green
        Write-Host ""
        Write-Host "  Started at: $($start.started_at)" -ForegroundColor Gray
        Write-Host ""
        Write-Host "  The system is now monitoring for:" -ForegroundColor Cyan
        Write-Host "    Connection spikes (>50 connections/min)" -ForegroundColor White
        Write-Host "    Suspicious ports (4444, 4445, 5555, 31337, etc.)" -ForegroundColor White
        Write-Host "    USB device attacks" -ForegroundColor White
        Write-Host "    CPU/Memory/Bandwidth spikes" -ForegroundColor White
        Write-Host "    Suspicious processes (metasploit, mimikatz, etc.)" -ForegroundColor White
        Write-Host ""
        Write-Host "  Actions:" -ForegroundColor Cyan
        Write-Host "    DETECT -> NEUTRALIZE -> COUNTER-ATTACK (if critical)" -ForegroundColor Yellow
        Write-Host ""
        Write-Host "  Check status: http://localhost:5000/api/v1/monitor/status" -ForegroundColor Gray
        Write-Host ""
        Write-Host "  Press Ctrl+C to view stats or run this script again to stop" -ForegroundColor Yellow
        Write-Host ""
        Write-Host "=" * 70 -ForegroundColor Green
        Write-Host ""
        
        # Keep showing stats every 10 seconds
        Write-Host "Monitoring statistics (updates every 10 seconds)..." -ForegroundColor Cyan
        Write-Host "Press Ctrl+C to exit" -ForegroundColor Gray
        Write-Host ""
        
        while ($true) {
            Start-Sleep -Seconds 10
            
            try {
                $status = Invoke-RestMethod -Uri "$ML_SERVICE/api/v1/monitor/status" -TimeoutSec 5
                
                $timestamp = Get-Date -Format "HH:mm:ss"
                Write-Host "[$timestamp] " -NoNewline -ForegroundColor Gray
                Write-Host "Detected: $($status.stats.attacks_detected) " -NoNewline -ForegroundColor Yellow
                Write-Host "| Neutralized: $($status.stats.attacks_neutralized) " -NoNewline -ForegroundColor Green
                Write-Host "| Counter-Attacked: $($status.stats.counter_offensives_executed)" -ForegroundColor Red
                
                if ($status.stats.last_detection) {
                    Write-Host "  Last detection: $($status.stats.last_detection)" -ForegroundColor Gray
                }
            } catch {
                Write-Host "  Could not get status" -ForegroundColor Red
                break
            }
        }
        
    } else {
        Write-Host "  Failed to start monitor: $($start.message)" -ForegroundColor Red
    }
} catch {
    Write-Host "  Error starting monitor: $($_.Exception.Message)" -ForegroundColor Red
    Write-Host "  Make sure the ML service is running" -ForegroundColor Yellow
}

Write-Host ""
