import 'package:arogyaraksha_ai/presentation/screens/history/emergency_history_screen.dart';
import 'package:arogyaraksha_ai/presentation/screens/settings/settings_screen.dart';
import 'package:flutter/material.dart';
import 'package:arogyaraksha_ai/core/routes/app_routes.dart';
import 'package:arogyaraksha_ai/core/constants/app_colors.dart';
import 'package:arogyaraksha_ai/presentation/widgets/specialty_card.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:arogyaraksha_ai/data/services/voice_command_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;



  final VoiceCommandService _voiceService = VoiceCommandService();
  bool _isListening = false;
  @override
  void initState() {
    super.initState();
    initVoiceFeature();
  }

  Future<void> initVoiceFeature() async {
    bool available = await _voiceService.initSpeech();
    if (available) {
      startVoiceListening();
    } else {
      debugPrint('Voice feature not available on this device');
    }
  }

  void startVoiceListening() async {
    setState(() => _isListening = true);
    await _voiceService.startListening(triggerEmergency);
  }

  void triggerEmergency() {
    setState(() => _isListening = false);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('🚨 Emergency Triggered (Voice Command)!')),
    );

    debugPrint('🚨 Emergency triggered by voice!');
  }


  final List<Widget> _screens = [
    const _DashboardScreen(),
    const EmergencyHistoryScreen(),
    const Center(child: Text('Alerts')),
    const SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: _screens[_selectedIndex],
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  Widget _buildBottomNavigationBar() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
        child: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: (index) => setState(() => _selectedIndex = index),
          type: BottomNavigationBarType.fixed,
          backgroundColor: AppColors.cardBackground,
          selectedItemColor: AppColors.primaryTeal,
          unselectedItemColor: AppColors.textLight,
          selectedFontSize: 12,
          unselectedFontSize: 12,
          elevation: 0,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              activeIcon: Icon(Icons.home),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.history_outlined),
              activeIcon: Icon(Icons.history),
              label: 'History',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.notifications_outlined),
              activeIcon: Icon(Icons.notifications),
              label: 'Alerts',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.settings_outlined),
              activeIcon: Icon(Icons.settings),
              label: 'Settings',
            ),
          ],
        ),
      ),
    );
  }
}

class _DashboardScreen extends StatefulWidget {
  const _DashboardScreen();

  @override
  State<_DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<_DashboardScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String _userName = 'User';
  String _userPhoto = 'https://via.placeholder.com/150';

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        final doc = await _firestore.collection('users').doc(user.uid).get();

