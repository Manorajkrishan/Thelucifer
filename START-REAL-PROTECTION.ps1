# Start SentinelAI X Real Protection System

Write-Host "`n" -NoNewline
Write-Host "=" * 70 -ForegroundColor Cyan
Write-Host "  SentinelAI X - Real Protection System" -ForegroundColor Cyan
Write-Host "  REAL attack detection and response" -ForegroundColor Yellow
Write-Host "=" * 70 -ForegroundColor Cyan
Write-Host ""

# Check if running as Administrator
$isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)

if (-not $isAdmin) {
    Write-Host "⚠️  WARNING: Not running as Administrator!" -ForegroundColor Red
    Write-Host ""
    Write-Host "For REAL protection (IP blocking, process killing), you MUST run as Admin:" -ForegroundColor Yellow
    Write-Host "  1. Right-click PowerShell" -ForegroundColor White
    Write-Host "  2. Select 'Run as Administrator'" -ForegroundColor White
    Write-Host "  3. Run: .\START-REAL-PROTECTION.ps1" -ForegroundColor White
    Write-Host ""
    $continue = Read-Host "Continue in LIMITED mode? (y/n)"
    if ($continue -ne 'y') {
        exit 0
    }
    Write-Host ""
}

Write-Host "Starting Real Protection System..." -ForegroundColor Yellow
Write-Host ""

Write-Host "🛡️  Features:" -ForegroundColor Cyan
Write-Host "   ✅ Real packet capture (deep inspection)" -ForegroundColor Green
Write-Host "   ✅ Real IP blocking (Windows Firewall)" -ForegroundColor Green
Write-Host "   ✅ Real process termination" -ForegroundColor Green
Write-Host "   ✅ Malware scanning (YARA rules)" -ForegroundColor Green
Write-Host "   ✅ SQL injection detection" -ForegroundColor Green
Write-Host "   ✅ XSS attack detection" -ForegroundColor Green
Write-Host "   ✅ Port scan detection" -ForegroundColor Green
Write-Host "   ✅ Intrusion Detection System (IDS)" -ForegroundColor Green
Write-Host ""

Write-Host "⚠️  This system will:" -ForegroundColor Yellow
Write-Host "   • Monitor ALL network traffic" -ForegroundColor White
Write-Host "   • Block malicious IPs automatically" -ForegroundColor White
Write-Host "   • Terminate suspicious processes" -ForegroundColor White
Write-Host "   • Scan files for malware" -ForegroundColor White
Write-Host ""

$confirm = Read-Host "Start protection? (y/n)"
if ($confirm -ne 'y') {
    Write-Host "Cancelled." -ForegroundColor Yellow
    exit 0
}

Write-Host ""
Write-Host "=" * 70 -ForegroundColor Green
Write-Host "  🛡️  PROTECTION ACTIVE" -ForegroundColor Green
Write-Host "=" * 70 -ForegroundColor Green
Write-Host ""

# Start the protection system
python sentinelai_protection.py
