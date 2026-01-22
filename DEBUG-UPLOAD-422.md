# 🔍 Debugging 422 Upload Error

## 📋 **What to Check**

The 422 error means validation failed. Here's how to debug it:

### **1. Check Browser Console**

Open browser DevTools (F12) and check:
- **Network tab** → Find the POST request to `/api/documents`
- **Response** → See the actual error message
- **Request Payload** → Verify the file is being sent

### **2. Check Laravel Logs**

```powershell
cd backend\api
Get-Content storage\logs\laravel.log -Tail 50
```

Look for:
- "Document upload request" - Shows what was received
- "Document upload validation failed" - Shows validation errors

### **3. Common Issues**

#### **Issue 1: File Not Sent**
- **Error:** "file: The file field is required"
- **Fix:** Make sure file input has a file selected

#### **Issue 2: Wrong File Type**
- **Error:** "file: The file must be a file of type: pdf, docx, txt, doc"
- **Fix:** Only upload PDF, DOCX, DOC, or TXT files

#### **Issue 3: File Too Large**
- **Error:** "file: The file may not be greater than 10240 kilobytes"
- **Fix:** File must be less than 10MB

#### **Issue 4: Not Authenticated**
- **Error:** "Unauthenticated"
- **Fix:** Make sure you're logged in

#### **Issue 5: PHP Upload Limits**
- **Check PHP settings:**
  ```ini
  upload_max_filesize = 10M
  post_max_size = 10M
  ```

---

## 🔧 **Quick Fixes**

### **1. Check File Type**
Make sure your file is:
- ✅ PDF (.pdf)
- ✅ Word Document (.docx or .doc)
- ✅ Text File (.txt)

### **2. Check File Size**
- Must be less than 10MB
- Check file properties

### **3. Check Authentication**
- Make sure you're logged in
- Token should be in localStorage

### **4. Check Browser Console**
The error message will now show exactly what's wrong!

---

## 📊 **What the Error Response Contains**

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

The frontend will now display this clearly!

---

**Check the browser console for the exact error message!** 🔍
