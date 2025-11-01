const express = require('express');
const cors = require('cors');
const helmet = require('helmet');
const morgan = require('morgan');
const compression = require('compression');
const { errorMiddleware } = require('./middlewares/error.middleware');
const { rateLimiter } = require('./middlewares/rateLimiter.middleware');
const logger = require('./utils/logger.util');

// Import routes
const authRoutes = require('./routes/auth.routes');
const userRoutes = require('./routes/user.routes');
const emergencyRoutes = require('./routes/emergency.routes');
const ambulanceRoutes = require('./routes/ambulance.routes');
const hospitalRoutes = require('./routes/hospital.routes');
const insuranceRoutes = require('./routes/insurance.routes');
const vitalsRoutes = require('./routes/vitals.routes');
const bloodRoutes = require('./routes/blood.routes');
const notificationRoutes = require('./routes/notification.routes');

// Initialize express app
const app = express();

// Security middleware
app.use(helmet());

// CORS configuration
const corsOptions = {
  origin: process.env.ALLOWED_ORIGINS?.split(',') || '*',
  credentials: true,
  optionsSuccessStatus: 200
};
app.use(cors(corsOptions));

// Body parsing middleware
app.use(express.json({ limit: '10mb' }));
app.use(express.urlencoded({ extended: true, limit: '10mb' }));

// Compression middleware
app.use(compression());

// Logging middleware
if (process.env.NODE_ENV === 'development') {
  app.use(morgan('dev'));
} else {
  app.use(morgan('combined'));
}

// Rate limiting
app.use('/api', rateLimiter);

// Health check endpoint
app.get('/health', (req, res) => {
  res.status(200).json({
    status: 'success',
    message: 'ArogyaRaksha Backend is running',
    timestamp: new Date().toISOString(),
    environment: process.env.NODE_ENV
  });
});

// API routes
const API_VERSION = process.env.API_VERSION || 'v1';
app.use(`/api/${API_VERSION}/auth`, authRoutes);
app.use(`/api/${API_VERSION}/user`, userRoutes);
app.use(`/api/${API_VERSION}/emergency`, emergencyRoutes);
app.use(`/api/${API_VERSION}/ambulance`, ambulanceRoutes);
app.use(`/api/${API_VERSION}/hospital`, hospitalRoutes);
app.use(`/api/${API_VERSION}/insurance`, insuranceRoutes);
app.use(`/api/${API_VERSION}/vitals`, vitalsRoutes);
app.use(`/api/${API_VERSION}/blood`, bloodRoutes);
app.use(`/api/${API_VERSION}/notification`, notificationRoutes);

// 404 handler
app.use('*', (req, res) => {
  res.status(404).json({
    status: 'error',
    message: `Route ${req.originalUrl} not found`
  });
});

// Global error handler
app.use(errorMiddleware);

module.exports = app;