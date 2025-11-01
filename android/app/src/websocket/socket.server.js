const socketIO = require('socket.io');
const logger = require('../utils/logger.util');

let io;

/**
 * Initialize Socket.IO server
 */
const initializeSocket = (server) => {
  io = socketIO(server, {
    cors: {
      origin: process.env.ALLOWED_ORIGINS?.split(',') || '*',
      credentials: true,
    },
  });

  io.on('connection', (socket) => {
    logger.info(`New socket connection: ${socket.id}`);

    // Join emergency room
    socket.on('join_emergency', (emergencyId) => {
      socket.join(`emergency_${emergencyId}`);
      logger.info(`Socket ${socket.id} joined emergency_${emergencyId}`);
    });

    // Leave emergency room
    socket.on('leave_emergency', (emergencyId) => {
      socket.leave(`emergency_${emergencyId}`);
      logger.info(`Socket ${socket.id} left emergency_${emergencyId}`);
    });

    // Join user room for notifications
    socket.on('join_user', (userId) => {
      socket.join(`user_${userId}`);
      logger.info(`Socket ${socket.id} joined user_${userId}`);
    });

    // Join ambulance tracking room
    socket.on('join_ambulance', (ambulanceId) => {
      socket.join(`ambulance_${ambulanceId}`);
      logger.info(`Socket ${socket.id} joined ambulance_${ambulanceId}`);
    });

    // Handle disconnection
    socket.on('disconnect', () => {
      logger.info(`Socket disconnected: ${socket.id}`);
    });
  });

  logger.success('✅ WebSocket server initialized');
  return io;
};

/**
 * Get Socket.IO instance
 */
const getIO = () => {
  if (!io) {
    throw new Error('Socket.IO not initialized');
  }
  return io;
};

/**
 * Emit emergency update to room
 */
const emitEmergencyUpdate = (emergencyId, data) => {
  if (io) {
    io.to(`emergency_${emergencyId}`).emit('emergency_update', data);
  }
};

/**
 * Emit ambulance location update
 */
const emitAmbulanceLocation = (ambulanceId, location) => {
  if (io) {
    io.to(`ambulance_${ambulanceId}`).emit('ambulance_location', location);
  }
};

/**
 * Emit notification to user
 */
const emitNotification = (userId, notification) => {
  if (io) {
    io.to(`user_${userId}`).emit('notification', notification);
  }
};

module.exports = {
  initializeSocket,
  getIO,
  emitEmergencyUpdate,
  emitAmbulanceLocation,
  emitNotification,
};