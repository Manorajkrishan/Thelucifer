# 🔧 Fix: Drive Learning Not Saving

## 🎯 **Problem Identified**

**Database Mismatch!** The system is using **SQLite**, but you're checking **MySQL** in phpMyAdmin.

- ✅ **ML Service:** Processes Drive links successfully
- ✅ **Learning:** Happens in ML service
- ❌ **Database Save:** Data saved to SQLite, not MySQL
- ❌ **Visibility:** Can't see data in phpMyAdmin (MySQL)

---

## ✅ **Solution**

### **Option 1: Switch to MySQL (Recommended)**

If you want to use phpMyAdmin, switch to MySQL:

```powershell
.\SWITCH-TO-MYSQL.ps1
```

Then:
1. Restart Laravel server
2. Try Drive link again
3. Check phpMyAdmin - data will be there!

### **Option 2: Check SQLite Database**

If you want to keep SQLite, check the SQLite database:

**Location:** `E:\Cyberpunck\backend\api\database\database.sqlite`

**Check with:**
```powershell
cd backend\api
C:\php81\php.exe artisan tinker
```

```php
// Count documents
\App\Models\Document::count()

// List Drive documents
\App\Models\Document::whereJsonContains('metadata->source', 'google_drive')->get()

// List all documents
\App\Models\Document::all()
```

---

## 🔍 **Debug Steps**

### **1. Run Debug Script:**
```powershell
.\DEBUG-DRIVE-LEARNING-SAVE.ps1
```

This will show:
- Current database type
- Documents in database
- Recent save attempts
- API status

### **2. Test Save Manually:**
```powershell
.\TEST-DRIVE-SAVE.ps1
```

This will:
- Process a Drive link
- Save to database
- Show detailed results

### **3. Check Browser Console:**
- Open browser DevTools (F12)
- Go to Console tab
- Try Drive link again
- Look for error messages

### **4. Check Laravel Logs:**
```powershell
cd backend\api
Get-Content storage\logs\laravel.log -Tail 50
```

Look for:
- "Document created successfully"
- "Failed to save document"
- Any errors

---

## 🐛 **Common Issues**

### **Issue 1: Authentication Token Missing**
**Symptom:** 401 Unauthorized errors

**Fix:**
- Make sure you're logged in
- Check token in localStorage
- Re-login if needed

### **Issue 2: Database Connection Failed**
**Symptom:** 500 errors, "could not find driver"

**Fix:**
- Check database configuration in `.env`
- Make sure MySQL is running (if using MySQL)
- Run migrations: `php artisan migrate`

### **Issue 3: Validation Errors**
**Symptom:** 422 errors, validation messages

**Fix:**
- Check browser console for specific errors
- Verify file_type is valid (pdf, docx, txt, doc)
- Check required fields are present

### **Issue 4: CORS Errors**
**Symptom:** Network errors, CORS messages

**Fix:**
- Check API server is running
- Verify CORS configuration
- Check API URL is correct

---

## ✅ **What Was Fixed**

1. **Better Error Logging:**
   - Added console.log for debugging
   - Better error messages
   - Detailed save response logging

2. **Improved Save Process:**
   - Added `extracted_data` to save request
   - Better error handling
   - Longer refresh delay (1000ms)

3. **Debug Scripts:**
   - `DEBUG-DRIVE-LEARNING-SAVE.ps1` - Check current state
   - `TEST-DRIVE-SAVE.ps1` - Test save manually

---

## 🚀 **Quick Fix**

**If using MySQL (phpMyAdmin):**
```powershell
.\SWITCH-TO-MYSQL.ps1
cd backend\api
C:\php81\php.exe artisan serve
```

**Then try Drive link again!**

---

## 📊 **Verify It's Working**

### **After Processing Drive Link:**

1. **Check Database:**
   ```powershell
   cd backend\api
   C:\php81\php.exe artisan tinker
   ```
   ```php
   \App\Models\Document::whereJsonContains('metadata->source', 'google_drive')->count()
   ```

2. **Check API:**
   - Go to: http://localhost:3000/documents
   - Documents should appear in list
   - Check browser console for success messages

3. **Check phpMyAdmin (if MySQL):**
   - Go to: http://localhost/phpmyadmin
   - Select: `sentinelai` database
   - Check: `documents` table
   - Look for records with `metadata->source = 'google_drive'`

---

## 💡 **Tips**

1. **Always check browser console** for errors
2. **Check Laravel logs** for backend errors
3. **Verify database type** matches where you're checking
4. **Use debug scripts** to diagnose issues
5. **Test with single file** before batch processing

---

**The main issue is the database mismatch. Switch to MySQL to see data in phpMyAdmin!** 🚀
