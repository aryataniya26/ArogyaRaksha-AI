const { emergenciesCollection } = require('../config/database.config');
const { v4: uuidv4 } = require('uuid');
const { EmergencyStatus, EmergencyType } = require('../utils/constants.util');

/**
 * Emergency Model Schema
 */
class EmergencyModel {
  static collectionName = 'emergencies';

  /**
   * Create new emergency
   */
  static async create(emergencyData) {
    const emergencyId = uuidv4();

    const emergency = {
      emergencyId: emergencyId,
      userId: emergencyData.userId,
      patientInfo: {
        name: emergencyData.patientInfo.name,
        age: emergencyData.patientInfo.age,
        gender: emergencyData.patientInfo.gender,
        bloodGroup: emergencyData.patientInfo.bloodGroup,
        phoneNumber: emergencyData.patientInfo.phoneNumber,
      },
      location: {
        latitude: emergencyData.location.latitude,
        longitude: emergencyData.location.longitude,
        address: emergencyData.location.address || '',
      },
      emergencyType: emergencyData.emergencyType || EmergencyType.OTHER,
      symptoms: emergencyData.symptoms || [],
      status: EmergencyStatus.TRIGGERED,
      priority: emergencyData.priority || 'high', // low, medium, high, critical

      // Ambulance details
      ambulanceId: null,
      ambulanceDetails: null,
      ambulanceAssignedAt: null,
      ambulanceArrivedAt: null,

      // Hospital details
      hospitalId: null,
      hospitalDetails: null,
      estimatedArrivalTime: null,

      // Insurance details
      insurance: {
        hasInsurance: emergencyData.insurance?.hasInsurance || false,
        provider: emergencyData.insurance?.provider || null,
        policyNumber: emergencyData.insurance?.policyNumber || null,
        status: emergencyData.insurance?.status || 'pending',
        preApprovalSent: false,
      },

      // Timeline
      timeline: [
        {
          status: EmergencyStatus.TRIGGERED,
          timestamp: new Date(),
          message: 'Emergency triggered',
        },
      ],

      // Contact alerts sent
      alertsSent: {
        emergencyContacts: false,
        ambulance: false,
        hospital: false,
        bloodBank: false,
        sms: false,
      },

      // Offline mode (SMS backup)
      isOfflineMode: emergencyData.isOfflineMode || false,

      // Additional info
      vitals: emergencyData.vitals || null, // BP, pulse, sugar at time of emergency
      notes: emergencyData.notes || '',

      createdAt: new Date(),
      updatedAt: new Date(),
      completedAt: null,
    };

    await emergenciesCollection().doc(emergencyId).set(emergency);
    return { id: emergencyId, ...emergency };
  }

  /**
   * Get emergency by ID
   */
  static async getById(emergencyId) {
    const doc = await emergenciesCollection().doc(emergencyId).get();
    if (!doc.exists) {
      return null;
    }
    return { id: doc.id, ...doc.data() };
  }

  /**
   * Update emergency status
   */
  static async updateStatus(emergencyId, status, message = '') {
    const emergency = await this.getById(emergencyId);

    const timeline = emergency.timeline || [];
    timeline.push({
      status,
      timestamp: new Date(),
      message: message || `Status updated to ${status}`,
    });

    const updates = {
      status,
      timeline,
      updatedAt: new Date(),
    };

    // Update specific timestamps
    if (status === EmergencyStatus.AMBULANCE_ASSIGNED) {
      updates.ambulanceAssignedAt = new Date();
    } else if (status === EmergencyStatus.AMBULANCE_ARRIVED) {
      updates.ambulanceArrivedAt = new Date();
    } else if (status === EmergencyStatus.COMPLETED || status === EmergencyStatus.CANCELLED) {
      updates.completedAt = new Date();
    }

    await emergenciesCollection().doc(emergencyId).update(updates);
    return await this.getById(emergencyId);
  }

  /**
   * Assign ambulance to emergency
   */
  static async assignAmbulance(emergencyId, ambulanceData) {
    const updates = {
      ambulanceId: ambulanceData.ambulanceId,
      ambulanceDetails: {
        driverName: ambulanceData.driverName,
        driverPhone: ambulanceData.driverPhone,
        vehicleNumber: ambulanceData.vehicleNumber,
        type: ambulanceData.type, // basic, advanced, ICU
      },
      status: EmergencyStatus.AMBULANCE_ASSIGNED,
      ambulanceAssignedAt: new Date(),
      'alertsSent.ambulance': true,
      updatedAt: new Date(),
    };

    await emergenciesCollection().doc(emergencyId).update(updates);
    await this.updateStatus(emergencyId, EmergencyStatus.AMBULANCE_ASSIGNED, 'Ambulance assigned');
    return await this.getById(emergencyId);
  }

  /**
   * Assign hospital to emergency
   */
  static async assignHospital(emergencyId, hospitalData) {
    const updates = {
      hospitalId: hospitalData.hospitalId,
      hospitalDetails: {
        name: hospitalData.name,
        phone: hospitalData.phone,
        address: hospitalData.address,
        distance: hospitalData.distance,
      },
      estimatedArrivalTime: hospitalData.estimatedArrivalTime,
      'alertsSent.hospital': true,
      updatedAt: new Date(),
    };

    await emergenciesCollection().doc(emergencyId).update(updates);
    return await this.getById(emergencyId);
  }

  /**
   * Get user's emergency history
   */
  static async getUserEmergencies(userId, limit = 10) {
    const snapshot = await emergenciesCollection()
      .where('userId', '==', userId)
      .orderBy('createdAt', 'desc')
      .limit(limit)
      .get();

    return snapshot.docs.map(doc => ({ id: doc.id, ...doc.data() }));
  }

  /**
   * Get active emergencies (for monitoring)
   */
  static async getActiveEmergencies() {
    const activeStatuses = [
      EmergencyStatus.TRIGGERED,
      EmergencyStatus.AMBULANCE_ASSIGNED,
      EmergencyStatus.AMBULANCE_EN_ROUTE,
      EmergencyStatus.AMBULANCE_ARRIVED,
      EmergencyStatus.PATIENT_PICKED,
      EmergencyStatus.EN_ROUTE_HOSPITAL,
    ];

    const snapshot = await emergenciesCollection()
      .where('status', 'in', activeStatuses)
      .orderBy('createdAt', 'desc')
      .get();

    return snapshot.docs.map(doc => ({ id: doc.id, ...doc.data() }));
  }

  /**
   * Cancel emergency
   */
  static async cancel(emergencyId, reason = '') {
    await this.updateStatus(emergencyId, EmergencyStatus.CANCELLED, reason || 'Emergency cancelled');
    return await this.getById(emergencyId);
  }
}

module.exports = EmergencyModel;