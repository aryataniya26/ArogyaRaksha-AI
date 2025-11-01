import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../data/models/emergency_model.dart';
import '../../../data/repositories/emergency_repository.dart';
import '../../../presentation/widgets/custom_button.dart';

class LiveStatusScreen extends StatefulWidget {
  final String emergencyId;

  const LiveStatusScreen({super.key, required this.emergencyId});

  @override
  State<LiveStatusScreen> createState() => _LiveStatusScreenState();
}

class _LiveStatusScreenState extends State<LiveStatusScreen> {
  final EmergencyRepository _emergencyRepository = EmergencyRepository();

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false, // Prevent back button
      child: Scaffold(
        backgroundColor: AppColors.backgroundLight,
        body: StreamBuilder<EmergencyModel?>(
          stream: _emergencyRepository.listenToEmergency(widget.emergencyId),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (!snapshot.hasData || snapshot.data == null) {
              return const Center(child: Text('Emergency not found'));
            }

            final emergency = snapshot.data!;

            return SafeArea(
              child: Column(
                children: [
                  _buildHeader(context, emergency),
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          _buildStatusTimeline(emergency),
                          const SizedBox(height: 24),
                          if (emergency.status == EmergencyStatus.ambulanceAssigned ||
                              emergency.status == EmergencyStatus.ambulanceEnRoute ||
                              emergency.status == EmergencyStatus.ambulanceArrived)
                            _buildAmbulanceCard(emergency),
                          if (emergency.hospitalName != null)
                            _buildHospitalCard(emergency),
                          const SizedBox(height: 24),
                          _buildLocationCard(emergency.location),
                          const SizedBox(height: 24),
                          _buildEmergencyContacts(emergency),
                          const SizedBox(height: 24),
                        ],
                      ),
                    ),
                  ),
                  _buildBottomActions(context, emergency),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, EmergencyModel emergency) {
    Color statusColor;
    switch (emergency.status) {
      case EmergencyStatus.completed:
        statusColor = AppColors.successGreen;
        break;
      case EmergencyStatus.cancelled:
        statusColor = AppColors.textSecondary;
        break;
      default:
        statusColor = AppColors.alertRed;
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: statusColor,
        boxShadow: [
          BoxShadow(
            color: statusColor.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Emergency Status',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  _getElapsedTime(emergency.triggeredAt),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                Icon(
                  _getStatusIcon(emergency.status),
                  color: Colors.white,
                  size: 40,
                ),
                const SizedBox(height: 8),
                Text(
                  emergency.status.displayName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  emergency.status.description,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusTimeline(EmergencyModel emergency) {
    final statuses = [
      EmergencyStatus.triggered,
      EmergencyStatus.locating,
      EmergencyStatus.notifying,
      EmergencyStatus.ambulanceSearching,
      EmergencyStatus.ambulanceAssigned,
      EmergencyStatus.ambulanceEnRoute,
      EmergencyStatus.ambulanceArrived,
      EmergencyStatus.hospitalEnRoute,
      EmergencyStatus.hospitalArrived,
      EmergencyStatus.completed,
    ];

    final currentIndex = statuses.indexOf(emergency.status);

    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow.withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Progress Timeline',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          ...statuses.asMap().entries.map((entry) {
            int index = entry.key;
            EmergencyStatus status = entry.value;
            bool isCompleted = index <= currentIndex;
            bool isCurrent = index == currentIndex;

            return _buildTimelineItem(
              status.displayName,
              isCompleted,
              isCurrent,
              index < statuses.length - 1,
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildTimelineItem(String title, bool isCompleted, bool isCurrent, bool showLine) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isCompleted ? AppColors.successGreen : Colors.grey[300],
                border: Border.all(
                  color: isCurrent ? AppColors.primaryTeal : Colors.transparent,
                  width: 3,
                ),
              ),
              child: isCompleted
                  ? const Icon(Icons.check, color: Colors.white, size: 14)
                  : null,
            ),
            if (showLine)
              Container(
                width: 2,
                height: 40,
                color: isCompleted ? AppColors.successGreen : Colors.grey[300],
              ),
          ],
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(bottom: 20),
            child: Text(
              title,
              style: TextStyle(
                fontSize: 14,
                fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
                color: isCompleted ? AppColors.textPrimary : AppColors.textSecondary,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAmbulanceCard(EmergencyModel emergency) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: AppColors.emergencyGradient,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.alertRed.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.car_rental_rounded, color: Colors.white, size: 28),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'Ambulance Details',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildInfoRow('Ambulance No:', emergency.ambulanceNumber ?? 'N/A', Colors.white),
          _buildInfoRow('Driver:', emergency.driverName ?? 'N/A', Colors.white),
          _buildInfoRow('Contact:', emergency.driverPhone ?? 'N/A', Colors.white),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: emergency.driverPhone != null
                  ? () {
                // TODO: Call driver
              }
                  : null,
              icon: const Icon(Icons.phone),
              label: const Text('Call Driver'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: AppColors.alertRed,
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHospitalCard(EmergencyModel emergency) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: AppColors.blueGradient,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.local_hospital, color: Colors.white, size: 28),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'Hospital Details',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildInfoRow('Hospital:', emergency.hospitalName ?? 'N/A', Colors.white),
          _buildInfoRow('Contact:', emergency.hospitalPhone ?? 'N/A', Colors.white),
        ],
      ),
    );
  }

