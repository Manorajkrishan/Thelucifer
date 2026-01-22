# 📚 How to View What the System Has Learned

## 🎯 **Overview**

The SentinelAI X system learns from:
- 📄 Documents (PDF, DOCX, TXT)
- 🔗 Google Drive links
- 🛡️ Threat incidents
- 📊 Cybersecurity datasets

You can view what it has learned in several ways!

---

## 🌐 **Method 1: Learning Page (UI)**

### **Access the Learning Page:**

1. **Go to:** http://localhost:3000/learning
2. **Or click:** "View Learning" from the Dashboard

### **What You'll See:**

#### **📊 Learning Summary:**
- **Total Documents Processed** - How many documents the system has learned from
- **Patterns Learned** - Total patterns extracted
- **Attack Techniques** - Unique attack techniques discovered
- **Exploit Patterns** - Unique exploit patterns identified

#### **🔍 Knowledge Graph Query:**
- Search for specific attack techniques
- Find defense strategies
- Query exploit patterns
- Search by keywords

#### **📋 Attack Techniques:**
- List of all attack techniques in the knowledge graph
- Descriptions and details

#### **🛡️ Defense Strategies:**
- List of defense strategies learned
- Countermeasures and mitigations

---

## 🔧 **Method 2: API Endpoints**

### **1. Get Learning Summary:**

```bash
curl http://localhost:5000/api/v1/learning/summary
```

**Response:**
```json
{
  "success": true,
  "summary": {
    "total_documents": 5,
    "total_patterns_learned": 127,
    "unique_attack_techniques": 23,
    "unique_exploit_patterns": 15,
    "attack_techniques": ["SQL Injection", "XSS", "CSRF", ...],
    "exploit_patterns": ["pattern1", "pattern2", ...]
  }
}
```

### **2. Query Knowledge Graph:**

```bash
curl "http://localhost:5000/api/v1/knowledge/query?query=SQL%20Injection"
```

**Response:**
```json
{
  "success": true,
  "results": [
    {
      "name": "SQL Injection",
      "description": "Attack technique description...",
      "labels": ["AttackTechnique", "Database"]
    }
  ]
}
```

### **3. Get Attack Techniques:**

```bash
curl "http://localhost:5000/api/v1/knowledge/query?query=attack%20technique"
```

### **4. Get Defense Strategies:**

```bash
curl "http://localhost:5000/api/v1/knowledge/query?query=defense%20strategy"
```

---

## 📍 **Where to Find It**

### **In the Portal:**

1. **Dashboard** → Click "View Learning"
2. **Direct URL:** http://localhost:3000/learning
3. **Navigation:** Available in the header menu

### **API Endpoints:**

- **ML Service:** http://localhost:5000/api/v1/learning/summary
- **Knowledge Graph:** http://localhost:5000/api/v1/knowledge/query?query=YOUR_QUERY

---

## 🔄 **Refresh Learning Data**

The learning data updates automatically when:
- ✅ New documents are processed
- ✅ New Drive links are learned from
- ✅ New threats are analyzed
- ✅ New datasets are processed

**To refresh manually:**
- Click the "Refresh" button on the Learning page
- Or reload the page

---

## 💡 **What the System Learns**

### **From Documents:**
- Attack techniques (SQL Injection, XSS, CSRF, etc.)
- Exploit patterns
- Defense strategies
- Security best practices
- Threat intelligence

### **From Threats:**
- Attack patterns
- Attacker behavior
- Network signatures
- Malware characteristics

### **From Datasets:**
- Traffic patterns
- Anomaly signatures
- Classification models
- Feature patterns

---

## 🎯 **Example Queries**

Try searching for:
- `SQL Injection`
- `XSS`
- `defense strategy`
- `exploit pattern`
- `malware`
- `phishing`
- `DDoS`

---

## ✅ **Quick Access**

**From Dashboard:**
1. Go to Dashboard
2. Click "View Learning" card
3. See all learning data!

**Direct URL:**
```
http://localhost:3000/learning
```

---

**You can now easily see what the system has learned!** 🚀
