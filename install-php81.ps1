# Download and Install PHP 8.1 for Windows
Write-Host "=== Installing PHP 8.1 for Laravel 10 ===" -ForegroundColor Cyan
Write-Host ""

$php81Url = "https://windows.php.net/downloads/releases/archives/php-8.1.27-Win32-vs16-x64.zip"
$downloadPath = "$env:TEMP\php81.zip"
$installPath = "C:\php81"

Write-Host "Downloading PHP 8.1..." -ForegroundColor Yellow
try {
    Invoke-WebRequest -Uri $php81Url -OutFile $downloadPath -UseBasicParsing
    Write-Host "Download complete!" -ForegroundColor Green
    
    Write-Host "Extracting PHP 8.1 to $installPath..." -ForegroundColor Yellow
    if (-not (Test-Path $installPath)) {
        New-Item -ItemType Directory -Path $installPath -Force | Out-Null
    }
    
    Expand-Archive -Path $downloadPath -DestinationPath $installPath -Force
    Write-Host "Extraction complete!" -ForegroundColor Green
    
    Write-Host ""
    Write-Host "PHP 8.1 installed at: $installPath" -ForegroundColor Green
    Write-Host ""
    Write-Host "To use PHP 8.1, run:" -ForegroundColor Yellow
    Write-Host "  `$env:Path = 'C:\php81;' + `$env:Path" -ForegroundColor White
    Write-Host "  php -v" -ForegroundColor White
    
    Remove-Item $downloadPath -ErrorAction SilentlyContinue
} catch {
    Write-Host "Error: $_" -ForegroundColor Red
    Write-Host ""
    Write-Host "Alternative: Download PHP 8.1 manually from:" -ForegroundColor Yellow
    Write-Host "https://windows.php.net/download/" -ForegroundColor White
}
