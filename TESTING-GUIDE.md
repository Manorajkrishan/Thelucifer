# 🧪 Complete Testing Guide for SentinelAI X

## 🚀 **Quick Start Testing**

### **1. Start All Services**

#### **A. Start Laravel API (Port 8000)**
```powershell
cd backend\api
C:\php81\php.exe artisan serve
```
**Verify:** Open http://localhost:8000 - Should show Laravel welcome or API response

#### **B. Start ML Service (Port 5000)**
```powershell
cd backend\ml-service
python app.py
```
**Verify:** Open http://localhost:5000 - Should show service info

#### **C. Start Next.js Portal (Port 3000)**
```powershell
cd frontend\portal
npm run dev
```
**Verify:** Open http://localhost:3000 - Should show homepage

#### **D. Start Vue Admin Dashboard (Port 5173)**
```powershell
cd frontend\admin-dashboard
npm run dev
```
**Verify:** Open http://localhost:5173 - Should show login page

---

## ✅ **Testing Checklist**

### **1. Authentication Testing** ✅

#### **Test Login:**
1. Go to: http://localhost:3000/login
2. **Credentials:**
   - Email: `admin@sentinelai.com`
   - Password: `admin123`
3. Click "Login"
4. **Expected:** Redirects to dashboard, token stored in localStorage

#### **Test Registration:**
1. Go to: http://localhost:3000/login
2. Click "Register" (if available)
3. Fill in form
4. **Expected:** Account created, auto-login

#### **Test Logout:**
1. Click logout button
2. **Expected:** Token removed, redirects to login

---

### **2. Documents Testing** ✅

#### **Test Document Upload:**
1. Go to: http://localhost:3000/documents
2. Click "Choose File"
3. Select a PDF, DOCX, DOC, or TXT file (< 10MB)
4. Click "Upload Document"
5. **Expected:** 
   - Success message
   - Document appears in list
   - Status shows "uploaded"

#### **Test Document Download:**
1. Find uploaded document in list
2. Click "Download"
3. **Expected:** File downloads

#### **Test Document Processing:**
1. Find uploaded document
2. Click "Process"
3. **Expected:** Status changes to "processing" then "processed"

#### **Test Document Delete:**
1. Find document
2. Click "Delete"
3. Confirm deletion
4. **Expected:** Document removed from list

#### **Test Document Search:**
1. Use search box
2. Type document name
3. **Expected:** Filtered results

---

### **3. Google Drive Link Learning** ✅

#### **Test Single Drive Link:**
1. Go to: http://localhost:3000/documents
2. Scroll to "📚 Learn from Google Drive Link"
3. Get a Google Drive file link:
   - Upload a document to Google Drive
   - Right-click → "Get link"
   - Set to "Anyone with the link"
   - Copy link (should be: `https://drive.google.com/file/d/FILE_ID/view`)
4. Paste link in input field
5. Click "📥 Download & Learn from Drive"
6. **Expected:**
   - Success message
   - Document downloaded and processed
   - Appears in documents list

#### **Test Multiple Drive Links:**
1. Scroll to "📚 Learn from Multiple Drive Links"
2. Add multiple file links
3. Click "📥 Process All Links"
4. **Expected:** All documents processed

---

### **4. Threats Testing** ✅

#### **Test View Threats:**
1. Go to: http://localhost:3000/threats
2. **Expected:** List of threats (or empty if none)

#### **Test Create Threat:**
1. Click "+ Create Threat"
2. Fill in form:
   - Type: "Malware"
   - Severity: 7
   - Description: "Test threat"
   - Source IP: "192.168.1.100"
3. Click "Create"
4. **Expected:** Threat appears in list

#### **Test Update Threat Status:**
1. Find a threat
2. Change status dropdown (Detected → Analyzing → Mitigated → Resolved)
3. **Expected:** Status updates

#### **Test Threat Details:**
1. Click "View" on a threat
2. **Expected:** Detailed threat information page

#### **Test Threat Search/Filter:**
1. Use search box
2. Filter by status/severity
3. **Expected:** Filtered results

---

### **5. Simulations Testing** ✅

#### **Test Defensive Simulation:**
1. Go to: http://localhost:3000/simulations
2. Select simulation type
3. Enter attack data (or select existing threat)
4. Click "Run Simulation"
5. **Expected:** Simulation results displayed

#### **Test Counter-Offensive Simulation:**
1. Scroll to "Autonomous Cyber Counter-Offensive" section
2. Click "Execute Counter-Offensive Simulation"
3. Confirm warning
4. **Expected:** 
   - Attacker profile
   - Validation result
   - Counter-offensive result (simulated)

---

### **6. Analytics Testing** ✅

#### **Test View Analytics:**
1. Go to: http://localhost:3000/analytics
2. **Expected:**
   - Overview statistics cards
   - Threat status distribution
   - Threat type distribution
   - Severity distribution
   - Recent threats

---

### **7. Learning & Knowledge Testing** ✅

#### **Test View Learning Summary:**
1. Go to: http://localhost:3000/learning
2. **Expected:**
   - Total documents processed
   - Patterns learned
   - Attack techniques discovered
   - Exploit patterns identified

#### **Test Knowledge Graph Query:**
1. In Learning page
2. Search for: "SQL Injection" or "XSS"
3. Click "Search"
4. **Expected:** Matching knowledge entries displayed

#### **Test View Attack Techniques:**
1. Scroll to "Attack Techniques" section
2. **Expected:** List of learned attack techniques

#### **Test View Defense Strategies:**
1. Scroll to "Defense Strategies" section
2. **Expected:** List of learned defense strategies

---

### **8. Dashboard Testing** ✅

