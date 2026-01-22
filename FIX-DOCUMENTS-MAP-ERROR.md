# ✅ Fixed: documents.map is not a function

## 🔧 **What Was Fixed**

The error occurred because the API returns **paginated data**, not a direct array.

### **API Response Structure:**
```json
{
  "success": true,
  "data": {
    "data": [...],  // Actual documents array
    "current_page": 1,
    "per_page": 15,
    "total": 0,
    ...
  }
}
```

### **Fix Applied:**
Updated `frontend/portal/pages/documents.js` to:
1. ✅ Handle paginated responses (`data.data.data`)
2. ✅ Handle direct array responses (`data.data`)
3. ✅ Ensure `documents` is always an array
4. ✅ Added safety check before calling `.map()`

### **Also Fixed:**
- ✅ Applied same fix to `threats.js` page
- ✅ Added array validation before mapping

---

## ✅ **Status**

**The error is FIXED!** 

The documents page now correctly handles:
- Paginated API responses
- Direct array responses
- Empty responses
- Error responses

**Refresh the page and it should work!** 🚀
