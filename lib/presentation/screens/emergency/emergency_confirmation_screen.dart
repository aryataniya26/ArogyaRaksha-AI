import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/routes/app_routes.dart';
import '../../../data/models/emergency_model.dart';
import '../../../data/models/user_model.dart';
import '../../../data/services/location_service.dart';
import '../../../data/services/sms_service.dart';
import '../../../data/repositories/emergency_repository.dart';

class EmergencyConfirmationScreen extends StatefulWidget {
  const EmergencyConfirmationScreen({super.key});

  @override
  State<EmergencyConfirmationScreen> createState() => _EmergencyConfirmationScreenState();
}

class _EmergencyConfirmationScreenState extends State<EmergencyConfirmationScreen> with TickerProviderStateMixin {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final LocationService _locationService = LocationService();
  final SmsService _smsService = SmsService();
  final EmergencyRepository _emergencyRepository = EmergencyRepository();

  int _countdown = 10;
  Timer? _timer;
  bool _isCancelled = false;
  bool _isTriggering = false;

  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _setupAnimation();
    _startCountdown();
  }

  void _setupAnimation() {
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  void _startCountdown() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_countdown > 0) {
        setState(() => _countdown--);
      } else {
        _timer?.cancel();
        _triggerEmergency();
      }
    });
  }

  Future<void> _triggerEmergency() async {
    if (_isTriggering || _isCancelled) return;

    setState(() => _isTriggering = true);

    try {
      // Get user data
      final userId = _auth.currentUser?.uid;
      if (userId == null) throw Exception('User not logged in');

      final userDoc = await _firestore.collection('users').doc(userId).get();
      if (!userDoc.exists) throw Exception('User data not found');

      final userData = UserModel.fromJson(userDoc.data()!);

      // Get current location
      final location = await _locationService.getCurrentLocation();
      if (location == null) throw Exception('Could not get location');

      // Create emergency model
      final emergency = EmergencyModel(
        id: '',
        userId: userId,
        userName: userData.name,
        userPhone: userData.phone,
        userBloodGroup: userData.bloodGroup,
        location: location,
        status: EmergencyStatus.triggered,
        triggeredAt: DateTime.now(),
        medicalInfo: {
          'allergies': userData.medicalInfo.allergies,
          'conditions': userData.medicalInfo.conditions,
          'medications': userData.medicalInfo.medications,
        },
      );

      // Save to Firebase
      final emergencyId = await _emergencyRepository.createEmergency(emergency);

      // Update status to notifying
      await _emergencyRepository.updateEmergencyStatus(
        emergencyId: emergencyId,
        status: EmergencyStatus.notifying,
      );

      // Send SMS to emergency contacts
      if (userData.emergencyContacts.isNotEmpty) {
        final notifiedContacts = await _smsService.sendEmergencySmsToContacts(
          contacts: userData.emergencyContacts,
          userName: userData.name,
          location: location,
          bloodGroup: userData.bloodGroup,
        );

        await _emergencyRepository.updateNotifiedContacts(
          emergencyId: emergencyId,
          contacts: notifiedContacts,
        );
      }

      // Update status to ambulance searching
      await _emergencyRepository.updateEmergencyStatus(
        emergencyId: emergencyId,
        status: EmergencyStatus.ambulanceSearching,
      );

      if (mounted) {
        // Navigate to live status screen
        Navigator.pushReplacementNamed(
          context,
          AppRoutes.liveStatus,
          arguments: emergencyId,
        );
      }
    } catch (e) {
      print('Error triggering emergency: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
        Navigator.pop(context);
      }
    }
  }

  void _cancelEmergency() {
    setState(() => _isCancelled = true);
    _timer?.cancel();
    _pulseController.stop();
    Navigator.pop(context);
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        _cancelEmergency();
        return false;
      },
      child: Scaffold(
        backgroundColor: AppColors.alertRed,
        body: SafeArea(
          child: Column(
            children: [
              // Top Bar
              Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Emergency Alert',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '${_countdown}s',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const Spacer(),

              // Pulsing Emergency Icon
              ScaleTransition(
                scale: _pulseAnimation,
                child: Container(
                  width: 200,
                  height: 200,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withOpacity(0.2),
                  ),
                  child: Center(
                    child: Container(
                      width: 160,
                      height: 160,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white,
                      ),
                      child: const Icon(
                        Icons.emergency,
                        size: 80,
                        color: AppColors.alertRed,
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 40),

              // Message
              const Text(
                'Emergency will be triggered in',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '$_countdown seconds',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 48,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 20),

              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 40),
                child: Text(
                  'Your location will be shared with emergency contacts and nearest ambulance will be notified',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
              ),

              const Spacer(),

              // Cancel Button
              Padding(
                padding: const EdgeInsets.all(40),
                child: SizedBox(
                  width: double.infinity,
                  height: 60,
                  child: ElevatedButton(
                    onPressed: _isTriggering ? null : _cancelEmergency,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: AppColors.alertRed,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      elevation: 8,
                    ),
                    child: _isTriggering
                        ? const CircularProgressIndicator(color: AppColors.alertRed)
                        : const Text(
                      'CANCEL EMERGENCY',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}


// import 'package:flutter/material.dart';
// import 'dart:async';
// import 'package:arogyaraksha_ai/core/constants/app_colors.dart';
// import 'package:arogyaraksha_ai/core/routes/app_routes.dart';
// import 'package:arogyaraksha_ai/presentation/widgets/custom_button.dart';
// class EmergencyConfirmationScreen extends StatefulWidget {
//   const EmergencyConfirmationScreen({super.key});
//
//   @override
//   State<EmergencyConfirmationScreen> createState() =>
//       _EmergencyConfirmationScreenState();
// }
//
// class _EmergencyConfirmationScreenState
//     extends State<EmergencyConfirmationScreen>
//     with SingleTickerProviderStateMixin {
//   late AnimationController _pulseController;
//   late Animation<double> _pulseAnimation;
//   int _countdown = 5;
//   Timer? _countdownTimer;
//   bool _isCancelled = false;
//
//   @override
//   void initState() {
//     super.initState();
//     _initializeAnimation();
//     _startCountdown();
//   }
//
//   void _initializeAnimation() {
//     _pulseController = AnimationController(
//       vsync: this,
//       duration: const Duration(milliseconds: 1000),
//     )..repeat(reverse: true);
//
//     _pulseAnimation = Tween<double>(begin: 1.0, end: 1.15).animate(
//       CurvedAnimation(
//         parent: _pulseController,
//         curve: Curves.easeInOut,
//       ),
//     );
//   }
//
//   void _startCountdown() {
//     _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
//       if (_countdown > 0) {
//         setState(() {
//           _countdown--;
//         });
//       } else {
//         timer.cancel();
//         if (!_isCancelled) {
//           _triggerEmergency();
//         }
//       }
//     });
//   }
//
//   void _triggerEmergency() {
//     Navigator.pushReplacementNamed(context, AppRoutes.liveStatus);
//   }
//
//   void _cancelEmergency() {
//     setState(() {
//       _isCancelled = true;
//     });
//     _countdownTimer?.cancel();
//     Navigator.pop(context);
//   }
//
//   @override
//   void dispose() {
//     _pulseController.dispose();
//     _countdownTimer?.cancel();
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final size = MediaQuery.of(context).size;
//
//     return Scaffold(
//       backgroundColor: AppColors.alertRed,
//       body: Container(
//         width: size.width,
//         height: size.height,
//         decoration: BoxDecoration(
//           gradient: LinearGradient(
//             begin: Alignment.topCenter,
//             end: Alignment.bottomCenter,
//             colors: [
//               AppColors.alertRed,
//               AppColors.alertRedDark,
//             ],
//           ),
//         ),
//         child: SafeArea(
//           child: Padding(
//             padding: const EdgeInsets.all(24.0),
//             child: Column(
//               children: [
//                 // Close Button
//                 Align(
//                   alignment: Alignment.topLeft,
//                   child: IconButton(
//                     onPressed: _cancelEmergency,
//                     icon: const Icon(
//                       Icons.close,
//                       color: AppColors.white,
//                       size: 32,
//                     ),
//                   ),
//                 ),
//
//                 const Spacer(),
//
//                 // Pulsing Emergency Icon
//                 AnimatedBuilder(
//                   animation: _pulseAnimation,
//                   builder: (context, child) {
//                     return Transform.scale(
//                       scale: _pulseAnimation.value,
//                       child: child,
//                     );
//                   },
//                   child: Container(
//                     width: 180,
//                     height: 180,
//                     decoration: BoxDecoration(
//                       color: AppColors.white.withOpacity(0.2),
//                       shape: BoxShape.circle,
//                     ),
//                     child: Center(
//                       child: Container(
//                         width: 140,
//                         height: 140,
//                         decoration: const BoxDecoration(
//                           color: AppColors.white,
//                           shape: BoxShape.circle,
//                         ),
//                         child: const Icon(
//                           Icons.emergency_outlined,
//                           size: 80,
//                           color: AppColors.alertRed,
//                         ),
//                       ),
//                     ),
//                   ),
//                 ),
//
//                 const SizedBox(height: 48),
//
//                 // Countdown
//                 Text(
//                   '$_countdown',
//                   style: Theme.of(context).textTheme.displayLarge?.copyWith(
//                     color: AppColors.white,
//                     fontSize: 72,
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//
//                 const SizedBox(height: 16),
//
//                 // Alert Text
//                 Text(
//                   'Emergency Alert Triggering',
//                   style: Theme.of(context).textTheme.headlineMedium?.copyWith(
//                     color: AppColors.white,
//                     fontWeight: FontWeight.bold,
//                   ),
//                   textAlign: TextAlign.center,
//                 ),
//
//                 const SizedBox(height: 12),
//
//                 Text(
//                   'Ambulance and nearest hospital will be\nnotified automatically',
//                   style: Theme.of(context).textTheme.bodyLarge?.copyWith(
//                     color: AppColors.white.withOpacity(0.9),
//                   ),
//                   textAlign: TextAlign.center,
//                 ),
//
//                 const Spacer(),
//
//                 // Cancel Button
//                 CustomButton(
//                   text: 'Cancel Emergency',
//                   onPressed: _cancelEmergency,
//                   backgroundColor: AppColors.white,
//                   textColor: AppColors.alertRed,
//                   icon: Icons.close,
//                 ),
//
//                 const SizedBox(height: 16),
//
//                 Text(
//                   'Press cancel if this was triggered accidentally',
//                   style: Theme.of(context).textTheme.bodySmall?.copyWith(
//                     color: AppColors.white.withOpacity(0.7),
//                   ),
//                   textAlign: TextAlign.center,
//                 ),
//
//                 const SizedBox(height: 24),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }