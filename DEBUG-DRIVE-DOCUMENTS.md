# 🔍 Debug: Drive Documents Not Showing

## Steps to Debug

### 1. Check Browser Console
Open browser DevTools (F12) → Console tab, then try downloading a Drive document. Look for:
- Any error messages
- "Document saved successfully" log
- "Failed to save document" warnings

### 2. Check Network Tab
Open DevTools → Network tab, then download a Drive document. Check:
- **POST to `/api/v1/learning/drive-link`** - Should return 200 with `result.filename`
- **POST to `/api/documents`** - Should return 201 if saved successfully
- **GET to `/api/documents`** - Should show the new document in the list

### 3. Check Laravel Logs
```powershell
cd backend\api
Get-Content storage\logs\laravel.log -Tail 50
```

Look for:
- "Creating document from Drive download" log
- "Document created successfully" log
- Any error messages

### 4. Check Database
```powershell
cd backend\api
C:\php81\php.exe artisan tinker
```

Then run:
```php
\App\Models\Document::latest()->take(5)->get(['id', 'title', 'filename', 'status', 'created_at'])
```

### 5. Test API Directly
```powershell
# Get your token first (from browser localStorage or login)
$token = "YOUR_TOKEN_HERE"

# Test creating a document
$body = @{
    title = "Test Document"
    filename = "test.pdf"
    file_path = "downloaded/test.pdf"
    file_type = "pdf"
    file_size = 0
    status = "processed"
    metadata = @{
        source = "google_drive"
        drive_link = "https://drive.google.com/file/d/TEST/view"
    }
} | ConvertTo-Json

Invoke-RestMethod -Uri "http://localhost:8000/api/documents" -Method POST -Body $body -ContentType "application/json" -Headers @{Authorization = "Bearer $token"}
```

### 6. Verify Authentication
Make sure you're logged in and the token is valid:
```javascript
// In browser console
localStorage.getItem('token')
```

## Common Issues

### Issue 1: Validation Error
**Symptom:** Console shows "Validation failed" error
**Fix:** Check that all required fields are sent:
- `title` (required)
- `filename` (required)
- `file_path` (required)
- `file_type` (must be: pdf, docx, txt, doc)
- `file_size` (optional, defaults to 0)
- `status` (optional, defaults to 'processed')
- `metadata` (optional, array)

### Issue 2: Authentication Error
**Symptom:** 401 Unauthorized
**Fix:** 
- Make sure you're logged in
- Check token is valid
- Token should be in Authorization header: `Bearer TOKEN`

### Issue 3: File Type Not Allowed
**Symptom:** Validation error about file_type
**Fix:** Ensure `file_type` is one of: `pdf`, `docx`, `txt`, `doc`

### Issue 4: Documents Not Refreshing
**Symptom:** Document saved but list doesn't update
**Fix:** 
- Check `fetchDocuments()` is being called
- Check API response format matches what frontend expects
- Try manually refreshing the page

## Quick Test

1. Open browser console (F12)
2. Go to Documents page
3. Enter a Drive link and download
4. Watch console for:
   - ML service response
   - Save API call
   - Fetch documents call
   - Any errors

## Expected Flow

1. ✅ ML Service downloads document → Returns `{success: true, result: {filename: "...", file_path: "..."}}`
2. ✅ Frontend calls Laravel API → `POST /api/documents` with document data
3. ✅ Laravel saves to database → Returns `{success: true, data: {...}}`
4. ✅ Frontend refreshes list → `GET /api/documents` shows new document
5. ✅ Document appears in list

If any step fails, check the error message and fix accordingly.
