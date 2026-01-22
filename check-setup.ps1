# SentinelAI X - Setup Verification Script
Write-Host "=== SentinelAI X - Project Setup Verification ===" -ForegroundColor Cyan
Write-Host ""

$errors = @()
$warnings = @()

# Check PHP
Write-Host "[1] Checking PHP..." -ForegroundColor Yellow
if (Test-Path "C:\xampp\php\php.exe") {
    $phpVersion = & "C:\xampp\php\php.exe" -v 2>&1 | Select-Object -First 1
    Write-Host "  OK - PHP found: $phpVersion" -ForegroundColor Green
} else {
    Write-Host "  WARNING - PHP not found. Add C:\xampp\php to PATH" -ForegroundColor Yellow
    $warnings += "PHP not in PATH"
}

# Check Composer
Write-Host "[2] Checking Composer..." -ForegroundColor Yellow
$composerFound = $false
if (Get-Command composer -ErrorAction SilentlyContinue) {
    $composerVersion = composer --version 2>&1 | Select-Object -First 1
    Write-Host "  OK - Composer found: $composerVersion" -ForegroundColor Green
    $composerFound = $true
} else {
    Write-Host "  WARNING - Composer not in PATH. Restart terminal after installation" -ForegroundColor Yellow
    $warnings += "Composer not in PATH"
}

# Check Python
Write-Host "[3] Checking Python..." -ForegroundColor Yellow
try {
    $pythonVersion = python --version 2>&1
    Write-Host "  OK - Python found: $pythonVersion" -ForegroundColor Green
} catch {
    Write-Host "  ERROR - Python not found" -ForegroundColor Red
    $errors += "Python not installed"
}

# Check Node.js
Write-Host "[4] Checking Node.js..." -ForegroundColor Yellow
try {
    $nodeVersion = node --version 2>&1
    Write-Host "  OK - Node.js found: $nodeVersion" -ForegroundColor Green
} catch {
    Write-Host "  ERROR - Node.js not found" -ForegroundColor Red
    $errors += "Node.js not installed"
}

# Check Docker
Write-Host "[5] Checking Docker..." -ForegroundColor Yellow
if (Get-Command docker -ErrorAction SilentlyContinue) {
    $dockerVersion = docker --version 2>&1 | Select-Object -First 1
    Write-Host "  OK - Docker found: $dockerVersion" -ForegroundColor Green
} else {
    Write-Host "  INFO - Docker not installed (optional - for containerized deployment)" -ForegroundColor Gray
}

# Check Project Structure
Write-Host "[6] Checking Project Structure..." -ForegroundColor Yellow
$requiredDirs = @(
    "backend\api",
    "backend\ml-service",
    "backend\realtime-service",
    "frontend\admin-dashboard",
    "frontend\portal"
)
$allDirsExist = $true
foreach ($dir in $requiredDirs) {
    if (Test-Path $dir) {
        Write-Host "  OK - $dir exists" -ForegroundColor Green
    } else {
        Write-Host "  ERROR - $dir not found" -ForegroundColor Red
        $allDirsExist = $false
        $errors += "$dir missing"
    }
}

# Check Key Files
Write-Host "[7] Checking Key Files..." -ForegroundColor Yellow
$requiredFiles = @(
    "docker-compose.yml",
    "README.md",
    "backend\api\composer.json",
    "backend\ml-service\requirements.txt",
    "backend\realtime-service\package.json",
    "frontend\admin-dashboard\package.json",
    "frontend\portal\package.json"
)
$allFilesExist = $true
foreach ($file in $requiredFiles) {
    if (Test-Path $file) {
        Write-Host "  OK - $file exists" -ForegroundColor Green
    } else {
        Write-Host "  ERROR - $file not found" -ForegroundColor Red
        $allFilesExist = $false
        $errors += "$file missing"
    }
}

# Summary
Write-Host ""
Write-Host "=== Summary ===" -ForegroundColor Cyan
if ($errors.Count -eq 0) {
    Write-Host "Status: READY" -ForegroundColor Green
    if ($warnings.Count -gt 0) {
        Write-Host "Warnings: $($warnings.Count)" -ForegroundColor Yellow
        foreach ($warning in $warnings) {
            Write-Host "  - $warning" -ForegroundColor Yellow
        }
    }
} else {
    Write-Host "Status: ISSUES FOUND" -ForegroundColor Red
    Write-Host "Errors: $($errors.Count)" -ForegroundColor Red
    foreach ($error in $errors) {
        Write-Host "  - $error" -ForegroundColor Red
    }
}

Write-Host ""
Write-Host "=== Next Steps ===" -ForegroundColor Cyan
if (-not $composerFound) {
    Write-Host "1. Restart terminal after Composer installation completes" -ForegroundColor Yellow
    Write-Host "2. Or add PHP and Composer to PATH manually" -ForegroundColor Yellow
}
Write-Host "3. Install dependencies:" -ForegroundColor White
Write-Host "   - Laravel API: cd backend\api && composer install" -ForegroundColor Gray
Write-Host "   - ML Service: cd backend\ml-service && pip install -r requirements.txt" -ForegroundColor Gray
Write-Host "   - Real-time: cd backend\realtime-service && npm install" -ForegroundColor Gray
Write-Host "   - Admin Dashboard: cd frontend\admin-dashboard && npm install" -ForegroundColor Gray
Write-Host "   - Portal: cd frontend\portal && npm install" -ForegroundColor Gray

Write-Host ""
