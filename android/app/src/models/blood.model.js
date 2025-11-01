const { bloodBanksCollection, bloodRequestsCollection } = require('../config/database.config');
const { v4: uuidv4 } = require('uuid');
const { BloodGroup, BloodRequestStatus } = require('../utils/constants.util');

/**
 * Blood Bank Model Schema
 */
class BloodBankModel {
  static collectionName = 'blood_banks';

  /**
   * Create new blood bank
   */
  static async create(bloodBankData) {
    const bloodBankId = uuidv4();

    const bloodBank = {
      bloodBankId: bloodBankId,
      name: bloodBankData.name,

      // Contact details
      contact: {
        phone: bloodBankData.contact.phone,
        emergencyPhone: bloodBankData.contact.emergencyPhone || bloodBankData.contact.phone,
        email: bloodBankData.contact.email || null,
      },

      // Location
      location: {
        latitude: bloodBankData.location.latitude,
        longitude: bloodBankData.location.longitude,
        address: bloodBankData.location.address,
        city: bloodBankData.location.city,
        state: bloodBankData.location.state,
        pincode: bloodBankData.location.pincode,
      },

      // Associated with hospital
      hospitalId: bloodBankData.hospitalId || null,
      hospitalName: bloodBankData.hospitalName || null,

      // Blood availability (units available for each blood group)
      bloodAvailability: {
        'A+': bloodBankData.bloodAvailability?.['A+'] || 0,
        'A-': bloodBankData.bloodAvailability?.['A-'] || 0,
        'B+': bloodBankData.bloodAvailability?.['B+'] || 0,
        'B-': bloodBankData.bloodAvailability?.['B-'] || 0,
        'O+': bloodBankData.bloodAvailability?.['O+'] || 0,
        'O-': bloodBankData.bloodAvailability?.['O-'] || 0,
        'AB+': bloodBankData.bloodAvailability?.['AB+'] || 0,
        'AB-': bloodBankData.bloodAvailability?.['AB-'] || 0,
        lastUpdated: new Date(),
      },

      // Operating hours
      operatingHours: {
        is24x7: bloodBankData.operatingHours?.is24x7 || false,
        timings: bloodBankData.operatingHours?.timings || '9:00 AM - 6:00 PM',
      },

      // Facilities
      facilities: {
        bloodTesting: bloodBankData.facilities?.bloodTesting || true,
        componentSeparation: bloodBankData.facilities?.componentSeparation || false,
        bloodStorage: bloodBankData.facilities?.bloodStorage || true,
      },

      // Type
      type: bloodBankData.type || 'hospital', // hospital, standalone, mobile

      isActive: bloodBankData.isActive !== undefined ? bloodBankData.isActive : true,
      isGovernment: bloodBankData.isGovernment || false,

      // Stats
      totalDonations: bloodBankData.totalDonations || 0,
      totalRequests: bloodBankData.totalRequests || 0,

      createdAt: new Date(),
      updatedAt: new Date(),
    };

    await bloodBanksCollection().doc(bloodBankId).set(bloodBank);
    return { id: bloodBankId, ...bloodBank };
  }

  /**
   * Get blood bank by ID
   */
  static async getById(bloodBankId) {
    const doc = await bloodBanksCollection().doc(bloodBankId).get();
    if (!doc.exists) {
      return null;
    }
    return { id: doc.id, ...doc.data() };
  }

  /**
   * Update blood availability
   */
  static async updateAvailability(bloodBankId, bloodGroup, units) {
    const updates = {
      [`bloodAvailability.${bloodGroup}`]: units,
      'bloodAvailability.lastUpdated': new Date(),
      updatedAt: new Date(),
    };

    await bloodBanksCollection().doc(bloodBankId).update(updates);
    return await this.getById(bloodBankId);
  }

  /**
   * Check blood availability
   */
  static async checkAvailability(bloodBankId, bloodGroup) {
    const bloodBank = await this.getById(bloodBankId);
    if (!bloodBank) return 0;

    return bloodBank.bloodAvailability?.[bloodGroup] || 0;
  }

  /**
   * Get nearby blood banks with availability
   */
  static async getNearbyWithBlood(latitude, longitude, bloodGroup, radiusKm = 25) {
    const snapshot = await bloodBanksCollection()
      .where('isActive', '==', true)
      .get();

    const bloodBanks = snapshot.docs.map(doc => ({ id: doc.id, ...doc.data() }));

    // Filter by availability and distance
    const { calculateDistance } = require('../utils/distance.util');

    return bloodBanks
      .filter(bank => (bank.bloodAvailability?.[bloodGroup] || 0) > 0)
      .map(bank => ({
        ...bank,
        distance: calculateDistance(
          latitude,
          longitude,
          bank.location.latitude,
          bank.location.longitude
        ),
        availableUnits: bank.bloodAvailability?.[bloodGroup] || 0,
      }))
      .filter(bank => bank.distance <= radiusKm)
      .sort((a, b) => a.distance - b.distance);
  }

