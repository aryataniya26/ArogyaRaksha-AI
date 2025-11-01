const rateLimit = require('express-rate-limit');

/**
 * General API Rate Limiter
 */
const rateLimiter = rateLimit({
  windowMs: parseInt(process.env.RATE_LIMIT_WINDOW_MS) || 15 * 60 * 1000, // 15 minutes
  max: parseInt(process.env.RATE_LIMIT_MAX_REQUESTS) || 100, // limit each IP to 100 requests per windowMs
  message: {
    status: 'error',
    message: 'Too many requests from this IP, please try again later.',
  },
  standardHeaders: true,
  legacyHeaders: false,
});

/**
 * Strict Rate Limiter for sensitive endpoints
 */
const strictRateLimiter = rateLimit({
  windowMs: 15 * 60 * 1000, // 15 minutes
  max: 5, // 5 requests per window
  message: {
    status: 'error',
    message: 'Too many attempts, please try again later.',
  },
});

/**
 * Emergency Rate Limiter - more lenient for emergency endpoints
 */
const emergencyRateLimiter = rateLimit({
  windowMs: 5 * 60 * 1000, // 5 minutes
  max: 20, // 20 emergency requests per 5 minutes
  message: {
    status: 'error',
    message: 'Emergency request limit reached. Contact support.',
  },
});

module.exports = {
  rateLimiter,
  strictRateLimiter,
  emergencyRateLimiter,
};