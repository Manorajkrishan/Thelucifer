# Process All Files from Google Drive Folder
# Since folder links aren't supported, this script helps you process individual files

Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "  Process Drive Folder Files" -ForegroundColor Cyan
Write-Host "========================================`n" -ForegroundColor Cyan

$FOLDER_LINK = "https://drive.google.com/drive/folders/1srkpnf0gwo6A0bIoMpXKZzADvZw3p67l"
$ML_SERVICE_URL = "http://localhost:5000"
$API_URL = "http://localhost:8000"

Write-Host "⚠️  Note: Google Drive folder links are not directly supported." -ForegroundColor Yellow
Write-Host "You need to get individual file links from the folder.`n" -ForegroundColor Yellow

Write-Host "📋 Files in the folder:" -ForegroundColor Cyan
Write-Host "  1. EagleCyberSolutions_Module_1 Introduction" -ForegroundColor White
Write-Host "  2. EagleCyberSolutions_Module_2 Basics and Environment setup" -ForegroundColor White
Write-Host "  3. EagleCyberSolutions_Module_3 Linux Refresher" -ForegroundColor White
Write-Host "  4. EagleCyberSolutions_Module_4 Networking Refresher" -ForegroundColor White
Write-Host "  5. EagleCyberSolutions_Module_5 Footprinting and Reconnaissance" -ForegroundColor White
Write-Host "  6. EagleCyberSolutions_Module_6 Scanning" -ForegroundColor White
Write-Host "  7. EagleCyberSolutions_Module_7 Enumeration" -ForegroundColor White
Write-Host "  8. EagleCyberSolutions_Module_8 System Hacking part2" -ForegroundColor White
Write-Host "  9. EagleCyberSolutions_Module_9 Malwares" -ForegroundColor White
Write-Host "  10. EagleCyberSolutions_Module_10 Sniffing and Spoofing" -ForegroundColor White
Write-Host "  11. EagleCyberSolutions_Module_11 Social Engineering" -ForegroundColor White
Write-Host "  12. EagleCyberSolutions_Module_12 Denial of Service" -ForegroundColor White
Write-Host "  13. EagleCyberSolutions_Module_13 Session Hijacking" -ForegroundColor White
Write-Host "  14. EagleCyberSolutions_Module_14 Hacking Web Servers" -ForegroundColor White
Write-Host "  15. EagleCyberSolutions_Module_15 Hacking Web Applications" -ForegroundColor White
Write-Host "  16. EagleCyberSolutions_Module_16 IDS, Firewalls and Honeypots" -ForegroundColor White
Write-Host "  17. EagleCyberSolutions_Module_17 Wireless Pentesting" -ForegroundColor White
Write-Host "  18. EagleCyberSolutions_Module_18 Mobile Platform Pentesting" -ForegroundColor White
Write-Host "  19. EagleCyberSolutions_Module_19 Cryptography" -ForegroundColor White
Write-Host "  20. EagleCyberSolutions_Module_20 Cloud Computing" -ForegroundColor White
Write-Host "  21. EagleCyberSolutions_Module_21 Digital Forensics" -ForegroundColor White
Write-Host "  22. EagleCyberSolutions_Module_22 Bug Hunting and Pentesting" -ForegroundColor White

Write-Host "`n📝 Instructions:" -ForegroundColor Cyan
Write-Host "  1. Open the folder: $FOLDER_LINK" -ForegroundColor White
Write-Host "  2. Right-click each file → 'Get link' → Set to 'Anyone with the link'" -ForegroundColor White
Write-Host "  3. Copy each file link" -ForegroundColor White
Write-Host "  4. Use the batch processing feature in the portal" -ForegroundColor White
Write-Host "     OR use this script with individual file links`n" -ForegroundColor White

Write-Host "💡 Alternative: Use the Portal's 'Learn from Multiple Drive Links' feature" -ForegroundColor Yellow
Write-Host "   Go to: http://localhost:3000/documents" -ForegroundColor White
Write-Host "   Scroll to 'Learn from Multiple Drive Links'" -ForegroundColor White
Write-Host "   Add all file links and click 'Process All Links'`n" -ForegroundColor White

Write-Host "🚀 Quick Start:" -ForegroundColor Cyan
Write-Host "  1. Get individual file links from the folder" -ForegroundColor White
Write-Host "  2. Open: http://localhost:3000/documents" -ForegroundColor White
Write-Host "  3. Use 'Learn from Multiple Drive Links' section" -ForegroundColor White
Write-Host "  4. Add all file links and process`n" -ForegroundColor White

Write-Host "========================================`n" -ForegroundColor Cyan
