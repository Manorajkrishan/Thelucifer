# Install SentinelAI X Real Protection System

Write-Host "`n" -NoNewline
Write-Host "=" * 70 -ForegroundColor Cyan
Write-Host "  SentinelAI X - Real Protection System Installation" -ForegroundColor Cyan
Write-Host "=" * 70 -ForegroundColor Cyan
Write-Host ""

# Check if running as Administrator
$isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)

if (-not $isAdmin) {
    Write-Host "⚠️  WARNING: Not running as Administrator!" -ForegroundColor Yellow
    Write-Host "   For full protection (IP blocking, process termination), please:" -ForegroundColor Yellow
    Write-Host "   1. Right-click PowerShell" -ForegroundColor White
    Write-Host "   2. Select 'Run as Administrator'" -ForegroundColor White
    Write-Host "   3. Run this script again" -ForegroundColor White
    Write-Host ""
    $continue = Read-Host "Continue anyway? (y/n)"
    if ($continue -ne 'y') {
        exit 0
    }
    Write-Host ""
}

Write-Host "Installing dependencies..." -ForegroundColor Yellow
Write-Host ""

# Install Python packages
Write-Host "1. Installing Scapy (packet capture)..." -ForegroundColor Cyan
pip install scapy --quiet
if ($?) { Write-Host "   ✅ Scapy installed" -ForegroundColor Green } else { Write-Host "   ❌ Failed" -ForegroundColor Red }

Write-Host "2. Installing psutil (system monitoring)..." -ForegroundColor Cyan
pip install psutil --quiet
if ($?) { Write-Host "   ✅ psutil installed" -ForegroundColor Green } else { Write-Host "   ❌ Failed" -ForegroundColor Red }

Write-Host "3. Installing YARA (malware scanning)..." -ForegroundColor Cyan
pip install yara-python --quiet
if ($?) { Write-Host "   ✅ YARA installed" -ForegroundColor Green } else { Write-Host "   ❌ Failed" -ForegroundColor Red }

Write-Host "4. Installing watchdog (file monitoring)..." -ForegroundColor Cyan
pip install watchdog --quiet
if ($?) { Write-Host "   ✅ watchdog installed" -ForegroundColor Green } else { Write-Host "   ❌ Failed" -ForegroundColor Red }

Write-Host "5. Installing requests..." -ForegroundColor Cyan
pip install requests --quiet
if ($?) { Write-Host "   ✅ requests installed" -ForegroundColor Green } else { Write-Host "   ❌ Failed" -ForegroundColor Red }

Write-Host ""
Write-Host "=" * 70 -ForegroundColor Green
Write-Host "  Installation Complete!" -ForegroundColor Green
Write-Host "=" * 70 -ForegroundColor Green
Write-Host ""

Write-Host "🛡️  Real Protection Features:" -ForegroundColor Cyan
Write-Host "   ✅ Packet Capture & Deep Inspection (Scapy)" -ForegroundColor White
Write-Host "   ✅ Real IP Blocking (Windows Firewall)" -ForegroundColor White
Write-Host "   ✅ Real Process Termination" -ForegroundColor White
Write-Host "   ✅ Malware Scanner (YARA rules)" -ForegroundColor White
Write-Host "   ✅ Intrusion Detection System (IDS)" -ForegroundColor White
Write-Host "   ✅ SQL Injection Detection" -ForegroundColor White
Write-Host "   ✅ XSS Attack Detection" -ForegroundColor White
Write-Host "   ✅ Port Scan Detection" -ForegroundColor White
Write-Host ""

Write-Host "To start protection:" -ForegroundColor Yellow
Write-Host "   python sentinelai_protection.py" -ForegroundColor White
Write-Host ""
Write-Host "Or use the PowerShell script:" -ForegroundColor Yellow
Write-Host "   .\START-REAL-PROTECTION.ps1" -ForegroundColor White
Write-Host ""

Write-Host "=" * 70 -ForegroundColor Cyan
Write-Host ""
