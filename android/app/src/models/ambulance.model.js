const { ambulancesCollection } = require('../config/database.config');
const { v4: uuidv4 } = require('uuid');
const { AmbulanceStatus } = require('../utils/constants.util');

/**
 * Ambulance Model Schema
 */
class AmbulanceModel {
  static collectionName = 'ambulances';

  /**
   * Create new ambulance
   */
  static async create(ambulanceData) {
    const ambulanceId = uuidv4();

    const ambulance = {
      ambulanceId: ambulanceId,
      vehicleNumber: ambulanceData.vehicleNumber,
      type: ambulanceData.type || 'basic', // basic, advanced, ICU

      driverInfo: {
        name: ambulanceData.driverInfo.name,
        phone: ambulanceData.driverInfo.phone,
        licenseNumber: ambulanceData.driverInfo.licenseNumber,
      },

      location: {
        latitude: ambulanceData.location.latitude,
        longitude: ambulanceData.location.longitude,
        address: ambulanceData.location.address || '',
        lastUpdated: new Date(),
      },

      status: ambulanceData.status || AmbulanceStatus.AVAILABLE,

      // Current assignment
      currentEmergencyId: null,

      // Facilities available
      facilities: {
        oxygen: ambulanceData.facilities?.oxygen || false,
        ventilator: ambulanceData.facilities?.ventilator || false,
        defibrillator: ambulanceData.facilities?.defibrillator || false,
        bloodPressureMonitor: ambulanceData.facilities?.bloodPressureMonitor || true,
        firstAidKit: ambulanceData.facilities?.firstAidKit || true,
        stretcher: ambulanceData.facilities?.stretcher || true,
      },

      // Service provider (govt/private)
      provider: ambulanceData.provider || '108', // 108, private, NGO
      providerContact: ambulanceData.providerContact || '',

      // Rating
      rating: ambulanceData.rating || 0,
      totalRides: ambulanceData.totalRides || 0,

      isActive: ambulanceData.isActive !== undefined ? ambulanceData.isActive : true,

      createdAt: new Date(),
      updatedAt: new Date(),
    };

    await ambulancesCollection().doc(ambulanceId).set(ambulance);
    return { id: ambulanceId, ...ambulance };
  }

  /**
   * Get ambulance by ID
   */
  static async getById(ambulanceId) {
    const doc = await ambulancesCollection().doc(ambulanceId).get();
    if (!doc.exists) {
      return null;
    }
    return { id: doc.id, ...doc.data() };
  }

  /**
   * Update ambulance location
   */
  static async updateLocation(ambulanceId, latitude, longitude, address = '') {
    const updates = {
      'location.latitude': latitude,
      'location.longitude': longitude,
      'location.address': address,
      'location.lastUpdated': new Date(),
      updatedAt: new Date(),
    };

    await ambulancesCollection().doc(ambulanceId).update(updates);
    return await this.getById(ambulanceId);
  }

  /**
   * Update ambulance status
   */
  static async updateStatus(ambulanceId, status, emergencyId = null) {
    const updates = {
      status,
      updatedAt: new Date(),
    };

    if (emergencyId) {
      updates.currentEmergencyId = emergencyId;
    }

    // Clear emergency ID if becoming available
    if (status === AmbulanceStatus.AVAILABLE) {
      updates.currentEmergencyId = null;
    }

    await ambulancesCollection().doc(ambulanceId).update(updates);
    return await this.getById(ambulanceId);
  }

  /**
   * Get available ambulances within radius
   */
  static async getAvailableNearby(latitude, longitude, radiusKm = 15) {
    // Note: Firestore doesn't support geoqueries natively
    // For production, use GeoFirestore or implement custom logic

    const snapshot = await ambulancesCollection()
      .where('status', '==', AmbulanceStatus.AVAILABLE)
      .where('isActive', '==', true)
      .get();

    const ambulances = snapshot.docs.map(doc => ({ id: doc.id, ...doc.data() }));

    // Filter by distance (client-side for now)
    const { calculateDistance } = require('../utils/distance.util');

    return ambulances
      .map(ambulance => ({
        ...ambulance,
        distance: calculateDistance(
          latitude,
          longitude,
          ambulance.location.latitude,
          ambulance.location.longitude
        ),
      }))
      .filter(ambulance => ambulance.distance <= radiusKm)
      .sort((a, b) => a.distance - b.distance);
  }

  /**
   * Get all ambulances (for admin)
   */
  static async getAll(filters = {}) {
    let query = ambulancesCollection();

    if (filters.status) {
      query = query.where('status', '==', filters.status);
    }

    if (filters.type) {
      query = query.where('type', '==', filters.type);
    }

    const snapshot = await query.get();
    return snapshot.docs.map(doc => ({ id: doc.id, ...doc.data() }));
  }

  /**
   * Assign ambulance to emergency
   */
  static async assignToEmergency(ambulanceId, emergencyId) {
    return await this.updateStatus(ambulanceId, AmbulanceStatus.ASSIGNED, emergencyId);
  }

  /**
   * Complete ride
   */
  static async completeRide(ambulanceId) {
    const ambulance = await this.getById(ambulanceId);

    const updates = {
      status: AmbulanceStatus.AVAILABLE,
      currentEmergencyId: null,
      totalRides: (ambulance.totalRides || 0) + 1,
      updatedAt: new Date(),
    };

    await ambulancesCollection().doc(ambulanceId).update(updates);
    return await this.getById(ambulanceId);
  }
}

module.exports = AmbulanceModel;