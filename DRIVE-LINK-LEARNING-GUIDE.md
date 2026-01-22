# 📚 Google Drive Link Learning Guide

## 🎯 Overview

SentinelAI X can now automatically:
- ✅ Download documents from Google Drive links
- ✅ Process and extract knowledge
- ✅ Learn from documents automatically
- ✅ Support multiple links at once
- ✅ Works with any shareable URL

---

## 🚀 Quick Start

### **Single Drive Link**

```bash
curl -X POST http://localhost:5000/api/v1/learning/drive-link \
  -H "Content-Type: application/json" \
  -d '{
    "drive_link": "https://drive.google.com/file/d/YOUR_FILE_ID/view",
    "auto_learn": true
  }'
```

### **Multiple Drive Links**

```bash
curl -X POST http://localhost:5000/api/v1/learning/drive-links \
  -H "Content-Type: application/json" \
  -d '{
    "drive_links": [
      "https://drive.google.com/file/d/FILE_ID_1/view",
      "https://drive.google.com/file/d/FILE_ID_2/view"
    ],
    "auto_learn": true
  }'
```

---

## 📋 Supported Link Formats

### **Google Drive Links**

1. **Direct File Link:**
   ```
   https://drive.google.com/file/d/FILE_ID/view
   ```

2. **Shareable Link:**
   ```
   https://drive.google.com/open?id=FILE_ID
   ```

3. **Any URL:**
   ```
   https://drive.google.com/uc?export=download&id=FILE_ID
   ```

### **Other URLs**

- Direct download links
- Dropbox links
- Any publicly accessible file URL

---

## 🔧 API Endpoints

### **1. Learn from Single Drive Link**

**POST** `/api/v1/learning/drive-link`

**Request:**
```json
{
  "drive_link": "https://drive.google.com/file/d/FILE_ID/view",
  "document_id": "optional_custom_id",
  "auto_learn": true
}
```

**Response:**
```json
{
  "success": true,
  "result": {
    "document_id": "doc_abc123",
    "filename": "cybersecurity_report.pdf",
    "file_path": "/path/to/downloaded/file.pdf",
    "extracted_data": {
      "attack_techniques": 15,
      "exploit_patterns": 8,
      "defense_strategies": 12,
      "keywords": 50,
      "summary": "Document summary..."
    },
    "learning_result": {
      "success": true,
      "patterns_learned": 23,
      "documents_processed": 1
    }
  }
}
```

### **2. Learn from Multiple Links**

**POST** `/api/v1/learning/drive-links`

**Request:**
```json
{
  "drive_links": [
    "https://drive.google.com/file/d/FILE_ID_1/view",
    "https://drive.google.com/file/d/FILE_ID_2/view"
  ],
  "auto_learn": true
}
```

**Response:**
```json
{
  "success": true,
  "result": {
    "successful": [
      {
        "document_id": "doc_abc123",
        "filename": "report1.pdf",
        "learning_result": {...}
      },
      {
        "document_id": "doc_def456",
        "filename": "report2.pdf",
        "learning_result": {...}
      }
    ],
    "failed": [],
    "total": 2,
    "success_count": 2,
    "failure_count": 0,
    "learned_patterns": 46
  }
}
```

### **3. Get Learning Summary**

**GET** `/api/v1/learning/summary`

**Response:**
```json
{
  "success": true,
  "summary": {
    "total_documents": 10,
    "total_patterns_learned": 234,
    "unique_attack_techniques": 45,
    "unique_exploit_patterns": 32,
    "attack_techniques": ["malware", "trojan", "ransomware", ...],
    "exploit_patterns": ["CVE-2023-1234", "CVE-2023-5678", ...]
  }
}
```

---

## 💡 Usage Examples

### **Python Example**

