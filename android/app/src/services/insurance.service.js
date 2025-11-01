const InsuranceModel = require('../models/insurance.model');
const digilockerService = require('./digilocker.service');
const smsService = require('./sms.service');
const fcmService = require('./fcm.service');
const logger = require('../utils/logger.util');
const { InsuranceStatus, InsuranceProvider } = require('../utils/constants.util');

/**
 * Insurance Service - Verification and management
 */
class InsuranceService {
  /**
   * Verify insurance for emergency
   */
  async verifyInsurance(userId, policyNumber = null) {
    try {
      logger.info(`Verifying insurance for user ${userId}`);

      // Get user's insurance
      let insurance = await InsuranceModel.getByUserId(userId);

      if (policyNumber) {
        insurance = await InsuranceModel.getByPolicyNumber(policyNumber);
      }

      if (!insurance) {
        return {
          verified: false,
          status: 'not_found',
          message: 'No insurance found',
        };
      }

      // Check if already verified
      if (insurance.isVerified && insurance.status === InsuranceStatus.VERIFIED) {
        return {
          verified: true,
          status: 'active',
          insurance: insurance,
        };
      }

      // Verify based on provider
      let verificationResult;

      switch (insurance.provider) {
        case InsuranceProvider.AYUSHMAN_BHARAT:
          verificationResult = await this.verifyAyushmanBharat(insurance);
          break;
        case InsuranceProvider.AAROGYASRI:
          verificationResult = await this.verifyAarogyasri(insurance);
          break;
        case InsuranceProvider.PRIVATE:
          verificationResult = await this.verifyPrivateInsurance(insurance);
          break;
        default:
          verificationResult = { verified: false };
      }

      if (verificationResult.verified) {
        await InsuranceModel.verify(insurance.insuranceId);
        logger.success(`Insurance verified for user ${userId}`);
      }

      return verificationResult;
    } catch (error) {
      logger.error('Insurance verification error:', error);
      throw error;
    }
  }

  /**
   * Verify Ayushman Bharat (Mock implementation)
   */
  async verifyAyushmanBharat(insurance) {
    try {
      // In production, this would call actual Ayushman Bharat API
      // For now, mock verification

      logger.info('Verifying Ayushman Bharat insurance');

      // Simulate API call delay
      await new Promise(resolve => setTimeout(resolve, 1000));

      // Mock verification (in production, check with actual API)
      const isValid = insurance.policyNumber && insurance.validUpto > new Date();

      if (isValid) {
        return {
          verified: true,
          status: 'active',
          provider: 'Ayushman Bharat',
          coverage: insurance.coverage.amount || 500000,
          message: 'Insurance verified successfully',
        };
      }

      return {
        verified: false,
        status: 'invalid',
        message: 'Insurance verification failed',
      };
    } catch (error) {
      logger.error('Ayushman Bharat verification error:', error);
      return { verified: false, error: error.message };
    }
  }

  /**
   * Verify Aarogyasri (Mock implementation)
   */
  async verifyAarogyasri(insurance) {
    try {
      logger.info('Verifying Aarogyasri insurance');

      await new Promise(resolve => setTimeout(resolve, 1000));

      const isValid = insurance.policyNumber && insurance.validUpto > new Date();

      if (isValid) {
        return {
          verified: true,
          status: 'active',
          provider: 'Aarogyasri',
          coverage: insurance.coverage.amount || 500000,
          message: 'Insurance verified successfully',
        };
      }

      return {
        verified: false,
        status: 'invalid',
        message: 'Insurance verification failed',
      };
    } catch (error) {
      logger.error('Aarogyasri verification error:', error);
      return { verified: false, error: error.message };
    }
  }

  /**
   * Verify Private Insurance (Mock implementation)
   */
  async verifyPrivateInsurance(insurance) {
    try {
      logger.info('Verifying private insurance');

      await new Promise(resolve => setTimeout(resolve, 1000));

      const isValid = insurance.policyNumber && insurance.validUpto > new Date();

      if (isValid) {
        return {
          verified: true,
          status: 'active',
          provider: insurance.providerName,
          coverage: insurance.coverage.amount,
          message: 'Insurance verified successfully',
        };
      }

      return {
        verified: false,
        status: 'invalid',
        message: 'Insurance verification failed',
      };
    } catch (error) {
      logger.error('Private insurance verification error:', error);
      return { verified: false, error: error.message };
    }
  }

  /**
   * Send pre-approval to hospital
   */
  async sendPreApproval(emergencyId, hospitalId, insurance) {
    try {
      logger.info(`Sending insurance pre-approval for emergency ${emergencyId}`);

      const HospitalModel = require('../models/hospital.model');
      const hospital = await HospitalModel.getById(hospitalId);

      if (!hospital) {
        throw new Error('Hospital not found');
      }

      const message = `✅ INSURANCE PRE-APPROVAL

Emergency ID: ${emergencyId}
Policy: ${insurance.policyNumber}
Provider: ${insurance.providerName || insurance.provider}
Coverage: ₹${insurance.coverage.amount}
Status: APPROVED

Patient is eligible for cashless treatment.
- ArogyaRaksha AI`;

      await smsService.sendSMS(hospital.contact.emergencyPhone, message);

      logger.success('Insurance pre-approval sent to hospital');

      return { success: true };
    } catch (error) {
      logger.error('Send pre-approval error:', error);
      throw error;
    }
  }

