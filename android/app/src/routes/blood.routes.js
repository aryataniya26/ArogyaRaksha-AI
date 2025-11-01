const express = require('express');
const router = express.Router();
const bloodController = require('../controllers/blood.controller');
const { verifyToken, optionalAuth } = require('../middlewares/auth.middleware');

/**
 * @route   POST /api/v1/blood/request
 * @desc    Create blood request
 * @access  Private
 */
router.post('/request', verifyToken, bloodController.createBloodRequest);

/**
 * @route   GET /api/v1/blood/request/:requestId
 * @desc    Get blood request status
 * @access  Private
 */
router.get('/request/:requestId', verifyToken, bloodController.getBloodRequestStatus);

/**
 * @route   GET /api/v1/blood/requests/user
 * @desc    Get user's blood requests
 * @access  Private
 */
router.get('/requests/user', verifyToken, bloodController.getUserBloodRequests);

/**
 * @route   PUT /api/v1/blood/request/:requestId/status
 * @desc    Update blood request status
 * @access  Private
 */
router.put(
  '/request/:requestId/status',
  verifyToken,
  bloodController.updateBloodRequestStatus
);

/**
 * @route   POST /api/v1/blood/request/:requestId/cancel
 * @desc    Cancel blood request
 * @access  Private
 */
router.post(
  '/request/:requestId/cancel',
  verifyToken,
  bloodController.cancelBloodRequest
);

/**
 * @route   GET /api/v1/blood/banks/nearest
 * @desc    Get nearest blood banks
 * @access  Public
 */
router.get('/banks/nearest', optionalAuth, bloodController.getNearestBloodBanks);

/**
 * @route   GET /api/v1/blood/bank/:bloodBankId
 * @desc    Get blood bank details
 * @access  Public
 */
router.get('/bank/:bloodBankId', bloodController.getBloodBankDetails);

/**
 * @route   GET /api/v1/blood/bank/:bloodBankId/availability
 * @desc    Check blood availability
 * @access  Public
 */
router.get('/bank/:bloodBankId/availability', bloodController.checkBloodAvailability);

/**
 * @route   PUT /api/v1/blood/bank/:bloodBankId/availability
 * @desc    Update blood availability
 * @access  Private (Blood Bank Admin)
 */
router.put(
  '/bank/:bloodBankId/availability',
  verifyToken,
  bloodController.updateBloodAvailability
);

/**
 * @route   GET /api/v1/blood/requests/active/:bloodGroup
 * @desc    Get active blood requests by blood group
 * @access  Public
 */
router.get(
  '/requests/active/:bloodGroup',
  bloodController.getActiveRequestsByBloodGroup
);

module.exports = router;