const axios = require('axios');
const VitalsModel = require('../models/vitals.model');
const logger = require('../utils/logger.util');
const { VitalsAlertLevel } = require('../utils/constants.util');

/**
 * AI Service - Health prediction and analysis
 */
class AIService {
  constructor() {
    this.aiApiUrl = process.env.AI_API_URL || 'http://localhost:5001';
    this.aiApiKey = process.env.AI_API_KEY;
  }

  /**
   * Analyze vitals and predict health risks
   */
  async analyzeVitals(vitalsData) {
    try {
      logger.info('Analyzing vitals with AI');

      // First check for obvious abnormalities
      const basicAlerts = VitalsModel.isAbnormal(vitalsData);

      // If AI API is configured, get AI prediction
      let aiPrediction = null;
      if (this.isAIConfigured()) {
        try {
          aiPrediction = await this.getAIPrediction(vitalsData);
        } catch (error) {
          logger.warn('AI API call failed, using rule-based analysis');
        }
      }

      // Combine rule-based and AI analysis
      const analysis = this.combineAnalysis(basicAlerts, aiPrediction, vitalsData);

      logger.success('Vitals analysis complete');

      return analysis;
    } catch (error) {
      logger.error('Analyze vitals error:', error);
      throw error;
    }
  }

  /**
   * Get AI prediction from Python API
   */
  async getAIPrediction(vitalsData) {
    try {
      const response = await axios.post(
        `${this.aiApiUrl}/predict`,
        {
          blood_pressure_systolic: vitalsData.bloodPressure?.systolic || null,
          blood_pressure_diastolic: vitalsData.bloodPressure?.diastolic || null,
          heart_rate: vitalsData.heartRate || null,
          blood_sugar: vitalsData.bloodSugar?.value || null,
          oxygen_saturation: vitalsData.oxygenSaturation || null,
          temperature: vitalsData.temperature || null,
          age: vitalsData.age || 30,
          gender: vitalsData.gender || 'unknown',
        },
        {
          headers: {
            'Content-Type': 'application/json',
            ...(this.aiApiKey && { 'X-API-Key': this.aiApiKey }),
          },
          timeout: 5000, // 5 second timeout
        }
      );

      return response.data;
    } catch (error) {
      logger.error('AI API call error:', error);
      throw error;
    }
  }

  /**
   * Combine rule-based and AI analysis
   */
  combineAnalysis(basicAlerts, aiPrediction, vitalsData) {
    let riskLevel = VitalsAlertLevel.NORMAL;
    let predictions = [];
    let recommendations = [];
    let confidence = 0;

    // Evaluate basic alerts
    if (basicAlerts.length > 0) {
      const criticalAlerts = basicAlerts.filter(a => a.level === 'critical');
      const warningAlerts = basicAlerts.filter(a => a.level === 'warning');

      if (criticalAlerts.length > 0) {
        riskLevel = VitalsAlertLevel.CRITICAL;
      } else if (warningAlerts.length > 0) {
        riskLevel = VitalsAlertLevel.WARNING;
      }

      predictions = basicAlerts.map(alert => alert.message);
    }

    // Add AI predictions if available
    if (aiPrediction) {
      if (aiPrediction.risk_level) {
        riskLevel = aiPrediction.risk_level;
      }

      if (aiPrediction.predictions) {
        predictions = [...predictions, ...aiPrediction.predictions];
      }

      if (aiPrediction.recommendations) {
        recommendations = aiPrediction.recommendations;
      }

      confidence = aiPrediction.confidence || 0;
    } else {
      // Generate rule-based recommendations
      recommendations = this.generateRecommendations(vitalsData, riskLevel);
      confidence = 0.7; // Lower confidence for rule-based
    }

    return {
      riskLevel,
      predictions: [...new Set(predictions)], // Remove duplicates
      recommendations,
      confidence,
      alerts: basicAlerts,
      requiresAction: riskLevel !== VitalsAlertLevel.NORMAL,
    };
  }

  /**
   * Generate recommendations based on vitals
   */
  generateRecommendations(vitalsData, riskLevel) {
    const recommendations = [];

    if (riskLevel === VitalsAlertLevel.CRITICAL) {
      recommendations.push('Seek immediate medical attention');
      recommendations.push('Call emergency services if needed');
    }

    // Blood pressure recommendations
    if (vitalsData.bloodPressure?.systolic > 140) {
      recommendations.push('Monitor blood pressure regularly');
      recommendations.push('Reduce salt intake');
      recommendations.push('Consult a doctor about hypertension');
    }

    // Heart rate recommendations
    if (vitalsData.heartRate > 100) {
      recommendations.push('Rest and avoid strenuous activity');
      recommendations.push('Stay hydrated');
    }

    // Blood sugar recommendations
    if (vitalsData.bloodSugar?.value > 200) {
      recommendations.push('Check blood sugar levels frequently');
      recommendations.push('Follow prescribed diabetes medication');
      recommendations.push('Maintain a healthy diet');
    } else if (vitalsData.bloodSugar?.value < 70) {
      recommendations.push('Consume quick-acting carbohydrates');
      recommendations.push('Recheck blood sugar in 15 minutes');
    }

    // Oxygen saturation recommendations
    if (vitalsData.oxygenSaturation < 95) {
      recommendations.push('Ensure proper ventilation');
      recommendations.push('Practice deep breathing exercises');
      if (vitalsData.oxygenSaturation < 90) {
        recommendations.push('Consider oxygen therapy - consult doctor');
      }
    }

    // General recommendations
    if (riskLevel === VitalsAlertLevel.NORMAL) {
      recommendations.push('Maintain healthy lifestyle');
      recommendations.push('Continue regular monitoring');
    }

    return recommendations;
  }

