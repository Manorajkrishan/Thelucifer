# Fix MySQL Shutdown Issue

Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "  Fix MySQL Shutdown Issue" -ForegroundColor Cyan
Write-Host "========================================`n" -ForegroundColor Cyan

# 1. Check port 3306
Write-Host "1. Checking Port 3306..." -ForegroundColor Yellow
$port = Get-NetTCPConnection -LocalPort 3306 -ErrorAction SilentlyContinue
if ($port) {
    Write-Host "   ❌ Port 3306 is in use by PID: $($port.OwningProcess)" -ForegroundColor Red
    $process = Get-Process -Id $port.OwningProcess -ErrorAction SilentlyContinue
    if ($process) {
        Write-Host "   Process: $($process.ProcessName)" -ForegroundColor Yellow
        Write-Host "   Location: $($process.Path)" -ForegroundColor Gray
        
        $kill = Read-Host "   Kill this process? (y/n)"
        if ($kill -eq 'y') {
            try {
                Stop-Process -Id $port.OwningProcess -Force
                Write-Host "   ✅ Process killed" -ForegroundColor Green
                Start-Sleep -Seconds 2
            } catch {
                Write-Host "   ❌ Failed to kill process: $_" -ForegroundColor Red
            }
        }
    }
} else {
    Write-Host "   ✅ Port 3306 is free" -ForegroundColor Green
}

# 2. Check for MySQL processes
Write-Host "`n2. Checking MySQL Processes..." -ForegroundColor Yellow
$mysqlProcs = Get-Process -Name "mysqld","mysql" -ErrorAction SilentlyContinue
if ($mysqlProcs) {
    Write-Host "   Found MySQL processes:" -ForegroundColor Yellow
    $mysqlProcs | ForEach-Object {
        Write-Host "     - $($_.ProcessName) (PID: $($_.Id))" -ForegroundColor Gray
    }
    
    $kill = Read-Host "   Kill all MySQL processes? (y/n)"
    if ($kill -eq 'y') {
        $mysqlProcs | ForEach-Object {
            try {
                Stop-Process -Id $_.Id -Force
                Write-Host "   ✅ Killed: $($_.ProcessName) (PID: $($_.Id))" -ForegroundColor Green
            } catch {
                Write-Host "   ⚠️  Failed to kill: $($_.ProcessName)" -ForegroundColor Yellow
            }
        }
        Start-Sleep -Seconds 2
    }
} else {
    Write-Host "   ✅ No MySQL processes found" -ForegroundColor Green
}

# 3. Check XAMPP MySQL location
Write-Host "`n3. Checking XAMPP MySQL..." -ForegroundColor Yellow
$xamppPaths = @(
    "C:\xampp\mysql\bin\mysqld.exe",
    "C:\Program Files\xampp\mysql\bin\mysqld.exe",
    "C:\xampp\mysql\data"
)

$found = $false
foreach ($path in $xamppPaths) {
    if (Test-Path $path) {
        Write-Host "   ✅ Found: $path" -ForegroundColor Green
        $found = $true
    }
}

if (-not $found) {
    Write-Host "   ⚠️  XAMPP MySQL not found in standard locations" -ForegroundColor Yellow
}

# 4. Check MySQL error log
Write-Host "`n4. Checking MySQL Error Log..." -ForegroundColor Yellow
$logPaths = @(
    "C:\xampp\mysql\data\*.err",
    "C:\Program Files\xampp\mysql\data\*.err"
)

$logFound = $false
foreach ($pattern in $logPaths) {
    $logs = Get-ChildItem $pattern -ErrorAction SilentlyContinue
    if ($logs) {
        $latestLog = $logs | Sort-Object LastWriteTime -Descending | Select-Object -First 1
        Write-Host "   Found log: $($latestLog.FullName)" -ForegroundColor Cyan
        Write-Host "   Last 10 lines:" -ForegroundColor Yellow
        Get-Content $latestLog.FullName -Tail 10 | ForEach-Object {
            Write-Host "     $_" -ForegroundColor Gray
        }
        $logFound = $true
        break
    }
}

if (-not $logFound) {
    Write-Host "   ⚠️  MySQL error log not found" -ForegroundColor Yellow
}

# 5. Solutions
Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "  SOLUTIONS" -ForegroundColor Cyan
Write-Host "========================================`n" -ForegroundColor Cyan

Write-Host "Option 1: Fix MySQL in XAMPP" -ForegroundColor Yellow
Write-Host "  1. Open XAMPP Control Panel" -ForegroundColor White
Write-Host "  2. Click 'Logs' button next to MySQL" -ForegroundColor White
Write-Host "  3. Check the error log for details" -ForegroundColor White
Write-Host "  4. Common fixes:" -ForegroundColor White
Write-Host "     - Stop all MySQL processes" -ForegroundColor Gray
Write-Host "     - Restart XAMPP" -ForegroundColor Gray
Write-Host "     - Check if port 3306 is free" -ForegroundColor Gray
Write-Host "     - Repair MySQL data directory" -ForegroundColor Gray

Write-Host "`nOption 2: Use SQLite (Temporary)" -ForegroundColor Yellow
Write-Host "  If MySQL keeps failing, switch to SQLite:" -ForegroundColor White
Write-Host "  .\SWITCH-TO-SQLITE.ps1" -ForegroundColor Cyan

Write-Host "`nOption 3: Reinstall MySQL in XAMPP" -ForegroundColor Yellow
Write-Host "  1. Backup your database" -ForegroundColor White
Write-Host "  2. Stop XAMPP" -ForegroundColor White
Write-Host "  3. Delete C:\xampp\mysql\data folder" -ForegroundColor White
Write-Host "  4. Restart XAMPP MySQL" -ForegroundColor White

Write-Host "`n========================================`n" -ForegroundColor Cyan
