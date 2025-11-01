import 'package:flutter/material.dart';
import '../../../core/routes/app_routes.dart';
import '../../widgets/custom_button.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Theme.of(context).primaryColor.withOpacity(0.1),
              Colors.white,
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              children: [
                const Spacer(),

                // Hero Image/Icon
                Container(
                  width: 200,
                  height: 200,
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.medical_services_rounded,
                    size: 100,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
                const SizedBox(height: 40),

                // Welcome Text
                const Text(
                  'Welcome to',
                  style: TextStyle(
                    fontSize: 24,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 8),

                Text(
                  'ArogyaRaksha AI',
                  style: TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).primaryColor,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),

                // Description
                Text(
                  'Your trusted companion for health emergencies.\nGet instant medical assistance with just one click.',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[600],
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),

                const Spacer(),

                // Get Started Button
                CustomButton(
                  text: 'Get Started',
                  onPressed: () {
                    Navigator.pushReplacementNamed(context, AppRoutes.onboarding);
                  },
                ),
                const SizedBox(height: 16),

                // Already have account
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Already have an account? ',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.pushReplacementNamed(context, AppRoutes.login);
                      },
                      child: Text(
                        'Sign In',
                        style: TextStyle(
                          color: Theme.of(context).primaryColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}


// import 'package:flutter/material.dart';
// import 'package:arogyaraksha_ai/core/constants/app_colors.dart';
// import 'package:arogyaraksha_ai/core/routes/app_routes.dart';
// import '../../widgets/custom_button.dart';
//
// class WelcomeScreen extends StatelessWidget {
//   const WelcomeScreen({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     final size = MediaQuery.of(context).size;
//
//     return Scaffold(
//       body: Container(
//         width: size.width,
//         height: size.height,
//         decoration: BoxDecoration(
//           gradient: LinearGradient(
//             begin: Alignment.topLeft,
//             end: Alignment.bottomRight,
//             colors: [
//               AppColors.primaryTeal.withOpacity(0.1),
//               AppColors.accentLightBlue.withOpacity(0.1),
//             ],
//           ),
//         ),
//         child: SafeArea(
//           child: Padding(
//             padding: const EdgeInsets.symmetric(horizontal: 24.0),
//             child: Column(
//               children: [
//                 const Spacer(flex: 1),
//
//                 // Logo and Title
//                 Container(
//                   width: 100,
//                   height: 100,
//                   decoration: BoxDecoration(
//                     gradient: AppColors.primaryGradient,
//                     shape: BoxShape.circle,
//                     boxShadow: [
//                       BoxShadow(
//                         color: AppColors.primaryTeal.withOpacity(0.3),
//                         blurRadius: 20,
//                         offset: const Offset(0, 10),
//                       ),
//                     ],
//                   ),
//                   child: const Icon(
//                     Icons.favorite_border_rounded,
//                     size: 50,
//                     color: AppColors.white,
//                   ),
//                 ),
//                 const SizedBox(height: 24),
//
//                 Text(
//                   'Welcome to',
//                   style: Theme.of(context).textTheme.headlineMedium?.copyWith(
//                     color: AppColors.textSecondary,
//                   ),
//                 ),
//                 const SizedBox(height: 8),
//
//                 Text(
//                   'ArogyaRaksha AI',
//                   style: Theme.of(context).textTheme.displayMedium?.copyWith(
//                     color: AppColors.primaryTeal,
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//                 const SizedBox(height: 16),
//
//                 Text(
//                   'Your 24/7 AI-Powered Health Guardian',
//                   textAlign: TextAlign.center,
//                   style: Theme.of(context).textTheme.bodyLarge?.copyWith(
//                     color: AppColors.textSecondary,
//                   ),
//                 ),
//
//                 const Spacer(flex: 1),
//
//                 // Features List
//                 _buildFeatureItem(
//                   context,
//                   Icons.emergency_outlined,
//                   'Instant Emergency Response',
//                   'One-click emergency alert with GPS tracking',
//                 ),
//                 const SizedBox(height: 20),
//
//                 _buildFeatureItem(
//                   context,
//                   Icons.health_and_safety_outlined,
//                   'AI Health Monitoring',
//                   'Smart predictions based on your vitals',
//                 ),
//                 const SizedBox(height: 20),
//
//                 _buildFeatureItem(
//                   context,
//                   Icons.assignment_turned_in_outlined,
//                   'Insurance Integration',
//                   'Pre-approved paperwork before arrival',
//                 ),
//
//                 const Spacer(flex: 2),
//
//                 // Buttons
//                 CustomButton(
//                   text: 'Get Started',
//                   onPressed: () {
//                     Navigator.pushNamed(context, AppRoutes.onboarding);
//                   },
//                   gradient: AppColors.primaryGradient,
//                 ),
//                 const SizedBox(height: 16),
//
//                 CustomButton(
//                   text: 'I Already Have an Account',
//                   onPressed: () {
//                     Navigator.pushNamed(context, AppRoutes.login);
//                   },
//                   isOutlined: true,
//                   borderColor: AppColors.primaryTeal,
//                   textColor: AppColors.primaryTeal,
//                 ),
//
//                 const SizedBox(height: 32),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
//
//   Widget _buildFeatureItem(
//       BuildContext context,
//       IconData icon,
//       String title,
//       String subtitle,
//       ) {
//     return Row(
//       children: [
//         Container(
//           width: 56,
//           height: 56,
//           decoration: BoxDecoration(
//             gradient: AppColors.primaryGradient,
//             borderRadius: BorderRadius.circular(16),
//           ),
//           child: Icon(
//             icon,
//             color: AppColors.white,
//             size: 28,
//           ),
//         ),
//         const SizedBox(width: 16),
//         Expanded(
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Text(
//                 title,
//                 style: Theme.of(context).textTheme.titleMedium?.copyWith(
//                   fontWeight: FontWeight.w600,
//                 ),
//               ),
//               const SizedBox(height: 4),
//               Text(
//                 subtitle,
//                 style: Theme.of(context).textTheme.bodySmall?.copyWith(
//                   color: AppColors.textSecondary,
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ],
//     );
//   }
// }