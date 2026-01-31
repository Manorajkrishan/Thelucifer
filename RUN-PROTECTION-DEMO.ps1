# SentinelAI X - Run Protection System Demo
# Two ways to show the last implemented part is working (no main frontend needed)

Set-Location $PSScriptRoot   # run from project root

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  SentinelAI X - Protection System Demo" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

Write-Host "Choose how to run the demo:" -ForegroundColor Yellow
Write-Host "  1. CLI Demo (terminal only) - run tests and show PASS/FAIL" -ForegroundColor White
Write-Host "  2. Web Dashboard - open browser, click 'Run Demo'" -ForegroundColor White
Write-Host "  3. Both - run CLI once, then start dashboard" -ForegroundColor White
Write-Host ""

$choice = Read-Host "Enter 1, 2, or 3"

if ($choice -eq "1") {
    Write-Host ""
    Write-Host "Running CLI demo..." -ForegroundColor Green
    python demo_protection.py
    exit 0
}

if ($choice -eq "2") {
    Write-Host ""
    Write-Host "Starting demo dashboard at http://localhost:5050" -ForegroundColor Green
    Write-Host "Open that URL in your browser and click 'Run Demo'." -ForegroundColor White
    Write-Host ""
    Set-Location $PSScriptRoot
    Set-Location protection-dashboard
    python app.py
    exit 0
}

if ($choice -eq "3") {
    Write-Host ""
    Write-Host "Running CLI demo first..." -ForegroundColor Green
    python demo_protection.py
    Write-Host ""
    Write-Host "Starting demo dashboard at http://localhost:5050" -ForegroundColor Green
    Set-Location $PSScriptRoot
    Set-Location protection-dashboard
    python app.py
    exit 0
}

Write-Host "Invalid choice." -ForegroundColor Red
exit 1