  /**
   * Get all blood banks
   */
  static async getAll(filters = {}) {
    let query = bloodBanksCollection();

    if (filters.city) {
      query = query.where('location.city', '==', filters.city);
    }

    const snapshot = await query.get();
    return snapshot.docs.map(doc => ({ id: doc.id, ...doc.data() }));
  }
}

/**
 * Blood Request Model Schema
 */
class BloodRequestModel {
  static collectionName = 'blood_requests';

  /**
   * Create new blood request
   */
  static async create(requestData) {
    const requestId = uuidv4();

    const request = {
      requestId: requestId,

      // Requester details
      userId: requestData.userId,
      emergencyId: requestData.emergencyId || null,

      // Patient details
      patientName: requestData.patientName,
      patientAge: requestData.patientAge,
      patientGender: requestData.patientGender,
      patientPhone: requestData.patientPhone,

      // Blood requirement
      bloodGroup: requestData.bloodGroup,
      unitsRequired: requestData.unitsRequired || 1,
      urgency: requestData.urgency || 'high', // low, medium, high, critical

      // Location
      location: {
        latitude: requestData.location.latitude,
        longitude: requestData.location.longitude,
        address: requestData.location.address,
      },

      // Hospital details
      hospitalId: requestData.hospitalId || null,
      hospitalName: requestData.hospitalName || '',

      // Medical condition
      medicalCondition: requestData.medicalCondition || '',
      reason: requestData.reason || '',

      // Status
      status: BloodRequestStatus.PENDING,

      // Matched blood banks
      matchedBloodBanks: [],

      // Fulfillment
      fulfilledBy: null,
      fulfilledAt: null,

      // Expiry
      requiredBy: requestData.requiredBy || null,
      expiresAt: requestData.expiresAt || (() => {
        const expiryDate = new Date();
        expiryDate.setHours(expiryDate.getHours() + 24); // 24 hours validity
        return expiryDate;
      })(),

      // Contact preferences
      contactPreference: requestData.contactPreference || 'phone', // phone, email, both

      createdAt: new Date(),
      updatedAt: new Date(),
    };

    await bloodRequestsCollection().doc(requestId).set(request);
    return { id: requestId, ...request };
  }

  /**
   * Get blood request by ID
   */
  static async getById(requestId) {
    const doc = await bloodRequestsCollection().doc(requestId).get();
    if (!doc.exists) {
      return null;
    }
    return { id: doc.id, ...doc.data() };
  }

  /**
   * Update request status
   */
  static async updateStatus(requestId, status, fulfilledBy = null) {
    const updates = {
      status: status,
      updatedAt: new Date(),
    };

    if (status === BloodRequestStatus.FULFILLED && fulfilledBy) {
      updates.fulfilledBy = fulfilledBy;
      updates.fulfilledAt = new Date();
    }

    await bloodRequestsCollection().doc(requestId).update(updates);
    return await this.getById(requestId);
  }

  /**
   * Add matched blood banks
   */
  static async addMatchedBloodBanks(requestId, bloodBanks) {
    const updates = {
      matchedBloodBanks: bloodBanks,
      status: BloodRequestStatus.MATCHED,
      updatedAt: new Date(),
    };

    await bloodRequestsCollection().doc(requestId).update(updates);
    return await this.getById(requestId);
  }

  /**
   * Get active requests by blood group
   */
  static async getActiveByBloodGroup(bloodGroup) {
    const snapshot = await bloodRequestsCollection()
      .where('bloodGroup', '==', bloodGroup)
      .where('status', 'in', [BloodRequestStatus.PENDING, BloodRequestStatus.MATCHED])
      .orderBy('createdAt', 'desc')
      .get();

    return snapshot.docs.map(doc => ({ id: doc.id, ...doc.data() }));
  }

  /**
   * Get user's blood requests
   */
  static async getUserRequests(userId, limit = 10) {
    const snapshot = await bloodRequestsCollection()
      .where('userId', '==', userId)
      .orderBy('createdAt', 'desc')
      .limit(limit)
      .get();

    return snapshot.docs.map(doc => ({ id: doc.id, ...doc.data() }));
  }

  /**
   * Cancel blood request
   */
  static async cancel(requestId, reason = '') {
    const updates = {
      status: BloodRequestStatus.CANCELLED,
      cancelReason: reason,
      updatedAt: new Date(),
    };

    await bloodRequestsCollection().doc(requestId).update(updates);
    return await this.getById(requestId);
  }
}

module.exports = {
  BloodBankModel,
  BloodRequestModel,
};