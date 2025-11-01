const { vitalsCollection } = require('../config/database.config');
const { v4: uuidv4 } = require('uuid');
const { VitalsAlertLevel } = require('../utils/constants.util');

/**
 * Vitals Model Schema
 */
class VitalsModel {
  static collectionName = 'vitals';

  /**
   * Create new vitals record
   */
  static async create(vitalsData) {
    const vitalId = uuidv4();

    const vital = {
      vitalId: vitalId,
      userId: vitalsData.userId,

      // Vital measurements
      bloodPressure: {
        systolic: vitalsData.bloodPressure?.systolic || null, // mmHg
        diastolic: vitalsData.bloodPressure?.diastolic || null, // mmHg
      },

      heartRate: vitalsData.heartRate || null, // bpm

      bloodSugar: {
        value: vitalsData.bloodSugar?.value || null, // mg/dL
        type: vitalsData.bloodSugar?.type || 'random', // fasting, random, postprandial
      },

      oxygenSaturation: vitalsData.oxygenSaturation || null, // SpO2 percentage

      temperature: vitalsData.temperature || null, // Celsius

      respiratoryRate: vitalsData.respiratoryRate || null, // breaths per minute

      weight: vitalsData.weight || null, // kg

      // Additional metrics
      BMI: vitalsData.BMI || null,

      // Recording details
      recordedAt: vitalsData.recordedAt || new Date(),
      recordedBy: vitalsData.recordedBy || 'self', // self, doctor, device

      // Device info (if recorded by wearable)
      deviceInfo: {
        deviceId: vitalsData.deviceInfo?.deviceId || null,
        deviceType: vitalsData.deviceInfo?.deviceType || null, // smartwatch, bp_monitor, glucometer
        brand: vitalsData.deviceInfo?.brand || null,
      },

      // AI Analysis
      aiAnalysis: {
        riskLevel: vitalsData.aiAnalysis?.riskLevel || VitalsAlertLevel.NORMAL,
        prediction: vitalsData.aiAnalysis?.prediction || null,
        recommendations: vitalsData.aiAnalysis?.recommendations || [],
        confidence: vitalsData.aiAnalysis?.confidence || 0,
      },

      // Alert generated
      alertGenerated: vitalsData.alertGenerated || false,
      alertMessage: vitalsData.alertMessage || null,

      // Notes
      notes: vitalsData.notes || '',
      symptoms: vitalsData.symptoms || [],

      // Context
      context: vitalsData.context || 'routine', // routine, emergency, post_meal, exercise, sleep

      createdAt: new Date(),
    };

    await vitalsCollection().doc(vitalId).set(vital);
    return { id: vitalId, ...vital };
  }

  /**
   * Get vital by ID
   */
  static async getById(vitalId) {
    const doc = await vitalsCollection().doc(vitalId).get();
    if (!doc.exists) {
      return null;
    }
    return { id: doc.id, ...doc.data() };
  }

  /**
   * Get user's vitals history
   */
  static async getUserVitals(userId, limit = 30, startDate = null, endDate = null) {
    let query = vitalsCollection()
      .where('userId', '==', userId)
      .orderBy('recordedAt', 'desc');

    if (startDate) {
      query = query.where('recordedAt', '>=', new Date(startDate));
    }

    if (endDate) {
      query = query.where('recordedAt', '<=', new Date(endDate));
    }

    query = query.limit(limit);

    const snapshot = await query.get();
    return snapshot.docs.map(doc => ({ id: doc.id, ...doc.data() }));
  }

  /**
   * Get latest vital for user
   */
  static async getLatest(userId) {
    const snapshot = await vitalsCollection()
      .where('userId', '==', userId)
      .orderBy('recordedAt', 'desc')
      .limit(1)
      .get();

    if (snapshot.empty) {
      return null;
    }

    const doc = snapshot.docs[0];
    return { id: doc.id, ...doc.data() };
  }

  /**
   * Get vitals with alerts
   */
  static async getAlertsForUser(userId, limit = 10) {
    const snapshot = await vitalsCollection()
      .where('userId', '==', userId)
      .where('alertGenerated', '==', true)
      .orderBy('recordedAt', 'desc')
      .limit(limit)
      .get();

    return snapshot.docs.map(doc => ({ id: doc.id, ...doc.data() }));
  }

