const InsuranceModel = require('../models/insurance.model');
const insuranceService = require('../services/insurance.service');
const { sendSuccess, sendError, sendCreated } = require('../utils/response.util');
const { asyncHandler } = require('../middlewares/error.middleware');

/**
 * Verify Insurance
 */
const verifyInsurance = asyncHandler(async (req, res) => {
  const { userId } = req;
  const { policyNumber } = req.body;

  const result = await insuranceService.verifyInsurance(userId, policyNumber);

  if (!result.verified) {
    return sendError(res, result.message || 'Insurance verification failed', 400);
  }

  return sendSuccess(res, 'Insurance verified successfully', result);
});

/**
 * Get Insurance Status
 */
const getInsuranceStatus = asyncHandler(async (req, res) => {
  const { userId } = req;

  const status = await insuranceService.getInsuranceStatus(userId);

  return sendSuccess(res, 'Insurance status retrieved', status);
});

/**
 * Get Insurance Details
 */
const getInsuranceDetails = asyncHandler(async (req, res) => {
  const { userId } = req;

  const insurance = await InsuranceModel.getByUserId(userId);

  if (!insurance) {
    return sendError(res, 'No insurance found', 404);
  }

  return sendSuccess(res, 'Insurance details retrieved', insurance);
});

/**
 * Add Insurance
 */
const addInsurance = asyncHandler(async (req, res) => {
  const { userId } = req;
  const insuranceData = {
    ...req.body,
    userId: userId,
  };

  const insurance = await InsuranceModel.create(insuranceData);

  return sendCreated(res, 'Insurance added successfully', insurance);
});

/**
 * Update Insurance
 */
const updateInsurance = asyncHandler(async (req, res) => {
  const { insuranceId } = req.params;
  const updateData = req.body;

  const insurance = await InsuranceModel.update(insuranceId, updateData);

  return sendSuccess(res, 'Insurance updated successfully', insurance);
});

/**
 * Check Eligibility
 */
const checkEligibility = asyncHandler(async (req, res) => {
  const { userId } = req;
  const { treatmentType } = req.query;

  const eligibility = await insuranceService.checkEligibility(
    userId,
    treatmentType || 'emergency'
  );

  return sendSuccess(res, 'Eligibility check completed', eligibility);
});

/**
 * Fetch from DigiLocker
 */
const fetchFromDigiLocker = asyncHandler(async (req, res) => {
  const { userId } = req;
  const { accessToken } = req.body;

  if (!accessToken) {
    return sendError(res, 'DigiLocker access token is required', 400);
  }

  const result = await insuranceService.fetchFromDigiLocker(userId, accessToken);

  if (!result.success) {
    return sendError(res, result.message, 400);
  }

  return sendSuccess(res, 'Insurance fetched from DigiLocker', result.insurance);
});

/**
 * Get Insurance Coverage
 */
const getCoverage = asyncHandler(async (req, res) => {
  const { userId } = req;

  const insurance = await InsuranceModel.getByUserId(userId);

  if (!insurance) {
    return sendError(res, 'No insurance found', 404);
  }

  return sendSuccess(res, 'Coverage details retrieved', {
    coverage: insurance.coverage,
    totalClaimedAmount: insurance.totalClaimedAmount,
    remainingCoverage: insurance.coverage.amount - insurance.totalClaimedAmount,
  });
});

/**
 * Add Claim
 */
const addClaim = asyncHandler(async (req, res) => {
  const { insuranceId } = req.params;
  const claimData = req.body;

  const insurance = await insuranceService.addClaim(insuranceId, claimData);

  return sendSuccess(res, 'Claim added successfully', insurance);
});

module.exports = {
  verifyInsurance,
  getInsuranceStatus,
  getInsuranceDetails,
  addInsurance,
  updateInsurance,
  checkEligibility,
  fetchFromDigiLocker,
  getCoverage,
  addClaim,
};