# Start ML Service for SentinelAI X
# This script starts the ML service on port 5000

Write-Host "Starting SentinelAI X ML Service..." -ForegroundColor Green
Write-Host ""

# Check if Python is available
$pythonCmd = Get-Command python -ErrorAction SilentlyContinue
if (-not $pythonCmd) {
    Write-Host "ERROR: Python not found in PATH!" -ForegroundColor Red
    Write-Host "Please install Python or add it to your PATH" -ForegroundColor Yellow
    exit 1
}

# Navigate to ML service directory
$mlServicePath = Join-Path $PSScriptRoot "backend\ml-service"
if (-not (Test-Path $mlServicePath)) {
    Write-Host "ERROR: ML service directory not found: $mlServicePath" -ForegroundColor Red
    exit 1
}

Set-Location $mlServicePath

Write-Host "ML Service Directory: $mlServicePath" -ForegroundColor Cyan
Write-Host ""

# Check if requirements are installed
Write-Host "Checking dependencies..." -ForegroundColor Yellow
$flaskInstalled = python -c "import flask" 2>&1
if ($LASTEXITCODE -ne 0) {
    Write-Host "Installing dependencies..." -ForegroundColor Yellow
    pip install -r requirements.txt
    if ($LASTEXITCODE -ne 0) {
        Write-Host "ERROR: Failed to install dependencies!" -ForegroundColor Red
        exit 1
    }
}

Write-Host ""
Write-Host "Starting ML Service on http://localhost:5000" -ForegroundColor Green
Write-Host "Press Ctrl+C to stop the service" -ForegroundColor Yellow
Write-Host ""

# Start the Flask app
python app.py