  /**
   * Fetch insurance from DigiLocker
   */
  async fetchFromDigiLocker(userId, accessToken) {
    try {
      logger.info('Fetching insurance from DigiLocker');

      const documents = await digilockerService.fetchInsuranceDocuments(userId, accessToken);

      if (documents.length === 0) {
        return {
          success: false,
          message: 'No insurance documents found in DigiLocker',
        };
      }

      // Process first insurance document
      const insuranceDoc = documents[0];

      // Parse document and create insurance record
      // This is a simplified version - actual implementation would parse PDF
      const insuranceData = {
        userId: userId,
        provider: this.detectProvider(insuranceDoc.documentName),
        providerName: insuranceDoc.issuer,
        policyNumber: 'EXTRACTED_FROM_DOC', // Would be extracted from PDF
        policyHolderName: 'EXTRACTED_FROM_DOC',
        coverage: {
          amount: 500000, // Would be extracted from PDF
          type: 'health',
        },
        validFrom: new Date(),
        validUpto: new Date(Date.now() + 365 * 24 * 60 * 60 * 1000), // 1 year
        status: InsuranceStatus.PENDING,
        digilockerLinked: true,
        digilockerDocumentId: insuranceDoc.docId,
      };

      const insurance = await InsuranceModel.create(insuranceData);

      logger.success('Insurance fetched from DigiLocker');

      return {
        success: true,
        insurance: insurance,
      };
    } catch (error) {
      logger.error('Fetch from DigiLocker error:', error);
      throw error;
    }
  }

  /**
   * Detect insurance provider from document name
   */
  detectProvider(documentName) {
    const nameLower = documentName.toLowerCase();

    if (nameLower.includes('ayushman')) {
      return InsuranceProvider.AYUSHMAN_BHARAT;
    } else if (nameLower.includes('aarogyasri')) {
      return InsuranceProvider.AAROGYASRI;
    }

    return InsuranceProvider.PRIVATE;
  }

  /**
   * Check insurance eligibility
   */
  async checkEligibility(userId, treatmentType = 'emergency') {
    try {
      const insurance = await InsuranceModel.getByUserId(userId);

      if (!insurance) {
        return {
          eligible: false,
          reason: 'No insurance found',
        };
      }

      const isValid = await InsuranceModel.isValid(insurance.insuranceId);

      if (!isValid) {
        return {
          eligible: false,
          reason: 'Insurance expired or inactive',
        };
      }

      // Check if treatment is covered
      const isCovered = this.isTreatmentCovered(insurance, treatmentType);

      if (!isCovered) {
        return {
          eligible: false,
          reason: 'Treatment not covered',
        };
      }

      return {
        eligible: true,
        insurance: insurance,
        coverage: insurance.coverage.amount,
      };
    } catch (error) {
      logger.error('Check eligibility error:', error);
      throw error;
    }
  }

  /**
   * Check if treatment is covered
   */
  isTreatmentCovered(insurance, treatmentType) {
    // Emergency treatments are usually covered
    if (treatmentType === 'emergency') {
      return true;
    }

    // Check specific coverage
    const { coverageDetails } = insurance;

    switch (treatmentType) {
      case 'maternity':
        return coverageDetails?.maternity || false;
      case 'dental':
        return coverageDetails?.dentalCare || false;
      case 'daycare':
        return coverageDetails?.dayCareProcedures || false;
      default:
        return true;
    }
  }

  /**
   * Add insurance claim
   */
  async addClaim(insuranceId, claimData) {
    try {
      const claim = await InsuranceModel.addClaim(insuranceId, claimData);
      logger.info(`Claim added for insurance ${insuranceId}`);
      return claim;
    } catch (error) {
      logger.error('Add claim error:', error);
      throw error;
    }
  }

  /**
   * Send insurance verification notification
   */
  async sendVerificationNotification(userId, insurance) {
    try {
      await fcmService.sendInsuranceVerifiedNotification(userId, insurance);
      await smsService.sendInsuranceVerificationSMS(
        insurance.policyHolderName, // Would need user's phone
        insurance
      );

      logger.success('Insurance verification notification sent');
    } catch (error) {
      logger.error('Send verification notification error:', error);
    }
  }

  /**
   * Get insurance status
   */
  async getInsuranceStatus(userId) {
    try {
      const insurance = await InsuranceModel.getByUserId(userId);

      if (!insurance) {
        return {
          hasInsurance: false,
          status: 'not_found',
        };
      }

      const isValid = await InsuranceModel.isValid(insurance.insuranceId);

      return {
        hasInsurance: true,
        status: insurance.status,
        isValid: isValid,
        insurance: insurance,
      };
    } catch (error) {
      logger.error('Get insurance status error:', error);
      throw error;
    }
  }
}

module.exports = new InsuranceService();