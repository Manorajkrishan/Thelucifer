# 📚 Process EagleCyberSolutions Folder - Complete Guide

## 📋 Folder Contents

The folder contains **22 cybersecurity training modules**:
- Module 1: Introduction
- Module 2: Basics and Environment setup
- Module 3: Linux Refresher
- Module 4: Networking Refresher
- Module 5: Footprinting and Reconnaissance
- Module 6: Scanning
- Module 7: Enumeration
- Module 8: System Hacking part2
- Module 9: Malwares
- Module 10: Sniffing and Spoofing
- Module 11: Social Engineering
- Module 12: Denial of Service
- Module 13: Session Hijacking
- Module 14: Hacking Web Servers
- Module 15: Hacking Web Applications
- Module 16: IDS, Firewalls and Honeypots
- Module 17: Wireless Pentesting
- Module 18: Mobile Platform Pentesting
- Module 19: Cryptography
- Module 20: Cloud Computing
- Module 21: Digital Forensics
- Module 22: Bug Hunting and Pentesting

**Folder Link:** https://drive.google.com/drive/folders/1srkpnf0gwo6A0bIoMpXKZzADvZw3p67l

---

## ⚠️ Important Note

**Google Drive folder links are NOT directly supported.** You need to get **individual file links** for each PDF.

---

## 🚀 Method 1: Portal (Easiest - Recommended)

### **Steps:**

1. **Open the folder:**
   - Go to: https://drive.google.com/drive/folders/1srkpnf0gwo6A0bIoMpXKZzADvZw3p67l

2. **Get individual file links:**
   - For EACH file (all 22):
     - Right-click the file
     - Click "Get link"
     - Set to "Anyone with the link"
     - Copy the link (should look like: `https://drive.google.com/file/d/FILE_ID/view`)

3. **Process in Portal:**
   - Go to: http://localhost:3000/documents
   - Scroll to "📚 Learn from Multiple Drive Links"
   - Click "+ Add Link" for each file (add all 22 links)
   - Click "📥 Process All Links"
   - Wait for processing (this may take several minutes)

4. **Verify:**
   - Documents should appear in the list
   - Check learning summary: http://localhost:5000/api/v1/learning/summary

---

## 🎛️ Method 2: Admin Dashboard

1. **Open Admin Dashboard:**
   - Go to: http://localhost:5173/documents
   - Login with: `admin@sentinelai.com` / `admin123`

2. **Use Drive Links Section:**
   - Scroll to "📚 Learn from Google Drive Links"
   - Add all 22 file links
   - Click "📥 Process All Links & Learn"

3. **Monitor Progress:**
   - Check ML service terminal for processing logs
   - Documents will appear in the list as they're processed

---

## 🔧 Method 3: API (Advanced)

### **Using PowerShell:**

```powershell
# Login first
$loginBody = @{email="admin@sentinelai.com";password="admin123"} | ConvertTo-Json
$response = Invoke-RestMethod -Uri "http://localhost:8000/api/login" -Method POST -Body $loginBody -ContentType "application/json"
$token = $response.token

# Prepare all file links (replace with actual links)
$driveLinks = @(
    "https://drive.google.com/file/d/FILE_ID_1/view",
    "https://drive.google.com/file/d/FILE_ID_2/view",
    # ... add all 22 links
)

# Process all links
$body = @{
    drive_links = $driveLinks
    auto_learn = $true
} | ConvertTo-Json

Invoke-RestMethod -Uri "http://localhost:5000/api/v1/learning/drive-links" -Method POST -Body $body -ContentType "application/json"
```

---

## ✅ After Processing

### **1. Verify Documents Saved:**
```powershell
# Check database
cd backend\api
C:\php81\php.exe artisan tinker
```

```php
\App\Models\Document::count()
\App\Models\Document::where('metadata->source', 'google_drive')->count()
```

### **2. Check Learning Summary:**
```powershell
Invoke-RestMethod -Uri "http://localhost:5000/api/v1/learning/summary" -Method GET
```

Should show:
- Total documents processed: 22
- Patterns learned
- Attack techniques discovered

### **3. Learn from Database:**
```powershell
.\LEARN-FROM-DATABASE.ps1
```

This ensures all documents are processed and learned from.

---

## 🧪 System Check

Run comprehensive system check:
```powershell
.\FULL-SYSTEM-CHECK.ps1
```

This verifies:
- All services running
- Authentication working
- API endpoints working
- ML service working
- Database connected
- Learning system working

---

## 📊 Expected Results

After processing all 22 modules:

1. **Documents:**
   - 22 documents in database
   - All marked as "processed"
   - Extracted knowledge stored

2. **Learning:**
   - Attack techniques learned
   - Exploit patterns identified
   - Defense strategies extracted
   - Knowledge graph populated

3. **System:**
   - Improved threat detection
   - Better pattern recognition
   - Enhanced counter-offensive capabilities

---

## 🐛 Troubleshooting

### **Issue: Folder link not working**
- **Solution:** Use individual file links (see instructions above)

### **Issue: Processing fails**
- Check ML service is running
- Check file links are accessible (set to "Anyone with the link")
- Check ML service logs for errors

### **Issue: Documents not saving**
- Restart Laravel server
- Check browser console for errors
- Check Laravel logs

### **Issue: Learning not happening**
- Run: `.\LEARN-FROM-DATABASE.ps1`
- Check ML service logs
- Verify documents have `extracted_data`

---

## 🎯 Quick Checklist

- [ ] Get all 22 individual file links from folder
- [ ] Process via Portal or Admin Dashboard
- [ ] Verify documents saved (check database)
- [ ] Check learning summary
- [ ] Run system check
- [ ] Train models (optional)
- [ ] Test threat detection

---

**Ready to process!** Use the Portal method for easiest processing of all 22 modules. 🚀
