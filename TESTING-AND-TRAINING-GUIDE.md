# 🧪 Testing & Training Guide - SentinelAI X

## 📋 **Quick Commands**

### **1. Check System Status**
```powershell
.\CHECK-SYSTEM.ps1
```
Verifies all services, database, authentication, and endpoints are working.

### **2. Run All Tests**
```powershell
.\RUN-TESTS.ps1
```
Runs comprehensive test suite covering:
- Service availability
- Authentication
- Documents API
- Threats API
- ML Service
- Database connectivity

### **3. Train ML Models**
```powershell
.\TRAIN-MODELS.ps1
```
Trains machine learning models using cybersecurity datasets.

---

## 🧪 **Detailed Testing**

### **Manual Testing**

#### **Test Documents API:**
```powershell
# Login first
$loginBody = @{email="admin@sentinelai.com";password="admin123"} | ConvertTo-Json
$response = Invoke-RestMethod -Uri "http://localhost:8000/api/login" -Method POST -Body $loginBody -ContentType "application/json"
$token = $response.token

# List documents
$headers = @{Authorization = "Bearer $token"}
Invoke-RestMethod -Uri "http://localhost:8000/api/documents" -Method GET -Headers $headers

# Create document (Drive download style)
$docBody = @{
    title = "Test Document"
    filename = "test.pdf"
    file_path = "downloaded/test.pdf"
    file_type = "pdf"
    file_size = 1024
    status = "processed"
    metadata = @{source = "test"}
} | ConvertTo-Json

Invoke-RestMethod -Uri "http://localhost:8000/api/documents" -Method POST -Headers $headers -Body $docBody -ContentType "application/json"
```

#### **Test ML Service:**
```powershell
# Health check
Invoke-RestMethod -Uri "http://localhost:5000/health" -Method GET

# Learning summary
Invoke-RestMethod -Uri "http://localhost:5000/api/v1/learning/summary" -Method GET

# Threat detection
$detectionBody = @{
    source_ip = "192.168.1.100"
    attack_type = "SQL Injection"
    payload = "SELECT * FROM users"
} | ConvertTo-Json

Invoke-RestMethod -Uri "http://localhost:5000/api/v1/threats/detect" -Method POST -Body $detectionBody -ContentType "application/json"
```

---

## 🎓 **Model Training**

### **Available Datasets**

1. **CICIDS2017** - Comprehensive intrusion detection dataset
2. **UNSW-NB15** - Network-based intrusion detection
3. **NSL-KDD** - Improved KDD dataset
4. **EMBER** - Malware detection dataset

### **Training Process**

#### **1. Train Threat Detection Model:**
```powershell
$trainBody = @{
    model_type = "threat_detector"
    dataset = "CICIDS2017"
    epochs = 10
    batch_size = 32
    validation_split = 0.2
} | ConvertTo-Json

Invoke-RestMethod -Uri "http://localhost:5000/api/v1/training/train" -Method POST -Body $trainBody -ContentType "application/json"
```

#### **2. Train Document Processor:**
```powershell
$trainBody = @{
    model_type = "document_processor"
    documents = @()  # Empty = use existing processed documents
    epochs = 5
} | ConvertTo-Json

Invoke-RestMethod -Uri "http://localhost:5000/api/v1/training/train" -Method POST -Body $trainBody -ContentType "application/json"
```

### **Download Datasets:**
```powershell
$datasetBody = @{dataset_id = "CICIDS2017"} | ConvertTo-Json
Invoke-RestMethod -Uri "http://localhost:5000/api/v1/datasets/download" -Method POST -Body $datasetBody -ContentType "application/json"
```

---

## ✅ **Verification Checklist**

After running tests, verify:

- [ ] All services are running
- [ ] Database connection works
- [ ] Authentication works
- [ ] Documents API works (list, create, delete)
- [ ] Threats API works (list, create, statistics)
- [ ] ML Service responds to health check
- [ ] Learning summary is accessible
- [ ] Threat detection works
- [ ] Models can be trained
- [ ] Datasets can be downloaded

---

## 🐛 **Troubleshooting**

### **Tests Fail:**

1. **Service Not Running:**
   ```powershell
   # Start all services
   .\START-ALL-SERVICES.ps1
   ```

2. **Database Issues:**
   ```powershell
   cd backend\api
   C:\php81\php.exe artisan migrate
   ```

3. **Authentication Fails:**
   - Check if user exists: `C:\php81\php.exe artisan tinker`
   - Run: `\App\Models\User::where('email', 'admin@sentinelai.com')->first()`
   - If missing, run: `C:\php81\php.exe artisan db:seed`

### **Training Fails:**

1. **Dataset Not Found:**
   - Download dataset first using dataset manager
   - Or provide full path to dataset file

2. **ML Service Not Running:**
   ```powershell
   cd backend\ml-service
   python app.py
   ```

3. **Memory Issues:**
   - Reduce batch_size
   - Use smaller dataset
   - Train on subset of data

---

## 📊 **Test Results**

After running `.\RUN-TESTS.ps1`, you'll see:

```
Test Summary
========================================

Services:
  Passed: 4/4

Auth:
  Passed: 2/2

Documents:
  Passed: 3/3

Threats:
  Passed: 3/3

ML Service:
  Passed: 3/3

Database:
  Passed: 1/1

Overall: 16/16 tests passed
```

---

## 🚀 **Quick Start**

1. **Check everything is working:**
   ```powershell
   .\CHECK-SYSTEM.ps1
   ```

2. **Run all tests:**
   ```powershell
   .\RUN-TESTS.ps1
   ```

3. **Train models:**
   ```powershell
   .\TRAIN-MODELS.ps1
   ```

4. **Start using the system!**

---

**All scripts are ready to use!** 🎉
