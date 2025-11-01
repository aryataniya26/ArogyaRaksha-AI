import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../core/constants/app_colors.dart';

class NotificationCenterScreen extends StatefulWidget {
  const NotificationCenterScreen({super.key});

  @override
  State<NotificationCenterScreen> createState() => _NotificationCenterScreenState();
}

class _NotificationCenterScreenState extends State<NotificationCenterScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String _selectedFilter = 'All';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        title: const Text('Notifications'),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.filter_list),
            onSelected: (value) => setState(() => _selectedFilter = value),
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'All', child: Text('All')),
              const PopupMenuItem(value: 'Emergency', child: Text('Emergency')),
              const PopupMenuItem(value: 'Health', child: Text('Health Alerts')),
              const PopupMenuItem(value: 'Insurance', child: Text('Insurance')),
              const PopupMenuItem(value: 'Blood', child: Text('Blood Requests')),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.done_all),
            onPressed: _markAllAsRead,
            tooltip: 'Mark all as read',
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _getNotificationsStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return _buildEmptyState();
          }

          final notifications = snapshot.data!.docs;

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: notifications.length,
            itemBuilder: (context, index) {
              final notification = notifications[index].data() as Map<String, dynamic>;
              final notificationId = notifications[index].id;
              return _buildNotificationCard(notification, notificationId);
            },
          );
        },
      ),
    );
  }

  Stream<QuerySnapshot> _getNotificationsStream() {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return const Stream.empty();

    var query = _firestore
        .collection('notifications')
        .where('userId', isEqualTo: userId)
        .orderBy('timestamp', descending: true);

    if (_selectedFilter != 'All') {
      query = query.where('type', isEqualTo: _selectedFilter.toLowerCase());
    }

    return query.snapshots();
  }

  Widget _buildNotificationCard(Map<String, dynamic> notification, String notificationId) {
    final bool isRead = notification['isRead'] ?? false;
    final String type = notification['type'] ?? 'general';
    final String title = notification['title'] ?? 'Notification';
    final String message = notification['message'] ?? '';
    final Timestamp? timestamp = notification['timestamp'] as Timestamp?;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isRead ? AppColors.cardBackground : AppColors.primaryTeal.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isRead ? Colors.transparent : AppColors.primaryTeal.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: _buildNotificationIcon(type),
        title: Row(
          children: [
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontWeight: isRead ? FontWeight.normal : FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
            if (!isRead)
              Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: AppColors.alertRed,
                  shape: BoxShape.circle,
                ),
              ),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              message,
              style: const TextStyle(fontSize: 14),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 8),
            Text(
              _formatTimestamp(timestamp),
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
        trailing: PopupMenuButton(
          icon: const Icon(Icons.more_vert),
          itemBuilder: (context) => [
            if (!isRead)
              PopupMenuItem(
                child: const Row(
                  children: [
                    Icon(Icons.done, size: 20),
                    SizedBox(width: 8),
                    Text('Mark as read'),
                  ],
                ),
                onTap: () => _markAsRead(notificationId),
              ),
            PopupMenuItem(
              child: const Row(
                children: [
                  Icon(Icons.delete, size: 20, color: AppColors.alertRed),
                  SizedBox(width: 8),
                  Text('Delete', style: TextStyle(color: AppColors.alertRed)),
                ],
              ),
              onTap: () => _deleteNotification(notificationId),
            ),
          ],
        ),
        onTap: () {
          if (!isRead) {
            _markAsRead(notificationId);
          }
          _showNotificationDetails(notification);
        },
      ),
    );
  }

  Widget _buildNotificationIcon(String type) {
    IconData icon;
    Color color;

    switch (type.toLowerCase()) {
      case 'emergency':
        icon = Icons.emergency;
        color = AppColors.alertRed;
        break;
      case 'health':
        icon = Icons.favorite;
        color = Colors.pink;
        break;
      case 'insurance':
        icon = Icons.security;
        color = Colors.blue;
        break;
      case 'blood':
        icon = Icons.bloodtype;
        color = AppColors.bloodBPositive;
        break;
      default:
        icon = Icons.notifications;
        color = AppColors.primaryTeal;
    }

    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(icon, color: color),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.notifications_none,
            size: 80,
            color: AppColors.textSecondary.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          const Text(
            'No Notifications',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'You\'re all caught up!',
            style: TextStyle(color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }

  String _formatTimestamp(Timestamp? timestamp) {
    if (timestamp == null) return 'Just now';

    final now = DateTime.now();
    final date = timestamp.toDate();
    final difference = now.difference(date);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inDays < 1) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }

  Future<void> _markAsRead(String notificationId) async {
    try {
      await _firestore.collection('notifications').doc(notificationId).update({
        'isRead': true,
      });
    } catch (e) {
      print('Error marking as read: $e');
    }
  }

  Future<void> _markAllAsRead() async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) return;

      final batch = _firestore.batch();
      final notifications = await _firestore
          .collection('notifications')
          .where('userId', isEqualTo: userId)
          .where('isRead', isEqualTo: false)
          .get();

      for (var doc in notifications.docs) {
        batch.update(doc.reference, {'isRead': true});
      }

      await batch.commit();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('All notifications marked as read')),
        );
      }
    } catch (e) {
      print('Error marking all as read: $e');
    }
  }

  Future<void> _deleteNotification(String notificationId) async {
    try {
      await _firestore.collection('notifications').doc(notificationId).delete();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Notification deleted')),
        );
      }
    } catch (e) {
      print('Error deleting notification: $e');
    }
  }

  void _showNotificationDetails(Map<String, dynamic> notification) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(notification['title'] ?? 'Notification'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(notification['message'] ?? ''),
              if (notification['details'] != null) ...[
                const SizedBox(height: 16),
                const Divider(),
                const SizedBox(height: 8),
                Text(
                  'Details:',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(notification['details']),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}

// Helper function to create sample notifications (for testing)
Future<void> createSampleNotification({
  required String userId,
  required String type,
  required String title,
  required String message,
  String? details,
}) async {
  await FirebaseFirestore.instance.collection('notifications').add({
    'userId': userId,
    'type': type,
    'title': title,
    'message': message,
    'details': details,
    'isRead': false,
    'timestamp': FieldValue.serverTimestamp(),
  });
}




// import 'package:flutter/material.dart';
// import 'package:arogyaraksha_ai/core/constants/app_colors.dart';
//
//
// class NotificationCenterScreen extends StatelessWidget {
//   const NotificationCenterScreen({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: AppColors.backgroundLight,
//       appBar: AppBar(
//         title: const Text('Notifications'),
//         actions: [
//           TextButton(
//             onPressed: () {},
//             child: const Text('Mark all read'),
//           ),
//         ],
//       ),
//       body: ListView(
//         padding: const EdgeInsets.all(16),
//         children: [
//           // Today Section
//           Padding(
//             padding: const EdgeInsets.only(bottom: 12),
//             child: Text(
//               'Today',
//               style: Theme.of(context).textTheme.titleMedium?.copyWith(
//                 fontWeight: FontWeight.bold,
//                 color: AppColors.textSecondary,
//               ),
//             ),
//           ),
//
//           _buildNotificationCard(
//             context,
//             'Emergency Alert Resolved',
//             'Your emergency request has been successfully completed. Patient safely reached Citycare Hospital.',
//             '5 mins ago',
//             Icons.check_circle,
//             AppColors.successGreen,
//             true,
//           ),
//
//           _buildNotificationCard(
//             context,
//             'AI Health Alert',
//             'Your blood pressure reading is slightly elevated. Consider consulting your doctor.',
//             '2 hours ago',
//             Icons.warning_amber_rounded,
//             AppColors.warningOrange,
//             true,
//           ),
//
//           _buildNotificationCard(
//             context,
//             'Insurance Verified',
//             'Your insurance policy has been verified successfully. Coverage: ₹5,00,000',
//             '4 hours ago',
//             Icons.verified,
//             AppColors.primaryTeal,
//             false,
//           ),
//
//           const SizedBox(height: 24),
//
//           // Yesterday Section
//           Padding(
//             padding: const EdgeInsets.only(bottom: 12),
//             child: Text(
//               'Yesterday',
//               style: Theme.of(context).textTheme.titleMedium?.copyWith(
//                 fontWeight: FontWeight.bold,
//                 color: AppColors.textSecondary,
//               ),
//             ),
//           ),
//
//           _buildNotificationCard(
//             context,
//             'Vitals Update Reminder',
//             'It\'s time to update your daily vitals. Track your health regularly for better AI predictions.',
//             'Yesterday, 8:00 AM',
//             Icons.favorite_border,
//             AppColors.alertRed,
//             false,
//           ),
//
//           _buildNotificationCard(
//             context,
//             'Blood Donation Request',
//             'Urgent: B+ blood required at Apollo Hospital. You are a matching donor nearby.',
//             'Yesterday, 2:30 PM',
//             Icons.bloodtype,
//             AppColors.alertRed,
//             false,
//           ),
//
//           _buildNotificationCard(
//             context,
//             'Device Connected',
//             'Your wearable emergency button has been successfully paired with the app.',
//             'Yesterday, 10:15 AM',
//             Icons.bluetooth_connected,
//             AppColors.primaryTeal,
//             false,
//           ),
//
//           const SizedBox(height: 24),
//
//           // Earlier Section
//           Padding(
//             padding: const EdgeInsets.only(bottom: 12),
//             child: Text(
//               'Earlier',
//               style: Theme.of(context).textTheme.titleMedium?.copyWith(
//                 fontWeight: FontWeight.bold,
//                 color: AppColors.textSecondary,
//               ),
//             ),
//           ),
//
//           _buildNotificationCard(
//             context,
//             'Health Report Available',
//             'Your monthly health report is now available. View insights and recommendations.',
//             '3 days ago',
//             Icons.assessment,
//             AppColors.secondaryBlue,
//             false,
//           ),
//
//           _buildNotificationCard(
//             context,
//             'Medication Reminder',
//             'Don\'t forget to take your prescribed medication at 9:00 PM today.',
//             '5 days ago',
//             Icons.medication,
//             AppColors.warningAmber,
//             false,
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildNotificationCard(
//       BuildContext context,
//       String title,
//       String message,
//       String time,
//       IconData icon,
//       Color iconColor,
//       bool isUnread,
//       ) {
//     return Container(
//       margin: const EdgeInsets.only(bottom: 12),
//       decoration: BoxDecoration(
//         color: isUnread
//             ? AppColors.primaryTeal.withOpacity(0.05)
//             : AppColors.white,
//         borderRadius: BorderRadius.circular(16),
//         border: isUnread
//             ? Border.all(color: AppColors.primaryTeal.withOpacity(0.3), width: 1)
//             : null,
//         boxShadow: [
//           BoxShadow(
//             color: AppColors.shadow.withOpacity(0.05),
//             blurRadius: 10,
//             offset: const Offset(0, 4),
//           ),
//         ],
//       ),
//       child: InkWell(
//         onTap: () {},
//         borderRadius: BorderRadius.circular(16),
//         child: Padding(
//           padding: const EdgeInsets.all(16),
//           child: Row(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               // Icon
//               Container(
//                 width: 48,
//                 height: 48,
//                 decoration: BoxDecoration(
//                   color: iconColor.withOpacity(0.1),
//                   borderRadius: BorderRadius.circular(12),
//                 ),
//                 child: Icon(
//                   icon,
//                   color: iconColor,
//                   size: 24,
//                 ),
//               ),
//
//               const SizedBox(width: 16),
//
//               // Content
//               Expanded(
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Row(
//                       children: [
//                         Expanded(
//                           child: Text(
//                             title,
//                             style:
//                             Theme.of(context).textTheme.titleMedium?.copyWith(
//                               fontWeight: FontWeight.bold,
//                             ),
//                           ),
//                         ),
//                         if (isUnread)
//                           Container(
//                             width: 8,
//                             height: 8,
//                             decoration: const BoxDecoration(
//                               color: AppColors.primaryTeal,
//                               shape: BoxShape.circle,
//                             ),
//                           ),
//                       ],
//                     ),
//                     const SizedBox(height: 6),
//                     Text(
//                       message,
//                       style: Theme.of(context).textTheme.bodyMedium?.copyWith(
//                         color: AppColors.textSecondary,
//                         height: 1.4,
//                       ),
//                     ),
//                     const SizedBox(height: 8),
//                     Row(
//                       children: [
//                         Icon(
//                           Icons.access_time,
//                           size: 14,
//                           color: AppColors.textLight,
//                         ),
//                         const SizedBox(width: 4),
//                         Text(
//                           time,
//                           style: Theme.of(context).textTheme.bodySmall?.copyWith(
//                             color: AppColors.textLight,
//                           ),
//                         ),
//                       ],
//                     ),
//                   ],
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }