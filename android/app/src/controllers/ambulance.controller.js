const AmbulanceModel = require('../models/ambulance.model');
const ambulanceService = require('../services/ambulance.service');
const { sendSuccess, sendError } = require('../utils/response.util');
const { asyncHandler } = require('../middlewares/error.middleware');
const { DistanceLimits } = require('../utils/constants.util');

/**
 * Get Nearest Ambulances
 */
const getNearestAmbulances = asyncHandler(async (req, res) => {
  const { latitude, longitude, radius } = req.query;

  if (!latitude || !longitude) {
    return sendError(res, 'Latitude and longitude are required', 400);
  }

  const radiusKm = radius ? parseFloat(radius) : DistanceLimits.AMBULANCE_SEARCH_RADIUS;

  const ambulances = await AmbulanceModel.getAvailableNearby(
    parseFloat(latitude),
    parseFloat(longitude),
    radiusKm
  );

  return sendSuccess(res, 'Nearest ambulances retrieved', {
    ambulances: ambulances,
    count: ambulances.length,
  });
});

/**
 * Get Ambulance Details
 */
const getAmbulanceDetails = asyncHandler(async (req, res) => {
  const { ambulanceId } = req.params;

  const ambulance = await AmbulanceModel.getById(ambulanceId);

  if (!ambulance) {
    return sendError(res, 'Ambulance not found', 404);
  }

  return sendSuccess(res, 'Ambulance details retrieved', ambulance);
});

/**
 * Update Ambulance Location (Driver/Admin)
 */
const updateAmbulanceLocation = asyncHandler(async (req, res) => {
  const { ambulanceId } = req.params;
  const { latitude, longitude, address } = req.body;

  if (!latitude || !longitude) {
    return sendError(res, 'Latitude and longitude are required', 400);
  }

  await ambulanceService.updateAmbulanceLocation(
    ambulanceId,
    parseFloat(latitude),
    parseFloat(longitude),
    address
  );

  return sendSuccess(res, 'Ambulance location updated');
});

/**
 * Mark Ambulance Arrived
 */
const markArrived = asyncHandler(async (req, res) => {
  const { ambulanceId } = req.params;
  const { emergencyId } = req.body;

  if (!emergencyId) {
    return sendError(res, 'Emergency ID is required', 400);
  }

  await ambulanceService.markAmbulanceArrived(ambulanceId, emergencyId);

  return sendSuccess(res, 'Ambulance marked as arrived');
});

/**
 * Mark Patient Picked Up
 */
const markPatientPicked = asyncHandler(async (req, res) => {
  const { ambulanceId } = req.params;
  const { emergencyId } = req.body;

  if (!emergencyId) {
    return sendError(res, 'Emergency ID is required', 400);
  }

  await ambulanceService.markPatientPicked(ambulanceId, emergencyId);

  return sendSuccess(res, 'Patient marked as picked up');
});

/**
 * Mark Reached Hospital
 */
const markReachedHospital = asyncHandler(async (req, res) => {
  const { ambulanceId } = req.params;
  const { emergencyId } = req.body;

  if (!emergencyId) {
    return sendError(res, 'Emergency ID is required', 400);
  }

  await ambulanceService.markReachedHospital(ambulanceId, emergencyId);

  return sendSuccess(res, 'Marked as reached hospital');
});

/**
 * Complete Ride
 */
const completeRide = asyncHandler(async (req, res) => {
  const { ambulanceId } = req.params;
  const { emergencyId } = req.body;

  if (!emergencyId) {
    return sendError(res, 'Emergency ID is required', 400);
  }

  await ambulanceService.completeRide(ambulanceId, emergencyId);

  return sendSuccess(res, 'Ride completed successfully');
});

/**
 * Get Ambulance Status
 */
const getAmbulanceStatus = asyncHandler(async (req, res) => {
  const { ambulanceId } = req.params;

  const status = await ambulanceService.getAmbulanceStatus(ambulanceId);

  return sendSuccess(res, 'Ambulance status retrieved', status);
});

/**
 * Get All Ambulances (Admin)
 */
const getAllAmbulances = asyncHandler(async (req, res) => {
  const { status, type } = req.query;

  const filters = {};
  if (status) filters.status = status;
  if (type) filters.type = type;

  const ambulances = await AmbulanceModel.getAll(filters);

  return sendSuccess(res, 'Ambulances retrieved', {
    ambulances: ambulances,
    count: ambulances.length,
  });
});

module.exports = {
  getNearestAmbulances,
  getAmbulanceDetails,
  updateAmbulanceLocation,
  markArrived,
  markPatientPicked,
  markReachedHospital,
  completeRide,
  getAmbulanceStatus,
  getAllAmbulances,
};