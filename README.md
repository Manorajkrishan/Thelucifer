# SentinelAI X: Autonomous Cyber Defense and Simulated Counter-Offensive Learning System

## Overview

SentinelAI X is an advanced AI-powered cybersecurity platform designed to autonomously detect, analyze, and neutralize cyber threats while continuously learning from real-world and documented cyberattack patterns. The system integrates document-based learning, real-time behavior analysis, and controlled cyber-offensive simulation to strengthen defensive strategies.

## 🏗️ Architecture

The platform consists of multiple microservices:

- **Laravel API** (`backend/api`) - Core API & Business Logic
- **Python ML Service** (`backend/ml-service`) - AI/ML Engine for document learning, threat detection, and simulation
- **Node.js Real-time Service** (`backend/realtime-service`) - WebSocket server for real-time monitoring
- **Vue.js Admin Dashboard** (`frontend/admin-dashboard`) - Administrative interface
- **Next.js Public Portal** (`frontend/portal`) - Public-facing portal and API gateway

## 🚀 Quick Start

### Prerequisites

- Docker and Docker Compose
- Node.js 18+ (for local development)
- PHP 8.1+ (for local development)
- Python 3.10+ (for local development)

### Installation

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd Cyberpunck
   ```

2. **Set up environment variables**
   ```bash
   cp .env.example .env
   # Edit .env with your configuration
   ```

3. **Start all services with Docker Compose**
   ```bash
   docker-compose up -d
   ```

4. **Initialize Laravel API**
   ```bash
   docker-compose exec api php artisan migrate
   docker-compose exec api php artisan db:seed
   ```

5. **Access the services**
   - API: http://localhost:8000
   - Admin Dashboard: http://localhost:8080
   - Public Portal: http://localhost:3000
   - Kibana: http://localhost:5601
   - Neo4j Browser: http://localhost:7474

## 📁 Project Structure

```
Cyberpunck/
├── backend/
│   ├── api/              # Laravel API
│   ├── ml-service/       # Python ML/AI Service
│   └── realtime-service/ # Node.js Real-time Service
├── frontend/
│   ├── admin-dashboard/  # Vue.js Admin Dashboard
│   └── portal/           # Next.js Public Portal
├── infrastructure/       # Infrastructure configs
│   └── logstash/         # Logstash pipelines
├── docker-compose.yml    # Docker orchestration
└── README.md

```

## 🔧 Development

### Backend API (Laravel)

```bash
cd backend/api
composer install
php artisan migrate
php artisan serve
```

### ML Service (Python)

```bash
cd backend/ml-service
pip install -r requirements.txt
python app.py
```

### Real-time Service (Node.js)

```bash
cd backend/realtime-service
npm install
npm run dev
```

### Admin Dashboard (Vue.js)

```bash
cd frontend/admin-dashboard
npm install
npm run dev
```

### Public Portal (Next.js)

```bash
cd frontend/portal
npm install
npm run dev
```

## 🧪 Testing

Run tests for each service:

```bash
# Laravel API
docker-compose exec api php artisan test

# Python ML Service
docker-compose exec ml-service pytest

# Node.js Service
docker-compose exec realtime-service npm test
```

## 📊 Features

### Core Modules

1. **Data Ingestion Layer** - Collects network traffic, system logs, and security events
2. **Document Learning Engine** - NLP-based extraction from cybersecurity documents
3. **Threat Detection Engine** - ML-based detection of malware, trojans, ransomware, etc.
4. **Attacker Profiling Module** - Identifies and profiles attack sources
5. **Simulation & Counter-Offensive Modeling** - Sandboxed simulation (ethical & legal)
6. **Defense Automation Engine** - Automatic firewall rules, isolation, and remediation
7. **Learning & Adaptation Engine** - Reinforcement learning for continuous improvement
8. **User Interface & Dashboard** - Real-time threat visualization and alerts

## 🔒 Security & Ethics

- **No real-world counter-attacks** - All offensive modeling occurs in sandboxed environments
- **Full compliance** with cybersecurity laws and regulations
- **Transparent audit trails** for all system actions
- **Human-in-the-loop** for critical decisions
- **GDPR compliant** data handling

## 📝 Documentation

- [API Documentation](docs/api.md)
- [Architecture Guide](docs/architecture.md)
- [Deployment Guide](docs/deployment.md)
- [Development Guide](docs/development.md)

## 🤝 Contributing

Please read [CONTRIBUTING.md](CONTRIBUTING.md) for details on our code of conduct and the process for submitting pull requests.

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## ⚠️ Disclaimer

This system is designed for ethical cybersecurity research and defense purposes only. All offensive simulations are performed in controlled, sandboxed environments. Users must comply with all applicable laws and regulations.

## 📧 Contact

For questions or support, please open an issue in the repository.
