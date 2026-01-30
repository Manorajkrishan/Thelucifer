# Batch Process All Files from Google Drive Folder
# This script helps you process all 22 EagleCyberSolutions modules

Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "  Batch Process Drive Folder Files" -ForegroundColor Cyan
Write-Host "========================================`n" -ForegroundColor Cyan

$FOLDER_LINK = "https://drive.google.com/drive/folders/1srkpnf0gwo6A0bIoMpXKZzADvZw3p67l"
$ML_SERVICE_URL = "http://localhost:5000"
$API_URL = "http://localhost:8000"

Write-Host "📋 Files to Process (22 modules):" -ForegroundColor Cyan
$files = @(
    "EagleCyberSolutions_Module_1 Introduction",
    "EagleCyberSolutions_Module_2 Basics and Environment setup",
    "EagleCyberSolutions_Module_3 Linux Refresher",
    "EagleCyberSolutions_Module_4 Networking Refresher",
    "EagleCyberSolutions_Module_5 Footprinting and Reconnaissance",
    "EagleCyberSolutions_Module_6 Scanning",
    "EagleCyberSolutions_Module_7 Enumeration",
    "EagleCyberSolutions_Module_8 System Hacking part2",
    "EagleCyberSolutions_Module_9 Malwares",
    "EagleCyberSolutions_Module_10 Sniffing and Spoofing",
    "EagleCyberSolutions_Module_11 Social Engineering",
    "EagleCyberSolutions_Module_12 Denial of Service",
    "EagleCyberSolutions_Module_13 Session Hijacking",
    "EagleCyberSolutions_Module_14 Hacking Web Servers",
    "EagleCyberSolutions_Module_15 Hacking Web Applications",
    "EagleCyberSolutions_Module_16 IDS, Firewalls and Honeypots",
    "EagleCyberSolutions_Module_17 Wireless Pentesting",
    "EagleCyberSolutions_Module_18 Mobile Platform Pentesting",
    "EagleCyberSolutions_Module_19 Cryptography",
    "EagleCyberSolutions_Module_20 Cloud Computing",
    "EagleCyberSolutions_Module_21 Digital Forensics",
    "EagleCyberSolutions_Module_22 Bug Hunting and Pentesting"
)

for ($i = 0; $i -lt $files.Length; $i++) {
    Write-Host "  $($i+1). $($files[$i])" -ForegroundColor White
}

Write-Host "`n📝 Instructions:" -ForegroundColor Cyan
Write-Host "  1. Open the folder: $FOLDER_LINK" -ForegroundColor White
Write-Host "  2. For EACH file:" -ForegroundColor Yellow
Write-Host "     - Right-click → 'Get link'" -ForegroundColor White
Write-Host "     - Set to 'Anyone with the link'" -ForegroundColor White
Write-Host "     - Copy the link" -ForegroundColor White
Write-Host "  3. Use one of these methods:" -ForegroundColor Yellow
Write-Host "`n   Method 1: Portal (Easiest)" -ForegroundColor Green
Write-Host "     - Go to: http://localhost:3000/documents" -ForegroundColor White
Write-Host "     - Scroll to 'Learn from Multiple Drive Links'" -ForegroundColor White
Write-Host "     - Add all 22 file links" -ForegroundColor White
Write-Host "     - Click 'Process All Links'" -ForegroundColor White
Write-Host "`n   Method 2: Admin Dashboard" -ForegroundColor Green
Write-Host "     - Go to: http://localhost:5173/documents" -ForegroundColor White
Write-Host "     - Use 'Learn from Google Drive Links' section" -ForegroundColor White
Write-Host "     - Add all links and process" -ForegroundColor White
Write-Host "`n   Method 3: API (Advanced)" -ForegroundColor Green
Write-Host "     - Use the API endpoint: POST /api/v1/learning/drive-links" -ForegroundColor White
Write-Host "     - Send all links in one request" -ForegroundColor White

Write-Host "`n💡 Tips:" -ForegroundColor Yellow
Write-Host "  - Process in batches of 5-10 files at a time" -ForegroundColor White
Write-Host "  - Check ML service logs to monitor progress" -ForegroundColor White
Write-Host "  - After processing, run: .\LEARN-FROM-DATABASE.ps1" -ForegroundColor White
Write-Host "  - Check learning summary: http://localhost:5000/api/v1/learning/summary" -ForegroundColor White

Write-Host "`n========================================`n" -ForegroundColor Cyan
