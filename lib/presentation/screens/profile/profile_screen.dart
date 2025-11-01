import 'package:flutter/material.dart';
import 'package:arogyaraksha_ai/core/constants/app_colors.dart';
import 'package:arogyaraksha_ai/core/routes/app_routes.dart';
import 'package:arogyaraksha_ai/presentation/widgets/custom_button.dart';
import 'package:arogyaraksha_ai/data/models/user_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  UserModel? _userData;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) {
        Navigator.pushReplacementNamed(context, AppRoutes.login);
        return;
      }

      final doc = await _firestore.collection('users').doc(userId).get();

      if (doc.exists && mounted) {
        setState(() {
          _userData = UserModel.fromJson(doc.data()!);
          _isLoading = false;
        });
      } else {
        setState(() => _isLoading = false);
      }
    } catch (e) {
      print('Error loading user data: $e');
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: AppColors.backgroundLight,
        appBar: AppBar(title: const Text('Profile')),
        body: const Center(
          child: CircularProgressIndicator(color: AppColors.primaryTeal),
        ),
      );
    }

    if (_userData == null) {
      return Scaffold(
        backgroundColor: AppColors.backgroundLight,
        appBar: AppBar(title: const Text('Profile')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('No profile data found'),
              const SizedBox(height: 14),
              CustomButton(
                text: 'Create Profile',
                onPressed: () async {
                  final result = await Navigator.pushNamed(context, AppRoutes.editProfile);
                  if (result == true) _loadUserData();
                },
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          TextButton.icon(
            onPressed: () async {
              final result = await Navigator.pushNamed(context, AppRoutes.editProfile);
              if (result == true) _loadUserData();
            },
            icon: const Icon(Icons.edit_outlined, size: 20),
            label: const Text('Edit'),
            style: TextButton.styleFrom(foregroundColor: AppColors.cardBackground),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Profile Header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: const BoxDecoration(color: AppColors.cardBackground),
              child: Column(
                children: [
                  Stack(
                    children: [
                      Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: AppColors.primaryTeal, width: 3),
                          image: DecorationImage(
                            image: NetworkImage(
                              _userData?.photoURL ?? 'https://via.placeholder.com/150',
                            ),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            gradient: AppColors.primaryGradient,
                            shape: BoxShape.circle,
                            border: Border.all(color: AppColors.cardBackground, width: 2),
                          ),
                          child: const Icon(
                            Icons.camera_alt_outlined,
                            color: AppColors.cardBackground,
                            size: 18,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    _userData?.name ?? 'N/A',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    _userData?.email ?? '',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Personal Details Section
            _buildSection(context, 'Personal Details', [
              _buildInfoRow(context, 'Name:', _userData?.name ?? 'N/A'),
              _buildInfoRow(context, 'Age:', '${_userData?.age ?? 0} years'),
              _buildInfoRow(context, 'Gender:', _userData?.gender ?? 'N/A'),
              _buildInfoRow(context, 'Address:', _userData?.address ?? 'N/A'),
              Row(
                children: [
                  Flexible(
                    child: _buildInfoRow(context, 'Contact:', _userData?.phone ?? 'N/A'),
                  ),
                  Flexible(
                    child: _buildInfoRow(context, 'Blood Group:', _userData?.bloodGroup ?? 'N/A'),
                  ),
                ],
              ),
            ]),

            const SizedBox(height: 16),

            // Emergency Contacts Section
            if (_userData?.emergencyContacts.isNotEmpty ?? false)
              _buildSection(context, 'Emergency Contacts', [
                ..._userData!.emergencyContacts.map((contact) =>
                    _buildEmergencyContactCard(context, contact)
                ),
              ]),

            const SizedBox(height: 16),

            // Medical History Section
            _buildSection(context, 'Medical History', [
              if (_userData?.medicalInfo.allergies.isNotEmpty ?? false)
                _buildInfoRow(context, 'Allergies:',
                    _userData!.medicalInfo.allergies.join(', ')),
              if (_userData?.medicalInfo.conditions.isNotEmpty ?? false)
                _buildInfoRow(context, 'Conditions:',
                    _userData!.medicalInfo.conditions.join(', ')),
              if (_userData?.medicalInfo.medications.isNotEmpty ?? false)
                _buildInfoRow(context, 'Medications:',
                    _userData!.medicalInfo.medications.join(', ')),
              if (_userData?.medicalInfo.lastCheckup != null)
                _buildInfoRow(context, 'Last Check-up:',
                    _userData!.medicalInfo.lastCheckup!),
            ]),

            const SizedBox(height: 16),

            // Insurance Details Section
            if (_userData?.insurance != null)
              _buildSection(context, 'Insurance Details', [
                _buildInfoRow(context, 'Provider:', _userData!.insurance!.provider),
                Row(
                  children: [
                    Flexible(
                      child: _buildInfoRow(context, 'Policy ID:',
                          _userData!.insurance!.policyNumber),
                    ),
                    CustomButton(
                      text: 'Verify Insurance',
                      onPressed: () {
                        Navigator.pushNamed(context, AppRoutes.insuranceStatus);
                      },
                      width: 140,
                      height: 36,
                    ),
                  ],
                ),
                if (_userData!.insurance!.validTill != null)
                  _buildInfoRow(context, 'Valid Till:',
                      _userData!.insurance!.validTill!),
                if (_userData!.insurance!.coverage != null)
                  _buildInfoRow(context, 'Coverage:',
                      _userData!.insurance!.coverage!),
              ]),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(BuildContext context, String title, List<Widget> children) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
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
          Text(
            title,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          ...children.map((child) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: child,
          )),
        ],
      ),
    );
  }

  Widget _buildInfoRow(BuildContext context, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label.isNotEmpty) ...[
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ),
        ],
        Expanded(
          child: Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEmergencyContactCard(BuildContext context, EmergencyContact contact) {
    return Container(
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: AppColors.backgroundLight,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: contact.isPrimary ? AppColors.primaryTeal : Colors.transparent,
          width: 2,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              gradient: AppColors.primaryGradient,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.person, color: Colors.white),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      contact.name,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (contact.isPrimary) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.primaryTeal,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Text(
                          'Primary',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                Text(
                  contact.relation,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                Text(
                  contact.phone,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.phone, color: AppColors.primaryTeal),
            onPressed: () {
              // TODO: Call functionality
            },
          ),
        ],
      ),
    );
  }
}


// import 'package:flutter/material.dart';
// import 'package:arogyaraksha_ai/core/constants/app_colors.dart';
// import 'package:arogyaraksha_ai/core/routes/app_routes.dart';
// import 'package:arogyaraksha_ai/presentation/widgets/custom_button.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
//
// class ProfileScreen extends StatefulWidget {
//   const ProfileScreen({super.key});
//
//   @override
//   State<ProfileScreen> createState() => _ProfileScreenState();
// }
//
// class _ProfileScreenState extends State<ProfileScreen> {
//   final FirebaseAuth _auth = FirebaseAuth.instance;
//   final FirebaseFirestore _firestore = FirebaseFirestore.instance;
//
//   Map<String, dynamic>? _userData;
//   bool _isLoading = true;
//
//   @override
//   void initState() {
//     super.initState();
//     _loadUserData();
//   }
//
//   Future<void> _loadUserData() async {
//     try {
//       final userId = _auth.currentUser?.uid;
//       if (userId == null) {
//         Navigator.pushReplacementNamed(context, AppRoutes.login);
//         return;
//       }
//
//       final doc = await _firestore.collection('users').doc(userId).get();
//
//       if (doc.exists) {
//         setState(() {
//           _userData = doc.data();
//           _isLoading = false;
//         });
//       } else {
//         setState(() => _isLoading = false);
//       }
//     } catch (e) {
//       print('Error loading user data: $e');
//       setState(() => _isLoading = false);
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     if (_isLoading) {
//       return Scaffold(
//         backgroundColor: AppColors.backgroundLight,
//         appBar: AppBar(title: const Text('Profile')),
//         body: const Center(
//           child: CircularProgressIndicator(color: AppColors.primaryTeal),
//         ),
//       );
//     }
//
//     return Scaffold(
//       backgroundColor: AppColors.backgroundLight,
//       appBar: AppBar(
//         title: const Text('Profile'),
//         actions: [
//           TextButton.icon(
//             onPressed: () async {
//               final result = await Navigator.pushNamed(context, AppRoutes.editProfile);
//               if (result == true) {
//                 _loadUserData(); // Reload data after edit
//               }
//             },
//             icon: const Icon(Icons.edit_outlined, size: 20),
//             label: const Text('Edit'),
//             style: TextButton.styleFrom(
//               foregroundColor: AppColors.cardBackground,
//             ),
//           ),
//           const SizedBox(width: 8),
//         ],
//       ),
//       body: SingleChildScrollView(
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             // Profile Header
//             Container(
//               width: double.infinity,
//               padding: const EdgeInsets.all(24),
//               decoration: const BoxDecoration(
//                 color: AppColors.cardBackground,
//               ),
//               child: Column(
//                 mainAxisSize: MainAxisSize.min,
//                 children: [
//                   Stack(
//                     children: [
//                       Container(
//                         width: 120,
//                         height: 120,
//                         decoration: BoxDecoration(
//                           shape: BoxShape.circle,
//                           border: Border.all(
//                             color: AppColors.primaryTeal,
//                             width: 3,
//                           ),
//                           image: DecorationImage(
//                             image: NetworkImage(
//                               _userData?['photoURL'] ?? 'https://via.placeholder.com/150',
//                             ),
//                             fit: BoxFit.cover,
//                           ),
//                         ),
//                       ),
//                       Positioned(
//                         bottom: 0,
//                         right: 0,
//                         child: Container(
//                           width: 36,
//                           height: 36,
//                           decoration: BoxDecoration(
//                             gradient: AppColors.primaryGradient,
//                             shape: BoxShape.circle,
//                             border: Border.all(
//                               color: AppColors.cardBackground,
//                               width: 2,
//                             ),
//                           ),
//                           child: const Icon(
//                             Icons.camera_alt_outlined,
//                             color: AppColors.cardBackground,
//                             size: 18,
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ],
//               ),
//             ),
//
//             const SizedBox(height: 16),
//
//             // Personal Details Section
//             _buildSection(
//               context,
//               'Personal Details:',
//               [
//                 _buildInfoRow(context, 'Name:', _userData?['name'] ?? 'N/A'),
//                 _buildInfoRow(context, 'Age:', _userData?['age']?.toString() ?? 'N/A'),
//                 _buildInfoRow(context, 'Address:', _userData?['address'] ?? 'N/A'),
//                 Row(
//                   children: [
//                     Flexible(
//                       child: _buildInfoRow(
//                           context,
//                           'Contact:',
//                           _userData?['phone'] ?? 'N/A'
//                       ),
//                     ),
//                     Flexible(
//                       child: _buildInfoRow(
//                           context,
//                           'Blood Group:',
//                           _userData?['bloodGroup'] ?? 'N/A'
//                       ),
//                     ),
//                   ],
//                 ),
//               ],
//             ),
//
//             const SizedBox(height: 16),
//
//             // Medical History Section
//             _buildSection(
//               context,
//               'Medical History:',
//               [
//                 _buildInfoRow(
//                     context,
//                     'Allergies:',
//                     _userData?['medicalHistory']?['allergies'] ?? 'None'
//                 ),
//                 _buildInfoRow(
//                     context,
//                     'Last Check-up:',
//                     _userData?['lastCheckup'] ?? 'N/A'
//                 ),
//               ],
//             ),
//
//             const SizedBox(height: 16),
//
//             // Insurance Details Section
//             _buildSection(
//               context,
//               'Insurance Details:',
//               [
//                 _buildInfoRow(
//                     context,
//                     'Provider:',
//                     _userData?['insurance']?['provider'] ?? 'N/A'
//                 ),
//                 Row(
//                   children: [
//                     Flexible(
//                       child: _buildInfoRow(
//                           context,
//                           'Policy ID:',
//                           _userData?['insurance']?['policyId'] ?? 'N/A'
//                       ),
//                     ),
//                     CustomButton(
//                       text: 'Verify Insurance',
//                       onPressed: () {
//                         Navigator.pushNamed(context, AppRoutes.insuranceStatus);
//                       },
//                       width: 140,
//                       height: 36,
//                     ),
//                   ],
//                 ),
//               ],
//             ),
//
//             const SizedBox(height: 24),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget _buildSection(
//       BuildContext context, String title, List<Widget> children) {
//     return Container(
//       margin: const EdgeInsets.symmetric(horizontal: 16),
//       padding: const EdgeInsets.all(20),
//       decoration: BoxDecoration(
//         color: AppColors.cardBackground,
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
//         crossAxisAlignment: CrossAxisAlignment.start,
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           Text(
//             title,
//             style: Theme.of(context).textTheme.titleLarge?.copyWith(
//               fontWeight: FontWeight.bold,
//             ),
//           ),
//           const SizedBox(height: 16),
//           ...children.map((child) => Padding(
//             padding: const EdgeInsets.only(bottom: 12),
//             child: child,
//           )),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildInfoRow(BuildContext context, String label, String value) {
//     return Row(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         if (label.isNotEmpty) ...[
//           SizedBox(
//             width: 120,
//             child: Text(
//               label,
//               style: Theme.of(context).textTheme.bodyMedium?.copyWith(
//                 color: AppColors.textSecondary,
//               ),
//             ),
//           ),
//         ],
//         Expanded(
//           child: Text(
//             value,
//             style: Theme.of(context).textTheme.bodyMedium?.copyWith(
//               fontWeight: FontWeight.w600,
//             ),
//           ),
//         ),
//       ],
//     );
//   }
// }
//
//
// // import 'package:flutter/material.dart';
// // import 'package:arogyaraksha_ai/core/constants/app_colors.dart';
// // import 'package:arogyaraksha_ai/core/routes/app_routes.dart';
// // import 'package:arogyaraksha_ai/presentation/widgets/custom_button.dart';
// //
// // class ProfileScreen extends StatelessWidget {
// //   const ProfileScreen({super.key});
// //
// //   @override
// //   Widget build(BuildContext context) {
// //     return Scaffold(
// //       backgroundColor: AppColors.backgroundLight,
// //       appBar: AppBar(
// //         title: const Text('Profile'),
// //         actions: [
// //           TextButton.icon(
// //             onPressed: () {
// //               Navigator.pushNamed(context, AppRoutes.editProfile);
// //             },
// //             icon: const Icon(Icons.edit_outlined, size: 20),
// //             label: const Text('Edit'),
// //             style: TextButton.styleFrom(
// //               foregroundColor: AppColors.cardBackground,
// //             ),
// //           ),
// //           const SizedBox(width: 8),
// //         ],
// //       ),
// //       body: SingleChildScrollView(
// //         child: Column(
// //           mainAxisSize: MainAxisSize.min, // ✅ important fix
// //           children: [
// //             // Profile Header
// //             Container(
// //               width: double.infinity,
// //               padding: const EdgeInsets.all(24),
// //               decoration: const BoxDecoration(
// //                 color: AppColors.cardBackground,
// //               ),
// //               child: Column(
// //                 mainAxisSize: MainAxisSize.min,
// //                 children: [
// //                   // Profile Picture
// //                   Stack(
// //                     children: [
// //                       Container(
// //                         width: 120,
// //                         height: 120,
// //                         decoration: BoxDecoration(
// //                           shape: BoxShape.circle,
// //                           border: Border.all(
// //                             color: AppColors.primaryTeal,
// //                             width: 3,
// //                           ),
// //                           image: const DecorationImage(
// //                             image: NetworkImage(
// //                               'https://via.placeholder.com/150',
// //                             ),
// //                             fit: BoxFit.cover,
// //                           ),
// //                         ),
// //                       ),
// //                       Positioned(
// //                         bottom: 0,
// //                         right: 0,
// //                         child: Container(
// //                           width: 36,
// //                           height: 36,
// //                           decoration: BoxDecoration(
// //                             gradient: AppColors.primaryGradient,
// //                             shape: BoxShape.circle,
// //                             border: Border.all(
// //                               color: AppColors.cardBackground,
// //                               width: 2,
// //                             ),
// //                           ),
// //                           child: const Icon(
// //                             Icons.camera_alt_outlined,
// //                             color: AppColors.cardBackground,
// //                             size: 18,
// //                           ),
// //                         ),
// //                       ),
// //                     ],
// //                   ),
// //                 ],
// //               ),
// //             ),
// //
// //             const SizedBox(height: 16),
// //
// //             // Personal Details Section
// //             _buildSection(
// //               context,
// //               'Personal Details:',
// //               [
// //                 _buildInfoRow(context, 'Name:', 'Taniya'),
// //                 _buildInfoRow(context, 'Age:', '21 years'),
// //                 _buildInfoRow(context, 'Address:', 'Sydney'),
// //                 Row(
// //                   children: [
// //                     Flexible(
// //                       child: _buildInfoRow(
// //                           context, 'Contact:', '+91 XXXXXXXXXX'),
// //                     ),
// //                     Flexible(
// //                       child: _buildInfoRow(context, 'Blood Group:', 'B+'),
// //                     ),
// //                   ],
// //                 ),
// //               ],
// //             ),
// //
// //             const SizedBox(height: 16),
// //
// //             // Medical History Section
// //             _buildSection(
// //               context,
// //               'Medical History:',
// //               [
// //                 _buildInfoRow(context, 'Allergies:', 'None'),
// //                 _buildInfoRow(context, 'Last Check-up:', '12 Sep 2025'),
// //               ],
// //             ),
// //
// //             const SizedBox(height: 16),
// //
// //             // Insurance Details Section
// //             _buildSection(
// //               context,
// //               'Insurance Details:',
// //               [
// //                 _buildInfoRow(context, 'Provider:', 'Star Health'),
// //                 Row(
// //                   children: [
// //                     Flexible(
// //                       child: _buildInfoRow(
// //                           context, 'Policy ID:', '#SH-2025-0041'),
// //                     ),
// //                     CustomButton(
// //                       text: 'Verify Insurance',
// //                       onPressed: () {
// //                         Navigator.pushNamed(
// //                             context, AppRoutes.insuranceStatus);
// //                       },
// //                       width: 140,
// //                       height: 36,
// //                     ),
// //                   ],
// //                 ),
// //               ],
// //             ),
// //
// //             const SizedBox(height: 24),
// //           ],
// //         ),
// //       ),
// //     );
// //   }
// //
// //   Widget _buildSection(
// //       BuildContext context, String title, List<Widget> children) {
// //     return Container(
// //       margin: const EdgeInsets.symmetric(horizontal: 16),
// //       padding: const EdgeInsets.all(20),
// //       decoration: BoxDecoration(
// //         color: AppColors.cardBackground,
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
// //         crossAxisAlignment: CrossAxisAlignment.start,
// //         mainAxisSize: MainAxisSize.min, // ✅ fix
// //         children: [
// //           Text(
// //             title,
// //             style: Theme.of(context).textTheme.titleLarge?.copyWith(
// //               fontWeight: FontWeight.bold,
// //             ),
// //           ),
// //           const SizedBox(height: 16),
// //           ...children.map((child) => Padding(
// //             padding: const EdgeInsets.only(bottom: 12),
// //             child: child,
// //           )),
// //         ],
// //       ),
// //     );
// //   }
// //
// //   Widget _buildInfoRow(BuildContext context, String label, String value) {
// //     return Row(
// //       crossAxisAlignment: CrossAxisAlignment.start,
// //       children: [
// //         if (label.isNotEmpty) ...[
// //           SizedBox(
// //             width: 120,
// //             child: Text(
// //               label,
// //               style: Theme.of(context).textTheme.bodyMedium?.copyWith(
// //                 color: AppColors.textSecondary,
// //               ),
// //             ),
// //           ),
// //         ],
// //         Expanded(
// //           child: Text(
// //             value,
// //             style: Theme.of(context).textTheme.bodyMedium?.copyWith(
// //               fontWeight: FontWeight.w600,
// //             ),
// //           ),
// //         ),
// //       ],
// //     );
// //   }
// // }
// //
// //
// // // import 'package:flutter/material.dart';
// // // import 'package:arogyaraksha_ai/core/constants/app_colors.dart';
// // // import 'package:arogyaraksha_ai/core/routes/app_routes.dart';
// // // import 'package:arogyaraksha_ai/presentation/widgets/custom_button.dart';
// // // class ProfileScreen extends StatelessWidget {
// // //   const ProfileScreen({super.key});
// // //
// // //   @override
// // //   Widget build(BuildContext context) {
// // //     return Scaffold(
// // //       backgroundColor: AppColors.backgroundLight,
// // //       appBar: AppBar(
// // //         title: const Text('Profile'),
// // //         actions: [
// // //           TextButton.icon(
// // //             onPressed: () {
// // //               Navigator.pushNamed(context, AppRoutes.editProfile);
// // //             },
// // //             icon: const Icon(Icons.edit_outlined, size: 20),
// // //             label: const Text('Edit'),
// // //             style: TextButton.styleFrom(
// // //               foregroundColor: AppColors.primaryTeal,
// // //             ),
// // //           ),
// // //           const SizedBox(width: 8),
// // //         ],
// // //       ),
// // //       body: SingleChildScrollView(
// // //         child: Column(
// // //           children: [
// // //             // Profile Header
// // //             Container(
// // //               width: double.infinity,
// // //               padding: const EdgeInsets.all(24),
// // //               decoration: const BoxDecoration(
// // //                 color: AppColors.cardBackground,
// // //               ),
// // //               child: Column(
// // //                 children: [
// // //                   // Profile Picture
// // //                   Stack(
// // //                     children: [
// // //                       Container(
// // //                         width: 120,
// // //                         height: 120,
// // //                         decoration: BoxDecoration(
// // //                           shape: BoxShape.circle,
// // //                           border: Border.all(
// // //                             color: AppColors.primaryTeal,
// // //                             width: 3,
// // //                           ),
// // //                           image: const DecorationImage(
// // //                             image: NetworkImage(
// // //                               'https://via.placeholder.com/150',
// // //                             ),
// // //                             fit: BoxFit.cover,
// // //                           ),
// // //                         ),
// // //                       ),
// // //                       Positioned(
// // //                         bottom: 0,
// // //                         right: 0,
// // //                         child: Container(
// // //                           width: 36,
// // //                           height: 36,
// // //                           decoration: BoxDecoration(
// // //                             gradient: AppColors.primaryGradient,
// // //                             shape: BoxShape.circle,
// // //                             border: Border.all(
// // //                               color: AppColors.cardBackground,
// // //                               width: 2,
// // //                             ),
// // //                           ),
// // //                           child: const Icon(
// // //                             Icons.camera_alt_outlined,
// // //                             color: AppColors.cardBackground,
// // //                             size: 18,
// // //                           ),
// // //                         ),
// // //                       ),
// // //                     ],
// // //                   ),
// // //                 ],
// // //               ),
// // //             ),
// // //
// // //             const SizedBox(height: 16),
// // //
// // //             // Personal Details Section
// // //             _buildSection(
// // //               context,
// // //               'Personal Details:',
// // //               [
// // //                 _buildInfoRow(context, 'Name:', 'Noaha'),
// // //                 _buildInfoRow(context, 'Age:', '25 years'),
// // //                 _buildInfoRow(context, 'Address:', 'Sydney'),
// // //                 Row(
// // //                   children: [
// // //
// // //                     Expanded(
// // //                       child: _buildInfoRow(
// // //                           context, 'Contact:', '+91 XXXXXXXXXX'),
// // //                     ),
// // //                     _buildInfoRow(context, 'Blood Group:', 'B+'),
// // //                   ],
// // //                 ),
// // //               ],
// // //             ),
// // //
// // //             const SizedBox(height: 16),
// // //
// // //             // Medical History Section
// // //             _buildSection(
// // //               context,
// // //               'Medical History:',
// // //               [
// // //                 _buildInfoRow(context, 'Allergies:', 'None'),
// // //                 _buildInfoRow(context, 'Last Check-up:', '12 Sep 2025'),
// // //               ],
// // //             ),
// // //
// // //             const SizedBox(height: 16),
// // //
// // //             // Insurance Details Section
// // //             _buildSection(
// // //               context,
// // //               'Insurance Details:',
// // //               [
// // //                 _buildInfoRow(context, 'Provider:', 'Star Health'),
// // //                 Row(
// // //                   children: [
// // //                     Expanded(
// // //                       child: _buildInfoRow(
// // //                           context, 'Policy ID:', '#SH-2025-0041'),
// // //                     ),
// // //                     CustomButton(
// // //                       text: 'Verify Insurance',
// // //                       onPressed: () {
// // //                         Navigator.pushNamed(context, AppRoutes.insuranceStatus);
// // //                       },
// // //                       width: 140,
// // //                       height: 36,
// // //                     ),
// // //                   ],
// // //                 ),
// // //               ],
// // //             ),
// // //
// // //             const SizedBox(height: 24),
// // //           ],
// // //         ),
// // //       ),
// // //     );
// // //   }
// // //
// // //   Widget _buildSection(
// // //       BuildContext context, String title, List<Widget> children) {
// // //     return Container(
// // //       margin: const EdgeInsets.symmetric(horizontal: 16),
// // //       padding: const EdgeInsets.all(20),
// // //       decoration: BoxDecoration(
// // //         color: AppColors.cardBackground,
// // //         borderRadius: BorderRadius.circular(16),
// // //         boxShadow: [
// // //           BoxShadow(
// // //             color: AppColors.shadow.withOpacity(0.08),
// // //             blurRadius: 10,
// // //             offset: const Offset(0, 4),
// // //           ),
// // //         ],
// // //       ),
// // //       child: Column(
// // //         crossAxisAlignment: CrossAxisAlignment.start,
// // //         children: [
// // //           Text(
// // //             title,
// // //             style: Theme.of(context).textTheme.titleLarge?.copyWith(
// // //               fontWeight: FontWeight.bold,
// // //             ),
// // //           ),
// // //           const SizedBox(height: 16),
// // //           ...children.map((child) => Padding(
// // //             padding: const EdgeInsets.only(bottom: 12),
// // //             child: child,
// // //           )),
// // //         ],
// // //       ),
// // //     );
// // //   }
// // //
// // //   Widget _buildInfoRow(BuildContext context, String label, String value) {
// // //     return Row(
// // //       crossAxisAlignment: CrossAxisAlignment.start,
// // //       children: [
// // //         if (label.isNotEmpty) ...[
// // //           SizedBox(
// // //             width: 120,
// // //             child: Text(
// // //               label,
// // //               style: Theme.of(context).textTheme.bodyMedium?.copyWith(
// // //                 color: AppColors.textSecondary,
// // //               ),
// // //             ),
// // //           ),
// // //         ],
// // //         Expanded(
// // //           child: Text(
// // //             value,
// // //             style: Theme.of(context).textTheme.bodyMedium?.copyWith(
// // //               fontWeight: FontWeight.w600,
// // //             ),
// // //           ),
// // //         ),
// // //       ],
// // //     );
// // //   }
// // // }