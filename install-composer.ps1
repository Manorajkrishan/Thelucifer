# PowerShell script to download and install Composer for Windows
# Run this script as Administrator for best results

Write-Host "=== Composer Installer for Windows ===" -ForegroundColor Cyan
Write-Host ""

# Check if PHP is installed
Write-Host "Checking for PHP installation..." -ForegroundColor Yellow
$phpInstalled = $false
try {
    $phpVersion = php -v 2>$null
    if ($phpVersion) {
        Write-Host "✓ PHP is installed" -ForegroundColor Green
        $phpInstalled = $true
    }
} catch {
    Write-Host "✗ PHP is not found in PATH" -ForegroundColor Red
}

if (-not $phpInstalled) {
    Write-Host ""
    Write-Host "WARNING: PHP is required for Composer!" -ForegroundColor Red
    Write-Host "Please install PHP first from: https://www.php.net/downloads.php" -ForegroundColor Yellow
    Write-Host "Or install XAMPP which includes PHP: https://www.apachefriends.org/" -ForegroundColor Yellow
    Write-Host ""
    $continue = Read-Host "Do you want to continue downloading Composer anyway? (y/n)"
    if ($continue -ne 'y' -and $continue -ne 'Y') {
        exit
    }
}

# Download Composer-Setup.exe
$composerSetupUrl = "https://getcomposer.org/Composer-Setup.exe"
$downloadPath = "$env:TEMP\Composer-Setup.exe"

Write-Host ""
Write-Host "Downloading Composer-Setup.exe..." -ForegroundColor Yellow
Write-Host "From: $composerSetupUrl" -ForegroundColor Gray
Write-Host "To: $downloadPath" -ForegroundColor Gray

try {
    # Use Invoke-WebRequest to download
    Invoke-WebRequest -Uri $composerSetupUrl -OutFile $downloadPath -UseBasicParsing
    Write-Host "✓ Download complete!" -ForegroundColor Green
    Write-Host ""
    
    # Check if file was downloaded
    if (Test-Path $downloadPath) {
        $fileSize = (Get-Item $downloadPath).Length / 1MB
        Write-Host "File size: $([math]::Round($fileSize, 2)) MB" -ForegroundColor Gray
        Write-Host ""
        
        Write-Host "=== Next Steps ===" -ForegroundColor Cyan
        Write-Host "1. The installer has been downloaded to: $downloadPath" -ForegroundColor White
        Write-Host "2. Run the installer by executing:" -ForegroundColor White
        Write-Host "   Start-Process '$downloadPath'" -ForegroundColor Yellow
        Write-Host ""
        Write-Host "   Or double-click the file in Windows Explorer" -ForegroundColor Gray
        Write-Host ""
        Write-Host "3. After installation, restart your terminal and run: composer --version" -ForegroundColor White
        Write-Host ""
        
        # Ask if user wants to run installer now
        $runNow = Read-Host "Do you want to run the installer now? (y/n)"
        if ($runNow -eq 'y' -or $runNow -eq 'Y') {
            Write-Host ""
            Write-Host "Launching installer..." -ForegroundColor Yellow
            Start-Process $downloadPath -Wait
            Write-Host ""
            Write-Host "✓ Installation process completed!" -ForegroundColor Green
            Write-Host ""
            Write-Host "IMPORTANT: Please restart your terminal/PowerShell window" -ForegroundColor Yellow
            Write-Host "Then run: composer --version" -ForegroundColor White
        } else {
            Write-Host ""
            Write-Host "You can run the installer later from: $downloadPath" -ForegroundColor Gray
        }
    }
} catch {
    Write-Host ""
    Write-Host "✗ Error downloading Composer installer" -ForegroundColor Red
    Write-Host "Error: $_" -ForegroundColor Red
    Write-Host ""
    Write-Host "You can manually download from: https://getcomposer.org/Composer-Setup.exe" -ForegroundColor Yellow
}

Write-Host ""
Write-Host "Script completed!" -ForegroundColor Cyan
