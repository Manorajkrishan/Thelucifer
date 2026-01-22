# 🚀 How to Run SentinelAI X

This guide shows you how to run the entire SentinelAI X project.

## 🐳 Option 1: Using Docker (Recommended - Easiest)

This is the simplest way to run everything at once.

### Prerequisites
1. **Install Docker Desktop**: https://www.docker.com/products/docker-desktop/
2. Start Docker Desktop

### Steps

```powershell
# Navigate to project root
cd E:\Cyberpunck

# Start all services
docker-compose up -d

# View logs
docker-compose logs -f

# Stop all services
docker-compose down
```

This will automatically start:
- ✅ PostgreSQL database
- ✅ Redis cache
- ✅ Neo4j knowledge graph
- ✅ Laravel API (port 8000)
- ✅ Python ML Service (port 5000)
- ✅ Node.js Real-time Service (port 3001)
- ✅ Vue.js Admin Dashboard (port 8080)
- ✅ Next.js Portal (port 3000)
- ✅ ELK Stack (Elasticsearch, Logstash, Kibana)

**Access URLs:**
- API: http://localhost:8000
- Admin Dashboard: http://localhost:8080
- Public Portal: http://localhost:3000
- ML Service: http://localhost:5000
- Real-time Service: http://localhost:3001
- Kibana: http://localhost:5601
- Neo4j Browser: http://localhost:7474

---

## 🖥️ Option 2: Manual Setup (Run Services Individually)

### Prerequisites

1. **PostgreSQL** - Install from https://www.postgresql.org/download/
2. **Redis** - Install from https://redis.io/download or use Docker
3. **Neo4j** - Install from https://neo4j.com/download/ or use Docker

Or run just the databases with Docker:
```powershell
docker run -d --name postgres -p 5432:5432 -e POSTGRES_DB=sentinelai -e POSTGRES_USER=sentinelai_user -e POSTGRES_PASSWORD=sentinelai_password postgres:15
docker run -d --name redis -p 6379:6379 redis:7-alpine
docker run -d --name neo4j -p 7474:7474 -p 7687:7687 -e NEO4J_AUTH=neo4j/sentinelai_password neo4j:5-community
```

### Step-by-Step Manual Setup

#### 1️⃣ Start Databases

**PostgreSQL:**
```powershell
# If installed locally, start the service
# Or use Docker container above
```

**Redis:**
```powershell
# If installed locally
redis-server

# Or use Docker container above
```

**Neo4j:**
```powershell
# If installed locally, start Neo4j Desktop or service
# Or use Docker container above
```

#### 2️⃣ Start Laravel API

```powershell
# Navigate to API directory
cd E:\Cyberpunck\backend\api

# Add Composer to PATH (if needed)
$env:Path = "$env:LOCALAPPDATA\Microsoft\WindowsApps;" + $env:Path

# Set up database (first time only)
C:\php81\php.exe artisan migrate

# Start the server
C:\php81\php.exe artisan serve
```

✅ **API will run on**: http://localhost:8000

#### 3️⃣ Start Python ML Service

```powershell
# Navigate to ML service directory
cd E:\Cyberpunck\backend\ml-service

# Install dependencies (if not already done)
pip install -r requirements.txt

# Start the service
python app.py
```

✅ **ML Service will run on**: http://localhost:5000

#### 4️⃣ Start Node.js Real-time Service

```powershell
# Navigate to real-time service directory
cd E:\Cyberpunck\backend\realtime-service

# Install dependencies (if not already done)
npm install

# Start the service
npm start
```

✅ **Real-time Service will run on**: http://localhost:3001

#### 5️⃣ Start Vue.js Admin Dashboard

```powershell
# Navigate to admin dashboard directory
cd E:\Cyberpunck\frontend\admin-dashboard

# Install dependencies (if not already done)
npm install

# Start development server
npm run dev
```

✅ **Admin Dashboard will run on**: http://localhost:5173

#### 6️⃣ Start Next.js Public Portal

