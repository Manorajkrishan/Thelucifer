/**
 * SentinelAI X Real-time Service
 * WebSocket server for real-time threat monitoring and alerts
 */

const express = require('express');
const http = require('http');
const crypto = require('crypto');
const { Server } = require('socket.io');
const redis = require('redis');
const axios = require('axios');
require('dotenv').config();

const app = express();
app.use(express.json({ limit: '64kb' }));
const server = http.createServer(app);
const io = new Server(server, {
  cors: {
    origin: (process.env.SOCKET_ALLOWED_ORIGINS || "").split(",").map(x => x.trim()).filter(Boolean),
    methods: ["GET", "POST"]
  }
});

// Redis client
const redisClient = redis.createClient({
  socket: { host: process.env.REDIS_HOST || 'localhost', port: Number(process.env.REDIS_PORT || 6379) }
});

redisClient.on('error', (err) => {
  console.error('Redis Client Error', err);
});

redisClient.connect().catch(console.error);

// API endpoints
const API_URL = process.env.API_URL || 'http://localhost:8000';
const ML_SERVICE_URL = process.env.ML_SERVICE_URL || 'http://localhost:5000';

// Store connected clients
const connectedClients = new Map();

// WebSocket connection handling
io.on('connection', (socket) => {
  console.log(`Client connected: ${socket.id}`);
  connectedClients.set(socket.id, {
    socket,
    userId: null,
    token: null,
    rooms: []
  });

  // Handle authentication
  socket.on('authenticate', async (data) => {
    try {
      // Verify token with API
      const response = await axios.get(`${API_URL}/api/user`, {
        headers: {
          Authorization: `Bearer ${data.token}`
        }
      });

      if (response.data?.user?.id) {
        const client = connectedClients.get(socket.id);
        client.userId = response.data.user.id;
        client.token = data.token;
        client.rooms.push(`user:${client.userId}`);
        
        socket.join(`user:${client.userId}`);
        socket.emit('authenticated', { success: true });
        
        console.log(`Client authenticated: ${socket.id} - User: ${client.userId}`);
      }
    } catch (error) {
      socket.emit('authenticated', { success: false, error: 'Authentication failed' });
      console.error('Authentication error:', error.message);
    }
  });

  // Join room for threat monitoring
  socket.on('join:threats', () => {
    const client = connectedClients.get(socket.id);
    if (!client?.userId) {
      return socket.emit('joined:threats', { success: false, error: 'Authentication required' });
    }
    socket.join('threats');
    if (!client.rooms.includes('threats')) {
      client.rooms.push('threats');
    }
    socket.emit('joined:threats', { success: true });
  });

  // Leave threat room
  socket.on('leave:threats', () => {
    socket.leave('threats');
    const client = connectedClients.get(socket.id);
    client.rooms = client.rooms.filter(room => room !== 'threats');
    socket.emit('left:threats', { success: true });
  });

  // Handle real-time threat detection request
  socket.on('monitor:threats', async (data) => {
    console.log(`Starting threat monitoring for client: ${socket.id}`);
    if (!connectedClients.get(socket.id)?.userId) {
      return socket.emit('threats:error', { error: 'Authentication required' });
    }
    startThreatMonitoring(socket);
  });

  // Handle stop monitoring
  socket.on('stop:monitoring', () => {
    console.log(`Stopping threat monitoring for client: ${socket.id}`);
    // Stop monitoring
    stopThreatMonitoring(socket);
  });

  // Handle disconnect
  socket.on('disconnect', () => {
    console.log(`Client disconnected: ${socket.id}`);
    stopThreatMonitoring(socket);
    connectedClients.delete(socket.id);
  });
});

// Threat monitoring interval storage
const monitoringIntervals = new Map();

