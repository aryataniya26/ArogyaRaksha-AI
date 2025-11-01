const express = require('express');
const router = express.Router();
const userController = require('../controllers/user.controller');
const { verifyToken } = require('../middlewares/auth.middleware');

/**
 * @route   GET /api/v1/user/profile
 * @desc    Get user profile
 * @access  Private
 */
router.get('/profile', verifyToken, userController.getProfile);

/**
 * @route   PUT /api/v1/user/profile
 * @desc    Update user profile
 * @access  Private
 */
router.put('/profile', verifyToken, userController.updateProfile);

/**
 * @route   POST /api/v1/user/emergency-contact
 * @desc    Add emergency contact
 * @access  Private
 */
router.post('/emergency-contact', verifyToken, userController.addEmergencyContact);

/**
 * @route   PUT /api/v1/user/device-token
 * @desc    Update device token for push notifications
 * @access  Private
 */
router.put('/device-token', verifyToken, userController.updateDeviceToken);

/**
 * @route   PUT /api/v1/user/location
 * @desc    Update user location
 * @access  Private
 */
router.put('/location', verifyToken, userController.updateLocation);

/**
 * @route   GET /api/v1/user/medical-history
 * @desc    Get medical history
 * @access  Private
 */
router.get('/medical-history', verifyToken, userController.getMedicalHistory);

/**
 * @route   PUT /api/v1/user/medical-history
 * @desc    Update medical history
 * @access  Private
 */
router.put('/medical-history', verifyToken, userController.updateMedicalHistory);

/**
 * @route   PUT /api/v1/user/insurance
 * @desc    Update insurance details
 * @access  Private
 */
router.put('/insurance', verifyToken, userController.updateInsurance);

module.exports = router;