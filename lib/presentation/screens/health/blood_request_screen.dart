import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/constants/app_colors.dart';
import '../../../presentation/widgets/custom_button.dart';

class BloodRequestScreen extends StatefulWidget {
  const BloodRequestScreen({super.key});

  @override
  State<BloodRequestScreen> createState() => _BloodRequestScreenState();
}

class _BloodRequestScreenState extends State<BloodRequestScreen> with SingleTickerProviderStateMixin {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  late TabController _tabController;
  String? _selectedBloodGroup;
  bool _isUrgent = false;

  final List<String> _bloodGroups = ['A+', 'A-', 'B+', 'B-', 'O+', 'O-', 'AB+', 'AB-'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _requestBlood() async {
    if (_selectedBloodGroup == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a blood group')),
      );
      return;
    }

    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) throw Exception('User not logged in');

      // Get user data
      final userDoc = await _firestore.collection('users').doc(userId).get();
      final userData = userDoc.data();

      // Create blood request
      await _firestore.collection('blood_requests').add({
        'userId': userId,
        'userName': userData?['name'] ?? 'Anonymous',
        'userPhone': userData?['phone'] ?? '',
        'bloodGroup': _selectedBloodGroup,
        'isUrgent': _isUrgent,
        'status': 'pending',
        'createdAt': FieldValue.serverTimestamp(),
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Blood request submitted successfully'),
            backgroundColor: AppColors.successGreen,
          ),
        );
        setState(() {
          _selectedBloodGroup = null;
          _isUrgent = false;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _registerAsDonor() async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) throw Exception('User not logged in');

      // Get user data
      final userDoc = await _firestore.collection('users').doc(userId).get();
      final userData = userDoc.data();

      if (userData?['bloodGroup'] == null || userData!['bloodGroup'].isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please add your blood group in profile first'),
          ),
        );
        return;
      }

      // Register as donor
      await _firestore.collection('blood_donors').doc(userId).set({
        'userId': userId,
        'name': userData['name'] ?? '',
        'phone': userData['phone'] ?? '',
        'bloodGroup': userData['bloodGroup'],
        'isAvailable': true,
        'lastDonation': null,
        'totalDonations': 0,
        'registeredAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Registered as blood donor successfully!'),
            backgroundColor: AppColors.successGreen,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        title: const Text('Blood Request'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Request Blood'),
            Tab(text: 'Donate Blood'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildRequestBloodTab(),
          _buildDonateBloodTab(),
        ],
      ),
    );
  }

  Widget _buildRequestBloodTab() {
    return SingleChildScrollView(
      child: Column(
        children: [
          _buildBloodRequestBanner(),
          const SizedBox(height: 24),
          _buildBloodGroupSelector(),
          const SizedBox(height: 16),
          _buildUrgencyToggle(),
          const SizedBox(height: 24),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: CustomButton(
              text: 'Submit Request',
              onPressed: _requestBlood,
              gradient: const LinearGradient(
                colors: [AppColors.bloodBPositive, AppColors.bloodONegative],
              ),
            ),
          ),
          const SizedBox(height: 24),
          _buildActiveRequests(),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildDonateBloodTab() {
    return SingleChildScrollView(
      child: Column(
        children: [
          _buildDonorBanner(),
          const SizedBox(height: 24),
          _buildDonorBenefits(),
          const SizedBox(height: 16),
          _buildDonorEligibility(),
          const SizedBox(height: 24),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: CustomButton(
              text: 'Register as Donor',
              onPressed: _registerAsDonor,
              gradient: AppColors.primaryGradient,
            ),
          ),
          const SizedBox(height: 24),
          _buildNearbyRequests(),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildBloodRequestBanner() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.bloodBPositive, AppColors.bloodONegative],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.bloodBPositive.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.bloodtype, color: Colors.white, size: 40),
          ),
          const SizedBox(width: 16),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Need Blood?',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Connect with donors instantly',
                  style: TextStyle(color: Colors.white70, fontSize: 14),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDonorBanner() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryTeal.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.favorite, color: Colors.white, size: 40),
          ),
          const SizedBox(width: 16),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Donate Blood',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Save lives by donating blood',
                  style: TextStyle(color: Colors.white70, fontSize: 14),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBloodGroupSelector() {
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
          const Text(
            'Select Blood Group',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: _bloodGroups.map((group) {
              final isSelected = _selectedBloodGroup == group;
              return GestureDetector(
                onTap: () => setState(() => _selectedBloodGroup = group),
                child: Container(
                  width: 70,
                  height: 70,
                  decoration: BoxDecoration(
                    gradient: isSelected
                        ? const LinearGradient(
                      colors: [AppColors.bloodBPositive, AppColors.bloodONegative],
                    )
                        : null,
                    color: isSelected ? null : AppColors.backgroundLight,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected ? Colors.transparent : AppColors.backgroundGrey,
                      width: 2,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      group,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: isSelected ? Colors.white : AppColors.textPrimary,
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildUrgencyToggle() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _isUrgent ? AppColors.alertRed.withOpacity(0.1) : AppColors.cardBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _isUrgent ? AppColors.alertRed : AppColors.backgroundGrey,
          width: 2,
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.emergency,
            color: _isUrgent ? AppColors.alertRed : AppColors.textSecondary,
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Text(
              'Mark as Urgent',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ),
          Switch(
            value: _isUrgent,
            onChanged: (value) => setState(() => _isUrgent = value),
            activeColor: AppColors.alertRed,
          ),
        ],
      ),
    );
  }

  Widget _buildActiveRequests() {
    return StreamBuilder<QuerySnapshot>(
      stream: _firestore
          .collection('blood_requests')
          .where('userId', isEqualTo: _auth.currentUser?.uid)
          .orderBy('createdAt', descending: true)
          .limit(5)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const SizedBox.shrink();
        }

        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.cardBackground,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Your Requests',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              ...snapshot.data!.docs.map((doc) {
                final data = doc.data() as Map<String, dynamic>;
                return _buildRequestCard(data);
              }),
            ],
          ),
        );
      },
    );
  }

  Widget _buildRequestCard(Map<String, dynamic> data) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.backgroundLight,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.backgroundGrey),
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppColors.bloodBPositive, AppColors.bloodONegative],
              ),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              child: Text(
                data['bloodGroup'] ?? '',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  data['isUrgent'] == true ? 'URGENT REQUEST' : 'Blood Request',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: data['isUrgent'] == true ? AppColors.alertRed : AppColors.textPrimary,
                  ),
                ),
                Text(
                  'Status: ${data['status'] ?? 'pending'}',
                  style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: data['status'] == 'fulfilled'
                  ? AppColors.successGreen.withOpacity(0.1)
                  : Colors.orange.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              data['status'] == 'fulfilled' ? 'Fulfilled' : 'Pending',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: data['status'] == 'fulfilled' ? AppColors.successGreen : Colors.orange,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDonorBenefits() {
    final benefits = [
      {'icon': Icons.favorite, 'text': 'Save up to 3 lives'},
      {'icon': Icons.health_and_safety, 'text': 'Free health checkup'},
      {'icon': Icons.local_fire_department, 'text': 'Burn calories'},
      {'icon': Icons.psychology, 'text': 'Emotional satisfaction'},
    ];

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Benefits of Donating',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          ...benefits.map((benefit) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(
              children: [
                Icon(benefit['icon'] as IconData, color: AppColors.primaryTeal),
                const SizedBox(width: 12),
                Text(benefit['text'] as String),
              ],
            ),
          )),
        ],
      ),
    );
  }

  Widget _buildDonorEligibility() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.blue.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.blue.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.info_outline, color: Colors.blue),
              const SizedBox(width: 8),
              const Text(
                'Eligibility Criteria',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Text('• Age: 18-65 years'),
          const Text('• Weight: Minimum 50 kg'),
          const Text('• Healthy and fit'),
          const Text('• No recent surgeries or medications'),
        ],
      ),
    );
  }

  Widget _buildNearbyRequests() {
    return StreamBuilder<QuerySnapshot>(
      stream: _firestore
          .collection('blood_requests')
          .where('status', isEqualTo: 'pending')
          .orderBy('createdAt', descending: true)
          .limit(5)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: AppColors.cardBackground,
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Center(
              child: Text('No active requests nearby'),
            ),
          );
        }

        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.cardBackground,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Nearby Requests',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              ...snapshot.data!.docs.map((doc) {
                final data = doc.data() as Map<String, dynamic>;
                return _buildRequestCard(data);
              }),
            ],
          ),
        );
      },
    );
  }
}


