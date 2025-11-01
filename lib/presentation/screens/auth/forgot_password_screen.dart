import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/auth_viewmodel.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/loading_indicator.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _handleResetPassword() async {
    if (!_formKey.currentState!.validate()) return;

    final authViewModel = context.read<AuthViewModel>();

    final success = await authViewModel.resetPassword(_emailController.text.trim());

    if (!mounted) return;

    if (success) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Email Sent'),
          content: const Text('Password reset link has been sent to your email.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close dialog
                Navigator.pop(context); // Go back to login
              },
              child: const Text('OK'),
            ),
          ],
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(authViewModel.errorMessage ?? 'Failed to send reset email'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Forgot Password'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SafeArea(
        child: Consumer<AuthViewModel>(
          builder: (context, authViewModel, child) {
            if (authViewModel.status == AuthStatus.loading) {
              return const LoadingIndicator(message: 'Sending reset link...');
            }

            return SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 20),

                    // Icon
                    Icon(
                      Icons.lock_reset,
                      size: 100,
                      color: Theme.of(context).primaryColor,
                    ),
                    const SizedBox(height: 30),

                    // Title
                    const Text(
                      'Reset Password',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),

                    // Description
                    Text(
                      'Enter your email address and we\'ll send you a link to reset your password.',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[600],
                        height: 1.5,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 40),

                    // Email Field
                    CustomTextField(
                      controller: _emailController,
                      label: 'Email',
                      hint: 'Enter your email',
                      keyboardType: TextInputType.emailAddress,
                      prefixIcon: Icons.email_outlined,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your email';
                        }
                        if (!value.contains('@')) {
                          return 'Please enter a valid email';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 30),

                    // Reset Button
                    CustomButton(
                      text: 'Send Reset Link',
                      onPressed: _handleResetPassword,
                    ),
                    const SizedBox(height: 20),

                    // Back to Login
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Back to Login'),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}


// import 'package:flutter/material.dart';
// import 'package:arogyaraksha_ai/core/constants/app_colors.dart';
// import 'package:arogyaraksha_ai/presentation/widgets/custom_button.dart';
// import 'package:arogyaraksha_ai/presentation/widgets/custom_text_field.dart';
// import 'package:firebase_auth/firebase_auth.dart';
//
// class ForgotPasswordScreen extends StatefulWidget {
//   const ForgotPasswordScreen({super.key});
//
//   @override
//   State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
// }
//
// class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
//   final _formKey = GlobalKey<FormState>();
//   final _emailController = TextEditingController();
//   final FirebaseAuth _auth = FirebaseAuth.instance;
//
//   bool _isLoading = false;
//   bool _isEmailSent = false;
//
//   @override
//   void dispose() {
//     _emailController.dispose();
//     super.dispose();
//   }
//
//   Future<void> _handleResetPassword() async {
//     if (_formKey.currentState!.validate()) {
//       setState(() => _isLoading = true);
//
//       try {
//         await _auth.sendPasswordResetEmail(
//           email: _emailController.text.trim(),
//         );
//
//         if (mounted) {
//           setState(() {
//             _isLoading = false;
//             _isEmailSent = true;
//           });
//         }
//       } on FirebaseAuthException catch (e) {
//         String errorMessage = 'Failed to send reset email';
//
//         switch (e.code) {
//           case 'user-not-found':
//             errorMessage = 'No user found with this email';
//             break;
//           case 'invalid-email':
//             errorMessage = 'Invalid email address';
//             break;
//           case 'too-many-requests':
//             errorMessage = 'Too many requests. Try again later';
//             break;
//           default:
//             errorMessage = e.message ?? 'An error occurred';
//         }
//
//         _showSnackBar(errorMessage, isError: true);
//         setState(() => _isLoading = false);
//       } catch (e) {
//         _showSnackBar('An unexpected error occurred', isError: true);
//         setState(() => _isLoading = false);
//         print('Reset password error: $e');
//       }
//     }
//   }
//
//   Future<void> _handleResendEmail() async {
//     setState(() {
//       _isEmailSent = false;
//       _isLoading = false;
//     });
//   }
//
//   void _showSnackBar(String message, {required bool isError}) {
//     if (!mounted) return;
//
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: Text(message),
//         backgroundColor: isError ? AppColors.alertRed : AppColors.successGreen,
//         duration: const Duration(seconds: 3),
//       ),
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: AppColors.backgroundLight,
//       appBar: AppBar(
//         title: const Text('Forgot Password'),
//       ),
//       body: SafeArea(
//         child: SingleChildScrollView(
//           padding: const EdgeInsets.all(24.0),
//           child: _isEmailSent ? _buildSuccessView() : _buildFormView(),
//         ),
//       ),
//     );
//   }
//
//   Widget _buildFormView() {
//     return Form(
//       key: _formKey,
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           const SizedBox(height: 24),
//           Center(
//             child: Container(
//               width: 120,
//               height: 120,
//               decoration: BoxDecoration(
//                 gradient: AppColors.primaryGradient,
//                 shape: BoxShape.circle,
//               ),
//               child: const Icon(
//                 Icons.lock_reset,
//                 size: 60,
//                 color: AppColors.white,
//               ),
//             ),
//           ),
//           const SizedBox(height: 32),
//
//           Text(
//             'Reset Password',
//             style: Theme.of(context).textTheme.displaySmall?.copyWith(
//               fontWeight: FontWeight.bold,
//             ),
//           ),
//           const SizedBox(height: 8),
//
//           Text(
//             'Enter your email address and we will send you a link to reset your password.',
//             style: Theme.of(context).textTheme.bodyLarge?.copyWith(
//               color: AppColors.textSecondary,
//               height: 1.5,
//             ),
//           ),
//           const SizedBox(height: 32),
//
//           CustomTextField(
//             controller: _emailController,
//             label: 'Email',
//             hint: 'Enter your email',
//             prefixIcon: Icons.email_outlined,
//             keyboardType: TextInputType.emailAddress,
//             validator: (value) {
//               if (value == null || value.isEmpty) {
//                 return 'Please enter your email';
//               }
//               if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
//                 return 'Please enter a valid email';
//               }
//               return null;
//             },
//           ),
//           const SizedBox(height: 32),
//
//           CustomButton(
//             text: 'Send Reset Link',
//             onPressed: _handleResetPassword,
//             gradient: AppColors.primaryGradient,
//             isLoading: _isLoading,
//           ),
//           const SizedBox(height: 16),
//
//           Center(
//             child: TextButton(
//               onPressed: () => Navigator.pop(context),
//               child: Text(
//                 'Back to Login',
//                 style: Theme.of(context).textTheme.bodyMedium?.copyWith(
//                   color: AppColors.primaryTeal,
//                   fontWeight: FontWeight.w600,
//                 ),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildSuccessView() {
//     return Column(
//       children: [
//         const SizedBox(height: 40),
//         Container(
//           width: 120,
//           height: 120,
//           decoration: BoxDecoration(
//             color: AppColors.successGreen.withOpacity(0.1),
//             shape: BoxShape.circle,
//           ),
//           child: const Icon(
//             Icons.check_circle_outline,
//             size: 60,
//             color: AppColors.successGreen,
//           ),
//         ),
//         const SizedBox(height: 32),
//
//         Text(
//           'Email Sent!',
//           style: Theme.of(context).textTheme.displaySmall?.copyWith(
//             fontWeight: FontWeight.bold,
//             color: AppColors.successGreen,
//           ),
//         ),
//         const SizedBox(height: 16),
//
//         Text(
//           'We have sent a password reset link to',
//           style: Theme.of(context).textTheme.bodyLarge?.copyWith(
//             color: AppColors.textSecondary,
//           ),
//           textAlign: TextAlign.center,
//         ),
//         const SizedBox(height: 8),
//
//         Text(
//           _emailController.text,
//           style: Theme.of(context).textTheme.bodyLarge?.copyWith(
//             color: AppColors.primaryTeal,
//             fontWeight: FontWeight.w600,
//           ),
//           textAlign: TextAlign.center,
//         ),
//         const SizedBox(height: 32),
//
//         CustomButton(
//           text: 'Back to Login',
//           onPressed: () => Navigator.pop(context),
//           gradient: AppColors.primaryGradient,
//         ),
//         const SizedBox(height: 16),
//
//         TextButton(
//           onPressed: _handleResendEmail,
//           child: Text(
//             'Resend Email',
//             style: Theme.of(context).textTheme.bodyMedium?.copyWith(
//               color: AppColors.primaryTeal,
//               fontWeight: FontWeight.w600,
//             ),
//           ),
//         ),
//       ],
//     );
//   }
// }
//
// // import 'package:flutter/material.dart';
// // import 'package:arogyaraksha_ai/core/constants/app_colors.dart';
// // import '../../widgets/custom_button.dart';
// // import '../../widgets/custom_text_field.dart';
// //
// // class ForgotPasswordScreen extends StatefulWidget {
// //   const ForgotPasswordScreen({super.key});
// //
// //   @override
// //   State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
// // }
// //
// // class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
// //   final _formKey = GlobalKey<FormState>();
// //   final _emailController = TextEditingController();
// //   bool _isLoading = false;
// //   bool _isEmailSent = false;
// //
// //   @override
// //   void dispose() {
// //     _emailController.dispose();
// //     super.dispose();
// //   }
// //
// //   Future<void> _handleResetPassword() async {
// //     if (_formKey.currentState!.validate()) {
// //       setState(() => _isLoading = true);
// //       await Future.delayed(const Duration(seconds: 2));
// //       if (mounted) {
// //         setState(() {
// //           _isLoading = false;
// //           _isEmailSent = true;
// //         });
// //       }
// //     }
// //   }
// //
// //   @override
// //   Widget build(BuildContext context) {
// //     return Scaffold(
// //       backgroundColor: AppColors.backgroundLight,
// //       appBar: AppBar(
// //         title: const Text('Forgot Password'),
// //       ),
// //       body: SafeArea(
// //         child: SingleChildScrollView(
// //           padding: const EdgeInsets.all(24.0),
// //           child: _isEmailSent ? _buildSuccessView() : _buildFormView(),
// //         ),
// //       ),
// //     );
// //   }
// //
// //   Widget _buildFormView() {
// //     return Form(
// //       key: _formKey,
// //       child: Column(
// //         crossAxisAlignment: CrossAxisAlignment.start,
// //         children: [
// //           const SizedBox(height: 24),
// //           Center(
// //             child: Container(
// //               width: 120,
// //               height: 120,
// //               decoration: BoxDecoration(
// //                 gradient: AppColors.primaryGradient,
// //                 shape: BoxShape.circle,
// //               ),
// //               child: const Icon(
// //                 Icons.lock_reset,
// //                 size: 60,
// //                 color: AppColors.white,
// //               ),
// //             ),
// //           ),
// //           const SizedBox(height: 32),
// //           Text(
// //             'Reset Password',
// //             style: Theme.of(context).textTheme.displaySmall?.copyWith(
// //               fontWeight: FontWeight.bold,
// //             ),
// //           ),
// //           const SizedBox(height: 8),
// //           Text(
// //             'Enter your email address and we will send you a link to reset your password.',
// //             style: Theme.of(context).textTheme.bodyLarge?.copyWith(
// //               color: AppColors.textSecondary,
// //               height: 1.5,
// //             ),
// //           ),
// //           const SizedBox(height: 32),
// //           CustomTextField(
// //             controller: _emailController,
// //             label: 'Email',
// //             hint: 'Enter your email',
// //             prefixIcon: Icons.email_outlined,
// //             keyboardType: TextInputType.emailAddress,
// //             validator: (value) {
// //               if (value == null || value.isEmpty) {
// //                 return 'Please enter your email';
// //               }
// //               if (!value.contains('@')) {
// //                 return 'Please enter a valid email';
// //               }
// //               return null;
// //             },
// //           ),
// //           const SizedBox(height: 32),
// //           CustomButton(
// //             text: 'Send Reset Link',
// //             onPressed: _handleResetPassword,
// //             gradient: AppColors.primaryGradient,
// //             isLoading: _isLoading,
// //           ),
// //           const SizedBox(height: 16),
// //           Center(
// //             child: TextButton(
// //               onPressed: () => Navigator.pop(context),
// //               child: Text(
// //                 'Back to Login',
// //                 style: Theme.of(context).textTheme.bodyMedium?.copyWith(
// //                   color: AppColors.primaryTeal,
// //                   fontWeight: FontWeight.w600,
// //                 ),
// //               ),
// //             ),
// //           ),
// //         ],
// //       ),
// //     );
// //   }
// //
// //   Widget _buildSuccessView() {
// //     return Column(
// //       children: [
// //         const SizedBox(height: 40),
// //         Container(
// //           width: 120,
// //           height: 120,
// //           decoration: BoxDecoration(
// //             color: AppColors.successGreen.withOpacity(0.1),
// //             shape: BoxShape.circle,
// //           ),
// //           child: const Icon(
// //             Icons.check_circle_outline,
// //             size: 60,
// //             color: AppColors.successGreen,
// //           ),
// //         ),
// //         const SizedBox(height: 32),
// //         Text(
// //           'Email Sent!',
// //           style: Theme.of(context).textTheme.displaySmall?.copyWith(
// //             fontWeight: FontWeight.bold,
// //             color: AppColors.successGreen,
// //           ),
// //         ),
// //         const SizedBox(height: 16),
// //         Text(
// //           'We have sent a password reset link to',
// //           style: Theme.of(context).textTheme.bodyLarge?.copyWith(
// //             color: AppColors.textSecondary,
// //           ),
// //           textAlign: TextAlign.center,
// //         ),
// //         const SizedBox(height: 8),
// //         Text(
// //           _emailController.text,
// //           style: Theme.of(context).textTheme.bodyLarge?.copyWith(
// //             color: AppColors.primaryTeal,
// //             fontWeight: FontWeight.w600,
// //           ),
// //           textAlign: TextAlign.center,
// //         ),
// //         const SizedBox(height: 32),
// //         CustomButton(
// //           text: 'Back to Login',
// //           onPressed: () => Navigator.pop(context),
// //           gradient: AppColors.primaryGradient,
// //         ),
// //         const SizedBox(height: 16),
// //         TextButton(
// //           onPressed: () {
// //             setState(() => _isEmailSent = false);
// //           },
// //           child: Text(
// //             'Resend Email',
// //             style: Theme.of(context).textTheme.bodyMedium?.copyWith(
// //               color: AppColors.primaryTeal,
// //               fontWeight: FontWeight.w600,
// //             ),
// //           ),
// //         ),
// //       ],
// //     );
// //   }
// // }
