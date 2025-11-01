const { messaging } = require('../config/firebase.config');
const logger = require('../utils/logger.util');
const UserModel = require('../models/user.model');
const NotificationModel = require('../models/notification.model');

/**
 * Firebase Cloud Messaging Service
 */
class FCMService {
  /**
   * Send push notification to a single device
   */
  async sendToDevice(deviceToken, notification, data = {}) {
    try {
      const message = {
        token: deviceToken,
        notification: {
          title: notification.title,
          body: notification.message,
        },
        data: {
          ...data,
          click_action: 'FLUTTER_NOTIFICATION_CLICK',
        },
        android: {
          priority: 'high',
          notification: {
            sound: 'default',
            channelId: 'emergency_channel',
          },
        },
        apns: {
          payload: {
            aps: {
              sound: 'default',
              badge: 1,
            },
          },
        },
      };

      const response = await messaging.send(message);
      logger.success(`Push notification sent to device: ${deviceToken.substring(0, 20)}...`);

      return {
        success: true,
        messageId: response,
      };
    } catch (error) {
      logger.error('FCM send error:', error);
      return {
        success: false,
        error: error.message,
      };
    }
  }

  /**
   * Send push notification to user (all devices)
   */
  async sendToUser(userId, notification, data = {}) {
    try {
      const user = await UserModel.getById(userId);

      if (!user || !user.deviceTokens || user.deviceTokens.length === 0) {
        logger.warn(`No device tokens found for user: ${userId}`);
        return {
          success: false,
          error: 'No device tokens',
        };
      }

      const results = [];

      for (const token of user.deviceTokens) {
        const result = await this.sendToDevice(token, notification, data);
        results.push(result);
      }

      // Create notification record
      await NotificationModel.create({
        userId: userId,
        title: notification.title,
        message: notification.message,
        type: notification.type,
        priority: notification.priority || 'medium',
        data: data,
        deliveryChannels: ['push'],
      });

      const successCount = results.filter(r => r.success).length;

      return {
        success: successCount > 0,
        totalDevices: user.deviceTokens.length,
        successCount: successCount,
        results: results,
      };
    } catch (error) {
      logger.error('Send to user error:', error);
      return {
        success: false,
        error: error.message,
      };
    }
  }

  /**
   * Send to multiple users
   */
  async sendToMultipleUsers(userIds, notification, data = {}) {
    const results = [];

    for (const userId of userIds) {
      const result = await this.sendToUser(userId, notification, data);
      results.push({
        userId,
        ...result,
      });
    }

    return results;
  }

  /**
   * Send emergency notification
   */
  async sendEmergencyNotification(userId, emergencyData) {
    return await this.sendToUser(
      userId,
      {
        title: '🚨 Emergency Alert',
        message: `Emergency triggered for ${emergencyData.patientName}. Help is on the way!`,
        type: 'emergency_triggered',
        priority: 'urgent',
      },
      {
        emergencyId: emergencyData.emergencyId,
        screen: 'emergency_status',
      }
    );
  }

  /**
   * Send ambulance assigned notification
   */
  async sendAmbulanceNotification(userId, ambulanceData) {
    return await this.sendToUser(
      userId,
      {
        title: '🚑 Ambulance Assigned',
        message: `Ambulance ${ambulanceData.vehicleNumber} is on the way. Driver: ${ambulanceData.driverName}`,
        type: 'ambulance_assigned',
        priority: 'high',
      },
      {
        ambulanceId: ambulanceData.ambulanceId,
        emergencyId: ambulanceData.emergencyId,
        screen: 'ambulance_tracking',
      }
    );
  }

  /**
   * Send ambulance arrived notification
   */
  async sendAmbulanceArrivedNotification(userId, emergencyId) {
    return await this.sendToUser(
      userId,
      {
        title: '✅ Ambulance Arrived',
        message: 'The ambulance has arrived at your location. Please be ready.',
        type: 'ambulance_arrived',
        priority: 'high',
      },
      {
        emergencyId: emergencyId,
        screen: 'emergency_status',
      }
    );
  }

  /**
   * Send hospital reached notification
   */
  async sendHospitalReachedNotification(userId, hospitalData) {
    return await this.sendToUser(
      userId,
      {
        title: '🏥 Hospital Reached',
        message: `Patient has reached ${hospitalData.name}. Admission process started.`,
        type: 'hospital_reached',
        priority: 'medium',
      },
      {
        hospitalId: hospitalData.hospitalId,
        screen: 'emergency_status',
      }
    );
  }

  /**
   * Send vitals alert notification
   */
  async sendVitalsAlertNotification(userId, vitalsData) {
    return await this.sendToUser(
      userId,
      {
        title: '⚠️ Health Alert',
        message: vitalsData.alertMessage,
        type: 'vitals_alert',
        priority: vitalsData.priority || 'high',
      },
      {
        vitalId: vitalsData.vitalId,
        screen: 'vitals_details',
      }
    );
  }

  /**
   * Send blood request notification
   */
  async sendBloodRequestNotification(userId, bloodData) {
    return await this.sendToUser(
      userId,
      {
        title: '🩸 Blood Required',
        message: `Urgent: ${bloodData.bloodGroup} blood needed for ${bloodData.patientName}`,
        type: 'blood_request',
        priority: 'high',
      },
      {
        requestId: bloodData.requestId,
        screen: 'blood_request',
      }
    );
  }

  /**
   * Send insurance verified notification
   */
  async sendInsuranceVerifiedNotification(userId, insuranceData) {
    return await this.sendToUser(
      userId,
      {
        title: '✅ Insurance Verified',
        message: `Your ${insuranceData.providerName} insurance has been verified successfully.`,
        type: 'insurance_update',
        priority: 'medium',
      },
      {
        insuranceId: insuranceData.insuranceId,
        screen: 'insurance_status',
      }
    );
  }

  /**
   * Send to topic (for broadcast)
   */
  async sendToTopic(topic, notification, data = {}) {
    try {
      const message = {
        topic: topic,
        notification: {
          title: notification.title,
          body: notification.message,
        },
        data: {
          ...data,
          click_action: 'FLUTTER_NOTIFICATION_CLICK',
        },
      };

      const response = await messaging.send(message);
      logger.success(`Push notification sent to topic: ${topic}`);

      return {
        success: true,
        messageId: response,
      };
    } catch (error) {
      logger.error('Send to topic error:', error);
      return {
        success: false,
        error: error.message,
      };
    }
  }

  /**
   * Subscribe user to topic
   */
  async subscribeToTopic(deviceTokens, topic) {
    try {
      const response = await messaging.subscribeToTopic(deviceTokens, topic);
      logger.success(`Subscribed ${deviceTokens.length} devices to topic: ${topic}`);
      return response;
    } catch (error) {
      logger.error('Subscribe to topic error:', error);
      throw error;
    }
  }

  /**
   * Unsubscribe user from topic
   */
  async unsubscribeFromTopic(deviceTokens, topic) {
    try {
      const response = await messaging.unsubscribeFromTopic(deviceTokens, topic);
      logger.success(`Unsubscribed ${deviceTokens.length} devices from topic: ${topic}`);
      return response;
    } catch (error) {
      logger.error('Unsubscribe from topic error:', error);
      throw error;
    }
  }

  /**
   * Validate device token
   */
  async validateToken(token) {
    try {
      await this.sendToDevice(token, {
        title: 'Test',
        message: 'Token validation',
      });
      return true;
    } catch (error) {
      return false;
    }
  }
}

module.exports = new FCMService();