  Widget _buildLocationCard(EmergencyLocation location) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow.withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.location_on, color: AppColors.primaryTeal),
              SizedBox(width: 8),
              Text(
                'Your Location',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (location.address != null)
            Text(
              location.address!,
              style: const TextStyle(fontSize: 14),
            ),
          const SizedBox(height: 8),
          Text(
            'Lat: ${location.latitude.toStringAsFixed(6)}, Long: ${location.longitude.toStringAsFixed(6)}',
            style: TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () {
                // TODO: Open in Google Maps
              },
              icon: const Icon(Icons.map),
              label: const Text('View in Maps'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmergencyContacts(EmergencyModel emergency) {
    if (emergency.notifiedContacts.isEmpty) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow.withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Notified Contacts',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          ...emergency.notifiedContacts.map((contact) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              children: [
                const Icon(Icons.check_circle, color: AppColors.successGreen, size: 20),
                const SizedBox(width: 8),
                Text(contact),
              ],
            ),
          )),
        ],
      ),
    );
  }

  Widget _buildBottomActions(BuildContext context, EmergencyModel emergency) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (emergency.status != EmergencyStatus.completed &&
              emergency.status != EmergencyStatus.cancelled)
            CustomButton(
              text: 'Mark as Completed',
              onPressed: () async {
                await _emergencyRepository.completeEmergency(widget.emergencyId);
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Emergency marked as completed'),
                      backgroundColor: AppColors.successGreen,
                    ),
                  );
                }
              },
              gradient: AppColors.primaryGradient,
            ),
          const SizedBox(height: 12),
          CustomButton(
            text: 'Back to Home',
            onPressed: () {
              Navigator.of(context).popUntil((route) => route.isFirst);
            },
            isOutlined: true,
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: TextStyle(
                color: color.withOpacity(0.8),
                fontSize: 14,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                color: color,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  IconData _getStatusIcon(EmergencyStatus status) {
    switch (status) {
      case EmergencyStatus.triggered:
      case EmergencyStatus.locating:
        return Icons.location_searching;
      case EmergencyStatus.notifying:
        return Icons.notification_important;
      case EmergencyStatus.ambulanceSearching:
        return Icons.search;
      case EmergencyStatus.ambulanceAssigned:
      case EmergencyStatus.ambulanceEnRoute:
        return Icons.car_rental_rounded;
      case EmergencyStatus.ambulanceArrived:
        return Icons.emergency;
      case EmergencyStatus.hospitalEnRoute:
      case EmergencyStatus.hospitalArrived:
        return Icons.local_hospital;
      case EmergencyStatus.completed:
        return Icons.check_circle;
      case EmergencyStatus.cancelled:
        return Icons.cancel;
    }
  }

  String _getElapsedTime(DateTime startTime) {
    final duration = DateTime.now().difference(startTime);
    if (duration.inHours > 0) {
      return '${duration.inHours}h ${duration.inMinutes % 60}m';
    } else if (duration.inMinutes > 0) {
      return '${duration.inMinutes}m';
    } else {
      return '${duration.inSeconds}s';
    }
  }
}


// import 'package:flutter/material.dart';
// import 'package:arogyaraksha_ai/core/constants/app_colors.dart';
// import 'package:arogyaraksha_ai/presentation/widgets/custom_button.dart';
//
// class LiveStatusScreen extends StatefulWidget {
//   const LiveStatusScreen({super.key});
//
//   @override
//   State<LiveStatusScreen> createState() => _LiveStatusScreenState();
// }
//
// class _LiveStatusScreenState extends State<LiveStatusScreen> {
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: AppColors.backgroundLight,
//       appBar: AppBar(
//         title: const Text('Emergency Status'),
//         leading: IconButton(
//           onPressed: () => Navigator.pop(context),
//           icon: const Icon(Icons.arrow_back),
//         ),
//         actions: [
//           IconButton(
//             onPressed: () {},
//             icon: Container(
//               width: 40,
//               height: 40,
//               decoration: const BoxDecoration(
//                 color: AppColors.primaryTeal,
//                 shape: BoxShape.circle,
//               ),
//               child: const Icon(
//                 Icons.home_outlined,
//                 color: AppColors.white,
//                 size: 20,
//               ),
//             ),
//           ),
//           const SizedBox(width: 8),
//         ],
//       ),
//       body: SingleChildScrollView(
//         child: Column(
//           children: [
//             // Status Banner
//             Container(
//               width: double.infinity,
//               padding: const EdgeInsets.all(16),
//               decoration: const BoxDecoration(
//                 gradient: LinearGradient(
//                   colors: [
//                     AppColors.primaryTeal,
//                     AppColors.accentLightBlue,
//                   ],
//                 ),
//               ),
//               child: Row(
//                 children: [
//                   const Icon(
//                     Icons.check_circle_outline,
//                     color: AppColors.white,
//                     size: 24,
//                   ),
//                   const SizedBox(width: 12),
//                   Expanded(
//                     child: Text(
//                       'Ambulance is on the way',
//                       style: Theme.of(context).textTheme.titleLarge?.copyWith(
//                         color: AppColors.white,
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                   ),
//                   Container(
//                     padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
//                     decoration: BoxDecoration(
//                       color: AppColors.white.withOpacity(0.3),
//                       borderRadius: BorderRadius.circular(12),
//                     ),
//                     child: Row(
//                       children: [
//                         Text(
//                           'ETA:',
//                           style: Theme.of(context).textTheme.bodySmall?.copyWith(
//                             color: AppColors.white,
//                           ),
//                         ),
//                         const SizedBox(width: 4),
//                         Text(
//                           '08 mins',
//                           style: Theme.of(context).textTheme.titleSmall?.copyWith(
//                             color: AppColors.white,
//                             fontWeight: FontWeight.bold,
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//
//             // Map View
//             Container(
//               height: 300,
//               margin: const EdgeInsets.all(16),
//               decoration: BoxDecoration(
//                 color: AppColors.backgroundGrey,
//                 borderRadius: BorderRadius.circular(16),
//               ),
//               child: Stack(
//                 children: [
//                   // Placeholder map
//                   ClipRRect(
//                     borderRadius: BorderRadius.circular(16),
//                     child: Container(
//                       color: AppColors.backgroundGrey,
//                       child: Center(
//                         child: Icon(
//                           Icons.map_outlined,
//                           size: 80,
//                           color: AppColors.textLight,
//                         ),
//                       ),
//                     ),
//                   ),
//                   // Live Status Badge
//                   Positioned(
//                     top: 16,
//                     right: 16,
//                     child: Container(
//                       padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
//                       decoration: BoxDecoration(
//                         color: AppColors.successGreen,
//                         borderRadius: BorderRadius.circular(20),
//                       ),
//                       child: Row(
//                         mainAxisSize: MainAxisSize.min,
//                         children: [
//                           Container(
//                             width: 8,
//                             height: 8,
//                             decoration: const BoxDecoration(
//                               color: AppColors.white,
//                               shape: BoxShape.circle,
//                             ),
//                           ),
//                           const SizedBox(width: 6),
//                           Text(
//                             'Live Status',
//                             style: Theme.of(context).textTheme.bodySmall?.copyWith(
//                               color: AppColors.white,
//                               fontWeight: FontWeight.w600,
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//
//             // Ambulance Details
//             _buildCard(
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     'Ambulance Details:',
//                     style: Theme.of(context).textTheme.titleLarge?.copyWith(
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                   const SizedBox(height: 16),
//                   _buildDetailRow(context, 'ID:', '#AR1234'),
//                   const SizedBox(height: 12),
//                   _buildDetailRow(context, 'Driver Name:', 'Rajesh Kumar'),
//                   const SizedBox(height: 12),
//                   Row(
//                     children: [
//                       Expanded(
//                         child: Text(
//                           'Status:',
//                           style: Theme.of(context).textTheme.bodyLarge?.copyWith(
//                             color: AppColors.textSecondary,
//                           ),
//                         ),
//                       ),
//                       Container(
//                         padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
//                         decoration: BoxDecoration(
//                           color: AppColors.warningOrange.withOpacity(0.1),
//                           borderRadius: BorderRadius.circular(8),
//                         ),
//                         child: Text(
//                           'On Route → Arriving',
//                           style: Theme.of(context).textTheme.bodySmall?.copyWith(
//                             color: AppColors.warningOrange,
//                             fontWeight: FontWeight.w600,
//                           ),
//                         ),
//                       ),
//                       const SizedBox(width: 12),
//                       CustomButton(
//                         text: 'Call',
//                         onPressed: () {},
//                         width: 100,
//                         height: 40,
//                         icon: Icons.call,
//                       ),
//                     ],
//                   ),
//                 ],
//               ),
//             ),
//
//             const SizedBox(height: 16),
//
//             // Hospital Information
//             _buildCard(
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     'Hospital Information',
//                     style: Theme.of(context).textTheme.titleLarge?.copyWith(
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                   const SizedBox(height: 16),
//                   _buildDetailRow(context, '', 'Citycare Hospital'),
//                   const SizedBox(height: 12),
//                   _buildDetailRow(context, 'Contact:', '+91 9876543210'),
//                   const SizedBox(height: 12),
//                   Row(
//                     children: [
//                       Expanded(
//                         child: Text(
//                           'Distance:',
//                           style: Theme.of(context).textTheme.bodyLarge?.copyWith(
//                             color: AppColors.textSecondary,
//                           ),
//                         ),
//                       ),
//                       Text(
//                         '3.2 Km',
//                         style: Theme.of(context).textTheme.bodyLarge?.copyWith(
//                           color: AppColors.primaryTeal,
//                           fontWeight: FontWeight.w600,
//                         ),
//                       ),
//                       const SizedBox(width: 16),
//                       CustomButton(
//                         text: 'Cancel Emergency',
//                         onPressed: () {
//                           _showCancelDialog(context);
//                         },
//                         width: 200,
//                         height: 40,
//                         backgroundColor: AppColors.alertRed,
//                         icon: Icons.cancel_outlined,
//                       ),
//                     ],
//                   ),
//                 ],
//               ),
//             ),
//
//             const SizedBox(height: 24),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget _buildDetailRow(BuildContext context, String label, String value) {
//     return Row(
//       children: [
//         if (label.isNotEmpty)
//           Expanded(
//             child: Text(
//               label,
//               style: Theme.of(context).textTheme.bodyLarge?.copyWith(
//                 color: AppColors.textSecondary,
//               ),
//             ),
//           ),
//         Text(
//           value,
//           style: Theme.of(context).textTheme.bodyLarge?.copyWith(
//             fontWeight: FontWeight.w600,
//           ),
//         ),
//       ],
//     );
//   }
//
//   Widget _buildCard({required Widget child}) {
//     return Container(
//       margin: const EdgeInsets.symmetric(horizontal: 16),
//       padding: const EdgeInsets.all(20),
//       decoration: BoxDecoration(
//         color: AppColors.white,
//         borderRadius: BorderRadius.circular(16),
//         boxShadow: [
//           BoxShadow(
//             color: AppColors.shadow.withOpacity(0.08),
//             blurRadius: 10,
//             offset: const Offset(0, 4),
//           ),
//         ],
//       ),
//       child: child,
//     );
//   }
//
//   void _showCancelDialog(BuildContext context) {
//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: const Text('Cancel Emergency?'),
//         content: const Text(
//           'Are you sure you want to cancel this emergency request?',
//         ),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context),
//             child: const Text('No'),
//           ),
//           ElevatedButton(
//             onPressed: () {
//               Navigator.pop(context);
//               Navigator.pop(context);
//             },
//             style: ElevatedButton.styleFrom(
//               backgroundColor: AppColors.alertRed,
//             ),
//             child: const Text('Yes, Cancel'),
//           ),
//         ],
//       ),
//     );
//   }
// }
//
//
// // import 'package:flutter/material.dart';
// // import 'package:arogyaraksha_ai/core/constants/app_colors.dart';
// // import 'package:arogyaraksha_ai/presentation/widgets/custom_button.dart';
// //
// // class LiveStatusScreen extends StatefulWidget {
// //   const LiveStatusScreen({super.key});
// //
// //   @override
// //   State<LiveStatusScreen> createState() => _LiveStatusScreenState();
// // }
// //
// // class _LiveStatusScreenState extends State<LiveStatusScreen> {
// //   @override
// //   Widget build(BuildContext context) {
// //     return Scaffold(
// //       backgroundColor: AppColors.backgroundLight,
// //       appBar: AppBar(
// //         title: const Text('Emergency Status'),
// //         leading: IconButton(
// //           onPressed: () => Navigator.pop(context),
// //           icon: const Icon(Icons.arrow_back),
// //         ),
// //         actions: [
// //           IconButton(
// //             onPressed: () {},
// //             icon: Container(
// //               width: 40,
// //               height: 40,
// //               decoration: BoxDecoration(
// //                 color: AppColors.primaryTeal,
// //                 shape: BoxShape.circle,
// //               ),
// //               child: const Icon(
// //                 Icons.home_outlined,
// //                 color: AppColors.white,
// //                 size: 20,
// //               ),
// //             ),
// //           ),
// //           const SizedBox(width: 8),
// //         ],
// //       ),
// //       body: SingleChildScrollView(
// //         child: Column(
// //           children: [
// //             // Status Banner
// //             Container(
// //               width: double.infinity,
// //               padding: const EdgeInsets.all(16),
// //               decoration: const BoxDecoration(
// //                 gradient: LinearGradient(
// //                   colors: [
// //                     AppColors.primaryTeal,
// //                     AppColors.accentLightBlue,
// //                   ],
// //                 ),
// //               ),
// //               child: Row(
// //                 children: [
// //                   const Icon(
// //                     Icons.check_circle_outline,
// //                     color: AppColors.white,
// //                     size: 24,
// //                   ),
// //                   const SizedBox(width: 12),
// //                   Expanded(
// //                     child: Text(
// //                       'Ambulance is on the way',
// //                       style: Theme.of(context).textTheme.titleLarge?.copyWith(
// //                         color: AppColors.white,
// //                         fontWeight: FontWeight.bold,
// //                       ),
// //                     ),
// //                   ),
// //                   Container(
// //                     padding:
// //                     const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
// //                     decoration: BoxDecoration(
// //                       color: AppColors.white.withOpacity(0.3),
// //                       borderRadius: BorderRadius.circular(12),
// //                     ),
// //                     child: Row(
// //                       children: [
// //                         Text(
// //                           'ETA:',
// //                           style:
// //                           Theme.of(context).textTheme.bodySmall?.copyWith(
// //                             color: AppColors.white,
// //                           ),
// //                         ),
// //                         const SizedBox(width: 4),
// //                         Text(
// //                           '08 mins',
// //                           style:
// //                           Theme.of(context).textTheme.titleSmall?.copyWith(
// //                             color: AppColors.white,
// //                             fontWeight: FontWeight.bold,
// //                           ),
// //                         ),
// //                       ],
// //                     ),
// //                   ),
// //                 ],
// //               ),
// //             ),
// //
// //             // Map View
// //             Container(
// //               height: 300,
// //               margin: const EdgeInsets.all(16),
// //               decoration: BoxDecoration(
// //                 color: AppColors.backgroundGrey,
// //                 borderRadius: BorderRadius.circular(16),
// //               ),
// //               child: Stack(
// //                 children: [
// //                   // Placeholder map
// //                   ClipRRect(
// //                     borderRadius: BorderRadius.circular(16),
// //                     child: Container(
// //                       color: AppColors.backgroundGrey,
// //                       child: Center(
// //                         child: Icon(
// //                           Icons.map_outlined,
// //                           size: 80,
// //                           color: AppColors.textLight,
// //                         ),
// //                       ),
// //                     ),
// //                   ),
// //                   // Live Status Badge
// //                   Positioned(
// //                     top: 16,
// //                     right: 16,
// //                     child: Container(
// //                       padding: const EdgeInsets.symmetric(
// //                         horizontal: 12,
// //                         vertical: 6,
// //                       ),
// //                       decoration: BoxDecoration(
// //                         color: AppColors.successGreen,
// //                         borderRadius: BorderRadius.circular(20),
// //                       ),
// //                       child: Row(
// //                         mainAxisSize: MainAxisSize.min,
// //                         children: [
// //                           Container(
// //                             width: 8,
// //                             height: 8,
// //                             decoration: const BoxDecoration(
// //                               color: AppColors.white,
// //                               shape: BoxShape.circle,
// //                             ),
// //                           ),
// //                           const SizedBox(width: 6),
// //                           Text(
// //                             'Live Status',
// //                             style:
// //                             Theme.of(context).textTheme.bodySmall?.copyWith(
// //                               color: AppColors.white,
// //                               fontWeight: FontWeight.w600,
// //                             ),
// //                           ),
// //                         ],
// //                       ),
// //                     ),
// //                   ),
// //                 ],
// //               ),
// //             ),
// //
// //             // Ambulance Details
// //             Container(
// //               margin: const EdgeInsets.symmetric(horizontal: 16),
// //               padding: const EdgeInsets.all(20),
// //               decoration: BoxDecoration(
// //                 color: AppColors.white,
// //                 borderRadius: BorderRadius.circular(16),
// //                 boxShadow: [
// //                   BoxShadow(
// //                     color: AppColors.shadow.withOpacity(0.08),
// //                     blurRadius: 10,
// //                     offset: const Offset(0, 4),
// //                   ),
// //                 ],
// //               ),
// //               child: Column(
// //                 crossAxisAlignment: CrossAxisAlignment.start,
// //                 children: [
// //                   Text(
// //                     'Ambulance Details:',
// //                     style: Theme.of(context).textTheme.titleLarge?.copyWith(
// //                       fontWeight: FontWeight.bold,
// //                     ),
// //                   ),
// //                   const SizedBox(height: 16),
// //                   _buildDetailRow(context, 'ID:', '#AR1234'),
// //                   const SizedBox(height: 12),
// //                   _buildDetailRow(context, 'Driver Name:', 'Rajesh Kumar'),
// //                   const SizedBox(height: 12),
// //                   Row(
// //                     children: [
// //                       Expanded(
// //                         child: Text(
// //                           'Status:',
// //                           style:
// //                           Theme.of(context).textTheme.bodyLarge?.copyWith(
// //                             color: AppColors.textSecondary,
// //                           ),
// //                         ),
// //                       ),
// //                       Container(
// //                         padding: const EdgeInsets.symmetric(
// //                           horizontal: 12,
// //                           vertical: 6,
// //                         ),
// //                         decoration: BoxDecoration(
// //                           color: AppColors.warningOrange.withOpacity(0.1),
// //                           borderRadius: BorderRadius.circular(8),
// //                         ),
// //                         child: Text(
// //                           'On Route → Arriving',
// //                           style:
// //                           Theme.of(context).textTheme.bodySmall?.copyWith(
// //                             color: AppColors.warningOrange,
// //                             fontWeight: FontWeight.w600,
// //                           ),
// //                         ),
// //                       ),
// //                       const SizedBox(width: 12),
// //                       CustomButton(
// //                         text: 'Call',
// //                         onPressed: () {},
// //                         width: 100,
// //                         height: 40,
// //                         icon: Icons.call,
// //                       ),
// //                     ],
// //                   ),
// //                 ],
// //               ),
// //             ),
// //
// //             const SizedBox(height: 16),
// //
// //             // Hospital Information
// //             Container(
// //               margin: const EdgeInsets.symmetric(horizontal: 16),
// //               padding: const EdgeInsets.all(20),
// //               decoration: BoxDecoration(
// //                 color: AppColors.white,
// //                 borderRadius: BorderRadius.circular(16),
// //                 boxShadow: [
// //                   BoxShadow(
// //                     color: AppColors.shadow.withOpacity(0.08),
// //                     blurRadius: 10,
// //                     offset: const Offset(0, 4),
// //                   ),
// //                 ],
// //               ),
// //               child: Column(
// //                 crossAxisAlignment: CrossAxisAlignment.start,
// //                 children: [
// //                   Text(
// //                     'Hospital Information',
// //                     style: Theme.of(context).textTheme.titleLarge?.copyWith(
// //                       fontWeight: FontWeight.bold,
// //                     ),
// //                   ),
// //                   const SizedBox(height: 16),
// //                   _buildDetailRow(context, '', 'Citycare Hospital'),
// //                   const SizedBox(height: 12),
// //                   _buildDetailRow(context, 'Contact:', '+91 9876543210'),
// //                   const SizedBox(height: 12),
// //                   Row(
// //                     children: [
// //                       Expanded(
// //                         child: Text(
// //                           'Distance:',
// //                           style:
// //                           Theme.of(context).textTheme.bodyLarge?.copyWith(
// //                             color: AppColors.textSecondary,
// //                           ),
// //                         ),
// //                       ),
// //                       Text(
// //                         '3.2 Km',
// //                         style: Theme.of(context).textTheme.bodyLarge?.copyWith(
// //                           color: AppColors.primaryTeal,
// //                           fontWeight: FontWeight.w600,
// //                         ),
// //                       ),
// //                       const SizedBox(width: 16),
// //                       CustomButton(
// //                         text: 'Cancel Emergency',
// //                         onPressed: () {
// //                           _showCancelDialog(context);
// //                         },
// //                         width: 200,
// //                         height: 40,
// //                         backgroundColor: AppColors.alertRed,
// //                         icon: Icons.cancel_outlined,
// //                       ),
// //                     ],
// //                   ),
// //                 ],
// //               ),
// //             ),
// //
// //             const SizedBox(height: 24),
// //           ],
// //         ),
// //       ),
// //     );
// //   }
// //
// //   Widget _buildDetailRow(BuildContext context, String label, String value) {
// //     return Row(
// //       children: [
// //         if (label.isNotEmpty) ...[
// //           Expanded(
// //             child: Text(
// //               label,
// //               style: Theme.of(context).textTheme.bodyLarge?.copyWith(
// //                 color: AppColors.textSecondary,
// //               ),
// //             ),
// //           ),
// //         ],
// //         Text(
// //           value,
// //           style: Theme.of(context).textTheme.bodyLarge?.copyWith(
// //             fontWeight: FontWeight.w600,
// //           ),
// //         ),
// //       ],
// //     );
// //   }
// //
// //   void _showCancelDialog(BuildContext context) {
// //     showDialog(
// //       context: context,
// //       builder: (context) => AlertDialog(
// //         title: const Text('Cancel Emergency?'),
// //         content: const Text(
// //           'Are you sure you want to cancel this emergency request?',
// //         ),
// //         actions: [
// //           TextButton(
// //             onPressed: () => Navigator.pop(context),
// //             child: const Text('No'),
// //           ),
// //           ElevatedButton(
// //             onPressed: () {
// //               Navigator.pop(context);
// //               Navigator.pop(context);
// //             },
// //             style: ElevatedButton.styleFrom(
// //               backgroundColor: AppColors.alertRed,
// //             ),
// //             child: const Text('Yes, Cancel'),
// //           ),
// //         ],
// //       ),
// //     );
// //   }
// // }