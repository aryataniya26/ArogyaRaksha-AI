const express = require('express');
const router = express.Router();
const vitalsController = require('../controllers/vitals.controller');
const { verifyToken } = require('../middlewares/auth.middleware');

/**
 * @route   POST /api/v1/vitals/record
 * @desc    Record vitals
 * @access  Private
 */
router.post('/record', verifyToken, vitalsController.recordVitals);

/**
 * @route   GET /api/v1/vitals/history
 * @desc    Get vitals history
 * @access  Private
 */
router.get('/history', verifyToken, vitalsController.getVitalsHistory);

/**
 * @route   GET /api/v1/vitals/latest
 * @desc    Get latest vitals
 * @access  Private
 */
router.get('/latest', verifyToken, vitalsController.getLatestVitals);

/**
 * @route   GET /api/v1/vitals/alerts
 * @desc    Get vitals alerts
 * @access  Private
 */
router.get('/alerts', verifyToken, vitalsController.getVitalsAlerts);

/**
 * @route   GET /api/v1/vitals/averages
 * @desc    Get vitals averages
 * @access  Private
 */
router.get('/averages', verifyToken, vitalsController.getVitalsAverages);

/**
 * @route   POST /api/v1/vitals/analyze
 * @desc    Analyze vitals
 * @access  Private
 */
router.post('/analyze', verifyToken, vitalsController.analyzeVitals);

/**
 * @route   GET /api/v1/vitals/predict-risk
 * @desc    Predict emergency risk
 * @access  Private
 */
router.get('/predict-risk', verifyToken, vitalsController.predictEmergencyRisk);

/**
 * @route   GET /api/v1/vitals/date-range
 * @desc    Get vitals by date range
 * @access  Private
 */
router.get('/date-range', verifyToken, vitalsController.getVitalsByDateRange);

/**
 * @route   DELETE /api/v1/vitals/:vitalId
 * @desc    Delete vitals record
 * @access  Private
 */
router.delete('/:vitalId', verifyToken, vitalsController.deleteVitals);

module.exports = router;