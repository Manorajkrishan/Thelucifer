# 🔧 Fix: 401 Unauthorized Error

## 🎯 **Problem**

Getting `401 Unauthorized` when trying to process documents. This happens because:

1. **Token Expired:** After database switch, tokens may be invalid
2. **Token Not Found:** Token doesn't exist in new MySQL database
3. **Authentication Issue:** Sanctum not recognizing the token

---

## ✅ **Solution**

### **Quick Fix: Re-Login**

The easiest solution is to **log out and log back in** to get a fresh token:

1. **In Admin Dashboard:**
   - Click "Logout"
   - Login again with: `admin@sentinelai.com` / `admin123`
   - This will generate a new token in MySQL database

2. **Verify Token:**
   - Check browser console (F12)
   - Look for token in localStorage
   - Should see new token after login

---

## 🔍 **Why This Happened**

When we switched from SQLite to MySQL:
- Old tokens were in SQLite database
- New MySQL database has no tokens
- Your browser still has old token
- Laravel can't find token in MySQL → 401 error

---

## ✅ **What Was Fixed**

1. **Better Error Handling:**
   - Added 401 specific error message
   - Suggests re-login when token invalid
   - Better error messages

2. **Token Validation:**
   - Checks if token exists before making request
   - Validates token format

---

## 🚀 **Steps to Fix**

### **Step 1: Re-Login**

1. Go to: http://localhost:5173
2. Click "Logout" (if logged in)
3. Login again:
   - Email: `admin@sentinelai.com`
   - Password: `admin123`

### **Step 2: Verify**

1. Check browser console (F12)
2. Should see successful API calls
3. No more 401 errors

### **Step 3: Test Document Process**

1. Go to Documents page
2. Click "Process" on a document
3. Should work without 401 error

---

## 🐛 **If Still Getting 401**

### **Check Token in Database:**

```powershell
cd backend\api
C:\php81\php.exe artisan tinker
```

```php
// Check tokens
DB::table('personal_access_tokens')->count()

// Check users
\App\Models\User::count()

// List tokens
DB::table('personal_access_tokens')->get()
```

### **Check Browser Token:**

1. Open browser DevTools (F12)
2. Go to Application/Storage → Local Storage
3. Look for `token` key
4. Copy the token value

### **Test Token Manually:**

```powershell
$token = "YOUR_TOKEN_HERE"
Invoke-RestMethod -Uri "http://localhost:8000/api/user" -Method GET -Headers @{Authorization="Bearer $token"}
```

Should return user info, not 401.

---

## 💡 **Prevention**

After database switches:
1. Always re-login to get fresh tokens
2. Clear browser localStorage if needed
3. Check token exists in new database

---

## ✅ **Status**

- ✅ Better error handling added
- ✅ 401 error detection
- ✅ Re-login suggestion
- ✅ Token validation

**Just re-login and it should work!** 🚀