```python
import requests

# Single Drive link
response = requests.post(
    'http://localhost:5000/api/v1/learning/drive-link',
    json={
        'drive_link': 'https://drive.google.com/file/d/YOUR_FILE_ID/view',
        'auto_learn': True
    }
)

result = response.json()
print(f"Learned {result['result']['learning_result']['patterns_learned']} patterns")

# Multiple links
response = requests.post(
    'http://localhost:5000/api/v1/learning/drive-links',
    json={
        'drive_links': [
            'https://drive.google.com/file/d/FILE_ID_1/view',
            'https://drive.google.com/file/d/FILE_ID_2/view',
            'https://drive.google.com/file/d/FILE_ID_3/view'
        ],
        'auto_learn': True
    }
)

result = response.json()
print(f"Processed {result['result']['success_count']} documents")
print(f"Learned {result['result']['learned_patterns']} total patterns")
```

### **JavaScript Example**

```javascript
// Single Drive link
fetch('http://localhost:5000/api/v1/learning/drive-link', {
  method: 'POST',
  headers: { 'Content-Type': 'application/json' },
  body: JSON.stringify({
    drive_link: 'https://drive.google.com/file/d/YOUR_FILE_ID/view',
    auto_learn: true
  })
})
.then(res => res.json())
.then(data => {
  console.log('Learned patterns:', data.result.learning_result.patterns_learned);
});

// Multiple links
fetch('http://localhost:5000/api/v1/learning/drive-links', {
  method: 'POST',
  headers: { 'Content-Type': 'application/json' },
  body: JSON.stringify({
    drive_links: [
      'https://drive.google.com/file/d/FILE_ID_1/view',
      'https://drive.google.com/file/d/FILE_ID_2/view'
    ],
    auto_learn: true
  })
})
.then(res => res.json())
.then(data => {
  console.log('Success:', data.result.success_count);
  console.log('Total patterns:', data.result.learned_patterns);
});
```

---

## 🔍 How It Works

1. **Download**: System downloads document from Drive link
2. **Detect Type**: Automatically detects file type (PDF, DOCX, TXT)
3. **Process**: Extracts text and knowledge
4. **Extract**: Finds attack techniques, exploit patterns, defense strategies
5. **Learn**: Automatically learns from extracted knowledge
6. **Store**: Saves to knowledge graph (Neo4j)

---

## 📝 Supported File Types

- ✅ **PDF** (.pdf)
- ✅ **Word Documents** (.docx, .doc)
- ✅ **Text Files** (.txt, .md)
- ✅ **CSV** (.csv)
- ✅ **JSON** (.json)

---

## ⚙️ Configuration

### **Download Directory**

Documents are downloaded to: `backend/ml-service/downloads/`

### **Auto-Learn**

Set `auto_learn: true` to automatically learn from documents after processing.

### **Custom Document ID**

Provide `document_id` to use a custom identifier instead of auto-generated one.

---

## 🎯 Use Cases

1. **Research Papers**: Share Drive links to cybersecurity research papers
2. **Threat Reports**: Upload threat intelligence reports
3. **Vulnerability Databases**: Process CVE databases
4. **Training Materials**: Learn from security training documents
5. **Incident Reports**: Process security incident documentation

---

## 🔒 Security Notes

- Documents must be **publicly shareable** or use **"Anyone with link"** permission
- For private documents, set up Google Drive API with OAuth
- Downloaded files are stored locally in `downloads/` directory
- Consider cleaning up old downloads periodically

---

## 🚨 Troubleshooting

### **"Could not extract file ID"**
- Ensure the Drive link is in a supported format
- Check that the file is shareable

### **"Failed to download"**
- Verify the file is publicly accessible
- Check internet connection
- For large files, ensure sufficient disk space

### **"File type not supported"**
- Currently supports: PDF, DOCX, TXT, CSV, JSON
- Convert other formats before uploading

---

## 📊 Example Workflow

```bash
# 1. Share your document on Google Drive
# 2. Get the shareable link
# 3. Send to API

curl -X POST http://localhost:5000/api/v1/learning/drive-link \
  -H "Content-Type: application/json" \
  -d '{
    "drive_link": "YOUR_DRIVE_LINK_HERE",
    "auto_learn": true
  }'

# 4. Check learning summary
curl http://localhost:5000/api/v1/learning/summary

# 5. System has now learned from your document!
```

---

**Status**: Ready to learn from Google Drive links! 🚀

Just provide the link and the system will download, process, and learn automatically!
