const VitalsModel = require('../models/vitals.model');
const aiService = require('../services/ai.service');
const fcmService = require('../services/fcm.service');
const smsService = require('../services/sms.service');
const { sendSuccess, sendError, sendCreated } = require('../utils/response.util');
const { asyncHandler } = require('../middlewares/error.middleware');
const { VitalsAlertLevel } = require('../utils/constants.util');

/**
 * Record Vitals
 */
const recordVitals = asyncHandler(async (req, res) => {
  const { userId } = req;
  const vitalsData = {
    ...req.body,
    userId: userId,
  };

  // Analyze vitals with AI
  const analysis = await aiService.analyzeVitals(vitalsData);

  // Add AI analysis to vitals data
  vitalsData.aiAnalysis = {
    riskLevel: analysis.riskLevel,
    prediction: analysis.predictions.join(', '),
    recommendations: analysis.recommendations,
    confidence: analysis.confidence,
  };

  // Check if alert should be generated
  if (analysis.riskLevel !== VitalsAlertLevel.NORMAL) {
    vitalsData.alertGenerated = true;
    vitalsData.alertMessage = analysis.predictions[0] || 'Abnormal vitals detected';

    // Send alert notifications
    await fcmService.sendVitalsAlertNotification(userId, {
      vitalId: null, // Will be set after creation
      alertMessage: vitalsData.alertMessage,
      priority: analysis.riskLevel === VitalsAlertLevel.CRITICAL ? 'urgent' : 'high',
    });

    // Send SMS for critical alerts
    if (analysis.riskLevel === VitalsAlertLevel.CRITICAL) {
      const UserModel = require('../models/user.model');
      const user = await UserModel.getById(userId);
      if (user) {
        await smsService.sendVitalsAlertSMS(user.phoneNumber, {
          alertMessage: vitalsData.alertMessage,
          recordedAt: new Date(),
        });
      }
    }
  }

  // Create vitals record
  const vital = await VitalsModel.create(vitalsData);

  return sendCreated(res, 'Vitals recorded successfully', {
    vital: vital,
    analysis: analysis,
  });
});

/**
 * Get Vitals History
 */
const getVitalsHistory = asyncHandler(async (req, res) => {
  const { userId } = req;
  const { limit, startDate, endDate } = req.query;

  const vitals = await VitalsModel.getUserVitals(
    userId,
    limit ? parseInt(limit) : 30,
    startDate,
    endDate
  );

  return sendSuccess(res, 'Vitals history retrieved', {
    vitals: vitals,
    count: vitals.length,
  });
});

/**
 * Get Latest Vitals
 */
const getLatestVitals = asyncHandler(async (req, res) => {
  const { userId } = req;

  const vital = await VitalsModel.getLatest(userId);

  if (!vital) {
    return sendError(res, 'No vitals found', 404);
  }

  return sendSuccess(res, 'Latest vitals retrieved', vital);
});

/**
 * Get Vitals Alerts
 */
const getVitalsAlerts = asyncHandler(async (req, res) => {
  const { userId } = req;
  const { limit } = req.query;

  const alerts = await VitalsModel.getAlertsForUser(
    userId,
    limit ? parseInt(limit) : 10
  );

  return sendSuccess(res, 'Vitals alerts retrieved', {
    alerts: alerts,
    count: alerts.length,
  });
});

/**
 * Get Vitals Averages
 */
const getVitalsAverages = asyncHandler(async (req, res) => {
  const { userId } = req;
  const { days } = req.query;

  const averages = await VitalsModel.getAverages(
    userId,
    days ? parseInt(days) : 7
  );

  if (!averages) {
    return sendError(res, 'Insufficient data for averages', 404);
  }

  return sendSuccess(res, 'Vitals averages calculated', averages);
});

/**
 * Analyze Vitals
 */
const analyzeVitals = asyncHandler(async (req, res) => {
  const vitalsData = req.body;

  const analysis = await aiService.analyzeVitals(vitalsData);

  return sendSuccess(res, 'Vitals analyzed', analysis);
});

/**
 * Predict Emergency Risk
 */
const predictEmergencyRisk = asyncHandler(async (req, res) => {
  const { userId } = req;

  const prediction = await aiService.predictEmergencyRisk(userId);

  return sendSuccess(res, 'Emergency risk prediction', prediction);
});

/**
 * Get Vitals by Date Range
 */
const getVitalsByDateRange = asyncHandler(async (req, res) => {
  const { userId } = req;
  const { startDate, endDate } = req.query;

  if (!startDate || !endDate) {
    return sendError(res, 'Start date and end date are required', 400);
  }

  const vitals = await VitalsModel.getByDateRange(userId, startDate, endDate);

  return sendSuccess(res, 'Vitals retrieved', {
    vitals: vitals,
    count: vitals.length,
  });
});

/**
 * Delete Vitals Record
 */
const deleteVitals = asyncHandler(async (req, res) => {
  const { vitalId } = req.params;

  await VitalsModel.delete(vitalId);

  return sendSuccess(res, 'Vitals record deleted');
});

module.exports = {
  recordVitals,
  getVitalsHistory,
  getLatestVitals,
  getVitalsAlerts,
  getVitalsAverages,
  analyzeVitals,
  predictEmergencyRisk,
  getVitalsByDateRange,
  deleteVitals,
};