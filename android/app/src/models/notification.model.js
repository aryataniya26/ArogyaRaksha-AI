const { notificationsCollection } = require('../config/database.config');
const { v4: uuidv4 } = require('uuid');
const { NotificationType } = require('../utils/constants.util');

/**
 * Notification Model Schema
 */
class NotificationModel {
  static collectionName = 'notifications';

  /**
   * Create new notification
   */
  static async create(notificationData) {
    const notificationId = uuidv4();

    const notification = {
      notificationId: notificationId,

      // Recipient
      userId: notificationData.userId,

      // Notification details
      type: notificationData.type || NotificationType.GENERAL,
      title: notificationData.title,
      message: notificationData.message,

      // Priority
      priority: notificationData.priority || 'medium', // low, medium, high, urgent

      // Associated data
      data: {
        emergencyId: notificationData.data?.emergencyId || null,
        ambulanceId: notificationData.data?.ambulanceId || null,
        hospitalId: notificationData.data?.hospitalId || null,
        vitalId: notificationData.data?.vitalId || null,
        bloodRequestId: notificationData.data?.bloodRequestId || null,
        ...notificationData.data,
      },

      // Action
      actionUrl: notificationData.actionUrl || null,
      actionLabel: notificationData.actionLabel || null,

      // Status
      isRead: false,
      readAt: null,

      // Delivery
      deliveryChannels: notificationData.deliveryChannels || ['push'], // push, sms, email
      deliveryStatus: {
        push: false,
        sms: false,
        email: false,
      },

      // Expiry
      expiresAt: notificationData.expiresAt || (() => {
        const expiryDate = new Date();
        expiryDate.setDate(expiryDate.getDate() + 7); // 7 days validity
        return expiryDate;
      })(),

      createdAt: new Date(),
      updatedAt: new Date(),
    };

    await notificationsCollection().doc(notificationId).set(notification);
    return { id: notificationId, ...notification };
  }

  /**
   * Get notification by ID
   */
  static async getById(notificationId) {
    const doc = await notificationsCollection().doc(notificationId).get();
    if (!doc.exists) {
      return null;
    }
    return { id: doc.id, ...doc.data() };
  }

  /**
   * Get user notifications
   */
  static async getUserNotifications(userId, filters = {}) {
    let query = notificationsCollection().where('userId', '==', userId);

    if (filters.type) {
      query = query.where('type', '==', filters.type);
    }

    if (filters.isRead !== undefined) {
      query = query.where('isRead', '==', filters.isRead);
    }

    query = query.orderBy('createdAt', 'desc');

    if (filters.limit) {
      query = query.limit(filters.limit);
    }

    const snapshot = await query.get();
    return snapshot.docs.map(doc => ({ id: doc.id, ...doc.data() }));
  }

  /**
   * Mark notification as read
   */
  static async markAsRead(notificationId) {
    const updates = {
      isRead: true,
      readAt: new Date(),
      updatedAt: new Date(),
    };

    await notificationsCollection().doc(notificationId).update(updates);
    return await this.getById(notificationId);
  }

  /**
   * Mark all user notifications as read
   */
  static async markAllAsRead(userId) {
    const snapshot = await notificationsCollection()
      .where('userId', '==', userId)
      .where('isRead', '==', false)
      .get();

    const batch = notificationsCollection().firestore.batch();

    snapshot.docs.forEach(doc => {
      batch.update(doc.ref, {
        isRead: true,
        readAt: new Date(),
        updatedAt: new Date(),
      });
    });

    await batch.commit();
    return { updated: snapshot.size };
  }

  /**
   * Update delivery status
   */
  static async updateDeliveryStatus(notificationId, channel, status) {
    const updates = {
      [`deliveryStatus.${channel}`]: status,
      updatedAt: new Date(),
    };

    await notificationsCollection().doc(notificationId).update(updates);
    return await this.getById(notificationId);
  }

  /**
   * Get unread count
   */
  static async getUnreadCount(userId) {
    const snapshot = await notificationsCollection()
      .where('userId', '==', userId)
      .where('isRead', '==', false)
      .get();

    return snapshot.size;
  }

  /**
   * Delete notification
   */
  static async delete(notificationId) {
    await notificationsCollection().doc(notificationId).delete();
    return true;
  }

  /**
   * Delete old notifications (cleanup)
   */
  static async deleteExpired() {
    const now = new Date();

    const snapshot = await notificationsCollection()
      .where('expiresAt', '<=', now)
      .get();

    const batch = notificationsCollection().firestore.batch();

    snapshot.docs.forEach(doc => {
      batch.delete(doc.ref);
    });

    await batch.commit();
    return { deleted: snapshot.size };
  }

  /**
   * Create emergency notification
   */
  static async createEmergencyNotification(userId, emergencyData) {
    return await this.create({
      userId: userId,
      type: NotificationType.EMERGENCY_TRIGGERED,
      title: '🚨 Emergency Alert',
      message: `Emergency triggered for ${emergencyData.patientName}. Help is on the way!`,
      priority: 'urgent',
      data: {
        emergencyId: emergencyData.emergencyId,
      },
      deliveryChannels: ['push', 'sms'],
    });
  }

  /**
   * Create ambulance notification
   */
  static async createAmbulanceNotification(userId, ambulanceData) {
    return await this.create({
      userId: userId,
      type: NotificationType.AMBULANCE_ASSIGNED,
      title: '🚑 Ambulance Assigned',
      message: `Ambulance ${ambulanceData.vehicleNumber} has been assigned. Driver: ${ambulanceData.driverName}`,
      priority: 'high',
      data: {
        ambulanceId: ambulanceData.ambulanceId,
        emergencyId: ambulanceData.emergencyId,
      },
      deliveryChannels: ['push', 'sms'],
    });
  }

  /**
   * Create vitals alert notification
   */
  static async createVitalsAlertNotification(userId, vitalsData) {
    return await this.create({
      userId: userId,
      type: NotificationType.VITALS_ALERT,
      title: '⚠️ Health Alert',
      message: vitalsData.alertMessage,
      priority: vitalsData.priority || 'high',
      data: {
        vitalId: vitalsData.vitalId,
      },
      deliveryChannels: ['push'],
    });
  }
}

module.exports = NotificationModel;