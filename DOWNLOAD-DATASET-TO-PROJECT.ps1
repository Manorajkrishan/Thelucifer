# Download a dataset from URL and store in project (backend/ml-service/datasets/custom/<id>).
# Optionally calls ML service POST /api/v1/datasets to download via API (if ML is running).
# Usage:
#   .\DOWNLOAD-DATASET-TO-PROJECT.ps1 -Url "https://example.com/data.csv"
#   .\DOWNLOAD-DATASET-TO-PROJECT.ps1 -Url "https://example.com/data.zip" -DatasetId "my_dataset"
#   .\DOWNLOAD-DATASET-TO-PROJECT.ps1 -Url "https://..." -UseApi   # use ML service if available

param(
    [Parameter(Mandatory = $true)]
    [string]$Url,
    [string]$DatasetId = "",
    [switch]$UseApi
)

$ErrorActionPreference = "Stop"
$base = $PSScriptRoot
$ml = Join-Path $base "backend\ml-service"
$datasetsDir = Join-Path $ml "datasets\custom"

if (-not (Test-Path $ml)) {
    Write-Host "Project backend/ml-service not found." -ForegroundColor Red
    exit 1
}

function Download-ViaApi {
    $mlUrl = $env:ML_SERVICE_URL
    if (-not $mlUrl) { $mlUrl = "http://localhost:5000" }
    $body = @{ action = "download-url"; url = $Url } | ConvertTo-Json
    if ($DatasetId) { $body = @{ action = "download-url"; url = $Url; dataset_id = $DatasetId } | ConvertTo-Json }
    try {
        $r = Invoke-RestMethod -Uri "$mlUrl/api/v1/datasets" -Method Post -Body $body -ContentType "application/json" -TimeoutSec 300
        if ($r.success -and $r.result) {
            Write-Host "Downloaded via ML service: $($r.result.path)" -ForegroundColor Green
            return $true
        }
    } catch {
        Write-Host "ML service download failed: $_" -ForegroundColor Yellow
    }
    return $false
}

function Download-Direct {
    $id = $DatasetId
    if (-not $id) {
        $f = [System.IO.Path]::GetFileName((Split-Path $Url -Leaf))
        $id = $f -replace '[^\w\-.]', '_'
        if (-not $id) { $id = "dataset" }
    }
    $dest = Join-Path $datasetsDir $id
    New-Item -ItemType Directory -Force -Path $dest | Out-Null
    $fileName = [System.IO.Path]::GetFileName(([uri]$Url).LocalPath)
    if (-not $fileName) { $fileName = "downloaded" }
    $outPath = Join-Path $dest $fileName
    Write-Host "Downloading to $outPath ..." -ForegroundColor Cyan
    Invoke-WebRequest -Uri $Url -OutFile $outPath -UseBasicParsing
    Write-Host "Saved: $outPath" -ForegroundColor Green
    $meta = @{
        name = $id
        description = "Downloaded from $Url"
        format = "auto"
        source_url = $Url
    } | ConvertTo-Json
    Set-Content -Path (Join-Path $dest "metadata.json") -Value $meta
}

if ($UseApi) {
    if (Download-ViaApi) { exit 0 }
    Write-Host "Falling back to direct download." -ForegroundColor Yellow
}
else {
    $mlUrl = $env:ML_SERVICE_URL; if (-not $mlUrl) { $mlUrl = "http://localhost:5000" }
    try {
        $null = Invoke-RestMethod -Uri "$mlUrl/health" -Method Get -TimeoutSec 2
        if (Download-ViaApi) { exit 0 }
    } catch { }
    Write-Host "ML service not reachable; using direct download." -ForegroundColor Yellow
}

Download-Direct