```powershell
# Navigate to portal directory
cd E:\Cyberpunck\frontend\portal

# Install dependencies (if not already done)
npm install

# Start development server
npm run dev
```

✅ **Public Portal will run on**: http://localhost:3000

---

## 🎯 Quick Start Commands

### All Services in Separate Terminals

Open **5 separate terminal windows** and run:

**Terminal 1 - Laravel API:**
```powershell
cd E:\Cyberpunck\backend\api
C:\php81\php.exe artisan serve
```

**Terminal 2 - Python ML Service:**
```powershell
cd E:\Cyberpunck\backend\ml-service
python app.py
```

**Terminal 3 - Node.js Real-time Service:**
```powershell
cd E:\Cyberpunck\backend\realtime-service
npm start
```

**Terminal 4 - Admin Dashboard:**
```powershell
cd E:\Cyberpunck\frontend\admin-dashboard
npm run dev
```

**Terminal 5 - Public Portal:**
```powershell
cd E:\Cyberpunck\frontend\portal
npm run dev
```

---

## ✅ Verification Checklist

After starting services, verify they're running:

### 1. Check Laravel API
```powershell
curl http://localhost:8000
# Should return JSON with API info
```

### 2. Check ML Service
```powershell
curl http://localhost:5000/health
# Should return health status
```

### 3. Check Real-time Service
```powershell
curl http://localhost:3001/health
# Should return health status
```

### 4. Check Admin Dashboard
Open browser: http://localhost:5173

### 5. Check Public Portal
Open browser: http://localhost:3000

---

## 🔧 Configuration Files

Before running, ensure these are configured:

### Laravel API (.env)
- `backend/api/.env` - Database, Redis, Neo4j settings

### Python ML Service
- `backend/ml-service/.env` (create if needed)
  - `REDIS_HOST=127.0.0.1`
  - `POSTGRES_HOST=127.0.0.1`
  - `NEO4J_URI=bolt://127.0.0.1:7687`

### Node.js Real-time Service
- `backend/realtime-service/.env` (create if needed)
  - `REDIS_HOST=127.0.0.1`
  - `API_URL=http://localhost:8000`
  - `ML_SERVICE_URL=http://localhost:5000`

---

## 🐛 Troubleshooting

### Port Already in Use

If a port is already in use, change it:

**Laravel API:**
```powershell
C:\php81\php.exe artisan serve --port=8001
```

**ML Service:**
Edit `backend/ml-service/app.py` and change port

**Real-time Service:**
Edit `backend/realtime-service/server.js` PORT variable

### Database Connection Issues

Check your `.env` files match your database setup:
- PostgreSQL: `DB_HOST`, `DB_PORT`, `DB_DATABASE`, `DB_USERNAME`, `DB_PASSWORD`
- Redis: `REDIS_HOST`, `REDIS_PORT`
- Neo4j: `NEO4J_URI`, `NEO4J_USER`, `NEO4J_PASSWORD`

### Missing Dependencies

**Laravel:**
```powershell
cd backend\api
composer install
```

**Python:**
```powershell
cd backend\ml-service
pip install -r requirements.txt
```

**Node.js:**
```powershell
cd backend\realtime-service
npm install

cd ..\..\frontend\admin-dashboard
npm install

cd ..\portal
npm install
```

---

## 📊 Service Dependencies

Services depend on each other in this order:

1. **Databases** (PostgreSQL, Redis, Neo4j) ← Must start first
2. **Laravel API** ← Depends on databases
3. **Python ML Service** ← Depends on databases
4. **Node.js Real-time Service** ← Depends on API and databases
5. **Frontend Apps** ← Depend on API and real-time service

---

## 🎉 Summary

**Easiest Method**: Use Docker Compose
```powershell
docker-compose up -d
```

**Manual Method**: Start each service in separate terminals in dependency order.

**Default Ports:**
- Laravel API: 8000
- ML Service: 5000
- Real-time Service: 3001
- Admin Dashboard: 5173
- Public Portal: 3000

---

**Ready to go!** 🚀
