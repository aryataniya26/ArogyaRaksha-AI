const HospitalModel = require('../models/hospital.model');
const EmergencyModel = require('../models/emergency.model');
const locationService = require('./location.service');
const smsService = require('./sms.service');
const logger = require('../utils/logger.util');
const { DistanceLimits } = require('../utils/constants.util');

/**
 * Hospital Service - Hospital notifications and management
 */
class HospitalService {
  /**
   * Find nearest suitable hospital
   */
  async findNearestHospital(emergencyData) {
    try {
      const { location, emergencyType, insurance } = emergencyData;

      logger.info('Finding nearest hospital for emergency');

      // Get nearby hospitals
      let hospitals = await HospitalModel.getNearby(
        location.latitude,
        location.longitude,
        DistanceLimits.HOSPITAL_SEARCH_RADIUS
      );

      // Filter by insurance if applicable
      if (insurance?.provider) {
        hospitals = hospitals.filter(hospital =>
          hospital.insuranceAccepted?.includes(insurance.provider)
        );
      }

      // Filter by available beds
      hospitals = hospitals.filter(hospital => {
        if (emergencyType === 'cardiac' || emergencyType === 'stroke') {
          return hospital.beds?.ICU?.available > 0;
        }
        return hospital.beds?.emergency?.available > 0;
      });

      if (hospitals.length === 0) {
        logger.warn('No suitable hospitals found');
        // Fallback: get all nearby without filters
        hospitals = await HospitalModel.getNearby(
          location.latitude,
          location.longitude,
          DistanceLimits.HOSPITAL_SEARCH_RADIUS * 2
        );
      }

      // Sort by distance
      hospitals.sort((a, b) => a.distance - b.distance);

      const selectedHospital = hospitals[0];

      if (!selectedHospital) {
        throw new Error('No hospitals found in the area');
      }

      logger.success(`Selected hospital: ${selectedHospital.name}`);

      return selectedHospital;
    } catch (error) {
      logger.error('Find nearest hospital error:', error);
      throw error;
    }
  }

  /**
   * Send pre-arrival notification to hospital
   */
  async sendPreArrivalNotification(emergencyId) {
    try {
      const emergency = await EmergencyModel.getById(emergencyId);

      if (!emergency) {
        throw new Error('Emergency not found');
      }

      // Find and assign hospital
      const hospital = await this.findNearestHospital({
        location: emergency.location,
        emergencyType: emergency.emergencyType,
        insurance: emergency.insurance,
      });

      // Calculate ETA
      const eta = await locationService.getETA(
        emergency.location,
        hospital.location
      );

      // Update emergency with hospital details
      await EmergencyModel.assignHospital(emergencyId, {
        hospitalId: hospital.id,
        name: hospital.name,
        phone: hospital.contact.phone,
        address: hospital.location.address,
        distance: hospital.distance,
        estimatedArrivalTime: eta.eta,
      });

      // Send notification to hospital
      await this.notifyHospital(hospital, emergency, eta);

      logger.success(`Pre-arrival notification sent to ${hospital.name}`);

      return {
        success: true,
        hospital: hospital,
        eta: eta,
      };
    } catch (error) {
      logger.error('Send pre-arrival notification error:', error);
      throw error;
    }
  }

  /**
   * Notify hospital about incoming patient
   */
  async notifyHospital(hospital, emergency, eta) {
    try {
      const message = `🏥 INCOMING EMERGENCY PATIENT

Patient: ${emergency.patientInfo.name}
Age: ${emergency.patientInfo.age} | Gender: ${emergency.patientInfo.gender}
Blood Group: ${emergency.patientInfo.bloodGroup}

Condition: ${emergency.emergencyType.toUpperCase()}
ETA: ${eta.durationMinutes} minutes

Insurance: ${emergency.insurance.hasInsurance ?
  `${emergency.insurance.provider} - ${emergency.insurance.status}` :
  'No insurance'}

Ambulance: ${emergency.ambulanceDetails?.vehicleNumber || 'Not assigned'}

Emergency ID: ${emergency.emergencyId}

Please prepare for immediate admission.
- ArogyaRaksha AI`;

      // Send SMS to hospital emergency number
      await smsService.sendSMS(hospital.contact.emergencyPhone, message);

      // Send to main contact as backup
      if (hospital.contact.phone !== hospital.contact.emergencyPhone) {
        await smsService.sendSMS(hospital.contact.phone, message);
      }

      // Update emergency alertsSent
      await EmergencyModel.getById(emergency.emergencyId).then(async (em) => {
        await EmergencyModel.updateStatus(
          emergency.emergencyId,
          em.status,
          'Hospital notified'
        );
      });

      logger.success('Hospital notification sent');

      return { success: true };
    } catch (error) {
      logger.error('Notify hospital error:', error);
      throw error;
    }
  }

