const express = require('express');
const http = require('http');
const socketIo = require('socket.io');
const cors = require('cors');
require('dotenv').config();

const app = express();
const server = http.createServer(app);
const io = socketIo(server, {
  cors: {
    origin: "*",
    methods: ["GET", "POST"],
    credentials: true
  },
  transports: ['websocket', 'polling']
});

app.use(cors());
app.use(express.json());

// Health check endpoint
app.get('/health', (req, res) => {
  res.json({ 
    status: 'healthy', 
    timestamp: new Date().toISOString(),
    uptime: process.uptime()
  });
});

// Store rooms
const rooms = new Map();

io.on('connection', (socket) => {
  console.log('Client connected:', socket.id);

  // Streamer joins room
  socket.on('streamer-join', ({ roomId, streamerName }) => {
    console.log(`Streamer ${streamerName} joining room: ${roomId}`);
    
    if (!rooms.has(roomId)) {
      rooms.set(roomId, { streamers: new Map(), viewers: new Set() });
    }
    
    const room = rooms.get(roomId);
    room.streamers.set(socket.id, { name: streamerName, socketId: socket.id });
    socket.join(roomId);
    socket.data.roomId = roomId;
    socket.data.role = 'streamer';
    
    // Notify viewers
    socket.to(roomId).emit('streamer-joined', {
      streamerId: socket.id,
      streamerName: streamerName,
      totalStreamers: room.streamers.size
    });
    
    socket.emit('streamer-joined-confirm', {
      success: true,
      roomId: roomId,
      streamerId: socket.id
    });
  });

  // Viewer joins room
  socket.on('viewer-join', (roomId) => {
    console.log(`Viewer joining room: ${roomId}`);
    
    if (!rooms.has(roomId)) {
      socket.emit('error', { message: 'Room does not exist' });
      return;
    }
    
    const room = rooms.get(roomId);
    room.viewers.add(socket.id);
    socket.join(roomId);
    socket.data.roomId = roomId;
    socket.data.role = 'viewer';
    
    // Send list of streamers
    const streamersList = Array.from(room.streamers.entries()).map(([id, info]) => ({
      streamerId: id,
      streamerName: info.name
    }));
    
    socket.emit('streamers-list', streamersList);
    socket.emit('viewer-joined-confirm', {
      success: true,
      roomId: roomId,
      streamersCount: streamersList.length
    });
  });

  // WebRTC signaling
  socket.on('offer', ({ target, sdp, streamerId }) => {
    io.to(target).emit('offer', { sdp, streamerId, from: socket.id });
  });

  socket.on('answer', ({ target, sdp, streamerId }) => {
    io.to(target).emit('answer', { sdp, streamerId });
  });

  socket.on('ice-candidate', ({ target, candidate }) => {
    if (target) {
      io.to(target).emit('ice-candidate', { candidate, from: socket.id });
    } else {
      const roomId = socket.data.roomId;
      if (roomId) {
        socket.to(roomId).emit('ice-candidate', { candidate, from: socket.id });
      }
    }
  });

  // Switch stream (for web viewer)
  socket.on('switch-stream', ({ roomId, targetStreamerId }) => {
    socket.to(roomId).emit('stream-switched', { targetStreamerId });
  });

  // Disconnect
  socket.on('disconnect', () => {
    console.log('Client disconnected:', socket.id);
    
    const roomId = socket.data.roomId;
    if (roomId && rooms.has(roomId)) {
      const room = rooms.get(roomId);
      
      if (socket.data.role === 'streamer') {
        room.streamers.delete(socket.id);
        socket.to(roomId).emit('streamer-left', { streamerId: socket.id });
        console.log(`Streamer left room ${roomId}. Remaining: ${room.streamers.size}`);
      } else if (socket.data.role === 'viewer') {
        room.viewers.delete(socket.id);
        socket.to(roomId).emit('viewer-left', { viewerId: socket.id });
      }
      
      // Clean up empty room
      if (room.streamers.size === 0 && room.viewers.size === 0) {
        rooms.delete(roomId);
        console.log(`Room ${roomId} deleted (empty)`);
      }
    }
  });
});

const PORT = process.env.PORT || 3001;
server.listen(PORT, '0.0.0.0', () => {
  console.log(`Signaling server running on port ${PORT}`);
});
