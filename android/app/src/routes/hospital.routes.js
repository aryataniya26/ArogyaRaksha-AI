const express = require('express');
const router = express.Router();
const hospitalController = require('../controllers/hospital.controller');
const { verifyToken, optionalAuth } = require('../middlewares/auth.middleware');

/**
 * @route   GET /api/v1/hospital/nearest
 * @desc    Get nearest hospitals
 * @access  Public
 */
router.get('/nearest', optionalAuth, hospitalController.getNearestHospitals);

/**
 * @route   GET /api/v1/hospital/:hospitalId
 * @desc    Get hospital details
 * @access  Public
 */
router.get('/:hospitalId', hospitalController.getHospitalDetails);

/**
 * @route   GET /api/v1/hospital/beds/available
 * @desc    Get hospitals with available beds
 * @access  Public
 */
router.get('/beds/available', hospitalController.getHospitalsWithBeds);

/**
 * @route   GET /api/v1/hospital/search/query
 * @desc    Search hospitals
 * @access  Public
 */
router.get('/search/query', hospitalController.searchHospitals);

/**
 * @route   PUT /api/v1/hospital/:hospitalId/beds
 * @desc    Update bed availability
 * @access  Private (Hospital Admin)
 */
router.put('/:hospitalId/beds', verifyToken, hospitalController.updateBedAvailability);

/**
 * @route   GET /api/v1/hospital/:hospitalId/can-accept
 * @desc    Check if hospital can accept patient
 * @access  Public
 */
router.get('/:hospitalId/can-accept', hospitalController.checkCanAccept);

/**
 * @route   GET /api/v1/hospital/all/list
 * @desc    Get all hospitals (Admin)
 * @access  Private (Admin)
 */
router.get('/all/list', verifyToken, hospitalController.getAllHospitals);

module.exports = router;