function startThreatMonitoring(socket) {
  // Clear existing interval if any
  if (monitoringIntervals.has(socket.id)) {
    clearInterval(monitoringIntervals.get(socket.id));
  }

  // Poll for new threats every 5 seconds
  const interval = setInterval(async () => {
    try {
      // Get latest threats from API
      const token = connectedClients.get(socket.id)?.token;
      if (!token) return stopThreatMonitoring(socket);
      const response = await axios.get(`${API_URL}/api/threats`, {
        headers: { Authorization: `Bearer ${token}` },
        params: {
          per_page: 10,
          status: 'detected'
        }
      });

      if (response.data && response.data.data) {
        const threats = response.data.data.data || response.data.data;
        
        // Emit new threats to client
        socket.emit('threats:update', {
          timestamp: new Date().toISOString(),
          threats: threats
        });

        // Check for critical threats
        const criticalThreats = threats.filter(t => t.severity >= 8);
        if (criticalThreats.length > 0) {
          socket.emit('threats:critical', {
            timestamp: new Date().toISOString(),
            threats: criticalThreats
          });
        }
      }
    } catch (error) {
      console.error('Error monitoring threats:', error.message);
      socket.emit('threats:error', { error: error.message });
    }
  }, 5000); // Poll every 5 seconds

  monitoringIntervals.set(socket.id, interval);
}

function stopThreatMonitoring(socket) {
  if (monitoringIntervals.has(socket.id)) {
    clearInterval(monitoringIntervals.get(socket.id));
    monitoringIntervals.delete(socket.id);
  }
}

// Redis subscriber for real-time events
async function setupRedisSubscriber() {
  const subscriber = redis.createClient({
    socket: { host: process.env.REDIS_HOST || 'localhost', port: Number(process.env.REDIS_PORT || 6379) }
  });

  await subscriber.connect();

  // Subscribe to threat channels
  await subscriber.subscribe('threats:new', (message) => {
    const threat = JSON.parse(message);
    io.to('threats').emit('threat:new', {
      timestamp: new Date().toISOString(),
      threat: threat
    });
  });

  await subscriber.subscribe('threats:updated', (message) => {
    const threat = JSON.parse(message);
    io.to('threats').emit('threat:updated', {
      timestamp: new Date().toISOString(),
      threat: threat
    });
  });

  await subscriber.subscribe('alerts:critical', (message) => {
    const alert = JSON.parse(message);
    io.to('threats').emit('alert:critical', {
      timestamp: new Date().toISOString(),
      alert: alert
    });
  });

  console.log('Redis subscriber setup complete');
}

// Health check endpoint
app.get('/health', (req, res) => {
  res.json({
    status: 'healthy',
    service: 'Real-time Service',
    version: '1.0.0',
    connectedClients: connectedClients.size
  });
});

// API endpoint to trigger real-time threat detection
app.post('/api/threats/detect', async (req, res) => {
  const configured = process.env.ML_INTERNAL_TOKEN || '';
  const supplied = req.get('X-Internal-Token') || '';
  if (!configured || Buffer.byteLength(supplied) !== Buffer.byteLength(configured) ||
      !crypto.timingSafeEqual(Buffer.from(supplied), Buffer.from(configured))) {
    return res.status(401).json({ success: false, error: 'Unauthorized' });
  }
  try {
    const threatData = req.body;

    // Send to ML service for detection
    const mlResponse = await axios.post(`${ML_SERVICE_URL}/api/v1/threats/detect`, threatData, {
      headers: { Authorization: `Bearer ${configured}` }, timeout: 10000
    });

    if (mlResponse.data && mlResponse.data.detection && mlResponse.data.detection.threat_detected) {
      // Broadcast to all connected clients
      io.to('threats').emit('threat:detected', {
        timestamp: new Date().toISOString(),
        detection: mlResponse.data.detection
      });

      // Publish to Redis
      await redisClient.publish('threats:new', JSON.stringify(mlResponse.data.detection));
    }

    res.json({
      success: true,
      detection: mlResponse.data.detection
    });
  } catch (error) {
    console.error('Error detecting threat:', error.message);
    res.status(500).json({
      success: false,
      error: error.message
    });
  }
});

// Start Redis subscriber
setupRedisSubscriber().catch(console.error);

// Start server
const PORT = process.env.PORT || 3001;
server.listen(PORT, () => {
  console.log(`Real-time service running on port ${PORT}`);
  console.log(`WebSocket server ready`);
});
