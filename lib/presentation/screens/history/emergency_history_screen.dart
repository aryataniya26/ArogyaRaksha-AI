import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../core/constants/app_colors.dart';
import '../../../data/models/emergency_model.dart';

class EmergencyHistoryScreen extends StatefulWidget {
  const EmergencyHistoryScreen({super.key});

  @override
  State<EmergencyHistoryScreen> createState() => _EmergencyHistoryScreenState();
}

class _EmergencyHistoryScreenState extends State<EmergencyHistoryScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String _selectedFilter = 'All';
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        title: const Text('Emergency History'),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.filter_list),
            onSelected: (value) => setState(() => _selectedFilter = value),
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'All', child: Text('All')),
              const PopupMenuItem(value: 'Active', child: Text('Active')),
              const PopupMenuItem(value: 'Completed', child: Text('Completed')),
              const PopupMenuItem(value: 'Cancelled', child: Text('Cancelled')),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          _buildSearchBar(),
          _buildFilterChips(),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _getEmergenciesStream(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return _buildEmptyState();
                }

                final emergencies = snapshot.data!.docs;

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: emergencies.length,
                  itemBuilder: (context, index) {
                    final emergency = EmergencyModel.fromJson({
                      ...emergencies[index].data() as Map<String, dynamic>,
                      'id': emergencies[index].id,
                    });
                    return _buildEmergencyCard(emergency);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Stream<QuerySnapshot> _getEmergenciesStream() {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return const Stream.empty();

    var query = _firestore
        .collection('emergencies')
        .where('userId', isEqualTo: userId)
        .orderBy('triggeredAt', descending: true);

    // Apply status filter
    if (_selectedFilter == 'Active') {
      query = query.where('status', whereIn: [
        'triggered',
        'locating',
        'notifying',
        'ambulanceSearching',
        'ambulanceAssigned',
        'ambulanceEnRoute',
        'hospitalEnRoute',
      ]);
    } else if (_selectedFilter == 'Completed') {
      query = query.where('status', isEqualTo: 'completed');
    } else if (_selectedFilter == 'Cancelled') {
      query = query.where('status', isEqualTo: 'cancelled');
    }

    return query.snapshots();
  }

  Widget _buildSearchBar() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: _searchController,
        decoration: const InputDecoration(
          hintText: 'Search by date or location...',
          border: InputBorder.none,
          icon: Icon(Icons.search, color: AppColors.textSecondary),
        ),
        onChanged: (value) => setState(() {}),
      ),
    );
  }

  Widget _buildFilterChips() {
    return Container(
      height: 50,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          _buildChip('All', _selectedFilter == 'All'),
          _buildChip('Active', _selectedFilter == 'Active'),
          _buildChip('Completed', _selectedFilter == 'Completed'),
          _buildChip('Cancelled', _selectedFilter == 'Cancelled'),
        ],
      ),
    );
  }

  Widget _buildChip(String label, bool isSelected) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (selected) {
          setState(() => _selectedFilter = label);
        },
        selectedColor: AppColors.primaryTeal,
        labelStyle: TextStyle(
          color: isSelected ? Colors.white : AppColors.textPrimary,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
    );
  }

  Widget _buildEmergencyCard(EmergencyModel emergency) {
    final statusColor = _getStatusColor(emergency.status);
    final statusIcon = _getStatusIcon(emergency.status);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: statusColor.withOpacity(0.3),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow.withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.1),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(14)),
            ),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(statusIcon, color: statusColor, size: 28),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        emergency.status.displayName,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: statusColor,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _formatDate(emergency.triggeredAt),
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: statusColor,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    emergency.emergencyType.toUpperCase(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Content
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Location
                Row(
                  children: [
                    const Icon(Icons.location_on, color: AppColors.primaryTeal, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        emergency.location.address ??
                            'Lat: ${emergency.location.latitude.toStringAsFixed(4)}, '
                                'Long: ${emergency.location.longitude.toStringAsFixed(4)}',
                        style: const TextStyle(fontSize: 13),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                // Details
                if (emergency.ambulanceNumber != null) ...[
                  _buildDetailRow(
                    Icons.car_crash,
                    'Ambulance',
                    emergency.ambulanceNumber!,
                  ),
                  const SizedBox(height: 8),
                ],

                if (emergency.hospitalName != null) ...[
                  _buildDetailRow(
                    Icons.local_hospital,
                    'Hospital',
                    emergency.hospitalName!,
                  ),
                  const SizedBox(height: 8),
                ],

                if (emergency.notifiedContacts.isNotEmpty) ...[
                  _buildDetailRow(
                    Icons.contact_phone,
                    'Contacts Notified',
                    '${emergency.notifiedContacts.length} contacts',
                  ),
                ],

                const SizedBox(height: 16),

                // Action Buttons
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _showEmergencyDetails(emergency),
                        icon: const Icon(Icons.info_outline, size: 18),
                        label: const Text('Details'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.primaryTeal,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => _openInMaps(emergency.location),
                        icon: const Icon(Icons.map, size: 18),
                        label: const Text('Map'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryTeal,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, color: AppColors.textSecondary, size: 18),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: const TextStyle(
            fontSize: 13,
            color: AppColors.textSecondary,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.history,
            size: 80,
            color: AppColors.textSecondary.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          const Text(
            'No Emergency History',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Your emergency history will appear here',
            style: TextStyle(color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(EmergencyStatus status) {
    switch (status) {
      case EmergencyStatus.completed:
        return AppColors.successGreen;
      case EmergencyStatus.cancelled:
        return AppColors.textSecondary;
      case EmergencyStatus.triggered:
      case EmergencyStatus.ambulanceEnRoute:
        return AppColors.alertRed;
      default:
        return AppColors.primaryTeal;
    }
  }

  IconData _getStatusIcon(EmergencyStatus status) {
    switch (status) {
      case EmergencyStatus.completed:
        return Icons.check_circle;
      case EmergencyStatus.cancelled:
        return Icons.cancel;
      case EmergencyStatus.ambulanceEnRoute:
      case EmergencyStatus.ambulanceAssigned:
        return Icons.car_crash;
      case EmergencyStatus.hospitalEnRoute:
      case EmergencyStatus.hospitalArrived:
        return Icons.local_hospital;
      default:
        return Icons.emergency;
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'Today, ${_formatTime(date)}';
    } else if (difference.inDays == 1) {
      return 'Yesterday, ${_formatTime(date)}';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }

  String _formatTime(DateTime date) {
    final hour = date.hour > 12 ? date.hour - 12 : (date.hour == 0 ? 12 : date.hour);
    final period = date.hour >= 12 ? 'PM' : 'AM';
    return '${hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')} $period';
  }

  void _showEmergencyDetails(EmergencyModel emergency) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) => SingleChildScrollView(
          controller: scrollController,
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.backgroundGrey,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Emergency Details',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 24),
              _buildDetailSection('Status', emergency.status.displayName),
              _buildDetailSection('Type', emergency.emergencyType.toUpperCase()),
              _buildDetailSection('Triggered At', _formatDate(emergency.triggeredAt)),
              if (emergency.location.address != null)
                _buildDetailSection('Location', emergency.location.address!),
              if (emergency.ambulanceNumber != null)
                _buildDetailSection('Ambulance', emergency.ambulanceNumber!),
              if (emergency.driverName != null)
                _buildDetailSection('Driver', emergency.driverName!),
              if (emergency.hospitalName != null)
                _buildDetailSection('Hospital', emergency.hospitalName!),
              if (emergency.notifiedContacts.isNotEmpty)
                _buildDetailSection(
                  'Contacts Notified',
                  emergency.notifiedContacts.join(', '),
                ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryTeal,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text('Close'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailSection(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  void _openInMaps(EmergencyLocation location) {
    // TODO: Use url_launcher to open Google Maps
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Opening location: ${location.mapsUrl}')),
    );
  }
}




// import 'package:flutter/material.dart';
// import 'package:arogyaraksha_ai/core/constants/app_colors.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:intl/intl.dart';
//
// class EmergencyHistoryScreen extends StatefulWidget {
//   const EmergencyHistoryScreen({super.key});
//
//   @override
//   State<EmergencyHistoryScreen> createState() => _EmergencyHistoryScreenState();
// }
//
// class _EmergencyHistoryScreenState extends State<EmergencyHistoryScreen> {
//   final FirebaseAuth _auth = FirebaseAuth.instance;
//   final FirebaseFirestore _firestore = FirebaseFirestore.instance;
//
//   String _selectedFilter = 'All';
//   final List<String> _filters = ['All', 'Completed', 'Cancelled', 'In Progress'];
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: AppColors.backgroundLight,
//       appBar: AppBar(
//         title: const Text('Emergency History'),
//         elevation: 0,
//         actions: [
//           IconButton(
//             onPressed: () {
//               _showFilterBottomSheet();
//             },
//             icon: const Icon(Icons.filter_list),
//           ),
//         ],
//       ),
//       body: Column(
//         children: [
//           // Filter Chips
//           SizedBox(
//             height: 60,
//             child: ListView.builder(
//               padding: const EdgeInsets.symmetric(horizontal: 16),
//               scrollDirection: Axis.horizontal,
//               itemCount: _filters.length,
//               itemBuilder: (context, index) {
//                 final filter = _filters[index];
//                 final isSelected = _selectedFilter == filter;
//                 return Padding(
//                   padding: const EdgeInsets.only(right: 8),
//                   child: FilterChip(
//                     label: Text(filter),
//                     selected: isSelected,
//                     onSelected: (selected) {
//                       setState(() {
//                         _selectedFilter = filter;
//                       });
//                     },
//                     backgroundColor: AppColors.white,
//                     selectedColor: AppColors.primaryTeal,
//                     labelStyle: TextStyle(
//                       color: isSelected ? AppColors.white : AppColors.textPrimary,
//                       fontWeight: FontWeight.w600,
//                       fontSize: 14,
//                     ),
//                     checkmarkColor: AppColors.white,
//                     padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
//                   ),
//                 );
//               },
//             ),
//           ),
//
//           // History List with StreamBuilder
//           Expanded(
//             child: StreamBuilder<QuerySnapshot>(
//               stream: _getEmergenciesStream(),
//               builder: (context, snapshot) {
//                 if (snapshot.connectionState == ConnectionState.waiting) {
//                   return const Center(
//                     child: CircularProgressIndicator(color: AppColors.primaryTeal),
//                   );
//                 }
//
//                 if (snapshot.hasError) {
//                   return Center(
//                     child: Text('Error: ${snapshot.error}'),
//                   );
//                 }
//
//                 if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
//                   return _buildEmptyState();
//                 }
//
//                 final emergencies = snapshot.data!.docs;
//
//                 return ListView.builder(
//                   padding: const EdgeInsets.all(16),
//                   itemCount: emergencies.length,
//                   itemBuilder: (context, index) {
//                     final emergency = emergencies[index].data() as Map<String, dynamic>;
//                     return _buildHistoryCard(context, emergency);
//                   },
//                 );
//               },
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Stream<QuerySnapshot> _getEmergenciesStream() {
//     final userId = _auth.currentUser?.uid;
//     if (userId == null) {
//       return const Stream.empty();
//     }
//
//     Query query = _firestore
//         .collection('emergencies')
//         .where('userId', isEqualTo: userId)
//         .orderBy('timestamp', descending: true);
//
//     if (_selectedFilter != 'All') {
//       query = query.where('status', isEqualTo: _selectedFilter.toLowerCase());
//     }
//
//     return query.snapshots();
//   }
//
//   Widget _buildEmptyState() {
//     return Center(
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           Icon(
//             Icons.history_outlined,
//             size: 80,
//             color: AppColors.textLight.withOpacity(0.5),
//           ),
//           const SizedBox(height: 16),
//           Text(
//             'No Emergency History',
//             style: Theme.of(context).textTheme.titleLarge?.copyWith(
//               color: AppColors.textSecondary,
//               fontWeight: FontWeight.bold,
//             ),
//           ),
//           const SizedBox(height: 8),
//           Text(
//             'Your emergency records will appear here',
//             style: Theme.of(context).textTheme.bodyMedium?.copyWith(
//               color: AppColors.textLight,
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildHistoryCard(BuildContext context, Map<String, dynamic> emergency) {
//     final String title = emergency['type'] ?? 'Emergency';
//     final Timestamp timestamp = emergency['timestamp'] ?? Timestamp.now();
//     final DateTime dateTime = timestamp.toDate();
//     final String formattedDate = DateFormat('dd MMM yyyy, hh:mm a').format(dateTime);
//     final String hospital = emergency['hospitalName'] ?? 'N/A';
//     final String ambulance = emergency['ambulanceId'] ?? 'N/A';
//     final String responseTime = emergency['responseTime'] ?? 'N/A';
//     final String status = emergency['status'] ?? 'pending';
//
//     Color statusColor;
//     IconData statusIcon;
//
//     switch (status.toLowerCase()) {
//       case 'completed':
//         statusColor = AppColors.successGreen;
//         statusIcon = Icons.check_circle;
//         break;
//       case 'cancelled':
//         statusColor = AppColors.textLight;
//         statusIcon = Icons.cancel;
//         break;
//       case 'in progress':
//         statusColor = AppColors.accentLightBlue;
//         statusIcon = Icons.timelapse;
//         break;
//       default:
//         statusColor = AppColors.textLight;
//         statusIcon = Icons.pending;
//     }
//
//     return Container(
//       margin: const EdgeInsets.only(bottom: 16),
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
//       child: Column(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           // Header
//           Container(
//             padding: const EdgeInsets.all(16),
//             decoration: BoxDecoration(
//               color: statusColor.withOpacity(0.1),
//               borderRadius: const BorderRadius.only(
//                 topLeft: Radius.circular(16),
//                 topRight: Radius.circular(16),
//               ),
//             ),
//             child: Row(
//               children: [
//                 Icon(statusIcon, color: statusColor, size: 24),
//                 const SizedBox(width: 12),
//                 Expanded(
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     mainAxisSize: MainAxisSize.min,
//                     children: [
//                       Text(
//                         title,
//                         style: Theme.of(context).textTheme.titleMedium?.copyWith(
//                           fontWeight: FontWeight.bold,
//                         ),
//                         maxLines: 1,
//                         overflow: TextOverflow.ellipsis,
//                       ),
//                       const SizedBox(height: 4),
//                       Text(
//                         formattedDate,
//                         style: Theme.of(context).textTheme.bodySmall?.copyWith(
//                           color: AppColors.textSecondary,
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//                 Container(
//                   padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
//                   decoration: BoxDecoration(
//                     color: statusColor,
//                     borderRadius: BorderRadius.circular(8),
//                   ),
//                   child: Text(
//                     status.toUpperCase(),
//                     style: Theme.of(context).textTheme.bodySmall?.copyWith(
//                       color: AppColors.white,
//                       fontWeight: FontWeight.bold,
//                       fontSize: 11,
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//
//           // Details
//           Padding(
//             padding: const EdgeInsets.all(16),
//             child: Column(
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 _buildDetailRow(
//                   context,
//                   Icons.local_hospital_outlined,
//                   'Hospital',
//                   hospital,
//                 ),
//                 const SizedBox(height: 12),
//                 _buildDetailRow(
//                   context,
//                   Icons.car_rental_rounded,
//                   'Ambulance',
//                   ambulance,
//                 ),
//                 const SizedBox(height: 12),
//                 _buildDetailRow(
//                   context,
//                   Icons.timer_outlined,
//                   'Response Time',
//                   responseTime,
//                 ),
//                 const SizedBox(height: 16),
//                 Row(
//                   children: [
//                     Expanded(
//                       child: OutlinedButton.icon(
//                         onPressed: () {
//                           _showDetailsDialog(context, emergency);
//                         },
//                         icon: const Icon(Icons.info_outline, size: 18),
//                         label: const Text('Details', style: TextStyle(fontSize: 13)),
//                         style: OutlinedButton.styleFrom(
//                           foregroundColor: AppColors.primaryTeal,
//                           side: const BorderSide(color: AppColors.primaryTeal),
//                           padding: const EdgeInsets.symmetric(vertical: 12),
//                         ),
//                       ),
//                     ),
//                     const SizedBox(width: 12),
//                     Expanded(
//                       child: OutlinedButton.icon(
//                         onPressed: () {
//                           // TODO: Generate and download report
//                           ScaffoldMessenger.of(context).showSnackBar(
//                             const SnackBar(
//                               content: Text('Report download coming soon!'),
//                             ),
//                           );
//                         },
//                         icon: const Icon(Icons.download_outlined, size: 18),
//                         label: const Text('Report', style: TextStyle(fontSize: 13)),
//                         style: OutlinedButton.styleFrom(
//                           foregroundColor: AppColors.secondaryBlue,
//                           side: const BorderSide(color: AppColors.secondaryBlue),
//                           padding: const EdgeInsets.symmetric(vertical: 12),
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildDetailRow(
//       BuildContext context,
//       IconData icon,
//       String label,
//       String value,
//       ) {
//     return Row(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Icon(icon, size: 20, color: AppColors.primaryTeal),
//         const SizedBox(width: 12),
//         Expanded(
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               Text(
//                 label,
//                 style: Theme.of(context).textTheme.bodySmall?.copyWith(
//                   color: AppColors.textSecondary,
//                 ),
//               ),
//               Text(
//                 value,
//                 style: Theme.of(context).textTheme.bodyMedium?.copyWith(
//                   fontWeight: FontWeight.w600,
//                 ),
//                 maxLines: 2,
//                 overflow: TextOverflow.ellipsis,
//               ),
//             ],
//           ),
//         ),
//       ],
//     );
//   }
//
//   void _showFilterBottomSheet() {
//     showModalBottomSheet(
//       context: context,
//       shape: const RoundedRectangleBorder(
//         borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
//       ),
//       builder: (context) {
//         return Padding(
//           padding: const EdgeInsets.all(20),
//           child: Column(
//             mainAxisSize: MainAxisSize.min,
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Text(
//                 'Filter by Status',
//                 style: Theme.of(context).textTheme.titleLarge?.copyWith(
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
//               const SizedBox(height: 16),
//               ..._filters.map((filter) {
//                 return ListTile(
//                   leading: Radio<String>(
//                     value: filter,
//                     groupValue: _selectedFilter,
//                     onChanged: (value) {
//                       setState(() {
//                         _selectedFilter = value!;
//                       });
//                       Navigator.pop(context);
//                     },
//                     activeColor: AppColors.primaryTeal,
//                   ),
//                   title: Text(filter),
//                   onTap: () {
//                     setState(() {
//                       _selectedFilter = filter;
//                     });
//                     Navigator.pop(context);
//                   },
//                 );
//               }).toList(),
//             ],
//           ),
//         );
//       },
//     );
//   }
//
//   void _showDetailsDialog(BuildContext context, Map<String, dynamic> emergency) {
//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: Text(emergency['type'] ?? 'Emergency Details'),
//         content: SingleChildScrollView(
//           child: Column(
//             mainAxisSize: MainAxisSize.min,
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               _buildDialogRow('Status:', emergency['status'] ?? 'N/A'),
//               const SizedBox(height: 8),
//               _buildDialogRow('Hospital:', emergency['hospitalName'] ?? 'N/A'),
//               const SizedBox(height: 8),
//               _buildDialogRow('Ambulance:', emergency['ambulanceId'] ?? 'N/A'),
//               const SizedBox(height: 8),
//               _buildDialogRow('Response Time:', emergency['responseTime'] ?? 'N/A'),
//               const SizedBox(height: 8),
//               _buildDialogRow('Location:', emergency['address'] ?? 'N/A'),
//               const SizedBox(height: 8),
//               _buildDialogRow('Notes:', emergency['notes'] ?? 'No additional notes'),
//             ],
//           ),
//         ),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context),
//             child: const Text('Close'),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildDialogRow(String label, String value) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       mainAxisSize: MainAxisSize.min,
//       children: [
//         Text(
//           label,
//           style: const TextStyle(
//             fontWeight: FontWeight.bold,
//             fontSize: 14,
//           ),
//         ),
//         const SizedBox(height: 4),
//         Text(
//           value,
//           style: const TextStyle(fontSize: 14),
//         ),
//       ],
//     );
//   }
// }
//
//
// // import 'package:flutter/material.dart';
// // import 'package:arogyaraksha_ai/core/constants/app_colors.dart';
// //
// //
// // class EmergencyHistoryScreen extends StatefulWidget {
// //   const EmergencyHistoryScreen({super.key});
// //
// //   @override
// //   State<EmergencyHistoryScreen> createState() => _EmergencyHistoryScreenState();
// // }
// //
// // class _EmergencyHistoryScreenState extends State<EmergencyHistoryScreen> {
// //   String _selectedFilter = 'All';
// //   final List<String> _filters = ['All', 'Completed', 'Cancelled', 'In Progress'];
// //
// //   @override
// //   Widget build(BuildContext context) {
// //     return Scaffold(
// //       backgroundColor: AppColors.backgroundLight,
// //       appBar: AppBar(
// //         title: const Text('Emergency History'),
// //         actions: [
// //           IconButton(
// //             onPressed: () {},
// //             icon: const Icon(Icons.filter_list),
// //           ),
// //         ],
// //       ),
// //       body: Column(
// //         children: [
// //           // Filter Chips
// //           Container(
// //             height: 60,
// //             padding: const EdgeInsets.symmetric(horizontal: 16),
// //             child: ListView.builder(
// //               scrollDirection: Axis.horizontal,
// //               itemCount: _filters.length,
// //               itemBuilder: (context, index) {
// //                 final filter = _filters[index];
// //                 final isSelected = _selectedFilter == filter;
// //                 return Padding(
// //                   padding: const EdgeInsets.only(right: 8),
// //                   child: FilterChip(
// //                     label: Text(filter),
// //                     selected: isSelected,
// //                     onSelected: (selected) {
// //                       setState(() {
// //                         _selectedFilter = filter;
// //                       });
// //                     },
// //                     backgroundColor: AppColors.white,
// //                     selectedColor: AppColors.primaryTeal,
// //                     labelStyle: TextStyle(
// //                       color: isSelected ? AppColors.white : AppColors.textPrimary,
// //                       fontWeight: FontWeight.w600,
// //                     ),
// //                     checkmarkColor: AppColors.white,
// //                   ),
// //                 );
// //               },
// //             ),
// //           ),
// //
// //           // History List
// //           Expanded(
// //             child: ListView(
// //               padding: const EdgeInsets.all(16),
// //               children: [
// //                 _buildHistoryCard(
// //                   context,
// //                   'Cardiac Emergency',
// //                   '15 Sep 2025, 3:45 PM',
// //                   'Citycare Hospital',
// //                   'Ambulance: AMB-9087',
// //                   '12 mins',
// //                   'Completed',
// //                   AppColors.successGreen,
// //                   Icons.check_circle,
// //                 ),
// //                 _buildHistoryCard(
// //                   context,
// //                   'Breathing Difficulty',
// //                   '28 Aug 2025, 8:20 AM',
// //                   'Metro Hospital',
// //                   'Ambulance: AMB-5621',
// //                   '8 mins',
// //                   'Completed',
// //                   AppColors.successGreen,
// //                   Icons.check_circle,
// //                 ),
// //                 _buildHistoryCard(
// //                   context,
// //                   'High Blood Pressure',
// //                   '12 Aug 2025, 11:30 PM',
// //                   'Apollo Hospital',
// //                   'Ambulance: AMB-3342',
// //                   '15 mins',
// //                   'Cancelled',
// //                   AppColors.textLight,
// //                   Icons.cancel,
// //                 ),
// //                 _buildHistoryCard(
// //                   context,
// //                   'Chest Pain',
// //                   '05 Jul 2025, 6:15 PM',
// //                   'Fortis Hospital',
// //                   'Ambulance: AMB-7754',
// //                   '10 mins',
// //                   'Completed',
// //                   AppColors.successGreen,
// //                   Icons.check_circle,
// //                 ),
// //               ],
// //             ),
// //           ),
// //         ],
// //       ),
// //     );
// //   }
// //
// //   Widget _buildHistoryCard(
// //       BuildContext context,
// //       String title,
// //       String dateTime,
// //       String hospital,
// //       String ambulance,
// //       String responseTime,
// //       String status,
// //       Color statusColor,
// //       IconData statusIcon,
// //       ) {
// //     return Container(
// //       margin: const EdgeInsets.only(bottom: 16),
// //       decoration: BoxDecoration(
// //         color: AppColors.white,
// //         borderRadius: BorderRadius.circular(16),
// //         boxShadow: [
// //           BoxShadow(
// //             color: AppColors.shadow.withOpacity(0.08),
// //             blurRadius: 10,
// //             offset: const Offset(0, 4),
// //           ),
// //         ],
// //       ),
// //       child: Column(
// //         children: [
// //           // Header
// //           Container(
// //             padding: const EdgeInsets.all(16),
// //             decoration: BoxDecoration(
// //               color: statusColor.withOpacity(0.1),
// //               borderRadius: const BorderRadius.only(
// //                 topLeft: Radius.circular(16),
// //                 topRight: Radius.circular(16),
// //               ),
// //             ),
// //             child: Row(
// //               children: [
// //                 Icon(
// //                   statusIcon,
// //                   color: statusColor,
// //                   size: 24,
// //                 ),
// //                 const SizedBox(width: 12),
// //                 Expanded(
// //                   child: Column(
// //                     crossAxisAlignment: CrossAxisAlignment.start,
// //                     children: [
// //                       Text(
// //                         title,
// //                         style: Theme.of(context).textTheme.titleMedium?.copyWith(
// //                           fontWeight: FontWeight.bold,
// //                         ),
// //                       ),
// //                       const SizedBox(height: 4),
// //                       Text(
// //                         dateTime,
// //                         style: Theme.of(context).textTheme.bodySmall?.copyWith(
// //                           color: AppColors.textSecondary,
// //                         ),
// //                       ),
// //                     ],
// //                   ),
// //                 ),
// //                 Container(
// //                   padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
// //                   decoration: BoxDecoration(
// //                     color: statusColor,
// //                     borderRadius: BorderRadius.circular(8),
// //                   ),
// //                   child: Text(
// //                     status,
// //                     style: Theme.of(context).textTheme.bodySmall?.copyWith(
// //                       color: AppColors.white,
// //                       fontWeight: FontWeight.bold,
// //                     ),
// //                   ),
// //                 ),
// //               ],
// //             ),
// //           ),
// //
// //           // Details
// //           Padding(
// //             padding: const EdgeInsets.all(16),
// //             child: Column(
// //               children: [
// //                 _buildDetailRow(
// //                   context,
// //                   Icons.local_hospital_outlined,
// //                   'Hospital',
// //                   hospital,
// //                 ),
// //                 const SizedBox(height: 12),
// //                 _buildDetailRow(
// //                   context,
// //                   Icons.car_rental_rounded,
// //                   'Ambulance',
// //                   ambulance,
// //                 ),
// //                 const SizedBox(height: 12),
// //                 _buildDetailRow(
// //                   context,
// //                   Icons.timer_outlined,
// //                   'Response Time',
// //                   responseTime,
// //                 ),
// //                 const SizedBox(height: 16),
// //                 Row(
// //                   children: [
// //                     Expanded(
// //                       child: OutlinedButton.icon(
// //                         onPressed: () {},
// //                         icon: const Icon(Icons.info_outline, size: 18),
// //                         label: const Text('View Details'),
// //                         style: OutlinedButton.styleFrom(
// //                           foregroundColor: AppColors.primaryTeal,
// //                           side: const BorderSide(color: AppColors.primaryTeal),
// //                         ),
// //                       ),
// //                     ),
// //                     const SizedBox(width: 12),
// //                     Expanded(
// //                       child: OutlinedButton.icon(
// //                         onPressed: () {},
// //                         icon: const Icon(Icons.download_outlined, size: 18),
// //                         label: const Text('Report'),
// //                         style: OutlinedButton.styleFrom(
// //                           foregroundColor: AppColors.secondaryBlue,
// //                           side: const BorderSide(color: AppColors.secondaryBlue),
// //                         ),
// //                       ),
// //                     ),
// //                   ],
// //                 ),
// //               ],
// //             ),
// //           ),
// //         ],
// //       ),
// //     );
// //   }
// //
// //   Widget _buildDetailRow(
// //       BuildContext context,
// //       IconData icon,
// //       String label,
// //       String value,
// //       ) {
// //     return Row(
// //       children: [
// //         Icon(
// //           icon,
// //           size: 20,
// //           color: AppColors.primaryTeal,
// //         ),
// //         const SizedBox(width: 12),
// //         Expanded(
// //           child: Column(
// //             crossAxisAlignment: CrossAxisAlignment.start,
// //             children: [
// //               Text(
// //                 label,
// //                 style: Theme.of(context).textTheme.bodySmall?.copyWith(
// //                   color: AppColors.textSecondary,
// //                 ),
// //               ),
// //               Text(
// //                 value,
// //                 style: Theme.of(context).textTheme.bodyMedium?.copyWith(
// //                   fontWeight: FontWeight.w600,
// //                 ),
// //               ),
// //             ],
// //           ),
// //         ),
// //       ],
// //     );
// //   }
// // }
