const AmbulanceModel = require('../models/ambulance.model');
const EmergencyModel = require('../models/emergency.model');
const locationService = require('./location.service');
const smsService = require('./sms.service');
const fcmService = require('./fcm.service');
const logger = require('../utils/logger.util');
const { AmbulanceStatus, EmergencyStatus, DistanceLimits } = require('../utils/constants.util');
const { emitEmergencyUpdate, emitAmbulanceLocation } = require('../websocket/socket.server');

/**
 * Ambulance Service - Auto-assignment and tracking
 */
class AmbulanceService {
  /**
   * Find and assign nearest available ambulance
   */
  async assignNearestAmbulance(emergencyId) {
    try {
      const emergency = await EmergencyModel.getById(emergencyId);
      if (!emergency) {
        throw new Error('Emergency not found');
      }

      logger.info(`Finding nearest ambulance for emergency ${emergencyId}`);

      // Get available ambulances near emergency location
      const availableAmbulances = await AmbulanceModel.getAvailableNearby(
        emergency.location.latitude,
        emergency.location.longitude,
        DistanceLimits.AMBULANCE_SEARCH_RADIUS
      );

      if (availableAmbulances.length === 0) {
        logger.warn(`No ambulances found near emergency ${emergencyId}`);

        // Try calling 108
        await this.fallbackTo108(emergency);

        return {
          success: false,
          message: 'No ambulances available nearby. 108 has been notified.',
        };
      }

      // Select nearest ambulance
      const nearestAmbulance = availableAmbulances[0];
      logger.info(`Nearest ambulance found: ${nearestAmbulance.vehicleNumber}, Distance: ${nearestAmbulance.distance} km`);

      // Assign ambulance to emergency
      await AmbulanceModel.assignToEmergency(nearestAmbulance.id, emergencyId);

      // Update emergency with ambulance details
      await EmergencyModel.assignAmbulance(emergencyId, {
        ambulanceId: nearestAmbulance.id,
        driverName: nearestAmbulance.driverInfo.name,
        driverPhone: nearestAmbulance.driverInfo.phone,
        vehicleNumber: nearestAmbulance.vehicleNumber,
        type: nearestAmbulance.type,
      });

      // Calculate ETA
      const eta = await locationService.getETA(
        nearestAmbulance.location,
        emergency.location
      );

      // Send notifications
      await this.notifyAmbulanceAssigned(emergency, nearestAmbulance, eta);

      // Emit real-time update
      emitEmergencyUpdate(emergencyId, {
        status: EmergencyStatus.AMBULANCE_ASSIGNED,
        ambulance: nearestAmbulance,
        eta: eta,
      });

      logger.success(`Ambulance ${nearestAmbulance.vehicleNumber} assigned to emergency ${emergencyId}`);

      return {
        success: true,
        ambulance: nearestAmbulance,
        eta: eta,
      };
    } catch (error) {
      logger.error('Ambulance assignment error:', error);
      throw error;
    }
  }

  /**
   * Update ambulance location (real-time tracking)
   */
  async updateAmbulanceLocation(ambulanceId, latitude, longitude, address = '') {
    try {
      await AmbulanceModel.updateLocation(ambulanceId, latitude, longitude, address);

      // Get ambulance details
      const ambulance = await AmbulanceModel.getById(ambulanceId);

      // If ambulance is assigned to an emergency, emit location update
      if (ambulance.currentEmergencyId) {
        emitAmbulanceLocation(ambulanceId, {
          latitude,
          longitude,
          address,
          timestamp: new Date(),
        });

        // Calculate new ETA
        const emergency = await EmergencyModel.getById(ambulance.currentEmergencyId);
        if (emergency) {
          const eta = await locationService.getETA(
            { latitude, longitude },
            emergency.location
          );

          emitEmergencyUpdate(ambulance.currentEmergencyId, {
            ambulanceLocation: { latitude, longitude, address },
            eta: eta,
          });
        }
      }

      return {
        success: true,
        location: { latitude, longitude, address },
      };
    } catch (error) {
      logger.error('Update ambulance location error:', error);
      throw error;
    }
  }

  /**
   * Notify when ambulance has arrived
   */
  async markAmbulanceArrived(ambulanceId, emergencyId) {
    try {
      // Update ambulance status
      await AmbulanceModel.updateStatus(ambulanceId, AmbulanceStatus.ARRIVED, emergencyId);

      // Update emergency status
      await EmergencyModel.updateStatus(
        emergencyId,
        EmergencyStatus.AMBULANCE_ARRIVED,
        'Ambulance has arrived at location'
      );

      const emergency = await EmergencyModel.getById(emergencyId);

      // Send notifications
      await fcmService.sendAmbulanceArrivedNotification(emergency.userId, emergencyId);
      await smsService.sendSMS(
        emergency.patientInfo.phoneNumber,
        '✅ Ambulance has arrived at your location. Please be ready.'
      );

      // Emit real-time update
      emitEmergencyUpdate(emergencyId, {
        status: EmergencyStatus.AMBULANCE_ARRIVED,
        message: 'Ambulance has arrived',
      });

      logger.success(`Ambulance ${ambulanceId} arrived at emergency ${emergencyId}`);

      return { success: true };
    } catch (error) {
      logger.error('Mark ambulance arrived error:', error);
      throw error;
    }
  }