#### **Test Dashboard:**
1. Go to: http://localhost:3000/dashboard
2. **Expected:**
   - Real-time statistics
   - Quick action cards
   - Recent threats
   - Auto-refresh every 30 seconds

---

## 🔧 **API Testing (Using curl/Postman)**

### **1. Test Authentication API:**

```powershell
# Login
$body = @{email="admin@sentinelai.com";password="admin123"} | ConvertTo-Json
$response = Invoke-RestMethod -Uri "http://localhost:8000/api/login" -Method POST -Body $body -ContentType "application/json"
$token = $response.token
Write-Host "Token: $token"
```

### **2. Test Document Upload API:**

```powershell
# Upload document (replace with actual file path)
$filePath = "C:\path\to\document.pdf"
$formData = @{
    file = Get-Item $filePath
    title = "Test Document"
}
$headers = @{
    Authorization = "Bearer $token"
}
Invoke-RestMethod -Uri "http://localhost:8000/api/documents" -Method POST -Form $formData -Headers $headers
```

### **3. Test Drive Link Learning API:**

```powershell
# Learn from Drive link
$body = @{
    drive_link = "https://drive.google.com/file/d/YOUR_FILE_ID/view"
    auto_learn = $true
} | ConvertTo-Json
Invoke-RestMethod -Uri "http://localhost:5000/api/v1/learning/drive-link" -Method POST -Body $body -ContentType "application/json"
```

### **4. Test Learning Summary API:**

```powershell
# Get learning summary
Invoke-RestMethod -Uri "http://localhost:5000/api/v1/learning/summary" -Method GET
```

### **5. Test Threat Statistics API:**

```powershell
# Get threat statistics
$headers = @{Authorization = "Bearer $token"}
Invoke-RestMethod -Uri "http://localhost:8000/api/threats/statistics" -Method GET -Headers $headers
```

---

## 🧪 **End-to-End Testing Scenarios**

### **Scenario 1: Complete Document Learning Flow**

1. ✅ Upload a PDF document
2. ✅ Process the document
3. ✅ Check Learning page - should show new patterns
4. ✅ Query knowledge graph for extracted techniques
5. ✅ Verify document appears in documents list

### **Scenario 2: Drive Link Learning Flow**

1. ✅ Upload document to Google Drive
2. ✅ Get shareable link
3. ✅ Use Drive link learning feature
4. ✅ Verify document downloaded and processed
5. ✅ Check Learning page for new knowledge

### **Scenario 3: Threat Detection & Response**

1. ✅ Create a threat manually
2. ✅ Update threat status through workflow
3. ✅ View threat in Analytics
4. ✅ Run simulation based on threat
5. ✅ Execute counter-offensive simulation

### **Scenario 4: Full System Integration**

1. ✅ Login to system
2. ✅ Upload multiple documents
3. ✅ Learn from Drive links
4. ✅ Create threats
5. ✅ View analytics
6. ✅ Check learning summary
7. ✅ Run simulations

---

## 📊 **Performance Testing**

### **Test Large File Upload:**
- Upload 9MB PDF file
- **Expected:** Uploads successfully

### **Test Multiple Concurrent Requests:**
- Open multiple browser tabs
- Make simultaneous requests
- **Expected:** All requests handled correctly

### **Test Auto-Refresh:**
- Open Dashboard
- Wait 30 seconds
- **Expected:** Data refreshes automatically

---

## 🐛 **Error Testing**

### **Test Invalid File Type:**
- Try uploading .exe or .zip file
- **Expected:** Clear error message about file type

### **Test File Too Large:**
- Try uploading > 10MB file
- **Expected:** Error message about file size

### **Test Without Authentication:**
- Logout
- Try accessing protected pages
- **Expected:** Redirects to login

### **Test Invalid Drive Link:**
- Use invalid or private Drive link
- **Expected:** Error message about link

---

## ✅ **Verification Checklist**

After testing, verify:

- [ ] All services start without errors
- [ ] Login works correctly
- [ ] Documents can be uploaded
- [ ] Documents can be downloaded
- [ ] Documents can be processed
- [ ] Drive link learning works
- [ ] Threats can be created
- [ ] Threats can be updated
- [ ] Analytics displays data
- [ ] Learning summary shows data
- [ ] Knowledge graph queries work
- [ ] Simulations run successfully
- [ ] Dashboard shows real-time data
- [ ] All navigation links work
- [ ] Error messages are clear

---

## 🚀 **Quick Test Script**

Run this PowerShell script to test all endpoints:

```powershell
# Test all endpoints
Write-Host "Testing SentinelAI X System..." -ForegroundColor Green

# 1. Test Laravel API
Write-Host "`n1. Testing Laravel API..." -ForegroundColor Yellow
try {
    $response = Invoke-WebRequest -Uri "http://localhost:8000" -UseBasicParsing
    Write-Host "✅ Laravel API is running" -ForegroundColor Green
} catch {
    Write-Host "❌ Laravel API is not running" -ForegroundColor Red
}

# 2. Test ML Service
Write-Host "`n2. Testing ML Service..." -ForegroundColor Yellow
try {
    $response = Invoke-WebRequest -Uri "http://localhost:5000/health" -UseBasicParsing
    Write-Host "✅ ML Service is running" -ForegroundColor Green
} catch {
    Write-Host "❌ ML Service is not running" -ForegroundColor Red
}

# 3. Test Portal
Write-Host "`n3. Testing Portal..." -ForegroundColor Yellow
try {
    $response = Invoke-WebRequest -Uri "http://localhost:3000" -UseBasicParsing
    Write-Host "✅ Portal is running" -ForegroundColor Green
} catch {
    Write-Host "❌ Portal is not running" -ForegroundColor Red
}

Write-Host "`n✅ Testing complete!" -ForegroundColor Green
```

---

**Start testing and verify everything works!** 🚀
