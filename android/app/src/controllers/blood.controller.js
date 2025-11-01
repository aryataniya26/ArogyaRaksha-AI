const { BloodBankModel, BloodRequestModel } = require('../models/blood.model');
const smsService = require('../services/sms.service');
const fcmService = require('../services/fcm.service');
const { sendSuccess, sendError, sendCreated } = require('../utils/response.util');
const { asyncHandler } = require('../middlewares/error.middleware');
const { DistanceLimits } = require('../utils/constants.util');

/**
 * Create Blood Request
 */
const createBloodRequest = asyncHandler(async (req, res) => {
  const { userId } = req;
  const requestData = {
    ...req.body,
    userId: userId,
  };

  // Create blood request
  const request = await BloodRequestModel.create(requestData);

  // Find matching blood banks
  const matchedBloodBanks = await BloodBankModel.getNearbyWithBlood(
    requestData.location.latitude,
    requestData.location.longitude,
    requestData.bloodGroup,
    DistanceLimits.BLOOD_BANK_SEARCH_RADIUS
  );

  if (matchedBloodBanks.length > 0) {
    await BloodRequestModel.addMatchedBloodBanks(
      request.id,
      matchedBloodBanks.map(bank => ({
        bloodBankId: bank.id,
        name: bank.name,
        phone: bank.contact.phone,
        distance: bank.distance,
        availableUnits: bank.availableUnits,
      }))
    );

    // Notify blood banks
    for (const bank of matchedBloodBanks.slice(0, 3)) { // Top 3 nearest
      await smsService.sendBloodRequestSMS(bank.contact.phone, {
        bloodGroup: requestData.bloodGroup,
        unitsRequired: requestData.unitsRequired,
        patientName: requestData.patientName,
        hospitalName: requestData.hospitalName,
        contactNumber: requestData.patientPhone,
      });
    }
  }

  // Notify user
  await fcmService.sendBloodRequestNotification(userId, {
    requestId: request.id,
    bloodGroup: requestData.bloodGroup,
    patientName: requestData.patientName,
  });

  return sendCreated(res, 'Blood request created successfully', {
    request: request,
    matchedBloodBanks: matchedBloodBanks,
  });
});

/**
 * Get Blood Request Status
 */
const getBloodRequestStatus = asyncHandler(async (req, res) => {
  const { requestId } = req.params;

  const request = await BloodRequestModel.getById(requestId);

  if (!request) {
    return sendError(res, 'Blood request not found', 404);
  }

  return sendSuccess(res, 'Blood request status retrieved', request);
});

/**
 * Get User's Blood Requests
 */
const getUserBloodRequests = asyncHandler(async (req, res) => {
  const { userId } = req;
  const { limit } = req.query;

  const requests = await BloodRequestModel.getUserRequests(
    userId,
    limit ? parseInt(limit) : 10
  );

  return sendSuccess(res, 'Blood requests retrieved', {
    requests: requests,
    count: requests.length,
  });
});

/**
 * Update Blood Request Status
 */
const updateBloodRequestStatus = asyncHandler(async (req, res) => {
  const { requestId } = req.params;
  const { status, fulfilledBy } = req.body;

  if (!status) {
    return sendError(res, 'Status is required', 400);
  }

  const request = await BloodRequestModel.updateStatus(requestId, status, fulfilledBy);

  return sendSuccess(res, 'Blood request status updated', request);
});

/**
 * Cancel Blood Request
 */
const cancelBloodRequest = asyncHandler(async (req, res) => {
  const { requestId } = req.params;
  const { reason } = req.body;

  const request = await BloodRequestModel.cancel(requestId, reason);

  return sendSuccess(res, 'Blood request cancelled', request);
});

/**
 * Get Nearest Blood Banks
 */
const getNearestBloodBanks = asyncHandler(async (req, res) => {
  const { latitude, longitude, bloodGroup, radius } = req.query;

  if (!latitude || !longitude) {
    return sendError(res, 'Latitude and longitude are required', 400);
  }

  const radiusKm = radius ? parseFloat(radius) : DistanceLimits.BLOOD_BANK_SEARCH_RADIUS;

  let bloodBanks;

  if (bloodGroup) {
    bloodBanks = await BloodBankModel.getNearbyWithBlood(
      parseFloat(latitude),
      parseFloat(longitude),
      bloodGroup,
      radiusKm
    );
  } else {
    // Get all nearby blood banks
    bloodBanks = await BloodBankModel.getAll();
    const { calculateDistance } = require('../utils/distance.util');

    bloodBanks = bloodBanks
      .map(bank => ({
        ...bank,
        distance: calculateDistance(
          parseFloat(latitude),
          parseFloat(longitude),
          bank.location.latitude,
          bank.location.longitude
        ),
      }))
      .filter(bank => bank.distance <= radiusKm)
      .sort((a, b) => a.distance - b.distance);
  }

  return sendSuccess(res, 'Nearest blood banks retrieved', {
    bloodBanks: bloodBanks,
    count: bloodBanks.length,
  });
});

/**
 * Get Blood Bank Details
 */
const getBloodBankDetails = asyncHandler(async (req, res) => {
  const { bloodBankId } = req.params;

  const bloodBank = await BloodBankModel.getById(bloodBankId);

  if (!bloodBank) {
    return sendError(res, 'Blood bank not found', 404);
  }

  return sendSuccess(res, 'Blood bank details retrieved', bloodBank);
});

/**
 * Check Blood Availability
 */
const checkBloodAvailability = asyncHandler(async (req, res) => {
  const { bloodBankId } = req.params;
  const { bloodGroup } = req.query;

  if (!bloodGroup) {
    return sendError(res, 'Blood group is required', 400);
  }

  const units = await BloodBankModel.checkAvailability(bloodBankId, bloodGroup);

  return sendSuccess(res, 'Blood availability checked', {
    bloodBankId: bloodBankId,
    bloodGroup: bloodGroup,
    availableUnits: units,
    isAvailable: units > 0,
  });
});

/**
 * Update Blood Availability (Blood Bank Admin)
 */
const updateBloodAvailability = asyncHandler(async (req, res) => {
  const { bloodBankId } = req.params;
  const { bloodGroup, units } = req.body;

  if (!bloodGroup || units === undefined) {
    return sendError(res, 'Blood group and units are required', 400);
  }

  await BloodBankModel.updateAvailability(bloodBankId, bloodGroup, parseInt(units));

  return sendSuccess(res, 'Blood availability updated');
});

/**
 * Get Active Blood Requests by Blood Group
 */
const getActiveRequestsByBloodGroup = asyncHandler(async (req, res) => {
  const { bloodGroup } = req.params;

  const requests = await BloodRequestModel.getActiveByBloodGroup(bloodGroup);

  return sendSuccess(res, 'Active blood requests retrieved', {
    requests: requests,
    count: requests.length,
  });
});

module.exports = {
  createBloodRequest,
  getBloodRequestStatus,
  getUserBloodRequests,
  updateBloodRequestStatus,
  cancelBloodRequest,
  getNearestBloodBanks,
  getBloodBankDetails,
  checkBloodAvailability,
  updateBloodAvailability,
  getActiveRequestsByBloodGroup,
};