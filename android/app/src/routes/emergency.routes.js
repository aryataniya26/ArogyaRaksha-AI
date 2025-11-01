const express = require('express');
const router = express.Router();
const emergencyController = require('../controllers/emergency.controller');
const { verifyToken } = require('../middlewares/auth.middleware');
const { emergencyRateLimiter } = require('../middlewares/rateLimiter.middleware');

/**
 * @route   POST /api/v1/emergency/trigger
 * @desc    Trigger emergency alert
 * @access  Private
 */
router.post(
  '/trigger',
  verifyToken,
  emergencyRateLimiter,
  emergencyController.triggerEmergency
);

/**
 * @route   GET /api/v1/emergency/:emergencyId
 * @desc    Get emergency status
 * @access  Private
 */
router.get(
  '/:emergencyId',
  verifyToken,
  emergencyController.getEmergencyStatus
);

/**
 * @route   PUT /api/v1/emergency/:emergencyId/status
 * @desc    Update emergency status
 * @access  Private
 */
router.put(
  '/:emergencyId/status',
  verifyToken,
  emergencyController.updateEmergencyStatus
);

/**
 * @route   POST /api/v1/emergency/:emergencyId/cancel
 * @desc    Cancel emergency
 * @access  Private
 */
router.post(
  '/:emergencyId/cancel',
  verifyToken,
  emergencyController.cancelEmergency
);

/**
 * @route   GET /api/v1/emergency/history/user
 * @desc    Get user's emergency history
 * @access  Private
 */
router.get(
  '/history/user',
  verifyToken,
  emergencyController.getEmergencyHistory
);

/**
 * @route   GET /api/v1/emergency/active/all
 * @desc    Get all active emergencies (Admin)
 * @access  Private (Admin)
 */
router.get(
  '/active/all',
  verifyToken,
  emergencyController.getActiveEmergencies
);

module.exports = router;