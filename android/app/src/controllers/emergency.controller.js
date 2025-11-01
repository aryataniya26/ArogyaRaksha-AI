const EmergencyModel = require('../models/emergency.model');
const UserModel = require('../models/user.model');
const ambulanceService = require('../services/ambulance.service');
const hospitalService = require('../services/hospital.service');
const insuranceService = require('../services/insurance.service');
const smsService = require('../services/sms.service');
const fcmService = require('../services/fcm.service');
const locationService = require('../services/location.service');
const { sendSuccess, sendError, sendCreated } = require('../utils/response.util');
const { asyncHandler } = require('../middlewares/error.middleware');
const logger = require('../utils/logger.util');
const { emitEmergencyUpdate } = require('../websocket/socket.server');

/**
 * Trigger Emergency
 */
const triggerEmergency = asyncHandler(async (req, res) => {
  const { userId } = req;
  const { location, emergencyType, symptoms, vitals, isOfflineMode } = req.body;

  // Get user details
  const user = await UserModel.getById(userId);
  if (!user) {
    return sendError(res, 'User not found', 404);
  }

  // Get address from coordinates
  const addressData = await locationService.getAddressFromCoordinates(
    location.latitude,
    location.longitude
  );

  // Create emergency
  const emergency = await EmergencyModel.create({
    userId: userId,
    patientInfo: {
      name: user.name,
      age: user.age,
      gender: user.gender,
      bloodGroup: user.bloodGroup,
      phoneNumber: user.phoneNumber,
    },
    location: {
      latitude: location.latitude,
      longitude: location.longitude,
      address: addressData.address,
    },
    emergencyType: emergencyType || 'other',
    symptoms: symptoms || [],
    vitals: vitals || null,
    insurance: {
      hasInsurance: user.insurance?.hasInsurance || false,
      provider: user.insurance?.provider || null,
      policyNumber: user.insurance?.policyNumber || null,
      status: 'pending',
    },
    isOfflineMode: isOfflineMode || false,
  });

  logger.success(`Emergency triggered: ${emergency.emergencyId}`);

  // Send emergency notification to user
  await fcmService.sendEmergencyNotification(userId, emergency);

  // Send SMS to user and emergency contacts
  await smsService.sendEmergencySMS(user.phoneNumber, emergency);

  if (user.emergencyContacts && user.emergencyContacts.length > 0) {
    for (const contact of user.emergencyContacts) {
      await smsService.sendEmergencySMS(contact.phone, emergency);
    }
  }

  // Auto-assign ambulance (async)
  ambulanceService.assignNearestAmbulance(emergency.emergencyId)
    .then(result => {
      logger.info('Ambulance assignment process completed');
    })
    .catch(error => {
      logger.error('Ambulance assignment failed:', error);
    });

  // Verify insurance (async)
  if (user.insurance?.hasInsurance) {
    insuranceService.verifyInsurance(userId)
      .then(result => {
        if (result.verified) {
          logger.success('Insurance verified');
        }
      })
      .catch(error => {
        logger.error('Insurance verification failed:', error);
      });
  }

  // Find and notify hospital (async)
  hospitalService.sendPreArrivalNotification(emergency.emergencyId)
    .then(result => {
      logger.info('Hospital notification sent');
    })
    .catch(error => {
      logger.error('Hospital notification failed:', error);
    });

  return sendCreated(res, 'Emergency triggered successfully', {
    emergency: emergency,
  });
});

/**
 * Get Emergency Status
 */
const getEmergencyStatus = asyncHandler(async (req, res) => {
  const { emergencyId } = req.params;

  const emergency = await EmergencyModel.getById(emergencyId);

  if (!emergency) {
    return sendError(res, 'Emergency not found', 404);
  }

  // Check if user owns this emergency
  if (emergency.userId !== req.userId) {
    return sendError(res, 'Unauthorized access', 403);
  }

  return sendSuccess(res, 'Emergency status retrieved', emergency);
});

/**
 * Update Emergency Status
 */
const updateEmergencyStatus = asyncHandler(async (req, res) => {
  const { emergencyId } = req.params;
  const { status, message } = req.body;

  const emergency = await EmergencyModel.updateStatus(emergencyId, status, message);

  // Emit real-time update
  emitEmergencyUpdate(emergencyId, {
    status: status,
    message: message,
    timestamp: new Date(),
  });

  return sendSuccess(res, 'Emergency status updated', emergency);
});

/**
 * Cancel Emergency
 */
const cancelEmergency = asyncHandler(async (req, res) => {
  const { emergencyId } = req.params;
  const { reason } = req.body;

  const emergency = await EmergencyModel.getById(emergencyId);

  if (!emergency) {
    return sendError(res, 'Emergency not found', 404);
  }

  if (emergency.userId !== req.userId) {
    return sendError(res, 'Unauthorized access', 403);
  }

  await EmergencyModel.cancel(emergencyId, reason);

  // If ambulance was assigned, free it
  if (emergency.ambulanceId) {
    const AmbulanceModel = require('../models/ambulance.model');
    await AmbulanceModel.updateStatus(emergency.ambulanceId, 'available');
  }

  return sendSuccess(res, 'Emergency cancelled successfully');
});

/**
 * Get Emergency History
 */
const getEmergencyHistory = asyncHandler(async (req, res) => {
  const { userId } = req;
  const { limit = 10 } = req.query;

  const emergencies = await EmergencyModel.getUserEmergencies(userId, parseInt(limit));

  return sendSuccess(res, 'Emergency history retrieved', {
    emergencies: emergencies,
    total: emergencies.length,
  });
});

/**
 * Get Active Emergencies (Admin)
 */
const getActiveEmergencies = asyncHandler(async (req, res) => {
  const emergencies = await EmergencyModel.getActiveEmergencies();

  return sendSuccess(res, 'Active emergencies retrieved', {
    emergencies: emergencies,
    count: emergencies.length,
  });
});

module.exports = {
  triggerEmergency,
  getEmergencyStatus,
  updateEmergencyStatus,
  cancelEmergency,
  getEmergencyHistory,
  getActiveEmergencies,
};