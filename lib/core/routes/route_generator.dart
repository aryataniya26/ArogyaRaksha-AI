import 'package:arogyaraksha_ai/presentation/screens/emergency/emergency_confirmation_screen.dart';
import 'package:arogyaraksha_ai/presentation/screens/emergency/live_status_screen.dart';
import 'package:arogyaraksha_ai/presentation/screens/health/ai_health_alerts_screen.dart';
import 'package:arogyaraksha_ai/presentation/screens/health/blood_request_screen.dart';
import 'package:arogyaraksha_ai/presentation/screens/health/vitals_monitoring_screen.dart';
import 'package:arogyaraksha_ai/presentation/screens/history/emergency_history_screen.dart';
import 'package:arogyaraksha_ai/presentation/screens/insurance/insurance_status_screen.dart';
import 'package:arogyaraksha_ai/presentation/screens/notifications/notification_center_screen.dart';
import 'package:flutter/material.dart';
import '../../presentation/screens/splash/splash_screen.dart';
import '../../presentation/screens/auth/welcome_screen.dart';
import '../../presentation/screens/auth/onboarding_screen.dart';
import '../../presentation/screens/auth/login_screen.dart';
import '../../presentation/screens/auth/signup_screen.dart';
import '../../presentation/screens/auth/forgot_password_screen.dart';
import '../../presentation/screens/home/home_screen.dart';
import '../../presentation/screens/home/dashboard_screen.dart';
import '../../presentation/screens/profile/profile_screen.dart';
import '../../presentation/screens/profile/edit_profile_screen.dart';
import '../../presentation/screens/emergency/emergency_trigger_screen.dart';
import '../../presentation/screens/settings/settings_screen.dart';
import 'app_routes.dart';

class RouteGenerator {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case AppRoutes.splash:
        return MaterialPageRoute(builder: (_) => const SplashScreen());

      case AppRoutes.welcome:
        return MaterialPageRoute(builder: (_) => const WelcomeScreen());

      case AppRoutes.onboarding:
        return MaterialPageRoute(builder: (_) => const OnboardingScreen());

      case AppRoutes.login:
        return MaterialPageRoute(builder: (_) => const LoginScreen());

      case AppRoutes.signup:
        return MaterialPageRoute(builder: (_) => const SignupScreen());

      case AppRoutes.forgotPassword:
        return MaterialPageRoute(builder: (_) => const ForgotPasswordScreen());

      case AppRoutes.home:
        return MaterialPageRoute(builder: (_) => const HomeScreen());

      case AppRoutes.emergencyConfirmation:
        return MaterialPageRoute( builder: (_) => const EmergencyConfirmationScreen(),);


      case AppRoutes.vitalsMonitoring:
        return MaterialPageRoute(  builder: (_) => const VitalsMonitoringScreen(),);

      case AppRoutes.aiHealthAlerts:
        return MaterialPageRoute(builder: (_) => const AiHealthAlertsScreen());
          case AppRoutes.bloodRequest:
            return MaterialPageRoute(builder: (_) => const BloodRequestScreen());

            // // Insurance
    case AppRoutes.insuranceStatus:
    return MaterialPageRoute(  builder: (_) => const InsuranceStatusScreen(), );

     // History
    case AppRoutes.emergencyHistory:
      return MaterialPageRoute(  builder: (_) => const EmergencyHistoryScreen(), );

      //Notifications
    case AppRoutes.notificationCenter:
      return MaterialPageRoute(  builder: (_) => const NotificationCenterScreen(),  );



      case AppRoutes.dashboard:
        return MaterialPageRoute(builder: (_) => const DashboardScreen());

      case AppRoutes.profile:
        return MaterialPageRoute(builder: (_) => const ProfileScreen());

      case AppRoutes.editProfile:
        return MaterialPageRoute(builder: (_) => const EditProfileScreen());

      case AppRoutes.emergencyTrigger:
        return MaterialPageRoute(builder: (_) => const EmergencyTriggerScreen());

      case AppRoutes.settings:
        return MaterialPageRoute(builder: (_) => const SettingsScreen());

      case AppRoutes.emergencyConfirmation:
        return MaterialPageRoute(builder: (_) => const EmergencyConfirmationScreen());

      case AppRoutes.liveStatus:
        final emergencyId = settings.arguments as String;
        return MaterialPageRoute(builder: (_) => LiveStatusScreen(emergencyId: emergencyId));


      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(
              child: Text('No route defined for ${settings.name}'),
            ),
          ),
        );
    }
  }
}



