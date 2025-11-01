const { hospitalsCollection } = require('../config/database.config');
const { v4: uuidv4 } = require('uuid');

/**
 * Hospital Model Schema
 */
class HospitalModel {
  static collectionName = 'hospitals';

  /**
   * Create new hospital
   */
  static async create(hospitalData) {
    const hospitalId = uuidv4();

    const hospital = {
      hospitalId: hospitalId,
      name: hospitalData.name,
      type: hospitalData.type || 'general', // general, specialty, trauma_center

      contact: {
        phone: hospitalData.contact.phone,
        emergencyPhone: hospitalData.contact.emergencyPhone || hospitalData.contact.phone,
        email: hospitalData.contact.email || null,
      },

      location: {
        latitude: hospitalData.location.latitude,
        longitude: hospitalData.location.longitude,
        address: hospitalData.location.address,
        city: hospitalData.location.city,
        state: hospitalData.location.state,
        pincode: hospitalData.location.pincode,
      },

      // Facilities and departments
      facilities: {
        emergencyWard: hospitalData.facilities?.emergencyWard || true,
        ICU: hospitalData.facilities?.ICU || false,
        NICU: hospitalData.facilities?.NICU || false,
        operationTheater: hospitalData.facilities?.operationTheater || false,
        bloodBank: hospitalData.facilities?.bloodBank || false,
        ambulanceService: hospitalData.facilities?.ambulanceService || false,
        pharmacy: hospitalData.facilities?.pharmacy || true,
        diagnostics: hospitalData.facilities?.diagnostics || true,
      },

      specialties: hospitalData.specialties || [], // cardiology, neurology, orthopedics, etc.

      // Bed availability
      beds: {
        total: hospitalData.beds?.total || 0,
        available: hospitalData.beds?.available || 0,
        ICU: {
          total: hospitalData.beds?.ICU?.total || 0,
          available: hospitalData.beds?.ICU?.available || 0,
        },
        emergency: {
          total: hospitalData.beds?.emergency?.total || 0,
          available: hospitalData.beds?.emergency?.available || 0,
        },
        lastUpdated: new Date(),
      },

      // Insurance accepted
      insuranceAccepted: hospitalData.insuranceAccepted || [
        'ayushman_bharat',
        'aarogyasri',
        'private',
      ],

      // Rating
      rating: hospitalData.rating || 0,
      totalPatients: hospitalData.totalPatients || 0,

      // Operating hours
      operatingHours: {
        emergency24x7: hospitalData.operatingHours?.emergency24x7 || true,
        opdTimings: hospitalData.operatingHours?.opdTimings || '9:00 AM - 8:00 PM',
      },

      isActive: hospitalData.isActive !== undefined ? hospitalData.isActive : true,
      isGovernment: hospitalData.isGovernment || false,

      createdAt: new Date(),
      updatedAt: new Date(),
    };

    await hospitalsCollection().doc(hospitalId).set(hospital);
    return { id: hospitalId, ...hospital };
  }

  /**
   * Get hospital by ID
   */
  static async getById(hospitalId) {
    const doc = await hospitalsCollection().doc(hospitalId).get();
    if (!doc.exists) {
      return null;
    }
    return { id: doc.id, ...doc.data() };
  }

  /**
   * Update bed availability
   */
  static async updateBedAvailability(hospitalId, bedUpdates) {
    const updates = {
      beds: {
        ...bedUpdates,
        lastUpdated: new Date(),
      },
      updatedAt: new Date(),
    };

    await hospitalsCollection().doc(hospitalId).update(updates);
    return await this.getById(hospitalId);
  }

  /**
   * Get nearby hospitals
   */
  static async getNearby(latitude, longitude, radiusKm = 20, filters = {}) {
    let query = hospitalsCollection().where('isActive', '==', true);

    // Apply filters
    if (filters.type) {
      query = query.where('type', '==', filters.type);
    }

    const snapshot = await query.get();
    const hospitals = snapshot.docs.map(doc => ({ id: doc.id, ...doc.data() }));

    // Calculate distance and filter by radius
    const { calculateDistance } = require('../utils/distance.util');

    return hospitals
      .map(hospital => ({
        ...hospital,
        distance: calculateDistance(
          latitude,
          longitude,
          hospital.location.latitude,
          hospital.location.longitude
        ),
      }))
      .filter(hospital => hospital.distance <= radiusKm)
      .sort((a, b) => a.distance - b.distance);
  }

  /**
   * Get hospitals with available beds
   */
  static async getWithAvailableBeds(latitude, longitude, bedType = 'emergency') {
    const hospitals = await this.getNearby(latitude, longitude);

    return hospitals.filter(hospital => {
      if (bedType === 'ICU') {
        return hospital.beds?.ICU?.available > 0;
      } else if (bedType === 'emergency') {
        return hospital.beds?.emergency?.available > 0;
      }
      return hospital.beds?.available > 0;
    });
  }

  /**
   * Check if hospital accepts insurance
   */
  static async checkInsuranceAccepted(hospitalId, insuranceProvider) {
    const hospital = await this.getById(hospitalId);
    if (!hospital) return false;

    return hospital.insuranceAccepted?.includes(insuranceProvider) || false;
  }

  /**
   * Get all hospitals (for admin)
   */
  static async getAll(filters = {}) {
    let query = hospitalsCollection();

    if (filters.city) {
      query = query.where('location.city', '==', filters.city);
    }

    if (filters.type) {
      query = query.where('type', '==', filters.type);
    }

    const snapshot = await query.get();
    return snapshot.docs.map(doc => ({ id: doc.id, ...doc.data() }));
  }

  /**
   * Search hospitals by name
   */
  static async search(searchTerm) {
    const snapshot = await hospitalsCollection()
      .where('isActive', '==', true)
      .get();

    const hospitals = snapshot.docs.map(doc => ({ id: doc.id, ...doc.data() }));

    return hospitals.filter(hospital =>
      hospital.name.toLowerCase().includes(searchTerm.toLowerCase())
    );
  }
}

module.exports = HospitalModel;