        if (doc.exists && mounted) {
          setState(() {
            _userName = doc.data()?['name'] ?? user.displayName ?? 'User';
            _userPhoto = doc.data()?['photoURL'] ?? user.photoURL ??
                'https://via.placeholder.com/150';
          });
        } else if (mounted) {
          setState(() {
            _userName = user.displayName ?? 'User';
            _userPhoto = user.photoURL ?? 'https://via.placeholder.com/150';
          });
        }
      }
    } catch (e) {
      print('Error loading user data: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(context),
              const SizedBox(height: 20),

              // Health Assistant Banner
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF00B4DB), Color(0xFF0083B0)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
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
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Your health assistant is',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 4),
                            const Text(
                              'ready to help',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.health_and_safety,
                          color: Colors.white,
                          size: 32,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              _buildSearchBar(context),
              const SizedBox(height: 24),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  'Speciality',
                  style: Theme
                      .of(context)
                      .textTheme
                      .headlineSmall
                      ?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              const SizedBox(height: 16),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 2,
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 16,
                  childAspectRatio: 1.0,
                  children: [
                    SpecialtyCard(
                      icon: Icons.emergency_outlined,
                      title: 'Emergency Help',
                      subtitle: 'Get instant ambulance\nsupport at one tap.',
                      gradient: AppColors.emergencyGradient,
                      onTap: () {
                        Navigator.pushNamed(
                            context, AppRoutes.emergencyConfirmation);
                      },
                    ),
                    SpecialtyCard(
                      icon: Icons.health_and_safety_outlined,
                      title: 'AI Health Alerts',
                      subtitle: 'View smart predictions\nbased on your health vitals.',
                      gradient: AppColors.primaryGradient,
                      onTap: () {
                        Navigator.pushNamed(context, AppRoutes.aiHealthAlerts);
                      },
                    ),
                    SpecialtyCard(
                      icon: Icons.bloodtype_outlined,
                      title: 'Blood Request',
                      subtitle: 'Request or donate blood\nin real time.',
                      gradient: const LinearGradient(
                        colors: [
                          AppColors.bloodBPositive,
                          AppColors.bloodONegative
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      onTap: () {
                        Navigator.pushNamed(context, AppRoutes.bloodRequest);
                      },
                    ),
                    SpecialtyCard(
                      icon: Icons.phone_android_outlined,
                      title: 'Insurance Status',
                      subtitle: 'Check your coverage and\napproval details instantly.',
                      gradient: AppColors.blueGradient,
                      onTap: () {
                        Navigator.pushNamed(context, AppRoutes.insuranceStatus);
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              _buildStayPreparedSection(context),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          IconButton(
            onPressed: () {
              // TODO: Open drawer/menu
            },
            icon: const Icon(Icons.menu_rounded),
            color: AppColors.primaryTeal,
            iconSize: 28,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Welcome',
                  style: Theme
                      .of(context)
                      .textTheme
                      .bodyMedium
                      ?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                Text(
                  _userName,
                  style: Theme
                      .of(context)
                      .textTheme
                      .headlineSmall
                      ?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: () {
              Navigator.pushNamed(context, AppRoutes.profile);
            },
            child: Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppColors.primaryTeal,
                  width: 2,
                ),
                image: DecorationImage(
                  image: NetworkImage(_userPhoto),
                  fit: BoxFit.cover,
                  onError: (exception, stackTrace) {
                    // Handle image load error
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        height: 56,
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: AppColors.shadow.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            const Icon(Icons.search, color: AppColors.textLight, size: 24),
            const SizedBox(width: 12),
            Expanded(
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Search hospital, ambulance, or insurance',
                  hintStyle: Theme
                      .of(context)
                      .textTheme
                      .bodyMedium
                      ?.copyWith(
                    color: AppColors.textLight,
                  ),
                  border: InputBorder.none,
                ),
                onTap: () {
                  // TODO: Navigate to search screen
                },
              ),
            ),
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.tune,
                color: AppColors.textWhite,
                size: 20,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStayPreparedSection(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primaryTeal.withOpacity(0.1),
            AppColors.primaryTeal.withOpacity(0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.primaryTeal.withOpacity(0.2),
          width: 1,
        ),
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
                  gradient: AppColors.primaryGradient,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.emergency_share_rounded,
                  color: AppColors.textWhite,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Stay Prepared,\nStay Protected',
                  style: Theme
                      .of(context)
                      .textTheme
                      .titleLarge
                      ?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                    height: 1.2,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          RichText(
            text: TextSpan(
              style: Theme
                  .of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(
                color: AppColors.textSecondary,
                height: 1.5,
              ),
              children: const [
                TextSpan(text: 'Your '),
                TextSpan(
                  text: 'AI-powered assistant',
                  style: TextStyle(
                    color: AppColors.primaryTeal,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                TextSpan(
                  text: ' keeps you safe with instant alerts, quick help, and real-time health updates.',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}


// import 'package:arogyaraksha_ai/presentation/screens/history/emergency_history_screen.dart';
// import 'package:arogyaraksha_ai/presentation/screens/settings/settings_screen.dart';
// import 'package:flutter/material.dart';
// import 'package:arogyaraksha_ai/core/routes/app_routes.dart';
// import 'package:arogyaraksha_ai/core/constants/app_colors.dart';
// import 'package:arogyaraksha_ai/presentation/widgets/specialty_card.dart';
// import 'package:arogyaraksha_ai/presentation/screens/settings/settings_screen.dart';
//
// class HomeScreen extends StatefulWidget {
//   const HomeScreen({super.key});
//
//   @override
//   State<HomeScreen> createState() => _HomeScreenState();
// }
//
// class _HomeScreenState extends State<HomeScreen> {
//   int _selectedIndex = 0;
//
//   final List<Widget> _screens = [
//     const _DashboardScreen(),
//     const EmergencyHistoryScreen(),
//     const Center(child: Text('Alerts')),
//     const SettingsScreen(),  ];
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: AppColors.backgroundLight,
//       body: _screens[_selectedIndex],
//       bottomNavigationBar: _buildBottomNavigationBar(),
//     );
//   }
//
//   Widget _buildBottomNavigationBar() {
//     return Container(
//       decoration: BoxDecoration(
//         color: AppColors.cardBackground,
//         boxShadow: [
//           BoxShadow(
//             color: AppColors.shadow.withOpacity(0.1),
//             blurRadius: 10,
//             offset: const Offset(0, -5),
//           ),
//         ],
//         borderRadius: const BorderRadius.only(
//           topLeft: Radius.circular(24),
//           topRight: Radius.circular(24),
//         ),
//       ),
//       child: ClipRRect(
//         borderRadius: const BorderRadius.only(
//           topLeft: Radius.circular(24),
//           topRight: Radius.circular(24),
//         ),
//         child: BottomNavigationBar(
//           currentIndex: _selectedIndex,
//           onTap: (index) {
//             setState(() {
//               _selectedIndex = index;
//             });
//           },
//           type: BottomNavigationBarType.fixed,
//           backgroundColor: AppColors.cardBackground,
//           selectedItemColor: AppColors.primaryTeal,
//           unselectedItemColor: AppColors.textLight,
//           selectedFontSize: 12,
//           unselectedFontSize: 12,
//           elevation: 0,
//           items: const [
//             BottomNavigationBarItem(
//               icon: Icon(Icons.home_outlined),
//               activeIcon: Icon(Icons.home),
//               label: 'Home',
//             ),
//             BottomNavigationBarItem(
//               icon: Icon(Icons.history_outlined),
//               activeIcon: Icon(Icons.history),
//               label: 'History',
//             ),
//             BottomNavigationBarItem(
//               icon: Icon(Icons.notifications_outlined),
//               activeIcon: Icon(Icons.notifications),
//               label: 'Alerts',
//             ),
//             BottomNavigationBarItem(
//               icon: Icon(Icons.settings_outlined),
//               activeIcon: Icon(Icons.settings),
//               label: 'Settings',
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
//
// class _DashboardScreen extends StatelessWidget {
//   const _DashboardScreen();
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: AppColors.backgroundLight,
//       body: SafeArea(
//         child: SingleChildScrollView(
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               _buildHeader(context),
//               const SizedBox(height: 24),
//               Padding(
//                 padding: const EdgeInsets.symmetric(horizontal: 20),
//                 child: _buildSearchBar(context),
//               ),
//               const SizedBox(height: 24),
//               Padding(
//                 padding: const EdgeInsets.symmetric(horizontal: 20),
//                 child: Text(
//                   'Speciality',
//                   style: Theme.of(context).textTheme.headlineSmall?.copyWith(
//                     fontWeight: FontWeight.bold,
//                     color: AppColors.textPrimary,
//                   ),
//                 ),
//               ),
//               const SizedBox(height: 16),
//               Padding(
//                 padding: const EdgeInsets.symmetric(horizontal: 20),
//                 child: GridView.count(
//                   shrinkWrap: true,
//                   physics: const NeverScrollableScrollPhysics(),
//                   crossAxisCount: 2,
//                   mainAxisSpacing: 16,
//                   crossAxisSpacing: 16,
//                   childAspectRatio: 1.1,
//                   children: [
//                     SpecialtyCard(
//                       icon: Icons.emergency_outlined,
//                       title: 'Emergency Help',
//                       subtitle: 'Get instant ambulance\nsupport at one tap.',
//                       gradient: AppColors.emergencyGradient,
//                       onTap: () {
//                         Navigator.pushNamed(
//                             context, AppRoutes.emergencyConfirmation);
//                       },
//                     ),
//                     SpecialtyCard(
//                       icon: Icons.health_and_safety_outlined,
//                       title: 'AI Health Alerts',
//                       subtitle:
//                       'View smart predictions\nbased on your health vitals.',
//                       gradient: AppColors.primaryGradient,
//                       onTap: () {
//                         Navigator.pushNamed(context, AppRoutes.aiHealthAlerts);
//                       },
//                     ),
//                     SpecialtyCard(
//                       icon: Icons.bloodtype_outlined,
//                       title: 'Blood Request',
//                       subtitle: 'Request or donate blood\nin real time.',
//                       gradient: const LinearGradient(
//                         colors: [
//                           AppColors.bloodBPositive,
//                           AppColors.bloodONegative,
//                         ],
//                         begin: Alignment.topLeft,
//                         end: Alignment.bottomRight,
//                       ),
//                       onTap: () {
//                         Navigator.pushNamed(context, AppRoutes.bloodRequest);
//                       },
//                     ),
//                     SpecialtyCard(
//                       icon: Icons.phone_android_outlined,
//                       title: 'Insurance Status',
//                       subtitle:
//                       'Check your coverage and\napproval details instantly.',
//                       gradient: AppColors.blueGradient,
//                       onTap: () {
//                         Navigator.pushNamed(
//                             context, AppRoutes.insuranceStatus);
//                       },
//                     ),
//                   ],
//                 ),
//               ),
//               const SizedBox(height: 24),
//               _buildStayPreparedSection(context),
//               const SizedBox(height: 24),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
//
//   Widget _buildHeader(BuildContext context) {
//     return Container(
//       padding: const EdgeInsets.all(20),
//       child: Row(
//         children: [
//           IconButton(
//             onPressed: () {},
//             icon: const Icon(Icons.menu_rounded),
//             color: AppColors.primaryTeal,
//             iconSize: 28,
//           ),
//           const SizedBox(width: 12),
//           Expanded(
//             child: Text(
//               'Welcome User',
//               style: Theme.of(context).textTheme.headlineMedium?.copyWith(
//                 fontWeight: FontWeight.bold,
//                 color: AppColors.textPrimary,
//               ),
//             ),
//           ),
//           GestureDetector(
//             onTap: () {
//               Navigator.pushNamed(context, AppRoutes.profile);
//             },
//             child: Container(
//               width: 50,
//               height: 50,
//               decoration: BoxDecoration(
//                 shape: BoxShape.circle,
//                 border: Border.all(
//                   color: AppColors.primaryTeal,
//                   width: 2,
//                 ),
//                 image: const DecorationImage(
//                   image: NetworkImage('https://via.placeholder.com/150'),
//                   fit: BoxFit.cover,
//                 ),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildSearchBar(BuildContext context) {
//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 16),
//       height: 50,
//       decoration: BoxDecoration(
//         color: AppColors.cardBackground,
//         borderRadius: BorderRadius.circular(12),
//         boxShadow: [
//           BoxShadow(
//             color: AppColors.shadow.withOpacity(0.05),
//             blurRadius: 10,
//             offset: const Offset(0, 2),
//           ),
//         ],
//       ),
//       child: Row(
//         children: [
//           const Icon(Icons.search, color: AppColors.textLight, size: 24),
//           const SizedBox(width: 12),
//           Expanded(
//             child: TextField(
//               decoration: InputDecoration(
//                 hintText: 'Search hospital, ambulance, or insurance',
//                 hintStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
//                   color: AppColors.textLight,
//                 ),
//                 border: InputBorder.none,
//               ),
//             ),
//           ),
//           Container(
//             width: 40,
//             height: 40,
//             decoration: BoxDecoration(
//               gradient: AppColors.primaryGradient,
//               borderRadius: BorderRadius.circular(8),
//             ),
//             child: const Icon(
//               Icons.tune,
//               color: AppColors.textWhite,
//               size: 20,
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildStayPreparedSection(BuildContext context) {
//     return Container(
//       margin: const EdgeInsets.symmetric(horizontal: 20),
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
//         children: [
//           Row(
//             children: [
//               Expanded(
//                 child: Text(
//                   'Stay Prepared, Stay Protected',
//                   style: Theme.of(context).textTheme.titleLarge?.copyWith(
//                     fontWeight: FontWeight.bold,
//                     color: AppColors.textPrimary,
//                   ),
//                 ),
//               ),
//               Container(
//                 width: 40,
//                 height: 40,
//                 decoration: BoxDecoration(
//                   gradient: AppColors.primaryGradient,
//                   borderRadius: BorderRadius.circular(8),
//                 ),
//                 child: const Icon(
//                   Icons.emergency_share_rounded,
//                   color: AppColors.textWhite,
//                   size: 20,
//                 ),
//               ),
//             ],
//           ),
//           const SizedBox(height: 12),
//           RichText(
//             text: TextSpan(
//               style: Theme.of(context).textTheme.bodyMedium?.copyWith(
//                 color: AppColors.textSecondary,
//                 height: 1.5,
//               ),
//               children: [
//                 const TextSpan(text: 'Your '),
//                 TextSpan(
//                   text: 'AI-powered assistant',
//                   style: const TextStyle(
//                     color: AppColors.primaryTeal,
//                     fontWeight: FontWeight.w600,
//                   ),
//                 ),
//                 const TextSpan(
//                   text:
//                   ' keeps you safe with instant alerts, quick help, and real-time health updates.',
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
