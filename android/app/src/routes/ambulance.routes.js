const express = require('express');
const router = express.Router();
const ambulanceController = require('../controllers/ambulance.controller');
const { verifyToken, optionalAuth } = require('../middlewares/auth.middleware');

/**
 * @route   GET /api/v1/ambulance/nearest
 * @desc    Get nearest ambulances
 * @access  Public
 */
router.get('/nearest', optionalAuth, ambulanceController.getNearestAmbulances);

/**
 * @route   GET /api/v1/ambulance/:ambulanceId
 * @desc    Get ambulance details
 * @access  Public
 */
router.get('/:ambulanceId', ambulanceController.getAmbulanceDetails);

/**
 * @route   PUT /api/v1/ambulance/:ambulanceId/location
 * @desc    Update ambulance location
 * @access  Private (Driver/Admin)
 */
router.put(
  '/:ambulanceId/location',
  verifyToken,
  ambulanceController.updateAmbulanceLocation
);

/**
 * @route   POST /api/v1/ambulance/:ambulanceId/arrived
 * @desc    Mark ambulance as arrived
 * @access  Private (Driver)
 */
router.post('/:ambulanceId/arrived', verifyToken, ambulanceController.markArrived);

/**
 * @route   POST /api/v1/ambulance/:ambulanceId/picked
 * @desc    Mark patient as picked up
 * @access  Private (Driver)
 */
router.post('/:ambulanceId/picked', verifyToken, ambulanceController.markPatientPicked);

/**
 * @route   POST /api/v1/ambulance/:ambulanceId/reached-hospital
 * @desc    Mark as reached hospital
 * @access  Private (Driver)
 */
router.post(
  '/:ambulanceId/reached-hospital',
  verifyToken,
  ambulanceController.markReachedHospital
);

/**
 * @route   POST /api/v1/ambulance/:ambulanceId/complete
 * @desc    Complete ride
 * @access  Private (Driver)
 */
router.post('/:ambulanceId/complete', verifyToken, ambulanceController.completeRide);

/**
 * @route   GET /api/v1/ambulance/:ambulanceId/status
 * @desc    Get ambulance status
 * @access  Public
 */
router.get('/:ambulanceId/status', ambulanceController.getAmbulanceStatus);

/**
 * @route   GET /api/v1/ambulance/all/list
 * @desc    Get all ambulances (Admin)
 * @access  Private (Admin)
 */
router.get('/all/list', verifyToken, ambulanceController.getAllAmbulances);

module.exports = router;