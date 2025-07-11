// server.js
const express   = require('express');
const session   = require('express-session');
const path      = require('path');
const http      = require('http');
const socketio  = require('socket.io');
const mqtt      = require('mqtt');
const fs        = require('fs');

const app    = express();
const server = http.createServer(app);
const io     = socketio(server);

// --- Paths ---
const publicDir = path.resolve(__dirname, 'public');
const csvFile   = path.join(publicDir, 'activity_history.csv');

// Debug: แสดง folder ที่รัน และ path ไฟล์
console.log('Process cwd:', process.cwd());
console.log('CSV file path:', csvFile);

// Ensure public dir & CSV exist
fs.mkdirSync(publicDir, { recursive: true });
if (!fs.existsSync(csvFile)) {
  fs.writeFileSync(csvFile, 'DateTime,Behavior\n', 'utf8');
  console.log('Initialized CSV with header');
}

// Middleware & Static
app.use(session({ secret: 'secret_key', resave: false, saveUninitialized: true }));
app.use(express.json());
app.use(express.urlencoded({ extended: true }));
app.use(express.static(publicDir));

// Routes
app.get('/', (req, res) => res.redirect('/csi.html'));
app.get('/history.csv', (req, res) => res.sendFile(csvFile));
app.get('/activity_history.csv', (req, res) => res.sendFile(csvFile));

// WebSocket: ส่งไฟล์ CSV ทั้งหมดทีเดียวตอน client connect
io.on('connection', socket => {
  console.log('Client connected:', socket.id);
  fs.readFile(csvFile, 'utf8', (err, data) => {
    if (err) {
      console.error('Error reading CSV on connect:', err);
    } else {
      socket.emit('csv-data', data);
    }
  });
});

// MQTT Setup
const MQTT_BROKER = 'mqtt://broker.emqx.io';
const TOPIC       = 'mn/csi';
const client      = mqtt.connect(MQTT_BROKER, { reconnectPeriod: 5000 });

client.on('connect', () => {
  console.log('MQTT connected to', MQTT_BROKER);
  client.subscribe(TOPIC, { qos: 1 }, err => {
    if (err) console.error('Subscribe error:', err);
    else console.log('Subscribed to', TOPIC);
  });
});

client.on('error', err => {
  console.error('MQTT error:', err);
});

client.on('message', (topic, msgBuffer) => {
  if (topic !== TOPIC) return;

  const raw = msgBuffer.toString();
  console.log('[MQTT] Received:', raw);

  let data;
  try {
    data = JSON.parse(raw);
  } catch {
    console.warn('Invalid JSON, using raw string as behavior');
    data = { behavior: raw };
  }

  // Broadcast real-time update
  io.emit('csi-data', data);

  // Prepare CSV line using server local time (Asia/Bangkok)
  const ts = new Date().toLocaleString('sv-SE', {
    timeZone: 'Asia/Bangkok',
    hour12: false
  }).replace(' ', 'T');  // e.g. "2025-06-23T14:05:30"
  const beh = String(data.behavior).replace(/[\r\n,]/g, '');
  const line = `${ts},${beh}\n`;

  // Synchronous write for reliability
  try {
    fs.appendFileSync(csvFile, line, 'utf8');
    console.log('[CSV] Appended:', line.trim());
    io.emit('csv-update', line);
  } catch (err) {
    console.error('[CSV] Write error:', err);
  }
});

// Start Server
const PORT = process.env.PORT || 3001;
server.listen(PORT, () => {
  console.log(`Server running at http://localhost:${PORT}`);
});
