// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import '../../viewmodels/auth_viewmodel.dart';
// import '../../../core/routes/app_routes.dart';
//
// class DashboardScreen extends StatelessWidget {
//   const DashboardScreen({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Dashboard'),
//         actions: [
//           IconButton(
//             icon: const Icon(Icons.settings),
//             onPressed: () {
//               Navigator.pushNamed(context, AppRoutes.settings);
//             },
//           ),
//         ],
//       ),
//       body: Consumer<AuthViewModel>(
//         builder: (context, authViewModel, child) {
//           final user = authViewModel.currentUser;
//
//           return Center(
//             child: Padding(
//               padding: const EdgeInsets.all(24.0),
//               child: Column(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   Icon(
//                     Icons.check_circle_outline,
//                     size: 100,
//                     color: Colors.green[400],
//                   ),
//                   const SizedBox(height: 30),
//
//                   const Text(
//                     'Welcome to ArogyaRaksha AI!',
//                     style: TextStyle(
//                       fontSize: 24,
//                       fontWeight: FontWeight.bold,
//                     ),
//                     textAlign: TextAlign.center,
//                   ),
//                   const SizedBox(height: 16),
//
//                   if (user != null) ...[
//                     Text(
//                       'Hello, ${user.name}!',
//                       style: TextStyle(
//                         fontSize: 18,
//                         color: Colors.grey[600],
//                       ),
//                       textAlign: TextAlign.center,
//                     ),
//                     const SizedBox(height: 8),
//                     Text(
//                       user.email,
//                       style: TextStyle(
//                         fontSize: 16,
//                         color: Colors.grey[500],
//                       ),
//                       textAlign: TextAlign.center,
//                     ),
//                   ],
//
//                   const SizedBox(height: 40),
//
//                   ElevatedButton.icon(
//                     onPressed: () async {
//                       final confirmed = await showDialog<bool>(
//                         context: context,
//                         builder: (context) => AlertDialog(
//                           title: const Text('Sign Out'),
//                           content: const Text('Are you sure you want to sign out?'),
//                           actions: [
//                             TextButton(
//                               onPressed: () => Navigator.pop(context, false),
//                               child: const Text('Cancel'),
//                             ),
//                             TextButton(
//                               onPressed: () => Navigator.pop(context, true),
//                               child: const Text('Sign Out'),
//                             ),
//                           ],
//                         ),
//                       );
//
//                       if (confirmed == true && context.mounted) {
//                         await authViewModel.signOut();
//                         Navigator.pushReplacementNamed(context, AppRoutes.login);
//                       }
//                     },
//                     icon: const Icon(Icons.logout),
//                     label: const Text('Sign Out'),
//                     style: ElevatedButton.styleFrom(
//                       padding: const EdgeInsets.symmetric(
//                         horizontal: 32,
//                         vertical: 16,
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           );
//         },
//       ),
//     );
//   }
// }
//
//
import 'package:flutter/material.dart';
import 'package:arogyaraksha_ai/core/constants/app_colors.dart';
class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text('Dashboard - Same as Home Screen'),
      ),
    );
  }
}