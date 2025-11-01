const jwt = require('jsonwebtoken');
const { auth } = require('../config/firebase.config');
const { sendError } = require('../utils/response.util');
const logger = require('../utils/logger.util');

/**
 * Verify JWT Token
 */
const verifyToken = async (req, res, next) => {
  try {
    // Get token from header
    const authHeader = req.headers.authorization;

    if (!authHeader || !authHeader.startsWith('Bearer ')) {
      return sendError(res, 'No token provided', 401);
    }

    const token = authHeader.split(' ')[1];

    // Verify token
    const decoded = jwt.verify(token, process.env.JWT_SECRET);

    // Attach user to request
    req.user = decoded;
    req.userId = decoded.userId;

    next();
  } catch (error) {
    logger.error('Token verification failed:', error);

    if (error.name === 'JsonWebTokenError') {
      return sendError(res, 'Invalid token', 401);
    }

    if (error.name === 'TokenExpiredError') {
      return sendError(res, 'Token expired', 401);
    }

    return sendError(res, 'Authentication failed', 401);
  }
};

/**
 * Verify Firebase ID Token (alternative method)
 */
const verifyFirebaseToken = async (req, res, next) => {
  try {
    const authHeader = req.headers.authorization;

    if (!authHeader || !authHeader.startsWith('Bearer ')) {
      return sendError(res, 'No token provided', 401);
    }

    const token = authHeader.split(' ')[1];

    // Verify Firebase token
    const decodedToken = await auth.verifyIdToken(token);

    req.user = {
      userId: decodedToken.uid,
      email: decodedToken.email,
      phoneNumber: decodedToken.phone_number,
    };
    req.userId = decodedToken.uid;

    next();
  } catch (error) {
    logger.error('Firebase token verification failed:', error);
    return sendError(res, 'Invalid Firebase token', 401);
  }
};

/**
 * Optional Auth - doesn't fail if no token
 */
const optionalAuth = async (req, res, next) => {
  try {
    const authHeader = req.headers.authorization;

    if (authHeader && authHeader.startsWith('Bearer ')) {
      const token = authHeader.split(' ')[1];
      const decoded = jwt.verify(token, process.env.JWT_SECRET);
      req.user = decoded;
      req.userId = decoded.userId;
    }

    next();
  } catch (error) {
    // Continue without user
    next();
  }
};

module.exports = {
  verifyToken,
  verifyFirebaseToken,
  optionalAuth,
};