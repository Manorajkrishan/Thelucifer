# PHP Installation Helper Script for Windows
# This script will help you download and set up PHP

Write-Host "=== PHP Installation Helper for Windows ===" -ForegroundColor Cyan
Write-Host ""

Write-Host "PHP is required for Composer. Here are your options:" -ForegroundColor Yellow
Write-Host ""

Write-Host "=== Option 1: Download PHP ZIP (Recommended) ===" -ForegroundColor Green
Write-Host "1. Go to: https://windows.php.net/download/" -ForegroundColor White
Write-Host "2. Download 'VS16 x64 Non Thread Safe' ZIP (latest version)" -ForegroundColor White
Write-Host "3. Extract to C:\php" -ForegroundColor White
Write-Host "4. Add C:\php to your system PATH" -ForegroundColor White
Write-Host ""

Write-Host "=== Option 2: Use XAMPP (Easier - includes PHP, MySQL, Apache) ===" -ForegroundColor Green
Write-Host "1. Go to: https://www.apachefriends.org/" -ForegroundColor White
Write-Host "2. Download and install XAMPP" -ForegroundColor White
Write-Host "3. PHP will be at: C:\xampp\php" -ForegroundColor White
Write-Host "4. Add C:\xampp\php to your system PATH" -ForegroundColor White
Write-Host ""

Write-Host "=== Quick Setup After Installing PHP ===" -ForegroundColor Cyan
Write-Host "After extracting PHP, open PowerShell as Administrator and run:" -ForegroundColor Yellow
Write-Host '[Environment]::SetEnvironmentVariable("Path", $env:Path + ";C:\php", "Machine")' -ForegroundColor White
Write-Host ""
Write-Host "Or manually add C:\php to PATH in System Environment Variables" -ForegroundColor Gray
Write-Host ""

# Ask if user wants to open browser to download page
$openBrowser = Read-Host "Do you want to open the PHP download page in your browser? (y/n)"
if ($openBrowser -eq 'y' -or $openBrowser -eq 'Y') {
    Start-Process "https://windows.php.net/download/"
    Write-Host ""
    Write-Host "Browser opened! Download the VS16 x64 Non Thread Safe ZIP file." -ForegroundColor Green
}

Write-Host ""
Write-Host "After installing PHP, restart your terminal and run: php -v" -ForegroundColor Yellow
