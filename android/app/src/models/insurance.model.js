const { insuranceCollection } = require('../config/database.config');
const { v4: uuidv4 } = require('uuid');
const { InsuranceStatus, InsuranceProvider } = require('../utils/constants.util');

/**
 * Insurance Model Schema
 */
class InsuranceModel {
  static collectionName = 'insurance';

  /**
   * Create new insurance record
   */
  static async create(insuranceData) {
    const insuranceId = uuidv4();

    const insurance = {
      insuranceId: insuranceId,
      userId: insuranceData.userId,

      // Provider details
      provider: insuranceData.provider || InsuranceProvider.PRIVATE,
      providerName: insuranceData.providerName || '',

      // Policy details
      policyNumber: insuranceData.policyNumber,
      policyHolderName: insuranceData.policyHolderName,
      policyHolderAadhaar: insuranceData.policyHolderAadhaar || null,

      // Coverage
      coverage: {
        amount: insuranceData.coverage?.amount || 0,
        type: insuranceData.coverage?.type || 'health', // health, accidental, life
        familyFloater: insuranceData.coverage?.familyFloater || false,
      },

      // Validity
      validFrom: insuranceData.validFrom || new Date(),
      validUpto: insuranceData.validUpto,

      // Status
      status: insuranceData.status || InsuranceStatus.PENDING,

      // Verification
      isVerified: insuranceData.isVerified || false,
      verifiedAt: null,
      verifiedBy: null,

      // DigiLocker integration
      digilockerLinked: insuranceData.digilockerLinked || false,
      digilockerDocumentId: insuranceData.digilockerDocumentId || null,

      // Coverage details
      coverageDetails: {
        preExistingDiseases: insuranceData.coverageDetails?.preExistingDiseases || false,
        maternity: insuranceData.coverageDetails?.maternity || false,
        dentalCare: insuranceData.coverageDetails?.dentalCare || false,
        dayCareProcedures: insuranceData.coverageDetails?.dayCareProcedures || false,
        ambulanceCover: insuranceData.coverageDetails?.ambulanceCover || false,
      },

      // Claim history
      claimHistory: insuranceData.claimHistory || [],
      totalClaimedAmount: insuranceData.totalClaimedAmount || 0,

      // Network hospitals
      networkHospitals: insuranceData.networkHospitals || [],

      // Documents
      documents: {
        policyDocument: insuranceData.documents?.policyDocument || null,
        idProof: insuranceData.documents?.idProof || null,
        addressProof: insuranceData.documents?.addressProof || null,
      },

      // Contact info
      customerCareNumber: insuranceData.customerCareNumber || '',
      emailId: insuranceData.emailId || null,

      isActive: insuranceData.isActive !== undefined ? insuranceData.isActive : true,

      createdAt: new Date(),
      updatedAt: new Date(),
    };

    await insuranceCollection().doc(insuranceId).set(insurance);
    return { id: insuranceId, ...insurance };
  }

  /**
   * Get insurance by ID
   */
  static async getById(insuranceId) {
    const doc = await insuranceCollection().doc(insuranceId).get();
    if (!doc.exists) {
      return null;
    }
    return { id: doc.id, ...doc.data() };
  }

  /**
   * Get insurance by user ID
   */
  static async getByUserId(userId) {
    const snapshot = await insuranceCollection()
      .where('userId', '==', userId)
      .where('isActive', '==', true)
      .get();

    if (snapshot.empty) {
      return null;
    }

    const doc = snapshot.docs[0];
    return { id: doc.id, ...doc.data() };
  }

  /**
   * Get insurance by policy number
   */
  static async getByPolicyNumber(policyNumber) {
    const snapshot = await insuranceCollection()
      .where('policyNumber', '==', policyNumber)
      .limit(1)
      .get();

    if (snapshot.empty) {
      return null;
    }

    const doc = snapshot.docs[0];
    return { id: doc.id, ...doc.data() };
  }

  /**
   * Verify insurance
   */
  static async verify(insuranceId, verifiedBy = 'system') {
    const updates = {
      status: InsuranceStatus.VERIFIED,
      isVerified: true,
      verifiedAt: new Date(),
      verifiedBy: verifiedBy,
      updatedAt: new Date(),
    };

    await insuranceCollection().doc(insuranceId).update(updates);
    return await this.getById(insuranceId);
  }

  /**
   * Update insurance status
   */
  static async updateStatus(insuranceId, status) {
    const updates = {
      status: status,
      updatedAt: new Date(),
    };

    if (status === InsuranceStatus.EXPIRED) {
      updates.isActive = false;
    }

    await insuranceCollection().doc(insuranceId).update(updates);
    return await this.getById(insuranceId);
  }

  /**
   * Add claim to history
   */
  static async addClaim(insuranceId, claimData) {
    const insurance = await this.getById(insuranceId);
    const claimHistory = insurance.claimHistory || [];

    const newClaim = {
      claimId: uuidv4(),
      emergencyId: claimData.emergencyId,
      hospitalId: claimData.hospitalId,
      claimAmount: claimData.claimAmount,
      approvedAmount: claimData.approvedAmount || 0,
      status: claimData.status || 'pending', // pending, approved, rejected
      claimDate: new Date(),
      settlementDate: claimData.settlementDate || null,
      remarks: claimData.remarks || '',
    };

    claimHistory.push(newClaim);

    const updates = {
      claimHistory: claimHistory,
      totalClaimedAmount: (insurance.totalClaimedAmount || 0) + (claimData.approvedAmount || 0),
      updatedAt: new Date(),
    };

    await insuranceCollection().doc(insuranceId).update(updates);
    return await this.getById(insuranceId);
  }

  /**
   * Check if insurance is valid
   */
  static async isValid(insuranceId) {
    const insurance = await this.getById(insuranceId);
    if (!insurance) return false;

    const now = new Date();
    const validUpto = new Date(insurance.validUpto);

    return (
      insurance.isActive &&
      insurance.status === InsuranceStatus.VERIFIED &&
      validUpto > now
    );
  }

  /**
   * Link DigiLocker document
   */
  static async linkDigiLocker(insuranceId, documentId) {
    const updates = {
      digilockerLinked: true,
      digilockerDocumentId: documentId,
      updatedAt: new Date(),
    };

    await insuranceCollection().doc(insuranceId).update(updates);
    return await this.getById(insuranceId);
  }

  /**
   * Update insurance details
   */
  static async update(insuranceId, updateData) {
    const updates = {
      ...updateData,
      updatedAt: new Date(),
    };

    await insuranceCollection().doc(insuranceId).update(updates);
    return await this.getById(insuranceId);
  }

  /**
   * Delete insurance
   */
  static async delete(insuranceId) {
    await insuranceCollection().doc(insuranceId).delete();
    return true;
  }

  /**
   * Get expiring insurances (for reminders)
   */
  static async getExpiringSoon(daysBeforeExpiry = 30) {
    const futureDate = new Date();
    futureDate.setDate(futureDate.getDate() + daysBeforeExpiry);

    const snapshot = await insuranceCollection()
      .where('isActive', '==', true)
      .where('validUpto', '<=', futureDate)
      .get();

    return snapshot.docs.map(doc => ({ id: doc.id, ...doc.data() }));
  }
}

module.exports = InsuranceModel;