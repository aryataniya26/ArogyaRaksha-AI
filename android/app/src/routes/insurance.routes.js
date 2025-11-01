const express = require('express');
const router = express.Router();
const insuranceController = require('../controllers/insurance.controller');
const { verifyToken } = require('../middlewares/auth.middleware');

/**
 * @route   POST /api/v1/insurance/verify
 * @desc    Verify insurance
 * @access  Private
 */
router.post('/verify', verifyToken, insuranceController.verifyInsurance);

/**
 * @route   GET /api/v1/insurance/status
 * @desc    Get insurance status
 * @access  Private
 */
router.get('/status', verifyToken, insuranceController.getInsuranceStatus);

/**
 * @route   GET /api/v1/insurance/details
 * @desc    Get insurance details
 * @access  Private
 */
router.get('/details', verifyToken, insuranceController.getInsuranceDetails);

/**
 * @route   POST /api/v1/insurance/add
 * @desc    Add insurance
 * @access  Private
 */
router.post('/add', verifyToken, insuranceController.addInsurance);

/**
 * @route   PUT /api/v1/insurance/:insuranceId
 * @desc    Update insurance
 * @access  Private
 */
router.put('/:insuranceId', verifyToken, insuranceController.updateInsurance);

/**
 * @route   GET /api/v1/insurance/eligibility
 * @desc    Check insurance eligibility
 * @access  Private
 */
router.get('/eligibility', verifyToken, insuranceController.checkEligibility);

/**
 * @route   POST /api/v1/insurance/digilocker
 * @desc    Fetch insurance from DigiLocker
 * @access  Private
 */
router.post('/digilocker', verifyToken, insuranceController.fetchFromDigiLocker);

/**
 * @route   GET /api/v1/insurance/coverage
 * @desc    Get insurance coverage
 * @access  Private
 */
router.get('/coverage', verifyToken, insuranceController.getCoverage);

/**
 * @route   POST /api/v1/insurance/:insuranceId/claim
 * @desc    Add insurance claim
 * @access  Private
 */
router.post('/:insuranceId/claim', verifyToken, insuranceController.addClaim);

module.exports = router;