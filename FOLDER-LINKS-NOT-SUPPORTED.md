# 📁 Folder Links Not Supported - Use Individual File Links

## ⚠️ **Issue**

You tried to use a **Google Drive folder link**, but the system currently only supports **individual file links**.

**Your link:** `https://drive.google.com/drive/folders/1srkpnf0gwo6A0bIoMpXKZzADvZw3p67l`

---

## ✅ **Solution: Use Individual File Links**

### **How to Get Individual File Links:**

1. **Open the folder** in Google Drive
2. **Right-click on each file** you want to process
3. **Click "Get link"** or "Share"
4. **Set permission** to "Anyone with the link" (if not already)
5. **Copy the file link** - it should look like:
   ```
   https://drive.google.com/file/d/FILE_ID/view
   ```
6. **Use that file link** in the Documents page

---

## 📋 **Supported Link Formats**

✅ **Individual File Links:**
- `https://drive.google.com/file/d/FILE_ID/view`
- `https://drive.google.com/open?id=FILE_ID`
- `https://drive.google.com/uc?export=download&id=FILE_ID`

❌ **Folder Links (Not Supported):**
- `https://drive.google.com/drive/folders/FOLDER_ID`
- `https://drive.google.com/drive/folders?id=FOLDER_ID`

---

## 🔄 **For Multiple Files**

If you have multiple files in a folder:

1. **Get individual links** for each file (as described above)
2. **Use the "Learn from Multiple Drive Links"** section on the Documents page
3. **Paste each file link** in separate input fields
4. **Click "Process All Links"**

---

## 🚀 **Alternative: Set Up Google Drive API**

If you need folder support, you can set up the Google Drive API:

1. Go to https://console.cloud.google.com/
2. Create a new project (or select existing)
3. Enable "Google Drive API"
4. Create credentials (OAuth 2.0)
5. Configure the API credentials in the ML service

**Note:** This requires additional setup and API keys.

---

## 💡 **Quick Fix**

**Right now, the easiest solution is:**
1. Open your folder in Google Drive
2. Get individual file links for each document
3. Use those file links in the system

---

**Use individual file links instead of folder links!** 🚀
