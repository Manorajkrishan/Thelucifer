# 🛡️ Real-Time Attack Detection & Auto-Response System

## Overview

SentinelAI X now includes a **Real-Time Monitoring System** that continuously watches for attacks from:
- 🌐 **Network** (suspicious IPs, port scanning, connection spikes)
- 💾 **USB Devices** (unauthorized USB attacks, BadUSB)
- ⚙️ **System Behavior** (CPU/memory spikes, bandwidth anomalies)
- 📊 **Processes** (suspicious executables like metasploit, mimikatz)

When an attack is detected, the system **AUTOMATICALLY**:
1. ✅ **DETECTS** the threat using AI-powered analysis
2. 🛡️ **NEUTRALIZES** the attack (blocks IP, disables USB, kills process)
3. ⚔️ **COUNTER-ATTACKS** critical threats (SIMULATED)

---

## 🚀 Quick Start

### Start Real-Time Monitoring

```powershell
.\START-REALTIME-MONITORING.ps1
```

This will:
- Check if ML service is running
- Display current monitoring status
- Start the real-time monitor
- Show live statistics

### Using API Endpoints

#### Start Monitoring
```bash
curl -X POST http://localhost:5000/api/v1/monitor/start
```

**Response:**
```json
{
  "success": true,
  "message": "Real-time monitoring started",
  "monitoring": true,
  "started_at": "2024-01-21T12:00:00"
}
```

#### Check Status
```bash
curl http://localhost:5000/api/v1/monitor/status
```

**Response:**
```json
{
  "monitoring": true,
  "stats": {
    "attacks_detected": 15,
    "attacks_neutralized": 12,
    "counter_offensives_executed": 3,
    "start_time": "2024-01-21T12:00:00",
    "last_detection": "2024-01-21T12:05:30"
  },
  "uptime": "0:05:30",
  "thresholds": {
    "connection_spike": 50,
    "suspicious_ports": [4444, 4445, 5555, 31337, 8080, 1337],
    "bandwidth_spike": 1000000,
    "failed_auth_attempts": 5,
    "privilege_escalation_attempts": 1
  },
  "whitelist": ["127.0.0.1", "localhost", "::1"]
}
```

#### Stop Monitoring
```bash
curl -X POST http://localhost:5000/api/v1/monitor/stop
```

---

## 🔍 What Gets Monitored

### 1. Network Attacks

**Detects:**
- Connection spikes (>50 connections/min from single IP)
- Suspicious port connections (4444, 4445, 5555, 31337, 8080, 1337)
- DDoS attempts
- Port scanning

**Auto-Response:**
- Blocks malicious IP (SIMULATED)
- Drops active connections
- Counter-attacks critical threats

### 2. USB Attacks

**Detects:**
- Unauthorized USB device connections
- BadUSB attacks
- Malicious flash drives

**Auto-Response:**
- Disables USB device (SIMULATED)
- Quarantines connected files
- Alerts security team

### 3. System Behavior Anomalies

**Detects:**
- CPU usage spikes (>90%)
- Memory usage spikes (>90%)
- Network bandwidth spikes (>1MB/s)
- Unusual system behavior

**Auto-Response:**
- Identifies source process
- Terminates malicious processes
- Throttles bandwidth if needed

### 4. Process-Level Threats

**Detects:**
- Suspicious executables:
  - `metasploit`, `msfconsole`, `msfvenom`
  - `mimikatz`
  - `psexec`
  - `nc`, `ncat` (netcat)
  - Other hacking tools

**Auto-Response:**
- Terminates malicious process (SIMULATED)
- Quarantines executable
- Creates forensic snapshot

---

## ⚔️ Auto Counter-Offensive

When a **CRITICAL** threat is detected, the system automatically:

### 1. Profiles the Attacker
- Traces network routes
- Identifies attack toolkit (Metasploit, Cobalt Strike, etc.)
- Creates threat fingerprint
- Assigns threat level

### 2. Validates Target
- Ensures it's not a proxy/VPN
- Verifies it's an active attack
- Checks whitelist
- Confirms malicious intent

### 3. Executes Counter-Offensive (SIMULATED)
- **Network Saturation** - DDoS-style traffic flood
- **Malware Deployment** - Backdoor to attacker's system
- **Data Destruction** - Wipes attacker's tools/data
- **Infrastructure Sabotage** - Disables attacker systems
- **Psychological Impact** - Deterrent warnings

**ALL COUNTER-OFFENSIVE ACTIONS ARE SIMULATED - NO REAL ATTACKS**

---

## 📊 Detection Flow

