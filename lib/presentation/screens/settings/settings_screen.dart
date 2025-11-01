import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/routes/app_routes.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  bool _notificationsEnabled = true;
  bool _emergencyAlertsEnabled = true;
  bool _locationEnabled = true;
  String _selectedLanguage = 'English';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Profile Section
            _buildProfileSection(),
            const SizedBox(height: 8),

            // Emergency Settings
            _buildSectionHeader('Emergency Settings'),
            _buildSettingCard(
              icon: Icons.emergency,
              title: 'Emergency Contacts',
              subtitle: 'Manage emergency contacts',
              onTap: () => Navigator.pushNamed(context, AppRoutes.editProfile),
            ),
            _buildSwitchTile(
              icon: Icons.notification_important,
              title: 'Emergency Alerts',
              subtitle: 'Get instant emergency notifications',
              value: _emergencyAlertsEnabled,
              onChanged: (value) => setState(() => _emergencyAlertsEnabled = value),
            ),
            _buildSwitchTile(
              icon: Icons.location_on,
              title: 'Location Services',
              subtitle: 'Allow location access for emergencies',
              value: _locationEnabled,
              onChanged: (value) => setState(() => _locationEnabled = value),
            ),

            const SizedBox(height: 8),

            // Notifications
            _buildSectionHeader('Notifications'),
            _buildSwitchTile(
              icon: Icons.notifications,
              title: 'Push Notifications',
              subtitle: 'Receive app notifications',
              value: _notificationsEnabled,
              onChanged: (value) => setState(() => _notificationsEnabled = value),
            ),
            _buildSettingCard(
              icon: Icons.notifications_active,
              title: 'Notification Center',
              subtitle: 'View all notifications',
              onTap: () {
                // TODO: Navigate to notification center
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Notification center coming soon')),
                );
              },
            ),

            const SizedBox(height: 8),

            // Language & Region
            _buildSectionHeader('Language & Region'),
            _buildLanguageSelector(),

            const SizedBox(height: 8),

            // Account & Privacy
            _buildSectionHeader('Account & Privacy'),
            _buildSettingCard(
              icon: Icons.person,
              title: 'My Profile',
              subtitle: 'View and edit profile',
              onTap: () => Navigator.pushNamed(context, AppRoutes.profile),
            ),
            _buildSettingCard(
              icon: Icons.history,
              title: 'Emergency History',
              subtitle: 'View past emergencies',
              onTap: () => Navigator.pushNamed(context, AppRoutes.emergencyHistory),
            ),
            _buildSettingCard(
              icon: Icons.lock,
              title: 'Privacy & Security',
              subtitle: 'Manage privacy settings',
              onTap: () {
                _showPrivacyDialog();
              },
            ),

            const SizedBox(height: 8),

            // Support & About
            _buildSectionHeader('Support & About'),
            _buildSettingCard(
              icon: Icons.help_outline,
              title: 'Help & Support',
              subtitle: 'Get help or contact support',
              onTap: () {
                _showHelpDialog();
              },
            ),
            _buildSettingCard(
              icon: Icons.info_outline,
              title: 'About App',
              subtitle: 'Version 1.0.0',
              onTap: () {
                _showAboutDialog();
              },
            ),
            _buildSettingCard(
              icon: Icons.description,
              title: 'Terms & Conditions',
              subtitle: 'Read terms of service',
              onTap: () {
                _showTermsDialog();
              },
            ),

            const SizedBox(height: 8),

            // Logout
            _buildLogoutButton(),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileSection() {
    final user = _auth.currentUser;
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
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
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 3),
              image: DecorationImage(
                image: NetworkImage(user?.photoURL ?? 'https://via.placeholder.com/150'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user?.displayName ?? 'User',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  user?.email ?? '',
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.edit, color: Colors.white),
            onPressed: () => Navigator.pushNamed(context, AppRoutes.editProfile),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: AppColors.textSecondary,
        ),
      ),
    );
  }

  Widget _buildSettingCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: AppColors.primaryTeal.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: AppColors.primaryTeal),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text(subtitle, style: const TextStyle(fontSize: 12)),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: onTap,
      ),
    );
  }

  Widget _buildSwitchTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required Function(bool) onChanged,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(12),
      ),
      child: SwitchListTile(
        secondary: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: AppColors.primaryTeal.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: AppColors.primaryTeal),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text(subtitle, style: const TextStyle(fontSize: 12)),
        value: value,
        activeColor: AppColors.primaryTeal,
        onChanged: onChanged,
      ),
    );
  }

  Widget _buildLanguageSelector() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: AppColors.primaryTeal.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Icon(Icons.language, color: AppColors.primaryTeal),
        ),
        title: const Text('Language', style: TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text(_selectedLanguage, style: const TextStyle(fontSize: 12)),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: () {
          showModalBottomSheet(
            context: context,
            builder: (context) => Container(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Select Language',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  _buildLanguageOption('English', '🇬🇧'),
                  _buildLanguageOption('हिंदी', '🇮🇳'),
                  _buildLanguageOption('తెలుగు', '🇮🇳'),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildLanguageOption(String language, String flag) {
    return ListTile(
      leading: Text(flag, style: const TextStyle(fontSize: 24)),
      title: Text(language),
      trailing: _selectedLanguage == language
          ? const Icon(Icons.check, color: AppColors.primaryTeal)
          : null,
      onTap: () {
        setState(() => _selectedLanguage = language);
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Language changed to $language')),
        );
      },
    );
  }

  Widget _buildLogoutButton() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: ElevatedButton.icon(
        onPressed: () => _showLogoutDialog(),
        icon: const Icon(Icons.logout),
        label: const Text('Logout'),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.alertRed,
          foregroundColor: Colors.white,
          minimumSize: const Size(double.infinity, 50),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              await _auth.signOut();
              if (mounted) {
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  AppRoutes.login,
                      (route) => false,
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.alertRed),
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }

  void _showPrivacyDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Privacy & Security'),
        content: const SingleChildScrollView(
          child: Text(
            'Your privacy and security are important to us.\n\n'
                '• All data is encrypted\n'
                '• Location is only used for emergencies\n'
                '• Emergency contacts are stored securely\n'
                '• Medical data is confidential\n\n'
                'You can delete your account anytime.',
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

  void _showHelpDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Help & Support'),
        content: const SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Need help? Contact us:', style: TextStyle(fontWeight: FontWeight.bold)),
              SizedBox(height: 12),
              Text('📧 Email: support@arogyaraksha.com'),
              Text('📞 Phone: +91-1800-XXX-XXXX'),
              Text('🌐 Website: www.arogyaraksha.com'),
              SizedBox(height: 16),
              Text('Emergency Helpline:', style: TextStyle(fontWeight: FontWeight.bold)),
              Text('🚑 Ambulance: 108'),
              Text('👮 Police: 100'),
              Text('🚒 Fire: 101'),
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

  void _showAboutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('About ArogyaRaksha AI'),
        content: const SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Version 1.0.0',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 16),
              Text(
                'ArogyaRaksha AI is a smart health emergency response system designed to provide instant medical assistance.',
              ),
              SizedBox(height: 12),
              Text('Developed by: Particle14 Infotech Pvt. Ltd.'),
              Text('© 2025 All rights reserved'),
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

  void _showTermsDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Terms & Conditions'),
        content: const SingleChildScrollView(
          child: Text(
            '1. Acceptance of Terms\n'
                'By using this app, you agree to these terms.\n\n'
                '2. Emergency Services\n'
                'This app provides emergency assistance but does not replace professional medical services.\n\n'
                '3. Data Privacy\n'
                'We collect and store data as per our privacy policy.\n\n'
                '4. Liability\n'
                'We are not liable for delays in emergency response.\n\n'
                '5. User Responsibilities\n'
                'Users must provide accurate information.\n\n'
                'For complete terms, visit our website.',
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



// import 'package:flutter/material.dart';
// import 'package:arogyaraksha_ai/core/constants/app_colors.dart';
// import 'package:arogyaraksha_ai/core/routes/app_routes.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
//
// class SettingsScreen extends StatefulWidget {
//   const SettingsScreen({super.key});
//
//   @override
//   State<SettingsScreen> createState() => _SettingsScreenState();
// }
//
// class _SettingsScreenState extends State<SettingsScreen> {
//   final FirebaseAuth _auth = FirebaseAuth.instance;
//   final FirebaseFirestore _firestore = FirebaseFirestore.instance;
//
//   bool _emergencyAlerts = true;
//   bool _healthReminders = true;
//   bool _bloodRequests = false;
//   bool _biometricAuth = false;
//   bool _isLoading = false;
//
//   String _userName = 'User';
//   String _userEmail = 'user@example.com';
//
//   @override
//   void initState() {
//     super.initState();
//     _loadUserData();
//     _loadNotificationSettings();
//   }
//
//   Future<void> _loadUserData() async {
//     final user = _auth.currentUser;
//     if (user != null) {
//       setState(() {
//         _userName = user.displayName ?? 'User';
//         _userEmail = user.email ?? 'user@example.com';
//       });
//
//       try {
//         final doc = await _firestore.collection('users').doc(user.uid).get();
//         if (doc.exists) {
//           final data = doc.data()!;
//           setState(() {
//             _userName = data['name'] ?? _userName;
//           });
//         }
//       } catch (e) {
//         print('Error loading user data: $e');
//       }
//     }
//   }
//
//   Future<void> _loadNotificationSettings() async {
//     final userId = _auth.currentUser?.uid;
//     if (userId == null) return;
//
//     try {
//       final doc = await _firestore
//           .collection('users')
//           .doc(userId)
//           .collection('settings')
//           .doc('notifications')
//           .get();
//
//       if (doc.exists) {
//         final data = doc.data()!;
//         setState(() {
//           _emergencyAlerts = data['emergencyAlerts'] ?? true;
//           _healthReminders = data['healthReminders'] ?? true;
//           _bloodRequests = data['bloodRequests'] ?? false;
//           _biometricAuth = data['biometricAuth'] ?? false;
//         });
//       }
//     } catch (e) {
//       print('Error loading settings: $e');
//     }
//   }
//
//   Future<void> _saveNotificationSettings() async {
//     final userId = _auth.currentUser?.uid;
//     if (userId == null) return;
//
//     try {
//       await _firestore
//           .collection('users')
//           .doc(userId)
//           .collection('settings')
//           .doc('notifications')
//           .set({
//         'emergencyAlerts': _emergencyAlerts,
//         'healthReminders': _healthReminders,
//         'bloodRequests': _bloodRequests,
//         'biometricAuth': _biometricAuth,
//         'updatedAt': FieldValue.serverTimestamp(),
//       }, SetOptions(merge: true));
//     } catch (e) {
//       print('Error saving settings: $e');
//     }
//   }
//
//   Future<void> _handleLogout() async {
//     setState(() => _isLoading = true);
//
//     try {
//       await _auth.signOut();
//       if (mounted) {
//         Navigator.pushNamedAndRemoveUntil(
//           context,
//           AppRoutes.welcome,
//               (route) => false,
//         );
//       }
//     } catch (e) {
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text('Logout failed: ${e.toString()}'),
//             backgroundColor: AppColors.alertRed,
//           ),
//         );
//       }
//     } finally {
//       if (mounted) {
//         setState(() => _isLoading = false);
//       }
//     }
//   }
//
//   Future<void> _handleDeleteAccount() async {
//     setState(() => _isLoading = true);
//
//     try {
//       final userId = _auth.currentUser?.uid;
//       if (userId != null) {
//         // Delete user data from Firestore
//         await _firestore.collection('users').doc(userId).delete();
//
//         // Delete user account
//         await _auth.currentUser?.delete();
//
//         if (mounted) {
//           Navigator.pushNamedAndRemoveUntil(
//             context,
//             AppRoutes.welcome,
//                 (route) => false,
//           );
//         }
//       }
//     } catch (e) {
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text('Failed to delete account: ${e.toString()}'),
//             backgroundColor: AppColors.alertRed,
//           ),
//         );
//       }
//     } finally {
//       if (mounted) {
//         setState(() => _isLoading = false);
//       }
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: AppColors.backgroundLight,
//       appBar: AppBar(
//         title: const Text('Settings'),
//         elevation: 0,
//       ),
//       body: _isLoading
//           ? const Center(
//         child: CircularProgressIndicator(color: AppColors.primaryTeal),
//       )
//           : SingleChildScrollView(
//         child: Padding(
//           padding: const EdgeInsets.all(16),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               // Profile Section
//               Container(
//                 padding: const EdgeInsets.all(20),
//                 decoration: BoxDecoration(
//                   color: AppColors.white,
//                   borderRadius: BorderRadius.circular(16),
//                   boxShadow: [
//                     BoxShadow(
//                       color: AppColors.shadow.withOpacity(0.08),
//                       blurRadius: 10,
//                       offset: const Offset(0, 4),
//                     ),
//                   ],
//                 ),
//                 child: Row(
//                   children: [
//                     Container(
//                       width: 64,
//                       height: 64,
//                       decoration: BoxDecoration(
//                         shape: BoxShape.circle,
//                         border: Border.all(
//                           color: AppColors.primaryTeal,
//                           width: 2,
//                         ),
//                         image: const DecorationImage(
//                           image: NetworkImage(
//                               'https://via.placeholder.com/150'),
//                           fit: BoxFit.cover,
//                         ),
//                       ),
//                     ),
//                     const SizedBox(width: 16),
//                     Expanded(
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         mainAxisSize: MainAxisSize.min,
//                         children: [
//                           Text(
//                             _userName,
//                             style: Theme.of(context)
//                                 .textTheme
//                                 .titleLarge
//                                 ?.copyWith(
//                               fontWeight: FontWeight.bold,
//                             ),
//                             maxLines: 1,
//                             overflow: TextOverflow.ellipsis,
//                           ),
//                           const SizedBox(height: 4),
//                           Text(
//                             _userEmail,
//                             style: Theme.of(context)
//                                 .textTheme
//                                 .bodyMedium
//                                 ?.copyWith(
//                               color: AppColors.textSecondary,
//                             ),
//                             maxLines: 1,
//                             overflow: TextOverflow.ellipsis,
//                           ),
//                         ],
//                       ),
//                     ),
//                     IconButton(
//                       onPressed: () {
//                         Navigator.pushNamed(context, AppRoutes.editProfile);
//                       },
//                       icon: const Icon(Icons.edit_outlined),
//                       color: AppColors.primaryTeal,
//                     ),
//                   ],
//                 ),
//               ),
//
//               const SizedBox(height: 24),
//
//               // Account Settings
//               _buildSectionHeader(context, 'Account'),
//               _buildSettingsTile(
//                 context,
//                 Icons.person_outline,
//                 'Profile Settings',
//                 'Manage your personal information',
//                     () {
//                   Navigator.pushNamed(context, AppRoutes.profile);
//                 },
//               ),
//               _buildSettingsTile(
//                 context,
//                 Icons.security_outlined,
//                 'Privacy & Security',
//                 'Control your privacy settings',
//                     () {},
//               ),
//               _buildSettingsTile(
//                 context,
//                 Icons.verified_user_outlined,
//                 'Insurance Details',
//                 'Manage insurance information',
//                     () {
//                   Navigator.pushNamed(context, AppRoutes.insuranceStatus);
//                 },
//               ),
//
//               const SizedBox(height: 24),
//
//               // Notification Settings
//               _buildSectionHeader(context, 'Notifications'),
//               _buildSwitchTile(
//                 context,
//                 Icons.emergency_outlined,
//                 'Emergency Alerts',
//                 'Receive critical emergency notifications',
//                 _emergencyAlerts,
//                     (value) {
//                   setState(() => _emergencyAlerts = value);
//                   _saveNotificationSettings();
//                 },
//               ),
//               _buildSwitchTile(
//                 context,
//                 Icons.favorite_border,
//                 'Health Reminders',
//                 'Daily vitals and medication reminders',
//                 _healthReminders,
//                     (value) {
//                   setState(() => _healthReminders = value);
//                   _saveNotificationSettings();
//                 },
//               ),
//               _buildSwitchTile(
//                 context,
//                 Icons.bloodtype_outlined,
//                 'Blood Requests',
//                 'Notifications for blood donation requests',
//                 _bloodRequests,
//                     (value) {
//                   setState(() => _bloodRequests = value);
//                   _saveNotificationSettings();
//                 },
//               ),
//
//               const SizedBox(height: 24),
//
//               // App Settings
//               _buildSectionHeader(context, 'App Settings'),
//               _buildSettingsTile(
//                 context,
//                 Icons.language_outlined,
//                 'Language',
//                 'English',
//                     () {},
//               ),
//               _buildSwitchTile(
//                 context,
//                 Icons.fingerprint_outlined,
//                 'Biometric Authentication',
//                 'Use fingerprint or face ID to login',
//                 _biometricAuth,
//                     (value) {
//                   setState(() => _biometricAuth = value);
//                   _saveNotificationSettings();
//                 },
//               ),
//               _buildSettingsTile(
//                 context,
//                 Icons.bluetooth_outlined,
//                 'Device Pairing',
//                 'Manage connected emergency devices',
//                     () {},
//               ),
//
//               const SizedBox(height: 24),
//
//               // Support
//               _buildSectionHeader(context, 'Support'),
//               _buildSettingsTile(
//                 context,
//                 Icons.help_outline,
//                 'Help & FAQ',
//                 'Get help and find answers',
//                     () {},
//               ),
//               _buildSettingsTile(
//                 context,
//                 Icons.contact_support_outlined,
//                 'Contact Support',
//                 'Reach out to our support team',
//                     () {},
//               ),
//               _buildSettingsTile(
//                 context,
//                 Icons.info_outline,
//                 'About App',
//                 'Version 1.0.0',
//                     () {},
//               ),
//
//               const SizedBox(height: 24),
//
//               // Danger Zone
//               _buildSectionHeader(context, 'Danger Zone'),
//               _buildSettingsTile(
//                 context,
//                 Icons.logout_outlined,
//                 'Logout',
//                 'Sign out from your account',
//                     () => _showLogoutDialog(context),
//                 isDestructive: true,
//               ),
//               _buildSettingsTile(
//                 context,
//                 Icons.delete_outline,
//                 'Delete Account',
//                 'Permanently delete your account',
//                     () => _showDeleteAccountDialog(context),
//                 isDestructive: true,
//               ),
//
//               const SizedBox(height: 40),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
//
//   Widget _buildSectionHeader(BuildContext context, String title) {
//     return Padding(
//       padding: const EdgeInsets.only(left: 4, bottom: 12),
//       child: Text(
//         title,
//         style: Theme.of(context).textTheme.titleMedium?.copyWith(
//           fontWeight: FontWeight.bold,
//           color: AppColors.textSecondary,
//         ),
//       ),
//     );
//   }
//
//   Widget _buildSettingsTile(
//       BuildContext context,
//       IconData icon,
//       String title,
//       String subtitle,
//       VoidCallback onTap, {
//         bool isDestructive = false,
//       }) {
//     return Container(
//       margin: const EdgeInsets.only(bottom: 8),
//       decoration: BoxDecoration(
//         color: AppColors.white,
//         borderRadius: BorderRadius.circular(12),
//         boxShadow: [
//           BoxShadow(
//             color: AppColors.shadow.withOpacity(0.05),
//             blurRadius: 5,
//             offset: const Offset(0, 2),
//           ),
//         ],
//       ),
//       child: ListTile(
//         contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//         leading: Container(
//           width: 40,
//           height: 40,
//           decoration: BoxDecoration(
//             color: isDestructive
//                 ? AppColors.alertRed.withOpacity(0.1)
//                 : AppColors.primaryTeal.withOpacity(0.1),
//             borderRadius: BorderRadius.circular(10),
//           ),
//           child: Icon(
//             icon,
//             color: isDestructive ? AppColors.alertRed : AppColors.primaryTeal,
//             size: 22,
//           ),
//         ),
//         title: Text(
//           title,
//           style: Theme.of(context).textTheme.titleSmall?.copyWith(
//             fontWeight: FontWeight.w600,
//             color: isDestructive ? AppColors.alertRed : null,
//           ),
//         ),
//         subtitle: Text(
//           subtitle,
//           style: Theme.of(context).textTheme.bodySmall?.copyWith(
//             color: AppColors.textSecondary,
//           ),
//           maxLines: 1,
//           overflow: TextOverflow.ellipsis,
//         ),
//         trailing: Icon(
//           Icons.chevron_right,
//           color: isDestructive ? AppColors.alertRed : AppColors.textLight,
//         ),
//         onTap: onTap,
//       ),
//     );
//   }
//
//   Widget _buildSwitchTile(
//       BuildContext context,
//       IconData icon,
//       String title,
//       String subtitle,
//       bool value,
//       Function(bool) onChanged,
//       ) {
//     return Container(
//       margin: const EdgeInsets.only(bottom: 8),
//       decoration: BoxDecoration(
//         color: AppColors.white,
//         borderRadius: BorderRadius.circular(12),
//         boxShadow: [
//           BoxShadow(
//             color: AppColors.shadow.withOpacity(0.05),
//             blurRadius: 5,
//             offset: const Offset(0, 2),
//           ),
//         ],
//       ),
//       child: SwitchListTile(
//         contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
//         secondary: Container(
//           width: 40,
//           height: 40,
//           decoration: BoxDecoration(
//             color: AppColors.primaryTeal.withOpacity(0.1),
//             borderRadius: BorderRadius.circular(10),
//           ),
//           child: Icon(
//             icon,
//             color: AppColors.primaryTeal,
//             size: 22,
//           ),
//         ),
//         title: Text(
//           title,
//           style: Theme.of(context).textTheme.titleSmall?.copyWith(
//             fontWeight: FontWeight.w600,
//           ),
//         ),
//         subtitle: Text(
//           subtitle,
//           style: Theme.of(context).textTheme.bodySmall?.copyWith(
//             color: AppColors.textSecondary,
//           ),
//           maxLines: 2,
//           overflow: TextOverflow.ellipsis,
//         ),
//         value: value,
//         onChanged: onChanged,
//         activeColor: AppColors.primaryTeal,
//       ),
//     );
//   }
//
//   void _showLogoutDialog(BuildContext context) {
//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: const Text('Logout'),
//         content: const Text('Are you sure you want to logout?'),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context),
//             child: const Text('Cancel'),
//           ),
//           ElevatedButton(
//             onPressed: () {
//               Navigator.pop(context);
//               _handleLogout();
//             },
//             style: ElevatedButton.styleFrom(
//               backgroundColor: AppColors.alertRed,
//               foregroundColor: AppColors.white,
//             ),
//             child: const Text('Logout'),
//           ),
//         ],
//       ),
//     );
//   }
//
//   void _showDeleteAccountDialog(BuildContext context) {
//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: const Text('Delete Account'),
//         content: const Text(
//           'This action cannot be undone. All your data will be permanently deleted.',
//         ),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context),
//             child: const Text('Cancel'),
//           ),
//           ElevatedButton(
//             onPressed: () {
//               Navigator.pop(context);
//               _handleDeleteAccount();
//             },
//             style: ElevatedButton.styleFrom(
//               backgroundColor: AppColors.alertRed,
//               foregroundColor: AppColors.white,
//             ),
//             child: const Text('Delete'),
//           ),
//         ],
//       ),
//     );
//   }
// }