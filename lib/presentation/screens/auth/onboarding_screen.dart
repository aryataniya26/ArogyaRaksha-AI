import 'package:flutter/material.dart';
import '../../../core/routes/app_routes.dart';
import '../../widgets/custom_button.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<OnboardingItem> _items = [
    OnboardingItem(
      icon: Icons.emergency,
      title: 'One-Click Emergency',
      description: 'Get instant help with just one tap. Emergency services will be notified immediately.',
    ),
    OnboardingItem(
      icon: Icons.health_and_safety,
      title: 'AI Health Monitoring',
      description: 'Track your vitals and get predictive alerts for potential health complications.',
    ),
    OnboardingItem(
      icon: Icons.local_hospital,
      title: 'Hospital Pre-Approval',
      description: 'Your medical records and insurance details sent to hospital before arrival.',
    ),
    // OnboardingItem(
    //   icon: Icons.language,
    //   title: 'Multi-Language Support',
    //   description: 'Available in Telugu, Hindi, and English for better accessibility.',
    // ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Skip Button
            Align(
              alignment: Alignment.topRight,
              child: TextButton(
                onPressed: () {
                  Navigator.pushReplacementNamed(context, AppRoutes.signup);
                },
                child: const Text('Skip'),
              ),
            ),

            // PageView
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: _items.length,
                onPageChanged: (index) {
                  setState(() {
                    _currentPage = index;
                  });
                },
                itemBuilder: (context, index) {
                  return _buildOnboardingPage(_items[index]);
                },
              ),
            ),

            // Page Indicators
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                _items.length,
                    (index) => _buildIndicator(index == _currentPage),
              ),
            ),
            const SizedBox(height: 30),

            // Next/Get Started Button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: CustomButton(
                text: _currentPage == _items.length - 1 ? 'Get Started' : 'Next',
                onPressed: () {
                  if (_currentPage == _items.length - 1) {
                    Navigator.pushReplacementNamed(context, AppRoutes.signup);
                  } else {
                    _pageController.nextPage(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                    );
                  }
                },
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildOnboardingPage(OnboardingItem item) {
    return Padding(
      padding: const EdgeInsets.all(40.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Icon
          Container(
            width: 150,
            height: 150,
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              item.icon,
              size: 80,
              color: Theme.of(context).primaryColor,
            ),
          ),
          const SizedBox(height: 50),

          // Title
          Text(
            item.title,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),

          // Description
          Text(
            item.description,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildIndicator(bool isActive) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.symmetric(horizontal: 4),
      width: isActive ? 24 : 8,
      height: 8,
      decoration: BoxDecoration(
        color: isActive ? Theme.of(context).primaryColor : Colors.grey[300],
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }
}

class OnboardingItem {
  final IconData icon;
  final String title;
  final String description;

  OnboardingItem({
    required this.icon,
    required this.title,
    required this.description,
  });
}


// import 'package:flutter/material.dart';
// import 'package:arogyaraksha_ai/core/constants/app_colors.dart';
// import 'package:arogyaraksha_ai/core/routes/app_routes.dart';
// import 'package:arogyaraksha_ai/presentation/widgets/custom_button.dart';
//
//
// class OnboardingScreen extends StatefulWidget {
//   const OnboardingScreen({super.key});
//
//   @override
//   State<OnboardingScreen> createState() => _OnboardingScreenState();
// }
//
// class _OnboardingScreenState extends State<OnboardingScreen> {
//   final PageController _pageController = PageController();
//   int _currentPage = 0;
//
//   final List<OnboardingData> _pages = [
//     OnboardingData(
//       title: 'One-Click Emergency Alert',
//       description:
//       'Press the emergency button and get instant ambulance support with GPS location sharing.',
//       icon: Icons.emergency_outlined,
//       gradient: AppColors.primaryGradient,
//     ),
//     OnboardingData(
//       title: 'AI Health Monitoring',
//       description:
//       'Smart predictions based on your vitals like BP, sugar, and pulse to prevent emergencies.',
//       icon: Icons.health_and_safety_outlined,
//       gradient: AppColors.primaryGradient,
//     ),
//     OnboardingData(
//       title: 'Pre-Approved Insurance',
//       description:
//       'Instant insurance validation and pre-filled hospital forms before you arrive.',
//       icon: Icons.assignment_turned_in_outlined,
//       gradient: AppColors.primaryGradient,
//     ),
//   ];
//
//   @override
//   void dispose() {
//     _pageController.dispose();
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: AppColors.backgroundLight,
//       body: SafeArea(
//         child: Column(
//           children: [
//             // Skip Button
//             Padding(
//               padding: const EdgeInsets.all(16.0),
//               child: Align(
//                 alignment: Alignment.topRight,
//                 child: TextButton(
//                   onPressed: () {
//                     Navigator.pushReplacementNamed(context, AppRoutes.signup);
//                   },
//                   child: Text(
//                     'Skip',
//                     style: Theme.of(context).textTheme.titleMedium?.copyWith(
//                       color: AppColors.primaryTeal,
//                       fontWeight: FontWeight.w600,
//                     ),
//                   ),
//                 ),
//               ),
//             ),
//
//             // PageView
//             Expanded(
//               child: PageView.builder(
//                 controller: _pageController,
//                 onPageChanged: (index) {
//                   setState(() {
//                     _currentPage = index;
//                   });
//                 },
//                 itemCount: _pages.length,
//                 itemBuilder: (context, index) {
//                   return _buildPage(_pages[index]);
//                 },
//               ),
//             ),
//
//             // Page Indicator
//             _buildPageIndicator(),
//
//             const SizedBox(height: 32),
//
//             // Buttons
//             Padding(
//               padding: const EdgeInsets.symmetric(horizontal: 24.0),
//               child: Column(
//                 children: [
//                   CustomButton(
//                     text: _currentPage == _pages.length - 1
//                         ? 'Get Started'
//                         : 'Next',
//                     onPressed: () {
//                       if (_currentPage == _pages.length - 1) {
//                         Navigator.pushReplacementNamed(
//                             context, AppRoutes.signup);
//                       } else {
//                         _pageController.nextPage(
//                           duration: const Duration(milliseconds: 350),
//                           curve: Curves.easeInOut,
//                         );
//                       }
//                     },
//                     gradient: AppColors.primaryGradient,
//                   ),
//                   if (_currentPage > 0) ...[
//                     const SizedBox(height: 12),
//                     CustomButton(
//                       text: 'Back',
//                       onPressed: () {
//                         _pageController.previousPage(
//                           duration: const Duration(milliseconds: 350),
//                           curve: Curves.easeInOut,
//                         );
//                       },
//                       isOutlined: true,
//                       borderColor: AppColors.primaryTeal,
//                       textColor: AppColors.primaryTeal,
//                     ),
//                   ],
//                 ],
//               ),
//             ),
//
//             const SizedBox(height: 32),
//           ],
//         ),
//       ),
//     );
//   }
//
//   /// --- Onboarding Page ---
//   Widget _buildPage(OnboardingData data) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(horizontal: 24.0),
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           // Icon with Gradient Circle
//           Container(
//             width: 200,
//             height: 200,
//             decoration: BoxDecoration(
//               gradient: data.gradient,
//               shape: BoxShape.circle,
//               boxShadow: [
//                 BoxShadow(
//                   color: data.gradient.colors.first.withOpacity(0.35),
//                   blurRadius: 25,
//                   offset: const Offset(0, 15),
//                 ),
//               ],
//             ),
//             child: Icon(
//               data.icon,
//               size: 100,
//               color: AppColors.cardBackground,
//             ),
//           ),
//
//           const SizedBox(height: 48),
//
//           // Title
//           Text(
//             data.title,
//             style: Theme.of(context).textTheme.headlineSmall?.copyWith(
//               fontWeight: FontWeight.bold,
//               color: AppColors.textPrimary,
//             ),
//             textAlign: TextAlign.center,
//           ),
//
//           const SizedBox(height: 16),
//
//           // Description
//           Text(
//             data.description,
//             style: Theme.of(context).textTheme.bodyLarge?.copyWith(
//               color: AppColors.textSecondary,
//               height: 1.6,
//             ),
//             textAlign: TextAlign.center,
//           ),
//         ],
//       ),
//     );
//   }
//
//   /// --- Page Indicator ---
//   Widget _buildPageIndicator() {
//     return Row(
//       mainAxisAlignment: MainAxisAlignment.center,
//       children: List.generate(
//         _pages.length,
//             (index) => AnimatedContainer(
//           duration: const Duration(milliseconds: 300),
//           margin: const EdgeInsets.symmetric(horizontal: 5),
//           width: _currentPage == index ? 30 : 8,
//           height: 8,
//           decoration: BoxDecoration(
//             gradient:
//             _currentPage == index ? AppColors.primaryGradient : null,
//             color: _currentPage == index
//                 ? null
//                 : AppColors.textLight.withOpacity(0.5),
//             borderRadius: BorderRadius.circular(4),
//           ),
//         ),
//       ),
//     );
//   }
// }
//
// class OnboardingData {
//   final String title;
//   final String description;
//   final IconData icon;
//   final Gradient gradient;
//
//   OnboardingData({
//     required this.title,
//     required this.description,
//     required this.icon,
//     required this.gradient,
//   });
// }
//