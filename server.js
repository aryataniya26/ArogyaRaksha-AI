require('dotenv').config();
const http = require('http');
const app = require('./src/app');
const { initializeSocket } = require('./src/websocket/socket.server');
const logger = require('./src/utils/logger.util');

// Configuration
const PORT = process.env.PORT || 5000;
const NODE_ENV = process.env.NODE_ENV || 'development';

// Create HTTP server
const server = http.createServer(app);

// Initialize WebSocket
const io = initializeSocket(server);

// Global socket instance for use in controllers
global.io = io;

// Start server
server.listen(PORT, () => {
  logger.info(`
  ╔════════════════════════════════════════════════╗
  ║   ArogyaRaksha AI Backend Server Started      ║
  ╠════════════════════════════════════════════════╣
  ║   Environment: ${NODE_ENV.padEnd(32)}║
  ║   Port: ${PORT.toString().padEnd(37)}║
  ║   URL: http://localhost:${PORT.toString().padEnd(24)}║
  ║   WebSocket: Enabled                          ║
  ╚════════════════════════════════════════════════╝
  `);
});

// Graceful shutdown
process.on('SIGTERM', () => {
  logger.info('SIGTERM received. Closing HTTP server...');
  server.close(() => {
    logger.info('HTTP server closed');
    process.exit(0);
  });
});

process.on('SIGINT', () => {
  logger.info('SIGINT received. Closing HTTP server...');
  server.close(() => {
    logger.info('HTTP server closed');
    process.exit(0);
  });
});

// Handle uncaught exceptions
process.on('uncaughtException', (error) => {
  logger.error('Uncaught Exception:', error);
  process.exit(1);
});

// Handle unhandled promise rejections
process.on('unhandledRejection', (reason, promise) => {
  logger.error('Unhandled Rejection at:', promise, 'reason:', reason);
  process.exit(1);
});

module.exports = server;