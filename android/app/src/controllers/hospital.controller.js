const HospitalModel = require('../models/hospital.model');
const hospitalService = require('../services/hospital.service');
const { sendSuccess, sendError } = require('../utils/response.util');
const { asyncHandler } = require('../middlewares/error.middleware');
const { DistanceLimits } = require('../utils/constants.util');

/**
 * Get Nearest Hospitals
 */
const getNearestHospitals = asyncHandler(async (req, res) => {
  const { latitude, longitude, radius, type } = req.query;

  if (!latitude || !longitude) {
    return sendError(res, 'Latitude and longitude are required', 400);
  }

  const radiusKm = radius ? parseFloat(radius) : DistanceLimits.HOSPITAL_SEARCH_RADIUS;
  const filters = type ? { type } : {};

  const hospitals = await HospitalModel.getNearby(
    parseFloat(latitude),
    parseFloat(longitude),
    radiusKm,
    filters
  );

  return sendSuccess(res, 'Nearest hospitals retrieved', {
    hospitals: hospitals,
    count: hospitals.length,
  });
});

/**
 * Get Hospital Details
 */
const getHospitalDetails = asyncHandler(async (req, res) => {
  const { hospitalId } = req.params;

  const hospital = await HospitalModel.getById(hospitalId);

  if (!hospital) {
    return sendError(res, 'Hospital not found', 404);
  }

  return sendSuccess(res, 'Hospital details retrieved', hospital);
});

/**
 * Get Hospitals with Available Beds
 */
const getHospitalsWithBeds = asyncHandler(async (req, res) => {
  const { latitude, longitude, bedType } = req.query;

  if (!latitude || !longitude) {
    return sendError(res, 'Latitude and longitude are required', 400);
  }

  const hospitals = await hospitalService.getHospitalsWithBeds(
    parseFloat(latitude),
    parseFloat(longitude),
    bedType || 'emergency'
  );

  return sendSuccess(res, 'Hospitals with available beds retrieved', {
    hospitals: hospitals,
    count: hospitals.length,
  });
});

/**
 * Search Hospitals
 */
const searchHospitals = asyncHandler(async (req, res) => {
  const { query } = req.query;

  if (!query) {
    return sendError(res, 'Search query is required', 400);
  }

  const hospitals = await hospitalService.searchHospitals(query);

  return sendSuccess(res, 'Search results', {
    hospitals: hospitals,
    count: hospitals.length,
  });
});

/**
 * Update Bed Availability (Hospital Admin)
 */
const updateBedAvailability = asyncHandler(async (req, res) => {
  const { hospitalId } = req.params;
  const { bedType, available } = req.body;

  if (!bedType || available === undefined) {
    return sendError(res, 'Bed type and available count are required', 400);
  }

  await hospitalService.updateBedAvailability(
    hospitalId,
    bedType,
    parseInt(available)
  );

  return sendSuccess(res, 'Bed availability updated');
});

/**
 * Check if Hospital Can Accept Patient
 */
const checkCanAccept = asyncHandler(async (req, res) => {
  const { hospitalId } = req.params;
  const { emergencyType, insuranceProvider } = req.query;

  const result = await hospitalService.canAcceptPatient(
    hospitalId,
    emergencyType,
    insuranceProvider
  );

  return sendSuccess(res, 'Hospital acceptance check', result);
});

/**
 * Get All Hospitals (Admin)
 */
const getAllHospitals = asyncHandler(async (req, res) => {
  const { city, type } = req.query;

  const filters = {};
  if (city) filters.city = city;
  if (type) filters.type = type;

  const hospitals = await HospitalModel.getAll(filters);

  return sendSuccess(res, 'Hospitals retrieved', {
    hospitals: hospitals,
    count: hospitals.length,
  });
});

module.exports = {
  getNearestHospitals,
  getHospitalDetails,
  getHospitalsWithBeds,
  searchHospitals,
  updateBedAvailability,
  checkCanAccept,
  getAllHospitals,
};