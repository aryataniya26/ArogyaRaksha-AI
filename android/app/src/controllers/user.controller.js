const UserModel = require('../models/user.model');
const { sendSuccess, sendError, sendCreated } = require('../utils/response.util');
const { asyncHandler } = require('../middlewares/error.middleware');
const logger = require('../utils/logger.util');

/**
 * Get User Profile
 */
const getProfile = asyncHandler(async (req, res) => {
  const { userId } = req;

  const user = await UserModel.getById(userId);

  if (!user) {
    return sendError(res, 'User not found', 404);
  }

  return sendSuccess(res, 'Profile retrieved successfully', user);
});

/**
 * Update User Profile
 */
const updateProfile = asyncHandler(async (req, res) => {
  const { userId } = req;
  const updateData = req.body;

  // Remove sensitive fields that shouldn't be updated directly
  delete updateData.uid;
  delete updateData.createdAt;

  const user = await UserModel.update(userId, updateData);

  logger.success(`User profile updated: ${userId}`);

  return sendSuccess(res, 'Profile updated successfully', user);
});

/**
 * Add Emergency Contact
 */
const addEmergencyContact = asyncHandler(async (req, res) => {
  const { userId } = req;
  const { name, phone, relation } = req.body;

  if (!name || !phone || !relation) {
    return sendError(res, 'Name, phone, and relation are required', 400);
  }

  const contacts = await UserModel.addEmergencyContact(userId, {
    name,
    phone,
    relation,
  });

  return sendSuccess(res, 'Emergency contact added', contacts);
});

/**
 * Update Device Token (for push notifications)
 */
const updateDeviceToken = asyncHandler(async (req, res) => {
  const { userId } = req;
  const { token } = req.body;

  if (!token) {
    return sendError(res, 'Device token is required', 400);
  }

  await UserModel.updateDeviceToken(userId, token);

  return sendSuccess(res, 'Device token updated');
});

/**
 * Update Location
 */
const updateLocation = asyncHandler(async (req, res) => {
  const { userId } = req;
  const { latitude, longitude } = req.body;

  if (!latitude || !longitude) {
    return sendError(res, 'Latitude and longitude are required', 400);
  }

  await UserModel.update(userId, {
    'location.latitude': latitude,
    'location.longitude': longitude,
  });

  return sendSuccess(res, 'Location updated');
});

/**
 * Get Medical History
 */
const getMedicalHistory = asyncHandler(async (req, res) => {
  const { userId } = req;

  const user = await UserModel.getById(userId);

  if (!user) {
    return sendError(res, 'User not found', 404);
  }

  return sendSuccess(res, 'Medical history retrieved', user.medicalHistory);
});

/**
 * Update Medical History
 */
const updateMedicalHistory = asyncHandler(async (req, res) => {
  const { userId } = req;
  const medicalHistory = req.body;

  await UserModel.update(userId, {
    medicalHistory: medicalHistory,
  });

  return sendSuccess(res, 'Medical history updated');
});

/**
 * Update Insurance Details
 */
const updateInsurance = asyncHandler(async (req, res) => {
  const { userId } = req;
  const insurance = req.body;

  await UserModel.update(userId, {
    insurance: insurance,
  });

  return sendSuccess(res, 'Insurance details updated');
});

module.exports = {
  getProfile,
  updateProfile,
  addEmergencyContact,
  updateDeviceToken,
  updateLocation,
  getMedicalHistory,
  updateMedicalHistory,
  updateInsurance,
};