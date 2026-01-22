# 🔍 How to Debug 422 Upload Error

## 📋 **Step-by-Step Debugging**

### **1. Check Browser Console (F12)**

1. Open **Developer Tools** (F12)
2. Go to **Network** tab
3. Try uploading a file
4. Find the **POST** request to `/api/documents`
5. Click on it
6. Check:
   - **Request Payload** - Is the file being sent?
   - **Response** - What's the exact error message?

### **2. Check the Error Message**

The error response will look like:
```json
{
  "success": false,
  "message": "Validation failed",
  "errors": {
    "file": ["The file field is required"]
  },
  "error": "The file field is required"
}
```

**The frontend will now display this error clearly!**

### **3. Check Laravel Logs**

```powershell
cd backend\api
Get-Content storage\logs\laravel.log -Tail 100
```

Look for:
- `Document upload request` - Shows what was received
- `Document upload validation failed` - Shows validation errors

---

## 🔧 **Common Issues & Fixes**

### **Issue 1: "file: The file field is required"**
- **Cause:** File not being sent in request
- **Fix:** Make sure file input has a file selected
- **Check:** Browser Network tab → Request Payload

### **Issue 2: "file: The file must be a file of type: pdf, docx, txt, doc"**
- **Cause:** Wrong file type
- **Fix:** Only upload PDF, DOCX, DOC, or TXT files
- **Check:** File extension must be .pdf, .docx, .doc, or .txt

### **Issue 3: "file: The file may not be greater than 10240 kilobytes"**
- **Cause:** File too large
- **Fix:** File must be less than 10MB
- **Check:** File properties → Size

### **Issue 4: "Unauthenticated"**
- **Cause:** Not logged in
- **Fix:** Login first, then try uploading
- **Check:** localStorage should have 'token'

### **Issue 5: PHP Upload Limits**
- **Check PHP settings:**
  ```ini
  upload_max_filesize = 10M
  post_max_size = 10M
  ```
- **Location:** `C:\php81\php.ini`

---

## ✅ **What I've Added**

1. ✅ **Client-side validation** - Catches errors before sending
2. ✅ **Better error messages** - Shows exactly what's wrong
3. ✅ **Debug logging** - Logs what's received on server
4. ✅ **Custom validation messages** - Clearer error text

---

## 🚀 **Next Steps**

1. **Restart Laravel Server:**
   ```powershell
   cd backend\api
   C:\php81\php.exe artisan serve
   ```

2. **Try Uploading:**
   - Open browser console (F12)
   - Try uploading a file
   - Check the error message - it will tell you exactly what's wrong!

3. **Check Logs:**
   ```powershell
   Get-Content backend\api\storage\logs\laravel.log -Tail 20
   ```

---

**The error message will now tell you exactly what validation failed!** 🔍
