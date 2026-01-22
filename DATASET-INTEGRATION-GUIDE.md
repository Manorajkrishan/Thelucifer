# 📊 Dataset Integration & Self-Learning Guide

## 🎯 Overview

SentinelAI X now supports:
- ✅ **Self-Learning Engine** - Continuously learns from new data
- ✅ **Dataset Integration** - Train on popular cybersecurity datasets
- ✅ **Hybrid Learning** - Combines document + dataset + threat learning
- ✅ **Continuous Improvement** - Models improve over time

---

## 📚 Available Datasets

### **1. CICIDS2017** (Recommended)
- **Size**: 2.8 GB
- **URL**: https://www.unb.ca/cic/datasets/ids-2017.html
- **Features**: Network traffic, DDoS, Port Scan, Brute Force attacks
- **Use Case**: Network intrusion detection

### **2. UNSW-NB15**
- **Size**: 1.5 GB
- **URL**: https://www.unsw.adfa.edu.au/unsw-canberra-cyber/cybersecurity/ADFA-NB15-Datasets/
- **Features**: 9 attack categories, network features
- **Use Case**: Multi-class attack classification

### **3. NSL-KDD**
- **Size**: 100 MB
- **URL**: https://www.kaggle.com/datasets/hassan06/nslkdd
- **Features**: Improved KDD Cup 1999 dataset
- **Use Case**: Baseline comparison

### **4. EMBER**
- **Size**: 1 GB
- **URL**: https://github.com/elastic/ember
- **Features**: Malware static features
- **Use Case**: Malware detection

---

## 🚀 Quick Start

### **1. List Available Datasets**

```bash
curl http://localhost:5000/api/v1/datasets?type=available
```

### **2. Add a Custom Dataset**

```bash
curl -X POST http://localhost:5000/api/v1/datasets \
  -H "Content-Type: application/json" \
  -d '{
    "action": "add",
    "dataset_id": "my_dataset",
    "file_path": "/path/to/dataset.csv",
    "metadata": {
      "name": "My Custom Dataset",
      "description": "Custom cybersecurity dataset",
      "format": "csv"
    }
  }'
```

### **3. Train from Dataset**

```bash
curl -X POST http://localhost:5000/api/v1/learning/learn \
  -H "Content-Type: application/json" \
  -d '{
    "type": "dataset",
    "dataset_path": "/path/to/cicids2017.csv",
    "dataset_type": "cicids2017"
  }'
```

### **4. Hybrid Learning (All Sources)**

```bash
curl -X POST http://localhost:5000/api/v1/learning/learn \
  -H "Content-Type: application/json" \
  -d '{
    "type": "hybrid",
    "datasets": ["/path/to/dataset1.csv"],
    "threats": [{"classification": "malware", "network": {...}}],
    "documents": [{"attack_techniques": [...]}]
  }'
```

---

## 📖 API Endpoints

### **Self-Learning**

**POST** `/api/v1/learning/learn`

Learn from datasets, threats, or documents.

**Request Body:**
```json
{
  "type": "dataset|threats|documents|hybrid",
  "dataset_path": "/path/to/dataset.csv",
  "dataset_type": "cicids2017|unsw-nb15|auto",
  "threats": [...],
  "documents": [...]
}
```

**Response:**
```json
{
  "success": true,
  "result": {
    "accuracy": 0.95,
    "samples_processed": 10000,
    "training_results": {...}
  }
}
```

### **Dataset Manager**

**GET** `/api/v1/datasets?type=available|downloaded`

List available or downloaded datasets.

**POST** `/api/v1/datasets`

Download or add a dataset.

**Request Body:**
```json
{
  "action": "download|add",
  "dataset_id": "cicids2017",
  "url": "https://...",
  "file_path": "/path/to/dataset.csv",
  "metadata": {...}
}
```

---

## 🔄 Self-Learning Workflow

### **Step 1: Download Dataset**
```python
# Using Python
from services.dataset_manager import DatasetManager

dm = DatasetManager()
result = dm.download_dataset('cicids2017', url='https://...')
```

### **Step 2: Train Model**
```python
from services.self_learning_engine import SelfLearningEngine

engine = SelfLearningEngine()
result = engine.learn_from_dataset('/path/to/cicids2017.csv', 'cicids2017')
print(f"Accuracy: {result['training_results']['accuracy']:.2%}")
```

### **Step 3: Continuous Learning**
```python
# Learn from new threats
threats = [
    {'classification': 'malware', 'network': {...}},
    {'classification': 'trojan', 'behavior': {...}}
]
result = engine.learn_from_threats(threats)
```

### **Step 4: Hybrid Learning**
```python
# Combine all sources
result = engine.hybrid_learn(
    datasets=['/path/to/dataset1.csv'],
    threats=[...],
    documents=[...]
)
```

---

## 🧠 How Self-Learning Works

1. **Dataset Learning**
   - Loads cybersecurity datasets
   - Extracts features automatically
   - Trains ML models (Random Forest, Gradient Boosting)
   - Saves trained models

2. **Threat Learning**
   - Learns from real threat incidents
   - Incremental model updates
   - Adapts to new attack patterns

3. **Document Learning**
   - Extracts attack patterns from documents
   - Updates knowledge base
   - Enhances rule-based detection

4. **Hybrid Learning**
   - Combines all learning sources
   - Ensemble models
   - Best of all approaches

---

## 📊 Model Performance

Models are automatically evaluated and the best one is selected:
- **Accuracy**: Overall correctness
- **Precision**: True positives / (True positives + False positives)
- **Recall**: True positives / (True positives + False negatives)
- **F1 Score**: Harmonic mean of precision and recall

---

## 🔧 Configuration

Models are saved in `backend/ml-service/models/`:
- `random_forest_v1.0.0.pkl`
- `gradient_boosting_v1.0.0.pkl`
- `scaler_v1.0.0.pkl`

Datasets are stored in `backend/ml-service/datasets/`:
- `cicids2017/`
- `unsw-nb15/`
- `custom_datasets/`

---

## 🎯 Next Steps

1. **Download CICIDS2017 dataset**
2. **Train initial model**
3. **Set up continuous learning from threats**
4. **Monitor model performance**
5. **Retrain periodically**

---

**Status**: Self-learning and dataset integration ready! 🚀
