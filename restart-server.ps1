# Restart Laravel Server Script
# This script stops all PHP processes and restarts the Laravel server

Write-Host "`n=== Restarting Laravel Server ===" -ForegroundColor Cyan

# Stop all PHP processes
Write-Host "`nStopping all PHP processes..." -ForegroundColor Yellow
Get-Process | Where-Object { $_.ProcessName -like "*php*" } | ForEach-Object {
    Write-Host "  Stopping process: $($_.Id) - $($_.Path)" -ForegroundColor Gray
    Stop-Process -Id $_.Id -Force -ErrorAction SilentlyContinue
}

Start-Sleep -Seconds 2

# Verify PHP extensions
Write-Host "`nVerifying PHP 8.1 SQLite extensions..." -ForegroundColor Yellow
$extensions = C:\php81\php.exe -m | Select-String "pdo_sqlite|sqlite3"
if ($extensions) {
    Write-Host "  ✓ SQLite extensions loaded" -ForegroundColor Green
    $extensions | ForEach-Object { Write-Host "    - $_" -ForegroundColor Gray }
} else {
    Write-Host "  ✗ SQLite extensions NOT found!" -ForegroundColor Red
    Write-Host "  Please check php.ini at C:\php81\php.ini" -ForegroundColor Yellow
    exit 1
}

# Navigate to API directory
Set-Location "E:\Cyberpunck\backend\api"

# Clear caches
Write-Host "`nClearing Laravel caches..." -ForegroundColor Yellow
C:\php81\php.exe artisan config:clear | Out-Null
C:\php81\php.exe artisan cache:clear | Out-Null
Write-Host "  ✓ Caches cleared" -ForegroundColor Green

# Start server
Write-Host "`nStarting Laravel server..." -ForegroundColor Yellow
Write-Host "  Server will run on: http://localhost:8000" -ForegroundColor Cyan
Write-Host "  Press Ctrl+C to stop the server`n" -ForegroundColor Gray

# Start the server (this will block)
C:\php81\php.exe artisan serve --port=8000