// import 'package:flutter/material.dart';
// import 'package:arogyaraksha_ai/core/constants/app_colors.dart';
// import 'package:arogyaraksha_ai/presentation/widgets/custom_button.dart';
//
// class BloodRequestScreen extends StatefulWidget {
//   const BloodRequestScreen({super.key});
//
//   @override
//   State<BloodRequestScreen> createState() => _BloodRequestScreenState();
// }
//
// class _BloodRequestScreenState extends State<BloodRequestScreen> {
//   String? _selectedBloodGroup;
//   final List<String> _bloodGroups = [
//     'A+',
//     'A-',
//     'B+',
//     'B-',
//     'O+',
//     'O-',
//     'AB+',
//     'AB-'
//   ];
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: AppColors.backgroundLight,
//       appBar: AppBar(
//         title: const Text('Blood Request'),
//       ),
//       body: SingleChildScrollView(
//         child: Column(
//           children: [
//             // Blood Type Selector
//             Container(
//               margin: const EdgeInsets.all(16),
//               padding: const EdgeInsets.all(20),
//               decoration: BoxDecoration(
//                 color: AppColors.white,
//                 borderRadius: BorderRadius.circular(16),
//                 boxShadow: [
//                   BoxShadow(
//                     color: AppColors.shadow.withOpacity(0.08),
//                     blurRadius: 10,
//                     offset: const Offset(0, 4),
//                   ),
//                 ],
//               ),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Row(
//                     children: [
//                       Container(
//                         width: 48,
//                         height: 48,
//                         decoration: BoxDecoration(
//                           color: AppColors.alertRed.withOpacity(0.1),
//                           borderRadius: BorderRadius.circular(12),
//                         ),
//                         child: const Icon(
//                           Icons.bloodtype_outlined,
//                           color: AppColors.alertRed,
//                           size: 28,
//                         ),
//                       ),
//                       const SizedBox(width: 16),
//                       Expanded(
//                         child: Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             Text(
//                               'Request Blood',
//                               style: Theme.of(context)
//                                   .textTheme
//                                   .titleLarge
//                                   ?.copyWith(
//                                 fontWeight: FontWeight.bold,
//                               ),
//                             ),
//                             Text(
//                               'Select blood type to request',
//                               style: Theme.of(context)
//                                   .textTheme
//                                   .bodySmall
//                                   ?.copyWith(
//                                 color: AppColors.textSecondary,
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//                     ],
//                   ),
//                   const SizedBox(height: 20),
//                   GridView.builder(
//                     shrinkWrap: true,
//                     physics: const NeverScrollableScrollPhysics(),
//                     gridDelegate:
//                     const SliverGridDelegateWithFixedCrossAxisCount(
//                       crossAxisCount: 4,
//                       mainAxisSpacing: 12,
//                       crossAxisSpacing: 12,
//                       childAspectRatio: 1.2,
//                     ),
//                     itemCount: _bloodGroups.length,
//                     itemBuilder: (context, index) {
//                       final bloodGroup = _bloodGroups[index];
//                       final isSelected = _selectedBloodGroup == bloodGroup;
//                       return GestureDetector(
//                         onTap: () {
//                           setState(() {
//                             _selectedBloodGroup = bloodGroup;
//                           });
//                         },
//                         child: Container(
//                           decoration: BoxDecoration(
//                             gradient: isSelected
//                                 ? LinearGradient(
//                               colors: [
//                                 AppColors.alertRed,
//                                 AppColors.alertRedLight,
//                               ],
//                             )
//                                 : null,
//                             color: isSelected
//                                 ? null
//                                 : AppColors.backgroundLight,
//                             borderRadius: BorderRadius.circular(12),
//                             border: Border.all(
//                               color: isSelected
//                                   ? AppColors.alertRed
//                                   : AppColors.backgroundGrey,
//                               width: 2,
//                             ),
//                           ),
//                           child: Center(
//                             child: Text(
//                               bloodGroup,
//                               style: Theme.of(context)
//                                   .textTheme
//                                   .titleMedium
//                                   ?.copyWith(
//                                 fontWeight: FontWeight.bold,
//                                 color: isSelected
//                                     ? AppColors.white
//                                     : AppColors.textPrimary,
//                               ),
//                             ),
//                           ),
//                         ),
//                       );
//                     },
//                   ),
//                   const SizedBox(height: 20),
//                   CustomButton(
//                     text: 'Request Now',
//                     onPressed: () {
//                       if (_selectedBloodGroup != null) {
//                         _showRequestDialog(context);
//                       } else {
//                         ScaffoldMessenger.of(context).showSnackBar(
//                           const SnackBar(
//                             content: Text('Please select blood group'),
//                             backgroundColor: AppColors.warningOrange,
//                           ),
//                         );
//                       }
//                     },
//                     gradient: LinearGradient(
//                       colors: [
//                         AppColors.alertRed,
//                         AppColors.alertRedLight,
//                       ],
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//
//             const SizedBox(height: 8),
//
//             // Available Donors
//             Container(
//               margin: const EdgeInsets.symmetric(horizontal: 16),
//               padding: const EdgeInsets.all(20),
//               decoration: BoxDecoration(
//                 color: AppColors.white,
//                 borderRadius: BorderRadius.circular(16),
//               ),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     'Available Donors Nearby',
//                     style: Theme.of(context).textTheme.titleLarge?.copyWith(
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                   const SizedBox(height: 16),
//                   _buildDonorCard('Jhon Smith', 'B+', '1.2 km away'),
//                   _buildDonorCard('Jhon Smith', 'O+', '1 day ago'),
//                   _buildDonorCard('Jhon Smith', 'A+', '5 hours ago'),
//                   _buildDonorCard('Jhon Smith', 'B+', '3 hours ago'),
//                   _buildDonorCard('Jhon Smith', 'AB+', '7 hours ago'),
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
//   Widget _buildDonorCard(String name, String bloodGroup, String distance) {
//     return Container(
//       margin: const EdgeInsets.only(bottom: 12),
//       padding: const EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         color: AppColors.backgroundLight,
//         borderRadius: BorderRadius.circular(12),
//       ),
//       child: Row(
//         children: [
//           Container(
//             width: 48,
//             height: 48,
//             decoration: BoxDecoration(
//               gradient: AppColors.primaryGradient,
//               shape: BoxShape.circle,
//             ),
//             child: const Icon(
//               Icons.person,
//               color: AppColors.white,
//             ),
//           ),
//           const SizedBox(width: 12),
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   name,
//                   style: Theme.of(context).textTheme.titleMedium?.copyWith(
//                     fontWeight: FontWeight.w600,
//                   ),
//                 ),
//                 Text(
//                   distance,
//                   style: Theme.of(context).textTheme.bodySmall?.copyWith(
//                     color: AppColors.textSecondary,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//           Container(
//             padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
//             decoration: BoxDecoration(
//               gradient: LinearGradient(
//                 colors: [
//                   AppColors.alertRed,
//                   AppColors.alertRedLight,
//                 ],
//               ),
//               borderRadius: BorderRadius.circular(8),
//             ),
//             child: Text(
//               bloodGroup,
//               style: Theme.of(context).textTheme.titleSmall?.copyWith(
//                 color: AppColors.white,
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   void _showRequestDialog(BuildContext context) {
//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: const Text('Blood Request Sent'),
//         content: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             const Icon(
//               Icons.check_circle_outline,
//               size: 64,
//               color: AppColors.successGreen,
//             ),
//             const SizedBox(height: 16),
//             Text(
//               'Your request for $_selectedBloodGroup blood has been sent to nearby donors and blood banks.',
//               textAlign: TextAlign.center,
//             ),
//           ],
//         ),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context),
//             child: const Text('OK'),
//           ),
//         ],
//       ),
//     );
//   }
// }