  /**
   * Send detailed patient data to hospital
   */
  async sendPatientData(emergencyId, additionalData = {}) {
    try {
      const emergency = await EmergencyModel.getById(emergencyId);

      if (!emergency || !emergency.hospitalId) {
        throw new Error('Hospital not assigned to emergency');
      }

      const hospital = await HospitalModel.getById(emergency.hospitalId);

      const patientData = {
        emergencyId: emergency.emergencyId,
        patientInfo: emergency.patientInfo,
        emergencyType: emergency.emergencyType,
        symptoms: emergency.symptoms,
        vitals: emergency.vitals,
        medicalHistory: additionalData.medicalHistory || {},
        allergies: additionalData.allergies || [],
        currentMedications: additionalData.currentMedications || [],
        insurance: emergency.insurance,
        emergencyContacts: additionalData.emergencyContacts || [],
        timestamp: new Date(),
      };

      // In production, this would send to hospital's API/system
      // For now, log and send SMS with essential info

      const message = `📋 PATIENT DETAILS

Name: ${emergency.patientInfo.name}
Age: ${emergency.patientInfo.age} | ${emergency.patientInfo.gender}
Blood: ${emergency.patientInfo.bloodGroup}

Medical History: ${additionalData.medicalHistory?.chronicDiseases?.join(', ') || 'None'}
Allergies: ${additionalData.allergies?.join(', ') || 'None'}

Contact: ${emergency.patientInfo.phoneNumber}

Full details available in ArogyaRaksha system.
Emergency ID: ${emergency.emergencyId}`;

      await smsService.sendSMS(hospital.contact.emergencyPhone, message);

      logger.success('Patient data sent to hospital');

      return { success: true, patientData };
    } catch (error) {
      logger.error('Send patient data error:', error);
      throw error;
    }
  }

  /**
   * Update hospital bed availability
   */
  async updateBedAvailability(hospitalId, bedType, count) {
    try {
      const hospital = await HospitalModel.getById(hospitalId);

      const updatedBeds = { ...hospital.beds };

      if (bedType === 'ICU') {
        updatedBeds.ICU.available = count;
      } else if (bedType === 'emergency') {
        updatedBeds.emergency.available = count;
      } else {
        updatedBeds.available = count;
      }

      await HospitalModel.updateBedAvailability(hospitalId, updatedBeds);

      logger.info(`Hospital ${hospitalId} bed availability updated`);

      return { success: true };
    } catch (error) {
      logger.error('Update bed availability error:', error);
      throw error;
    }
  }

  /**
   * Get hospitals with available beds
   */
  async getHospitalsWithBeds(latitude, longitude, bedType = 'emergency') {
    try {
      const hospitals = await HospitalModel.getWithAvailableBeds(
        latitude,
        longitude,
        bedType
      );

      return hospitals;
    } catch (error) {
      logger.error('Get hospitals with beds error:', error);
      throw error;
    }
  }

  /**
   * Check if hospital can accept patient
   */
  async canAcceptPatient(hospitalId, emergencyType, insuranceProvider) {
    try {
      const hospital = await HospitalModel.getById(hospitalId);

      if (!hospital || !hospital.isActive) {
        return {
          canAccept: false,
          reason: 'Hospital not available',
        };
      }

      // Check bed availability
      const hasAvailableBeds = emergencyType === 'cardiac' || emergencyType === 'stroke'
        ? hospital.beds?.ICU?.available > 0
        : hospital.beds?.emergency?.available > 0;

      if (!hasAvailableBeds) {
        return {
          canAccept: false,
          reason: 'No beds available',
        };
      }

      // Check insurance acceptance
      if (insuranceProvider && !hospital.insuranceAccepted?.includes(insuranceProvider)) {
        return {
          canAccept: false,
          reason: 'Insurance not accepted',
        };
      }

      return {
        canAccept: true,
        hospital: hospital,
      };
    } catch (error) {
      logger.error('Check can accept patient error:', error);
      return {
        canAccept: false,
        reason: error.message,
      };
    }
  }

  /**
   * Search hospitals by name
   */
  async searchHospitals(searchTerm) {
    try {
      const hospitals = await HospitalModel.search(searchTerm);
      return hospitals;
    } catch (error) {
      logger.error('Search hospitals error:', error);
      throw error;
    }
  }

  /**
   * Get hospital details
   */
  async getHospitalDetails(hospitalId) {
    try {
      const hospital = await HospitalModel.getById(hospitalId);

      if (!hospital) {
        throw new Error('Hospital not found');
      }

      return hospital;
    } catch (error) {
      logger.error('Get hospital details error:', error);
      throw error;
    }
  }

  /**
   * Reserve bed for incoming patient
   */
  async reserveBed(hospitalId, emergencyId, bedType = 'emergency') {
    try {
      const hospital = await HospitalModel.getById(hospitalId);

      // Decrease available bed count
      const updatedBeds = { ...hospital.beds };

      if (bedType === 'ICU' && updatedBeds.ICU.available > 0) {
        updatedBeds.ICU.available -= 1;
      } else if (bedType === 'emergency' && updatedBeds.emergency.available > 0) {
        updatedBeds.emergency.available -= 1;
      }

      await HospitalModel.updateBedAvailability(hospitalId, updatedBeds);

      logger.info(`Bed reserved at hospital ${hospitalId} for emergency ${emergencyId}`);

      return { success: true };
    } catch (error) {
      logger.error('Reserve bed error:', error);
      throw error;
    }
  }
}

module.exports = new HospitalService();