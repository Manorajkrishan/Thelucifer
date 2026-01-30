# Quick MySQL Fix - Try Common Solutions

Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "  Quick MySQL Fix" -ForegroundColor Cyan
Write-Host "========================================`n" -ForegroundColor Cyan

# Check if XAMPP MySQL data exists
$xamppData = "C:\xampp\mysql\data"
if (Test-Path $xamppData) {
    Write-Host "✅ MySQL data directory found" -ForegroundColor Green
} else {
    Write-Host "❌ MySQL data directory not found" -ForegroundColor Red
    Write-Host "   This might be the issue!" -ForegroundColor Yellow
}

# Check for common error log locations
Write-Host "`nChecking for MySQL error logs..." -ForegroundColor Yellow
$logLocations = @(
    "C:\xampp\mysql\data\*.err",
    "C:\xampp\mysql\bin\*.err",
    "C:\xampp\apache\logs\error.log"
)

$foundLog = $false
foreach ($pattern in $logLocations) {
    $logs = Get-ChildItem $pattern -ErrorAction SilentlyContinue
    if ($logs) {
        $latest = $logs | Sort-Object LastWriteTime -Descending | Select-Object -First 1
        Write-Host "   Found: $($latest.FullName)" -ForegroundColor Cyan
        Write-Host "   Last 5 lines:" -ForegroundColor Yellow
        Get-Content $latest.FullName -Tail 5 | ForEach-Object {
            Write-Host "     $_" -ForegroundColor Gray
        }
        $foundLog = $true
        break
    }
}

if (-not $foundLog) {
    Write-Host "   ⚠️  No error logs found" -ForegroundColor Yellow
}

# Solutions
Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "  RECOMMENDED FIXES" -ForegroundColor Cyan
Write-Host "========================================`n" -ForegroundColor Cyan

Write-Host "🔧 Fix 1: Restart XAMPP MySQL" -ForegroundColor Yellow
Write-Host "  1. Open XAMPP Control Panel" -ForegroundColor White
Write-Host "  2. Stop MySQL (if running)" -ForegroundColor White
Write-Host "  3. Wait 5 seconds" -ForegroundColor White
Write-Host "  4. Start MySQL again" -ForegroundColor White

Write-Host "`n🔧 Fix 2: Repair Data Directory" -ForegroundColor Yellow
Write-Host "  If Fix 1 doesn't work:" -ForegroundColor White
Write-Host "  1. Stop XAMPP completely" -ForegroundColor White
Write-Host "  2. Backup: Copy C:\xampp\mysql\data to backup location" -ForegroundColor White
Write-Host "  3. Delete: C:\xampp\mysql\data folder" -ForegroundColor White
Write-Host "  4. Start XAMPP MySQL (will recreate data)" -ForegroundColor White
Write-Host "  5. Restore your databases from backup" -ForegroundColor White

Write-Host "`n🔧 Fix 3: Use SQLite (Immediate Solution)" -ForegroundColor Yellow
Write-Host "  If MySQL keeps failing, switch to SQLite:" -ForegroundColor White
Write-Host "  .\SWITCH-TO-SQLITE.ps1" -ForegroundColor Cyan
Write-Host "  This will work immediately!" -ForegroundColor Green

Write-Host "`n========================================`n" -ForegroundColor Cyan

# Check current database config
Write-Host "Current Database Configuration:" -ForegroundColor Cyan
if (Test-Path "backend\api\.env") {
    $envContent = Get-Content "backend\api\.env" | Select-String -Pattern "DB_CONNECTION"
    Write-Host "  $envContent" -ForegroundColor White
} else {
    Write-Host "  ⚠️  .env file not found" -ForegroundColor Yellow
}

Write-Host "`n💡 Recommendation:" -ForegroundColor Cyan
Write-Host "  If you need the system working NOW, use SQLite:" -ForegroundColor White
Write-Host "  .\SWITCH-TO-SQLITE.ps1" -ForegroundColor Yellow
Write-Host "  You can switch back to MySQL later when it's fixed." -ForegroundColor Gray