  /**
   * Get vitals by date range
   */
  static async getByDateRange(userId, startDate, endDate) {
    const snapshot = await vitalsCollection()
      .where('userId', '==', userId)
      .where('recordedAt', '>=', new Date(startDate))
      .where('recordedAt', '<=', new Date(endDate))
      .orderBy('recordedAt', 'desc')
      .get();

    return snapshot.docs.map(doc => ({ id: doc.id, ...doc.data() }));
  }

  /**
   * Calculate average vitals for a period
   */
  static async getAverages(userId, days = 7) {
    const startDate = new Date();
    startDate.setDate(startDate.getDate() - days);

    const vitals = await this.getByDateRange(userId, startDate, new Date());

    if (vitals.length === 0) {
      return null;
    }

    // Calculate averages
    let totalSystolic = 0, totalDiastolic = 0, totalHeartRate = 0;
    let totalSugar = 0, totalOxygen = 0, totalTemp = 0;
    let countBP = 0, countHR = 0, countSugar = 0, countOxygen = 0, countTemp = 0;

    vitals.forEach(vital => {
      if (vital.bloodPressure?.systolic) {
        totalSystolic += vital.bloodPressure.systolic;
        totalDiastolic += vital.bloodPressure.diastolic;
        countBP++;
      }
      if (vital.heartRate) {
        totalHeartRate += vital.heartRate;
        countHR++;
      }
      if (vital.bloodSugar?.value) {
        totalSugar += vital.bloodSugar.value;
        countSugar++;
      }
      if (vital.oxygenSaturation) {
        totalOxygen += vital.oxygenSaturation;
        countOxygen++;
      }
      if (vital.temperature) {
        totalTemp += vital.temperature;
        countTemp++;
      }
    });

    return {
      bloodPressure: countBP > 0 ? {
        systolic: Math.round(totalSystolic / countBP),
        diastolic: Math.round(totalDiastolic / countBP),
      } : null,
      heartRate: countHR > 0 ? Math.round(totalHeartRate / countHR) : null,
      bloodSugar: countSugar > 0 ? Math.round(totalSugar / countSugar) : null,
      oxygenSaturation: countOxygen > 0 ? Math.round(totalOxygen / countOxygen) : null,
      temperature: countTemp > 0 ? (totalTemp / countTemp).toFixed(1) : null,
      period: `${days} days`,
      recordCount: vitals.length,
    };
  }

  /**
   * Check if vitals are abnormal
   */
  static isAbnormal(vitalsData) {
    const alerts = [];

    // Blood Pressure check
    if (vitalsData.bloodPressure?.systolic) {
      if (vitalsData.bloodPressure.systolic > 140 || vitalsData.bloodPressure.systolic < 90) {
        alerts.push({
          type: 'blood_pressure',
          level: vitalsData.bloodPressure.systolic > 180 ? 'critical' : 'warning',
          message: 'Abnormal blood pressure detected',
        });
      }
    }

    // Heart Rate check
    if (vitalsData.heartRate) {
      if (vitalsData.heartRate > 100 || vitalsData.heartRate < 60) {
        alerts.push({
          type: 'heart_rate',
          level: vitalsData.heartRate > 120 ? 'critical' : 'warning',
          message: 'Abnormal heart rate detected',
        });
      }
    }

    // Blood Sugar check
    if (vitalsData.bloodSugar?.value) {
      if (vitalsData.bloodSugar.value > 200 || vitalsData.bloodSugar.value < 70) {
        alerts.push({
          type: 'blood_sugar',
          level: vitalsData.bloodSugar.value > 300 || vitalsData.bloodSugar.value < 50 ? 'critical' : 'warning',
          message: 'Abnormal blood sugar detected',
        });
      }
    }

    // Oxygen Saturation check
    if (vitalsData.oxygenSaturation) {
      if (vitalsData.oxygenSaturation < 95) {
        alerts.push({
          type: 'oxygen',
          level: vitalsData.oxygenSaturation < 90 ? 'critical' : 'warning',
          message: 'Low oxygen saturation detected',
        });
      }
    }

    return alerts;
  }

  /**
   * Delete vital record
   */
  static async delete(vitalId) {
    await vitalsCollection().doc(vitalId).delete();
    return true;
  }
}

module.exports = VitalsModel;