  /**
   * Mark patient picked up
   */
  async markPatientPicked(ambulanceId, emergencyId) {
    try {
      // Update ambulance status
      await AmbulanceModel.updateStatus(ambulanceId, AmbulanceStatus.TRANSPORTING, emergencyId);

      // Update emergency status
      await EmergencyModel.updateStatus(
        emergencyId,
        EmergencyStatus.PATIENT_PICKED,
        'Patient picked up, en route to hospital'
      );

      // Emit real-time update
      emitEmergencyUpdate(emergencyId, {
        status: EmergencyStatus.PATIENT_PICKED,
        message: 'Patient picked up, heading to hospital',
      });

      logger.success(`Patient picked up for emergency ${emergencyId}`);

      return { success: true };
    } catch (error) {
      logger.error('Mark patient picked error:', error);
      throw error;
    }
  }

  /**
   * Mark reached hospital
   */
  async markReachedHospital(ambulanceId, emergencyId) {
    try {
      const emergency = await EmergencyModel.getById(emergencyId);

      // Update emergency status
      await EmergencyModel.updateStatus(
        emergencyId,
        EmergencyStatus.REACHED_HOSPITAL,
        'Reached hospital'
      );

      // Send notification
      if (emergency.hospitalDetails) {
        await fcmService.sendHospitalReachedNotification(
          emergency.userId,
          emergency.hospitalDetails
        );
      }

      // Emit real-time update
      emitEmergencyUpdate(emergencyId, {
        status: EmergencyStatus.REACHED_HOSPITAL,
        message: 'Patient reached hospital',
      });

      logger.success(`Emergency ${emergencyId} reached hospital`);

      return { success: true };
    } catch (error) {
      logger.error('Mark reached hospital error:', error);
      throw error;
    }
  }

  /**
   * Complete ambulance ride
   */
  async completeRide(ambulanceId, emergencyId) {
    try {
      // Complete ambulance ride
      await AmbulanceModel.completeRide(ambulanceId);

      // Update emergency status
      await EmergencyModel.updateStatus(
        emergencyId,
        EmergencyStatus.COMPLETED,
        'Emergency response completed'
      );

      logger.success(`Ride completed for emergency ${emergencyId}`);

      return { success: true };
    } catch (error) {
      logger.error('Complete ride error:', error);
      throw error;
    }
  }

  /**
   * Fallback to 108 emergency service
   */
  async fallbackTo108(emergency) {
    try {
      const emergencyNumber = process.env.EMERGENCY_NUMBER_108 || '108';

      // Send SMS to 108
      const message = `EMERGENCY ALERT
Location: ${emergency.location.address || `${emergency.location.latitude}, ${emergency.location.longitude}`}
Patient: ${emergency.patientInfo.name}, Age: ${emergency.patientInfo.age}
Condition: ${emergency.emergencyType}
Contact: ${emergency.patientInfo.phoneNumber}
Emergency ID: ${emergency.emergencyId}`;

      await smsService.sendSMS(`+91${emergencyNumber}`, message);

      // Update emergency
      await EmergencyModel.updateStatus(
        emergency.emergencyId,
        EmergencyStatus.TRIGGERED,
        '108 emergency service notified'
      );

      logger.info(`Fallback to 108 for emergency ${emergency.emergencyId}`);
    } catch (error) {
      logger.error('Fallback to 108 error:', error);
    }
  }

  /**
   * Notify ambulance assigned
   */
  async notifyAmbulanceAssigned(emergency, ambulance, eta) {
    try {
      // Notify patient
      await fcmService.sendAmbulanceNotification(emergency.userId, {
        ambulanceId: ambulance.id,
        emergencyId: emergency.emergencyId,
        vehicleNumber: ambulance.vehicleNumber,
        driverName: ambulance.driverInfo.name,
        driverPhone: ambulance.driverInfo.phone,
        eta: `${eta.durationMinutes} mins`,
      });

      await smsService.sendAmbulanceAssignedSMS(emergency.patientInfo.phoneNumber, {
        vehicleNumber: ambulance.vehicleNumber,
        driverName: ambulance.driverInfo.name,
        driverPhone: ambulance.driverInfo.phone,
        eta: `${eta.durationMinutes} mins`,
      });

      // Notify emergency contacts
      if (emergency.patientInfo.emergencyContacts) {
        for (const contact of emergency.patientInfo.emergencyContacts) {
          await smsService.sendSMS(
            contact.phone,
            `Emergency alert for ${emergency.patientInfo.name}. Ambulance ${ambulance.vehicleNumber} assigned. Driver: ${ambulance.driverInfo.name}, ${ambulance.driverInfo.phone}`
          );
        }
      }

      logger.success('Ambulance assignment notifications sent');
    } catch (error) {
      logger.error('Notify ambulance assigned error:', error);
    }
  }

  /**
   * Get ambulance current status
   */
  async getAmbulanceStatus(ambulanceId) {
    try {
      const ambulance = await AmbulanceModel.getById(ambulanceId);

      if (!ambulance) {
        throw new Error('Ambulance not found');
      }

      let emergencyDetails = null;
      if (ambulance.currentEmergencyId) {
        emergencyDetails = await EmergencyModel.getById(ambulance.currentEmergencyId);
      }

      return {
        ambulance,
        currentEmergency: emergencyDetails,
      };
    } catch (error) {
      logger.error('Get ambulance status error:', error);
      throw error;
    }
  }
}

module.exports = new AmbulanceService();