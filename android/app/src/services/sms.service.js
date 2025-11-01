const twilio = require('twilio');
const axios = require('axios');
const logger = require('../utils/logger.util');

/**
 * SMS Service - Supports Twilio & Fast2SMS
 */
class SMSService {
  constructor() {
    // Twilio Configuration
    this.twilioClient = process.env.TWILIO_ACCOUNT_SID
      ? twilio(process.env.TWILIO_ACCOUNT_SID, process.env.TWILIO_AUTH_TOKEN)
      : null;

    this.twilioPhone = process.env.TWILIO_PHONE_NUMBER;

    // Fast2SMS Configuration (Indian SMS provider)
    this.fast2smsApiKey = process.env.FAST2SMS_API_KEY;
    this.fast2smsUrl = 'https://www.fast2sms.com/dev/bulkV2';
  }

  /**
   * Send SMS using Twilio
   */
  async sendViaTwilio(to, message) {
    try {
      if (!this.twilioClient) {
        throw new Error('Twilio not configured');
      }

      const result = await this.twilioClient.messages.create({
        body: message,
        from: this.twilioPhone,
        to: to,
      });

      logger.success(`SMS sent via Twilio to ${to}`);
      return {
        success: true,
        messageId: result.sid,
        provider: 'twilio',
      };
    } catch (error) {
      logger.error('Twilio SMS error:', error);
      throw error;
    }
  }

  /**
   * Send SMS using Fast2SMS (Indian provider)
   */
  async sendViaFast2SMS(to, message) {
    try {
      if (!this.fast2smsApiKey) {
        throw new Error('Fast2SMS not configured');
      }

      // Remove +91 if present, Fast2SMS needs 10-digit number
      const phone = to.replace(/^\+91/, '');

      const response = await axios.post(
        this.fast2smsUrl,
        {
          route: 'v3',
          sender_id: 'AROGYARX',
          message: message,
          language: 'english',
          flash: 0,
          numbers: phone,
        },
        {
          headers: {
            authorization: this.fast2smsApiKey,
            'Content-Type': 'application/json',
          },
        }
      );

      logger.success(`SMS sent via Fast2SMS to ${to}`);
      return {
        success: true,
        messageId: response.data.message_id,
        provider: 'fast2sms',
      };
    } catch (error) {
      logger.error('Fast2SMS error:', error);
      throw error;
    }
  }

  /**
   * Send emergency SMS
   */
  async sendEmergencySMS(to, emergencyData) {
    const message = `🚨 EMERGENCY ALERT 🚨
Patient: ${emergencyData.patientName}
Type: ${emergencyData.emergencyType}
Location: ${emergencyData.location.address}
Time: ${new Date().toLocaleString()}
Emergency ID: ${emergencyData.emergencyId}

Help is on the way! Do not panic.
- ArogyaRaksha AI`;

    return await this.sendSMS(to, message);
  }

  /**
   * Send ambulance assigned SMS
   */
  async sendAmbulanceAssignedSMS(to, ambulanceData) {
    const message = `🚑 Ambulance Assigned!
Vehicle: ${ambulanceData.vehicleNumber}
Driver: ${ambulanceData.driverName}
Phone: ${ambulanceData.driverPhone}
ETA: ${ambulanceData.eta || 'Calculating...'}

Track live location in app.
- ArogyaRaksha AI`;

    return await this.sendSMS(to, message);
  }

  /**
   * Send hospital notification SMS
   */
  async sendHospitalNotificationSMS(to, hospitalData, patientData) {
    const message = `🏥 Hospital Notification
Patient Incoming: ${patientData.name}
Age: ${patientData.age} | Blood: ${patientData.bloodGroup}
Condition: ${patientData.condition}
ETA: ${hospitalData.eta || '15 mins'}
Insurance: ${patientData.insuranceStatus}

Please prepare for admission.
- ArogyaRaksha AI`;

    return await this.sendSMS(to, message);
  }

  /**
   * Send vitals alert SMS
   */
  async sendVitalsAlertSMS(to, vitalsData) {
    const message = `⚠️ Health Alert!
${vitalsData.alertMessage}
Recorded: ${new Date(vitalsData.recordedAt).toLocaleString()}

Please check the app for details.
- ArogyaRaksha AI`;

    return await this.sendSMS(to, message);
  }

  /**
   * Send blood request SMS
   */
  async sendBloodRequestSMS(to, bloodData) {
    const message = `🩸 Blood Required URGENT
Blood Group: ${bloodData.bloodGroup}
Units: ${bloodData.unitsRequired}
Patient: ${bloodData.patientName}
Hospital: ${bloodData.hospitalName}
Contact: ${bloodData.contactNumber}

Please help save a life!
- ArogyaRaksha AI`;

    return await this.sendSMS(to, message);
  }

  /**
   * Send insurance verification SMS
   */
  async sendInsuranceVerificationSMS(to, insuranceData) {
    const message = `✅ Insurance Verified
Policy: ${insuranceData.policyNumber}
Provider: ${insuranceData.providerName}
Coverage: ₹${insuranceData.coverage}
Status: Active

Pre-approval sent to hospital.
- ArogyaRaksha AI`;

    return await this.sendSMS(to, message);
  }

  /**
   * Send OTP SMS
   */
  async sendOTP(to, otp) {
    const message = `Your ArogyaRaksha AI verification code is: ${otp}

Valid for 10 minutes. Do not share this code.`;

    return await this.sendSMS(to, message);
  }

  /**
   * Main SMS sender - tries Fast2SMS first (for Indian numbers), falls back to Twilio
   */
  async sendSMS(to, message) {
    try {
      // Check if Indian number
      const isIndianNumber = to.startsWith('+91') || to.length === 10;

      // Try Fast2SMS first for Indian numbers
      if (isIndianNumber && this.fast2smsApiKey) {
        try {
          return await this.sendViaFast2SMS(to, message);
        } catch (error) {
          logger.warn('Fast2SMS failed, trying Twilio...');
        }
      }

      // Fallback to Twilio
      if (this.twilioClient) {
        return await this.sendViaTwilio(to, message);
      }

      // No SMS provider configured
      logger.warn('No SMS provider configured, SMS not sent');
      return {
        success: false,
        error: 'No SMS provider configured',
      };
    } catch (error) {
      logger.error('SMS Service error:', error);
      return {
        success: false,
        error: error.message,
      };
    }
  }

  /**
   * Send bulk SMS
   */
  async sendBulkSMS(recipients, message) {
    const results = [];

    for (const recipient of recipients) {
      try {
        const result = await this.sendSMS(recipient, message);
        results.push({
          recipient,
          ...result,
        });
      } catch (error) {
        results.push({
          recipient,
          success: false,
          error: error.message,
        });
      }
    }

    return results;
  }

  /**
   * Format phone number
   */
  formatPhoneNumber(phone) {
    // Remove spaces, dashes, etc.
    let formatted = phone.replace(/[\s\-()]/g, '');

    // Add +91 if not present (for Indian numbers)
    if (formatted.length === 10 && !formatted.startsWith('+')) {
      formatted = `+91${formatted}`;
    }

    return formatted;
  }
}

module.exports = new SMSService();