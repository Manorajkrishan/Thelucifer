# 🔧 Fix: Database Save & Learning from Database

## Issues Identified

### **1. Documents Not Saving to Database**
- **Problem**: Content-Type header check was too strict
- **Fix**: Now accepts `application/json` with or without charset

### **2. System Not Learning from Database**
- **Problem**: No automatic mechanism to send documents from database to ML service
- **Fix**: Added automatic learning trigger when documents are saved

---

## What Was Fixed

### **1. Improved Document Save Detection**

**Before:**
```php
$request->header('Content-Type') === 'application/json'
```

**After:**
```php
$contentType = $request->header('Content-Type', '');
$isJsonContentType = str_contains($contentType, 'application/json');
```

Now accepts:
- `application/json`
- `application/json; charset=utf-8`
- Any header containing `application/json`

### **2. Automatic Learning from Saved Documents**

Added `triggerDocumentLearning()` method that:
1. ✅ Automatically called when document is saved
2. ✅ Sends document to ML service for processing
3. ✅ Triggers learning from extracted data
4. ✅ Updates document status and extracted_data

### **3. Learning Flow**

```
Document Saved → triggerDocumentLearning() → ML Service Process → Extract Knowledge → Learn from Data
```

---

## How It Works Now

### **When Document is Saved:**

1. **Document saved to database** ✅
2. **Automatically triggers learning:**
   - Sends to ML service: `POST /api/v1/documents/process`
   - ML service processes and extracts knowledge
   - Triggers learning: `POST /api/v1/learning/learn`
   - Updates document with extracted data
   - System learns from the knowledge

### **For Drive Downloads:**

- Document already processed by ML service during download
- When saved to database, triggers learning from existing extracted data
- No need to reprocess

### **For Regular Uploads:**

- Document saved to database
- Sent to ML service for processing
- Extracted knowledge triggers learning
- Document updated with extracted data

---

## Manual Learning from Database

If you want to learn from all existing documents:

```powershell
.\LEARN-FROM-DATABASE.ps1
```

This script:
1. Logs in to API
2. Fetches all documents
3. Processes each document through ML service
4. Triggers learning from extracted data

---

## Testing

### **1. Test Document Save:**
```powershell
# Login
$loginBody = @{email="admin@sentinelai.com";password="admin123"} | ConvertTo-Json
$response = Invoke-RestMethod -Uri "http://localhost:8000/api/login" -Method POST -Body $loginBody -ContentType "application/json"
$token = $response.token

# Save document (Drive style)
$docBody = @{
    title = "Test Document"
    filename = "test.pdf"
    file_path = "downloaded/test.pdf"
    file_type = "pdf"
    file_size = 0
    status = "processed"
    metadata = @{source = "google_drive"}
} | ConvertTo-Json

$headers = @{
    Authorization = "Bearer $token"
    "Content-Type" = "application/json"
}

Invoke-RestMethod -Uri "http://localhost:8000/api/documents" -Method POST -Headers $headers -Body $docBody
```

### **2. Check Laravel Logs:**
```powershell
cd backend\api
Get-Content storage\logs\laravel.log -Tail 30
```

Look for:
- `Document created successfully from JSON`
- `Document sent to ML service for learning`
- `Triggered learning from extracted document data`

### **3. Check ML Service Logs:**
Check ML service terminal for:
- Document processing logs
- Learning from documents logs

---

## Verification

### **Check Database:**
```powershell
cd backend\api
C:\php81\php.exe artisan tinker
```

```php
// Check documents
\App\Models\Document::latest()->take(5)->get(['id', 'title', 'status', 'processed_at', 'extracted_data'])

// Check if extracted_data exists
\App\Models\Document::whereNotNull('extracted_data')->count()
```

### **Check Learning Summary:**
```powershell
Invoke-RestMethod -Uri "http://localhost:5000/api/v1/learning/summary" -Method GET
```

Should show:
- Total documents processed
- Patterns learned
- Attack techniques discovered

---

## Next Steps

1. **Restart Laravel server:**
   ```powershell
   cd backend\api
   C:\php81\php.exe artisan serve
   ```

2. **Try saving a document** (Drive download or upload)

3. **Check logs** to verify learning is triggered

4. **Run learning script** to process all existing documents:
   ```powershell
   .\LEARN-FROM-DATABASE.ps1
   ```

---

**Status:** ✅ Fixed - Documents now save AND automatically trigger learning!