  /**
   * Predict emergency risk based on vitals history
   */
  async predictEmergencyRisk(userId) {
    try {
      logger.info(`Predicting emergency risk for user ${userId}`);

      // Get recent vitals (last 7 days)
      const recentVitals = await VitalsModel.getUserVitals(userId, 20);

      if (recentVitals.length < 5) {
        return {
          risk: 'insufficient_data',
          message: 'Not enough data for prediction',
        };
      }

      // Get averages
      const averages = await VitalsModel.getAverages(userId, 7);

      // Analyze trends
      const trends = this.analyzeTrends(recentVitals);

      // Calculate risk score
      const riskScore = this.calculateRiskScore(averages, trends);

      let riskLevel = 'low';
      if (riskScore > 0.7) {
        riskLevel = 'high';
      } else if (riskScore > 0.4) {
        riskLevel = 'medium';
      }

      return {
        risk: riskLevel,
        riskScore: riskScore,
        trends: trends,
        recommendations: this.getRiskRecommendations(riskLevel),
      };
    } catch (error) {
      logger.error('Predict emergency risk error:', error);
      throw error;
    }
  }

  /**
   * Analyze trends in vitals
   */
  analyzeTrends(vitals) {
    const trends = {
      bloodPressure: 'stable',
      heartRate: 'stable',
      bloodSugar: 'stable',
    };

    if (vitals.length < 3) return trends;

    // Analyze last 3 readings
    const recent = vitals.slice(0, 3);

    // Blood Pressure trend
    const bpValues = recent
      .filter(v => v.bloodPressure?.systolic)
      .map(v => v.bloodPressure.systolic);

    if (bpValues.length >= 2) {
      if (bpValues[0] > bpValues[bpValues.length - 1] + 10) {
        trends.bloodPressure = 'increasing';
      } else if (bpValues[0] < bpValues[bpValues.length - 1] - 10) {
        trends.bloodPressure = 'decreasing';
      }
    }

    // Heart Rate trend
    const hrValues = recent.filter(v => v.heartRate).map(v => v.heartRate);

    if (hrValues.length >= 2) {
      if (hrValues[0] > hrValues[hrValues.length - 1] + 10) {
        trends.heartRate = 'increasing';
      } else if (hrValues[0] < hrValues[hrValues.length - 1] - 10) {
        trends.heartRate = 'decreasing';
      }
    }

    return trends;
  }

  /**
   * Calculate risk score
   */
  calculateRiskScore(averages, trends) {
    let score = 0;

    // Blood pressure risk
    if (averages?.bloodPressure?.systolic > 140) {
      score += 0.3;
    }
    if (averages?.bloodPressure?.systolic > 160) {
      score += 0.2;
    }

    // Heart rate risk
    if (averages?.heartRate > 100) {
      score += 0.2;
    }

    // Blood sugar risk
    if (averages?.bloodSugar > 200) {
      score += 0.2;
    }

    // Oxygen saturation risk
    if (averages?.oxygenSaturation < 95) {
      score += 0.3;
    }

    // Trend risk
    if (trends.bloodPressure === 'increasing') {
      score += 0.1;
    }
    if (trends.heartRate === 'increasing') {
      score += 0.1;
    }

    return Math.min(score, 1.0); // Cap at 1.0
  }

  /**
   * Get recommendations based on risk level
   */
  getRiskRecommendations(riskLevel) {
    if (riskLevel === 'high') {
      return [
        'Schedule immediate doctor consultation',
        'Monitor vitals daily',
        'Keep emergency contacts updated',
        'Ensure medications are readily available',
      ];
    } else if (riskLevel === 'medium') {
      return [
        'Schedule regular health check-ups',
        'Monitor vitals regularly',
        'Follow prescribed treatments',
        'Maintain healthy lifestyle',
      ];
    }

    return [
      'Continue regular monitoring',
      'Maintain healthy habits',
      'Stay active and hydrated',
    ];
  }

  /**
   * Check if AI is configured
   */
  isAIConfigured() {
    return !!(this.aiApiUrl && this.aiApiUrl !== 'http://localhost:5001');
  }
}

module.exports = new AIService();