```
Monitoring Loop (Every 5 seconds)
    ↓
[Network Check] → Suspicious? → THREAT DETECTED
[USB Check]     → Suspicious? → THREAT DETECTED
[System Check]  → Suspicious? → THREAT DETECTED
[Process Check] → Suspicious? → THREAT DETECTED
    ↓
THREAT DETECTED
    ↓
Neutralize Immediately
    ├── Block IP / Disable USB / Kill Process
    └── Update Statistics
    ↓
If Critical Threat:
    ↓
Profile Attacker → Validate Target → Counter-Offensive
```

---

## 🛡️ Safety Features

1. **Whitelist Protection** - Never attacks whitelisted IPs (localhost, etc.)
2. **Deduplication** - Ignores duplicate attacks within 60 seconds
3. **Severity-Based Response** - Only counter-attacks critical threats
4. **Simulation Mode** - All counter-offensive actions are simulated
5. **Audit Logging** - All actions are logged
6. **Manual Override** - Can be stopped at any time

---

## ⚙️ Configuration

### Thresholds (Configurable)

```python
thresholds = {
    'connection_spike': 50,       # Max connections per minute
    'suspicious_ports': [4444, 4445, 5555, 31337, 8080, 1337],
    'bandwidth_spike': 1000000,   # Bytes per second
    'failed_auth_attempts': 5,
    'privilege_escalation_attempts': 1
}
```

### Whitelist (Never Counter-Attack These)

```python
whitelist = ['127.0.0.1', 'localhost', '::1']
```

You can modify these in `backend/ml-service/services/real_time_monitor.py`.

---

## 📈 Example Output

```
[12:05:30] Detected: 15 | Neutralized: 12 | Counter-Attacked: 3
  Last detection: 2024-01-21T12:05:30

[12:05:40] Detected: 16 | Neutralized: 13 | Counter-Attacked: 3
  Last detection: 2024-01-21T12:05:35

THREAT DETECTED: Connection spike from 192.168.1.100: 75 connections
NEUTRALIZING: Blocking IP 192.168.1.100 (SIMULATED)
THREAT NEUTRALIZED

COUNTER-OFFENSIVE EXECUTED: Attack from 192.168.1.100
  Warning: THIS IS A SIMULATION - NO ACTUAL ATTACKS WERE EXECUTED
```

---

## 🧪 Testing the System

### Simulate a Network Attack

1. Start the monitor:
   ```powershell
   .\START-REALTIME-MONITORING.ps1
   ```

2. The system will detect real network anomalies automatically

3. Watch the statistics update in real-time

### Simulate Custom Attack Data

Use the counter-offensive API directly:

```bash
curl -X POST http://localhost:5000/api/v1/counter-offensive/execute \
  -H "Content-Type: application/json" \
  -d '{
    "attack_data": {
      "network": {
        "source_ip": "192.168.1.100",
        "destination_ip": "10.0.0.1",
        "connection_count": 150,
        "is_proxy": false,
        "is_vpn": false
      },
      "behavior": {
        "privilege_escalation": 1,
        "suspicious_file_access": 25,
        "unusual_network_activity": 10,
        "persistence": true
      },
      "timestamp": "2024-01-21T12:00:00Z",
      "is_active": true
    }
  }'
```

---

## 🔗 Integration

The real-time monitor integrates with:

- ✅ **Threat Detector** - AI-powered threat detection
- ✅ **Counter-Offensive Engine** - Automated counter-attacks
- ✅ **Attacker Profiler** - Creates threat fingerprints
- ✅ **Target Validator** - Ensures safe counter-offensive
- ✅ **Learning System** - Learns from detected attacks

---

## ⚠️ Important Notes

1. **Educational/Research Only** - This is a simulation system
2. **No Real Attacks** - Counter-offensive actions are simulated
3. **Legal Compliance** - Ensure compliance with local laws
4. **Authorized Use Only** - Use in controlled environments
5. **Resource Usage** - Monitoring uses system resources (CPU, memory)

---

## 📚 See Also

- [COUNTER-OFFENSIVE-SYSTEM.md](COUNTER-OFFENSIVE-SYSTEM.md) - Full counter-offensive documentation
- [PROJECT-IMPLEMENTATION-STATUS.md](PROJECT-IMPLEMENTATION-STATUS.md) - Complete system status
- [TESTING-GUIDE.md](TESTING-GUIDE.md) - Testing procedures

---

**Status:** Real-Time Monitoring System ACTIVE 🛡️

**Remember:** All counter-offensive actions are SIMULATED for safety and legal compliance!
