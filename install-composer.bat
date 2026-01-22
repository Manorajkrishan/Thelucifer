@echo off
REM Batch script to download and run Composer installer
echo === Composer Installer for Windows ===
echo.

REM Check if PowerShell is available
where powershell >nul 2>&1
if %ERRORLEVEL% NEQ 0 (
    echo ERROR: PowerShell is not available!
    pause
    exit /b 1
)

REM Run the PowerShell script
powershell.exe -ExecutionPolicy Bypass -File "%~dp0install-composer.ps1"

pause
