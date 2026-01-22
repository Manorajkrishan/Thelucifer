# Start Laravel Server with SQLite Support
# Run this script to start the server with the correct PHP

Write-Host "`n=== Starting Laravel Server ===" -ForegroundColor Cyan

# Navigate to API directory
Set-Location "E:\Cyberpunck\backend\api"

# Verify PHP version and extensions
Write-Host "`nVerifying PHP configuration..." -ForegroundColor Yellow
$phpVersion = C:\php81\php.exe -v | Select-String "PHP (\d+\.\d+\.\d+)" | ForEach-Object { $_.Matches[0].Groups[1].Value }
Write-Host "  PHP Version: $phpVersion" -ForegroundColor Cyan

$extensions = C:\php81\php.exe -m | Select-String "pdo_sqlite|sqlite3"
if ($extensions) {
    Write-Host "  ✓ SQLite extensions loaded" -ForegroundColor Green
} else {
    Write-Host "  ✗ SQLite extensions NOT found!" -ForegroundColor Red
    Write-Host "  Please check C:\php81\php.ini" -ForegroundColor Yellow
    exit 1
}

# Clear caches
Write-Host "`nClearing Laravel caches..." -ForegroundColor Yellow
C:\php81\php.exe artisan config:clear | Out-Null
C:\php81\php.exe artisan cache:clear | Out-Null
Write-Host "  ✓ Caches cleared" -ForegroundColor Green

# Test database connection
Write-Host "`nTesting database connection..." -ForegroundColor Yellow
$dbTest = C:\php81\php.exe artisan tinker --execute="try { DB::connection()->getPdo(); echo 'SUCCESS'; } catch (Exception `$e) { echo 'FAILED'; }" 2>&1 | Select-String "SUCCESS|FAILED"
if ($dbTest -match "SUCCESS") {
    Write-Host "  ✓ Database connection works" -ForegroundColor Green
} else {
    Write-Host "  ✗ Database connection failed" -ForegroundColor Red
    exit 1
}

# Start server
Write-Host "`n=== Starting Server ===" -ForegroundColor Cyan
Write-Host "  URL: http://localhost:8000" -ForegroundColor White
Write-Host "  API: http://localhost:8000/api" -ForegroundColor White
Write-Host "  Login: http://localhost:8000/api/login" -ForegroundColor White
Write-Host "`n  Press Ctrl+C to stop the server`n" -ForegroundColor Gray

# Start the server
C:\php81\php.exe artisan serve --port=8000
