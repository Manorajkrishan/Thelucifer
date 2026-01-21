# SentinelAI X Architecture

## System Overview

SentinelAI X is a microservices-based architecture designed for autonomous cyber defense. The system consists of multiple interconnected services that work together to detect, analyze, and respond to cyber threats.

## Architecture Diagram

```
┌─────────────────────────────────────────────────────────────┐
│                     Frontend Layer                           │
├─────────────────────────────────────────────────────────────┤
│  Vue.js Admin Dashboard  │  Next.js Public Portal           │
└─────────────────────────────────────────────────────────────┘
                            │
                            ▼
┌─────────────────────────────────────────────────────────────┐
│                     API Gateway Layer                        │
├─────────────────────────────────────────────────────────────┤
│              Laravel API (Core API & Business Logic)        │
└─────────────────────────────────────────────────────────────┘
                            │
        ┌───────────────────┼───────────────────┐
        │                   │                   │
        ▼                   ▼                   ▼
┌──────────────┐   ┌──────────────┐   ┌──────────────┐
│  Python ML   │   │  Node.js     │   │  PostgreSQL  │
│  Service     │   │  Real-time   │   │  Database    │
│              │   │  Service     │   │              │
└──────────────┘   └──────────────┘   └──────────────┘
        │                   │                   │
        └───────────────────┼───────────────────┘
                            │
        ┌───────────────────┼───────────────────┐
        │                   │                   │
        ▼                   ▼                   ▼
┌──────────────┐   ┌──────────────┐   ┌──────────────┐
│    Redis     │   │    Neo4j     │   │ Elasticsearch│
│    Cache     │   │  Knowledge   │   │    (ELK)     │
│              │   │    Graph     │   │              │
└──────────────┘   └──────────────┘   └──────────────┘
```

## Core Components

### 1. Laravel API (`backend/api`)
- **Purpose**: Core API and business logic layer
- **Responsibilities**:
  - RESTful API endpoints
  - Authentication and authorization
  - Data validation and business rules
  - Database operations
  - Integration with ML service

### 2. Python ML Service (`backend/ml-service`)
- **Purpose**: AI/ML engine for document learning, threat detection, and simulation
- **Responsibilities**:
  - Document processing and NLP
  - Threat detection using ML models
  - Cyber-offensive simulation (sandboxed)
  - Knowledge graph management
  - Behavioral analysis

### 3. Node.js Real-time Service (`backend/realtime-service`)
- **Purpose**: WebSocket server for real-time monitoring
- **Responsibilities**:
  - WebSocket connections
  - Real-time threat alerts
  - Live monitoring dashboard updates
  - Redis pub/sub integration

### 4. Vue.js Admin Dashboard (`frontend/admin-dashboard`)
- **Purpose**: Administrative interface
- **Features**:
  - Threat management
  - Document upload and processing
  - Incident management
  - Simulation controls
  - System monitoring

### 5. Next.js Public Portal (`frontend/portal`)
- **Purpose**: Public-facing portal and API gateway
- **Features**:
  - Public documentation
  - API documentation
  - Public dashboards
  - Landing page

## Data Flow

### Threat Detection Flow

1. **Data Ingestion**: Network traffic, system logs, and security events are collected
2. **Preprocessing**: Data is normalized and features are extracted
3. **ML Detection**: Python ML service analyzes data using ML models
4. **Threat Classification**: Threats are classified (malware, trojan, ransomware, etc.)
5. **Alert Generation**: Real-time alerts are sent via WebSocket
6. **Database Storage**: Threats are stored in PostgreSQL
7. **Knowledge Graph**: Related knowledge is stored in Neo4j
8. **Dashboard Update**: Admin dashboard is updated in real-time

### Document Learning Flow

1. **Document Upload**: User uploads cybersecurity document (PDF, DOCX, TXT)
2. **API Reception**: Laravel API receives and stores document
3. **ML Processing**: Python ML service processes document using NLP
4. **Knowledge Extraction**: Attack techniques, exploit patterns, and defense strategies are extracted
5. **Knowledge Graph**: Extracted knowledge is stored in Neo4j
6. **Database Update**: Knowledge entries are stored in PostgreSQL
7. **Dashboard Display**: Results are displayed in admin dashboard

### Simulation Flow

1. **Simulation Request**: User requests cyber-offensive simulation
2. **Sandbox Creation**: Virtual sandbox environment is created
3. **Attacker Behavior**: Attacker behavior is simulated
4. **Defensive Modeling**: Counter-offensive strategies are modeled
5. **Effectiveness Evaluation**: Defensive strategies are evaluated
6. **Recommendations**: Recommendations are generated
7. **Results Storage**: Simulation results are stored

## Database Schema

### PostgreSQL (Main Database)
- `users` - User accounts
- `threats` - Detected threats
- `documents` - Uploaded documents
- `knowledge_entries` - Extracted knowledge
- `incidents` - Security incidents
- `threat_actions` - Actions taken on threats
- `incident_responses` - Incident response records

### Neo4j (Knowledge Graph)
- `Document` nodes - Cybersecurity documents
- `AttackTechnique` nodes - Attack techniques
- `ExploitPattern` nodes - Exploit patterns (CVE, etc.)
- `DefenseStrategy` nodes - Defense strategies
- `ThreatPattern` nodes - Threat patterns
- Relationships: `DESCRIBES`, `CONTAINS`, `RECOMMENDS`, `COUNTERS`, `USES`

### Redis (Cache)
- Session storage
- Real-time event pub/sub
- Caching frequently accessed data

### Elasticsearch (Logging)
- Threat logs
- Incident logs
- System logs
- Accessible via Kibana dashboard

## Security Considerations

1. **Authentication**: JWT tokens via Laravel Sanctum
2. **Authorization**: Role-based access control
3. **Data Encryption**: Data encrypted at rest and in transit
4. **Sandboxing**: All offensive simulations in isolated environments
5. **Audit Logging**: All actions are logged
6. **Input Validation**: All inputs are validated and sanitized

## Scalability

- **Horizontal Scaling**: Services can be scaled independently
- **Load Balancing**: Nginx/HAProxy for frontend load balancing
- **Database Replication**: PostgreSQL master-slave replication
- **Caching Strategy**: Redis for distributed caching
- **Message Queues**: Redis for async job processing

## Deployment

The system is designed for containerized deployment using Docker and Docker Compose. Each service runs in its own container, allowing for independent scaling and updates.

## Monitoring

- **Health Checks**: Each service exposes health check endpoints
- **Logging**: Centralized logging via ELK stack
- **Metrics**: System metrics collection (can be integrated with Prometheus)
- **Alerting**: Real-time alerts via WebSocket and email
