const express = require('express');
const router = express.Router();
const notificationController = require('../controllers/notification.controller');
const { verifyToken } = require('../middlewares/auth.middleware');

/**
 * @route   GET /api/v1/notification/all
 * @desc    Get user notifications
 * @access  Private
 */
router.get('/all', verifyToken, notificationController.getUserNotifications);

/**
 * @route   PUT /api/v1/notification/:notificationId/read
 * @desc    Mark notification as read
 * @access  Private
 */
router.put('/:notificationId/read', verifyToken, notificationController.markAsRead);

/**
 * @route   PUT /api/v1/notification/read-all
 * @desc    Mark all notifications as read
 * @access  Private
 */
router.put('/read-all', verifyToken, notificationController.markAllAsRead);

/**
 * @route   GET /api/v1/notification/unread-count
 * @desc    Get unread count
 * @access  Private
 */
router.get('/unread-count', verifyToken, notificationController.getUnreadCount);

/**
 * @route   DELETE /api/v1/notification/:notificationId
 * @desc    Delete notification
 * @access  Private
 */
router.delete('/:notificationId', verifyToken, notificationController.deleteNotification);

module.exports = router;