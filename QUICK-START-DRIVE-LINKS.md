# 🚀 Quick Start: Learn from Google Drive Links

## ✅ **What's New**

You can now provide Google Drive links and the system will:
1. ✅ **Download** the document automatically
2. ✅ **Process** and extract knowledge
3. ✅ **Learn** from the document automatically
4. ✅ **Store** in knowledge graph

---

## 🎯 **Simple Usage**

### **Just Provide a Drive Link!**

```bash
curl -X POST http://localhost:5000/api/v1/learning/drive-link \
  -H "Content-Type: application/json" \
  -d '{
    "drive_link": "YOUR_GOOGLE_DRIVE_LINK_HERE",
    "auto_learn": true
  }'
```

That's it! The system will:
- Download the document
- Extract attack techniques, exploit patterns, defense strategies
- Learn from it automatically
- Store in knowledge graph

---

## 📋 **Supported Link Formats**

### **Google Drive File Links:**

1. **Direct Link:**
   ```
   https://drive.google.com/file/d/FILE_ID/view
   ```

2. **Shareable Link:**
   ```
   https://drive.google.com/open?id=FILE_ID
   ```

3. **Download Link:**
   ```
   https://drive.google.com/uc?export=download&id=FILE_ID
   ```

### **How to Get Your Drive Link:**

1. Upload your document to Google Drive
2. Right-click → "Get link"
3. Set permission to "Anyone with the link"
4. Copy the link
5. Use it in the API!

---

## 🔧 **Multiple Documents**

### **Process Multiple Drive Links at Once:**

```bash
curl -X POST http://localhost:5000/api/v1/learning/drive-links \
  -H "Content-Type: application/json" \
  -d '{
    "drive_links": [
      "https://drive.google.com/file/d/FILE_ID_1/view",
      "https://drive.google.com/file/d/FILE_ID_2/view",
      "https://drive.google.com/file/d/FILE_ID_3/view"
    ],
    "auto_learn": true
  }'
```

---

## 📊 **Check What You've Learned**

```bash
curl http://localhost:5000/api/v1/learning/summary
```

**Response:**
```json
{
  "success": true,
  "summary": {
    "total_documents": 5,
    "total_patterns_learned": 234,
    "unique_attack_techniques": 45,
    "unique_exploit_patterns": 32,
    "attack_techniques": ["malware", "trojan", "ransomware", ...],
    "exploit_patterns": ["CVE-2023-1234", ...]
  }
}
```

---

## 💡 **Example Workflow**

### **Step 1: Share Your Document**
- Upload PDF/DOCX to Google Drive
- Get shareable link
- Set to "Anyone with link"

### **Step 2: Send to API**
```bash
curl -X POST http://localhost:5000/api/v1/learning/drive-link \
  -H "Content-Type: application/json" \
  -d '{
    "drive_link": "https://drive.google.com/file/d/YOUR_FILE_ID/view",
    "auto_learn": true
  }'
```

### **Step 3: Done!**
- Document downloaded ✅
- Knowledge extracted ✅
- System learned ✅
- Ready to detect threats! ✅

---

## 🎯 **What Gets Learned**

From each document, the system extracts:

- ✅ **Attack Techniques** (malware, trojan, ransomware, etc.)
- ✅ **Exploit Patterns** (CVE numbers, vulnerability patterns)
- ✅ **Defense Strategies** (firewall, encryption, monitoring, etc.)
- ✅ **Keywords** (important security terms)
- ✅ **Entities** (named entities from NLP)

All of this is automatically learned and used for threat detection!

---

## 🔒 **Important Notes**

1. **File Must Be Shareable**: Set Google Drive file to "Anyone with the link"
2. **Supported Formats**: PDF, DOCX, TXT, CSV, JSON
3. **File Size**: Large files may take time to download
4. **Storage**: Files are downloaded to `backend/ml-service/downloads/`

---

## 🚨 **Troubleshooting**

### **"Could not extract file ID"**
- Make sure the link is a valid Google Drive link
- Try using the direct file link format

### **"Failed to download"**
- Check that file is set to "Anyone with the link"
- Verify internet connection
- For very large files, wait longer

### **"File type not supported"**
- Currently supports: PDF, DOCX, TXT, CSV, JSON
- Convert other formats first

---

## 📚 **Full Documentation**

See `DRIVE-LINK-LEARNING-GUIDE.md` for complete API documentation.

---

**Ready to learn! Just provide your Drive links! 🚀**
