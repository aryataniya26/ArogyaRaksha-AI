const NotificationModel = require('../models/notification.model');
const { sendSuccess, sendError } = require('../utils/response.util');
const { asyncHandler } = require('../middlewares/error.middleware');

/**
 * Get User Notifications
 */
const getUserNotifications = asyncHandler(async (req, res) => {
  const { userId } = req;
  const { type, isRead, limit } = req.query;

  const filters = {};
  if (type) filters.type = type;
  if (isRead !== undefined) filters.isRead = isRead === 'true';
  if (limit) filters.limit = parseInt(limit);

  const notifications = await NotificationModel.getUserNotifications(userId, filters);

  return sendSuccess(res, 'Notifications retrieved', {
    notifications: notifications,
    count: notifications.length,
  });
});

/**
 * Mark Notification as Read
 */
const markAsRead = asyncHandler(async (req, res) => {
  const { notificationId } = req.params;

  const notification = await NotificationModel.markAsRead(notificationId);

  return sendSuccess(res, 'Notification marked as read', notification);
});

/**
 * Mark All as Read
 */
const markAllAsRead = asyncHandler(async (req, res) => {
  const { userId } = req;

  const result = await NotificationModel.markAllAsRead(userId);

  return sendSuccess(res, 'All notifications marked as read', result);
});

/**
 * Get Unread Count
 */
const getUnreadCount = asyncHandler(async (req, res) => {
  const { userId } = req;

  const count = await NotificationModel.getUnreadCount(userId);

  return sendSuccess(res, 'Unread count retrieved', {
    unreadCount: count,
  });
});

/**
 * Delete Notification
 */
const deleteNotification = asyncHandler(async (req, res) => {
  const { notificationId } = req.params;

  await NotificationModel.delete(notificationId);

  return sendSuccess(res, 'Notification deleted');
});

module.exports = {
  getUserNotifications,
  markAsRead,
  markAllAsRead,
  getUnreadCount,
  deleteNotification,
};