// import 'package:flutter/material.dart';
// import 'app_routes.dart';
// import '../../presentation/screens/splash/splash_screen.dart';
// import '../../presentation/screens/auth/welcome_screen.dart';
// import '../../presentation/screens/auth/onboarding_screen.dart';
// import '../../presentation/screens/auth/login_screen.dart';
// import '../../presentation/screens/auth/signup_screen.dart';
// import '../../presentation/screens/auth/forgot_password_screen.dart';
// import '../../presentation/screens/home/home_screen.dart';
// import '../../presentation/screens/emergency/emergency_confirmation_screen.dart';
// import '../../presentation/screens/emergency/live_status_screen.dart';
// import '../../presentation/screens/profile/profile_screen.dart';
// import '../../presentation/screens/profile/edit_profile_screen.dart';
// import '../../presentation/screens/health/vitals_monitoring_screen.dart';
// import '../../presentation/screens/health/ai_health_alerts_screen.dart';
// import '../../presentation/screens/health/blood_request_screen.dart';
// import '../../presentation/screens/insurance/insurance_status_screen.dart';
// import '../../presentation/screens/history/emergency_history_screen.dart';
// import '../../presentation/screens/notifications/notification_center_screen.dart';
// import '../../presentation/screens/settings/settings_screen.dart';
//
// class RouteGenerator {
//   static Route<dynamic> generateRoute(RouteSettings settings) {
//     final args = settings.arguments;
//
//     switch (settings.name) {
//     // Splash & Onboarding
//       case AppRoutes.splash:
//         return MaterialPageRoute(builder: (_) => const SplashScreen());
//
//       case AppRoutes.welcome:
//         return MaterialPageRoute(builder: (_) => const WelcomeScreen());
//
//       case AppRoutes.onboarding:
//         return MaterialPageRoute(builder: (_) => const OnboardingScreen());
//
//     // Authentication
//       case AppRoutes.login:
//         return MaterialPageRoute(builder: (_) => const LoginScreen());
//
//       case AppRoutes.signup:
//         return MaterialPageRoute(builder: (_) => const SignupScreen());
//
//       case AppRoutes.forgotPassword:
//         return MaterialPageRoute(builder: (_) => const ForgotPasswordScreen());
//
//     // Home
//       case AppRoutes.home:
//         return MaterialPageRoute(builder: (_) => const HomeScreen());
//
//     // Emergency
//       case AppRoutes.emergencyConfirmation:
//         return MaterialPageRoute(
//           builder: (_) => const EmergencyConfirmationScreen(),
//         );
//
//       case AppRoutes.liveStatus:
//         return MaterialPageRoute(builder: (_) => const LiveStatusScreen());
//
//     // Profile
//       case AppRoutes.profile:
//         return MaterialPageRoute(builder: (_) => const ProfileScreen());
//
//       case AppRoutes.editProfile:
//         return MaterialPageRoute(builder: (_) => const EditProfileScreen());
//
//     // Health & Vitals
//       case AppRoutes.vitalsMonitoring:
//         return MaterialPageRoute(
//           builder: (_) => const VitalsMonitoringScreen(),
//         );
//
//       case AppRoutes.aiHealthAlerts:
//         return MaterialPageRoute(builder: (_) => const AIHealthAlertsScreen());
//
//       case AppRoutes.bloodRequest:
//         return MaterialPageRoute(builder: (_) => const BloodRequestScreen());
//
//     // Insurance
//       case AppRoutes.insuranceStatus:
//         return MaterialPageRoute(
//           builder: (_) => const InsuranceStatusScreen(),
//         );
//
//     // History
//       case AppRoutes.emergencyHistory:
//         return MaterialPageRoute(
//           builder: (_) => const EmergencyHistoryScreen(),
//         );
//
//     // Notifications
//       case AppRoutes.notifications:
//         return MaterialPageRoute(
//           builder: (_) => const NotificationCenterScreen(),
//         );
//
//     // Settings
//       case AppRoutes.settings:
//         return MaterialPageRoute(builder: (_) => const SettingsScreen());
//
//       default:
//         return MaterialPageRoute(
//     builder: (_) => Scaffold(
//     body: Center(
//     child: Text('No route defined for ${settings.name}'),
//     ),
//     ),
//         );
//     }
//   }
//
//   // static Route<dynamic> _errorRoute() {
//   //   return MaterialPageRoute(
//   //     builder: (_) => Scaffold(
//   //       appBar: AppBar(title: const Text('Error')),
//   //       body: const Center(
//   //         child: Text('Page not found!'),
//   //       ),
//   //     ),
//   //   );
//   // }
// }