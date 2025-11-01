import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/auth_viewmodel.dart';
import '../../../core/routes/app_routes.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _dotAnimation;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _navigateToNextScreen();
  }

  void _setupAnimations() {
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeIn),
      ),
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOutBack),
      ),
    );

    _dotAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.linear),
    );

    _animationController.forward();
    _animationController.repeat(reverse: false);
  }

  Future<void> _navigateToNextScreen() async {
    await Future.delayed(const Duration(seconds: 3));

    if (!mounted) return;

    final authViewModel = context.read<AuthViewModel>();
    final isFirstTime = await authViewModel.isFirstTimeUser();

    if (isFirstTime) {
      Navigator.pushReplacementNamed(context, AppRoutes.welcome);
    } else {
      final isLoggedIn = await authViewModel.checkLoginStatus();
      if (isLoggedIn) {
        Navigator.pushReplacementNamed(context, AppRoutes.home);
      } else {
        Navigator.pushReplacementNamed(context, AppRoutes.login);
      }
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: ScaleTransition(
              scale: _scaleAnimation,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.08),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.favorite,
                        color: Color(0xFF0097A7),
                        size: 70,
                      ),
                    ),
                  ),

                  const SizedBox(height: 30),

                  // App Name
                  const Text(
                    'Arogya Rakshak AI',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF0097A7),
                      letterSpacing: 0.5,
                    ),
                  ),

                  const SizedBox(height: 10),

                  // Tagline
                  const Text(
                    'Your AI-Powered Health Guardian',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                      color: Color(0xFF607D8B),
                      letterSpacing: 0.3,
                    ),
                  ),

                  const SizedBox(height: 80),

                  // Loading text with animated dots
                  AnimatedBuilder(
                    animation: _dotAnimation,
                    builder: (context, child) {
                      final dotCount = (_dotAnimation.value * 3).floor() % 4;
                      return Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            'Loading',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: Color(0xFF0097A7),
                              letterSpacing: 0.5,
                            ),
                          ),
                          SizedBox(
                            width: 30,
                            child: Text(
                              ' ${'•' * dotCount}',
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF0097A7),
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}



// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import '../../viewmodels/auth_viewmodel.dart';
// import '../../../core/routes/app_routes.dart';
//
// class SplashScreen extends StatefulWidget {
//   const SplashScreen({super.key});
//
//   @override
//   State<SplashScreen> createState() => _SplashScreenState();
// }
//
// class _SplashScreenState extends State<SplashScreen>
//     with SingleTickerProviderStateMixin {
//   late AnimationController _animationController;
//   late Animation<double> _fadeAnimation;
//   late Animation<double> _scaleAnimation;
//   late Animation<double> _dotAnimation;
//
//   @override
//   void initState() {
//     super.initState();
//     _setupAnimations();
//     _navigateToNextScreen();
//   }
//
//   void _setupAnimations() {
//     _animationController = AnimationController(
//       vsync: this,
//       duration: const Duration(milliseconds: 2000),
//     );
//
//     _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
//       CurvedAnimation(
//         parent: _animationController,
//         curve: const Interval(0.0, 0.6, curve: Curves.easeIn),
//       ),
//     );
//
//     _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
//       CurvedAnimation(
//         parent: _animationController,
//         curve: const Interval(0.0, 0.6, curve: Curves.easeOutBack),
//       ),
//     );
//
//     _dotAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
//       CurvedAnimation(
//         parent: _animationController,
//         curve: Curves.linear,
//       ),
//     );
//
//     _animationController.forward();
//     _animationController.repeat(reverse: false);
//   }
//
//   Future<void> _navigateToNextScreen() async {
//     await Future.delayed(const Duration(seconds: 3));
//
//     if (!mounted) return;
//
//     final authViewModel = context.read<AuthViewModel>();
//
//     // Check if first time user
//     final isFirstTime = await authViewModel.isFirstTimeUser();
//
//     if (isFirstTime) {
//       Navigator.pushReplacementNamed(context, AppRoutes.welcome);
//     } else {
//       final isLoggedIn = await authViewModel.checkLoginStatus();
//
//       if (isLoggedIn) {
//         Navigator.pushReplacementNamed(context, AppRoutes.home);
//       } else {
//         Navigator.pushReplacementNamed(context, AppRoutes.login);
//       }
//     }
//   }
//
//   @override
//   void dispose() {
//     _animationController.dispose();
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: const Color(0xFFF5F7FA),
//       body: SafeArea(
//         child: Center(
//           child: FadeTransition(
//             opacity: _fadeAnimation,
//             child: ScaleTransition(
//               scale: _scaleAnimation,
//               child: Column(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   // Logo Container
//                   Container(
//                     width: 140,
//                     height: 140,
//                     decoration: BoxDecoration(
//                       color: Colors.white,
//                       borderRadius: BorderRadius.circular(30),
//                       boxShadow: [
//                         BoxShadow(
//                           color: Colors.black.withOpacity(0.08),
//                           blurRadius: 30,
//                           offset: const Offset(0, 10),
//                         ),
//                       ],
//                     ),
//                     child: Center(
//                       child: Icon(
//                         Icons.favorite,
//                         size: 70,
//                         color: const Color(0xFF00ACC1),
//                       ),
//                     ),
//                   ),
//
//                   const SizedBox(height: 40),
//
//                   // App Name
//                   const Text(
//                     'Arogya Rakshak AI',
//                     style: TextStyle(
//                       fontSize: 34,
//                       fontWeight: FontWeight.w700,
//                       color: Color(0xFF00ACC1),
//                       letterSpacing: 0.5,
//                     ),
//                   ),
//
//                   const SizedBox(height: 12),
//
//                   // Tagline
//                   const Text(
//                     'Your AI-Powered Health Guardian',
//                     style: TextStyle(
//                       fontSize: 16,
//                       fontWeight: FontWeight.w400,
//                       color: Color(0xFF607D8B),
//                       letterSpacing: 0.3,
//                     ),
//                   ),
//
//                   const SizedBox(height: 80),
//
//                   // Loading Text with Animated Dots
//                   AnimatedBuilder(
//                     animation: _dotAnimation,
//                     builder: (context, child) {
//                       final dotCount = (_dotAnimation.value * 3).floor() % 4;
//                       return Row(
//                         mainAxisAlignment: MainAxisAlignment.center,
//                         children: [
//                           const Text(
//                             'Loading',
//                             style: TextStyle(
//                               fontSize: 16,
//                               fontWeight: FontWeight.w500,
//                               color: Color(0xFF00ACC1),
//                               letterSpacing: 0.5,
//                             ),
//                           ),
//                           SizedBox(
//                             width: 30,
//                             child: Text(
//                               ' ${'•' * dotCount}',
//                               style: const TextStyle(
//                                 fontSize: 20,
//                                 fontWeight: FontWeight.bold,
//                                 color: Color(0xFF00ACC1),
//                               ),
//                             ),
//                           ),
//                         ],
//                       );
//                     },
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }
//
//
//
// // import 'package:flutter/material.dart';
// // import 'package:provider/provider.dart';
// // import '../../viewmodels/auth_viewmodel.dart';
// // import '../../../core/routes/app_routes.dart';
// //
// // class SplashScreen extends StatefulWidget {
// //   const SplashScreen({super.key});
// //   @override
// //   State<SplashScreen> createState() => _SplashScreenState();
// // }
// //
// // class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
// //   late AnimationController _animationController;
// //   late Animation<double> _fadeAnimation;
// //   late Animation<double> _scaleAnimation;
// //
// //   @override
// //   void initState() {
// //     super.initState();
// //     _setupAnimations();
// //     _navigateToNextScreen();
// //   }
// //
// //   void _setupAnimations() {
// //     _animationController = AnimationController(
// //       vsync: this,
// //       duration: const Duration(milliseconds: 1500),
// //     );
// //
// //     _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
// //       CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
// //     );
// //
// //     _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
// //       CurvedAnimation(parent: _animationController, curve: Curves.easeOutBack),
// //     );
// //
// //     _animationController.forward();
// //   }
// //
// //   Future<void> _navigateToNextScreen() async {
// //     await Future.delayed(const Duration(seconds: 3));
// //
// //     if (!mounted) return;
// //
// //     final authViewModel = context.read<AuthViewModel>();
// //
// //     // Check if first time user
// //     final isFirstTime = await authViewModel.isFirstTimeUser();
// //
// //     if (isFirstTime) {
// //       // First time user -> Show Welcome/Onboarding
// //       Navigator.pushReplacementNamed(context, AppRoutes.welcome);
// //     } else {
// //       // Check if user is logged in
// //       final isLoggedIn = await authViewModel.checkLoginStatus();
// //
// //       if (isLoggedIn) {
// //         // Logged in -> Go to Dashboard
// //         Navigator.pushReplacementNamed(context, AppRoutes.home);
// //       } else {
// //         // Not logged in -> Go to Login
// //         Navigator.pushReplacementNamed(context, AppRoutes.login);
// //       }
// //     }
// //   }
// //
// //   @override
// //   void dispose() {
// //     _animationController.dispose();
// //     super.dispose();
// //   }
// //
// //   @override
// //   Widget build(BuildContext context) {
// //     return Scaffold(
// //       body: Container(
// //         decoration: BoxDecoration(
// //           gradient: LinearGradient(
// //             begin: Alignment.topLeft,
// //             end: Alignment.bottomRight,
// //             colors: [
// //               Theme.of(context).primaryColor,
// //               Theme.of(context).colorScheme.secondary,
// //             ],
// //           ),
// //         ),
// //         child: Center(
// //           child: FadeTransition(
// //             opacity: _fadeAnimation,
// //             child: ScaleTransition(
// //               scale: _scaleAnimation,
// //               child: Column(
// //                 mainAxisAlignment: MainAxisAlignment.center,
// //                 children: [
// //                   // App Logo/Icon
// //                   Container(
// //                     width: 120,
// //                     height: 120,
// //                     decoration: BoxDecoration(
// //                       color: Colors.white,
// //                       borderRadius: BorderRadius.circular(30),
// //                       boxShadow: [
// //                         BoxShadow(
// //                           color: Colors.black.withOpacity(0.2),
// //                           blurRadius: 20,
// //                           offset: const Offset(0, 10),
// //                         ),
// //                       ],
// //                     ),
// //                     child: Icon(
// //                       Icons.medical_services_rounded,
// //                       size: 60,
// //                       color: Theme.of(context).primaryColor,
// //                     ),
// //                   ),
// //                   const SizedBox(height: 30),
// //
// //                   // App Name
// //                   const Text(
// //                     'ArogyaRaksha AI',
// //                     style: TextStyle(
// //                       fontSize: 32,
// //                       fontWeight: FontWeight.bold,
// //                       color: Colors.white,
// //                       letterSpacing: 1.2,
// //                     ),
// //                   ),
// //                   const SizedBox(height: 10),
// //
// //                   // Tagline
// //                   Text(
// //                     'Smart Health Emergency Response',
// //                     style: TextStyle(
// //                       fontSize: 16,
// //                       color: Colors.white.withOpacity(0.9),
// //                       letterSpacing: 0.5,
// //                     ),
// //                   ),
// //                   const SizedBox(height: 50),
// //
// //                   // Loading Indicator
// //                   SizedBox(
// //                     width: 40,
// //                     height: 40,
// //                     child: CircularProgressIndicator(
// //                       strokeWidth: 3,
// //                       valueColor: AlwaysStoppedAnimation<Color>(
// //                         Colors.white.withOpacity(0.8),
// //                       ),
// //                     ),
// //                   ),
// //                 ],
// //               ),
// //             ),
// //           ),
// //         ),
// //       ),
// //     );
// //   }
// // }
