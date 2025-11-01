import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../domain/usecases/validate_insurance_usecase.dart';
import '../../../presentation/widgets/custom_button.dart';

class InsuranceStatusScreen extends StatefulWidget {
  const InsuranceStatusScreen({super.key});

  @override
  State<InsuranceStatusScreen> createState() => _InsuranceStatusScreenState();
}

class _InsuranceStatusScreenState extends State<InsuranceStatusScreen> {
  final ValidateInsuranceUseCase _validateInsuranceUseCase = ValidateInsuranceUseCase();

  bool _isLoading = false;
  InsuranceValidationResult? _result;

  @override
  void initState() {
    super.initState();
    _validateInsurance();
  }

  Future<void> _validateInsurance() async {
    setState(() => _isLoading = true);

    try {
      final result = await _validateInsuranceUseCase.execute();
      setState(() {
        _result = result;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        title: const Text('Insurance Status'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _isLoading ? null : _validateInsurance,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _result == null
          ? _buildError()
          : _result!.hasInsurance
          ? _result!.isValid
          ? _buildValidInsurance()
          : _buildInvalidInsurance()
          : _buildNoInsurance(),
    );
  }

  Widget _buildValidInsurance() {
    return SingleChildScrollView(
      child: Column(
        children: [
          // Success Header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              gradient: AppColors.primaryGradient,
              boxShadow: [
                BoxShadow(
                  color: AppColors.primaryTeal.withOpacity(0.3),
                  blurRadius: 15,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Column(
              children: [
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.verified_user,
                    size: 50,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Insurance Verified',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _result!.message,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Insurance Details
          _buildInfoCard(
            'Insurance Details',
            Icons.card_membership,
            [
              _buildDetailRow('Provider', _result!.provider ?? 'N/A'),
              _buildDetailRow('Policy Number', _result!.policyNumber ?? 'N/A'),
              _buildDetailRow('Coverage', _result!.coverage ?? 'N/A'),
              _buildDetailRow('Valid Till', _result!.validTill ?? 'N/A'),
              _buildDetailRow('Status', _result!.status ?? 'N/A',
                  statusColor: AppColors.successGreen),
            ],
          ),

          const SizedBox(height: 16),

          // Benefits Card
          if (_result!.benefits.isNotEmpty)
            _buildInfoCard(
              'Coverage Benefits',
              Icons.favorite,
              _result!.benefits
                  .map((benefit) => _buildBenefitItem(benefit))
                  .toList(),
            ),

          const SizedBox(height: 16),

          // Quick Actions
          _buildInfoCard(
            'Quick Actions',
            Icons.flash_on,
            [
              _buildActionButton(
                'View Policy Documents',
                Icons.description,
                    () {
                  // TODO: Open DigiLocker or policy PDFs
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('DigiLocker integration coming soon')),
                  );
                },
              ),
              const SizedBox(height: 12),
              _buildActionButton(
                'Find Network Hospitals',
                Icons.local_hospital,
                    () {
                  // TODO: Navigate to hospital finder
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Hospital finder coming soon')),
                  );
                },
              ),
              const SizedBox(height: 12),
              _buildActionButton(
                'Contact Insurance Provider',
                Icons.phone,
                    () {
                  // TODO: Call insurance provider
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Contact feature coming soon')),
                  );
                },
              ),
            ],
          ),

          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildNoInsurance() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: AppColors.backgroundGrey,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.shield_outlined,
                size: 60,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'No Insurance Found',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'You haven\'t added any insurance information yet. Add your insurance details to get instant coverage verification.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 32),
            CustomButton(
              text: 'Add Insurance Details',
              onPressed: () {
                Navigator.pushNamed(context, '/edit-profile');
              },
              gradient: AppColors.primaryGradient,
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () {
                // TODO: Show insurance benefits info
              },
              child: const Text('Why do I need insurance?'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInvalidInsurance() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: AppColors.alertRed.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.error_outline,
                size: 60,
                color: AppColors.alertRed,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Insurance Validation Failed',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              _result!.message,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 32),
            CustomButton(
              text: 'Update Insurance Details',
              onPressed: () {
                Navigator.pushNamed(context, '/edit-profile');
              },
              gradient: AppColors.primaryGradient,
            ),
            const SizedBox(height: 16),
            CustomButton(
              text: 'Contact Support',
              onPressed: () {
                // TODO: Contact support
              },
              isOutlined: true,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildError() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 64, color: AppColors.alertRed),
          const SizedBox(height: 16),
          const Text('Failed to load insurance status'),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _validateInsurance,
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard(String title, IconData icon, List<Widget> children) {
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
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: Colors.white, size: 22),
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          ...children,
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, {Color? statusColor}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: statusColor ?? AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBenefitItem(String benefit) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.check_circle,
            color: AppColors.successGreen,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              benefit,
              style: const TextStyle(fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(String title, IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.backgroundLight,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.backgroundGrey),
        ),
        child: Row(
          children: [
            Icon(icon, color: AppColors.primaryTeal),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const Icon(Icons.arrow_forward_ios, size: 16, color: AppColors.textSecondary),
          ],
        ),
      ),
    );
  }
}



// import 'package:flutter/material.dart';
// import 'package:arogyaraksha_ai/core/constants/app_colors.dart';
// import 'package:arogyaraksha_ai/presentation/widgets/custom_button.dart';
//
// class InsuranceStatusScreen extends StatelessWidget {
//   const InsuranceStatusScreen({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: AppColors.backgroundLight,
//       appBar: AppBar(
//         title: const Text('Insurance Status'),
//         backgroundColor: AppColors.primaryTeal,
//         foregroundColor: AppColors.textWhite,
//       ),
//       body: SingleChildScrollView(
//         child: Column(
//           children: [
//             // Insurance Card
//             Container(
//               margin: const EdgeInsets.all(16),
//               padding: const EdgeInsets.all(24),
//               decoration: BoxDecoration(
//                 gradient: AppColors.primaryGradient,
//                 borderRadius: BorderRadius.circular(20),
//                 boxShadow: [
//                   BoxShadow(
//                     color: AppColors.primaryTeal.withOpacity(0.3),
//                     blurRadius: 20,
//                     offset: const Offset(0, 10),
//                   ),
//                 ],
//               ),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Row(
//                     children: [
//                       const Icon(
//                         Icons.verified_user,
//                         color: AppColors.white,
//                         size: 32,
//                       ),
//                       const SizedBox(width: 12),
//                       Text(
//                         'Active Coverage',
//                         style: Theme.of(context).textTheme.titleLarge?.copyWith(
//                           color: AppColors.white,
//                           fontWeight: FontWeight.bold,
//                         ),
//                       ),
//                     ],
//                   ),
//                   const SizedBox(height: 24),
//                   Text(
//                     'Star Health Insurance',
//                     style: Theme.of(context).textTheme.headlineSmall?.copyWith(
//                       color: AppColors.white,
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                   const SizedBox(height: 8),
//                   Text(
//                     'Policy ID: #SH-2025-0041',
//                     style: Theme.of(context).textTheme.bodyLarge?.copyWith(
//                       color: AppColors.white.withOpacity(0.9),
//                     ),
//                   ),
//                   const SizedBox(height: 24),
//                   Container(
//                     padding: const EdgeInsets.all(16),
//                     decoration: BoxDecoration(
//                       color: AppColors.white.withOpacity(0.2),
//                       borderRadius: BorderRadius.circular(12),
//                     ),
//                     child: Row(
//                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                       children: [
//                         Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             Text(
//                               'Coverage Amount',
//                               style: Theme.of(context)
//                                   .textTheme
//                                   .bodySmall
//                                   ?.copyWith(
//                                 color: AppColors.white.withOpacity(0.9),
//                               ),
//                             ),
//                             const SizedBox(height: 4),
//                             Text(
//                               '₹5,00,000',
//                               style: Theme.of(context)
//                                   .textTheme
//                                   .headlineSmall
//                                   ?.copyWith(
//                                 color: AppColors.white,
//                                 fontWeight: FontWeight.bold,
//                               ),
//                             ),
//                           ],
//                         ),
//                         Column(
//                           crossAxisAlignment: CrossAxisAlignment.end,
//                           children: [
//                             Text(
//                               'Valid Until',
//                               style: Theme.of(context)
//                                   .textTheme
//                                   .bodySmall
//                                   ?.copyWith(
//                                 color: AppColors.white.withOpacity(0.9),
//                               ),
//                             ),
//                             const SizedBox(height: 4),
//                             Text(
//                               '2026-06-21',
//                               style: Theme.of(context)
//                                   .textTheme
//                                   .titleMedium
//                                   ?.copyWith(
//                                 color: AppColors.white,
//                                 fontWeight: FontWeight.bold,
//                               ),
//                             ),
//                           ],
//                         ),
//                       ],
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//
//             // Quick Actions
//             Container(
//               margin: const EdgeInsets.symmetric(horizontal: 16),
//               child: Row(
//                 children: [
//                   Expanded(
//                     child: _buildActionButton(
//                       context,
//                       'Verify Policy',
//                       Icons.verified_outlined,
//                           () {},
//                     ),
//                   ),
//                   const SizedBox(width: 12),
//                   Expanded(
//                     child: _buildActionButton(
//                       context,
//                       'DigiLocker',
//                       Icons.folder_outlined,
//                           () {},
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//
//             const SizedBox(height: 16),
//
//             // Coverage Details
//             Container(
//               margin: const EdgeInsets.symmetric(horizontal: 16),
//               padding: const EdgeInsets.all(20),
//               decoration: BoxDecoration(
//                 color: AppColors.cardBackground,
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
//                   Text(
//                     'Coverage Details',
//                     style: Theme.of(context).textTheme.titleLarge?.copyWith(
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                   const SizedBox(height: 16),
//                   _buildDetailRow(context, 'Provider', 'Ayush Kumar'),
//                   _buildDetailRow(context, 'Valid Until', '2026-06-21'),
//                   _buildDetailRow(context, 'Coverage', 'Rs. 5,00,000'),
//                   _buildDetailRow(context, 'Used', 'Rs. 5,000'),
//                   _buildDetailRow(context, 'Available', 'Rs. 4,95,000'),
//                   _buildDetailRow(context, 'Estimate Cost', 'Rs. 78,000.0',
//                       isHighlight: true),
//                 ],
//               ),
//             ),
//
//             const SizedBox(height: 16),
//
//             // Claims History
//             Container(
//               margin: const EdgeInsets.symmetric(horizontal: 16),
//               padding: const EdgeInsets.all(20),
//               decoration: BoxDecoration(
//                 color: AppColors.cardBackground,
//                 borderRadius: BorderRadius.circular(16),
//               ),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     'Claims History',
//                     style: Theme.of(context).textTheme.titleLarge?.copyWith(
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                   const SizedBox(height: 16),
//                   _buildClaimCard(
//                     context,
//                     'Emergency Visit',
//                     '12 Sep 2025',
//                     '₹15,000',
//                     'Approved',
//                     AppColors.successGreen,
//                   ),
//                   _buildClaimCard(
//                     context,
//                     'Routine Checkup',
//                     '05 Aug 2025',
//                     '₹5,000',
//                     'Approved',
//                     AppColors.successGreen,
//                   ),
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
//   // --------------------------
//   // Helper Widgets
//   // --------------------------
//
//   Widget _buildActionButton(
//       BuildContext context, String label, IconData icon, VoidCallback onTap) {
//     return GestureDetector(
//       onTap: onTap,
//       child: Container(
//         padding: const EdgeInsets.all(16),
//         decoration: BoxDecoration(
//           color: AppColors.cardBackground,
//           borderRadius: BorderRadius.circular(12),
//           boxShadow: [
//             BoxShadow(
//               color: AppColors.shadow.withOpacity(0.08),
//               blurRadius: 10,
//               offset: const Offset(0, 4),
//             ),
//           ],
//         ),
//         child: Column(
//           children: [
//             Container(
//               width: 48,
//               height: 48,
//               decoration: BoxDecoration(
//                 gradient: AppColors.primaryGradient,
//                 borderRadius: BorderRadius.circular(12),
//               ),
//               child: Icon(
//                 icon,
//                 color: AppColors.white,
//               ),
//             ),
//             const SizedBox(height: 8),
//             Text(
//               label,
//               style: Theme.of(context).textTheme.bodyMedium?.copyWith(
//                 fontWeight: FontWeight.w600,
//                 color: AppColors.textPrimary,
//               ),
//               textAlign: TextAlign.center,
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget _buildDetailRow(
//       BuildContext context,
//       String label,
//       String value, {
//         bool isHighlight = false,
//       }) {
//     return Padding(
//       padding: const EdgeInsets.only(bottom: 12),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         children: [
//           Text(
//             label,
//             style: Theme.of(context).textTheme.bodyMedium?.copyWith(
//               color: AppColors.textSecondary,
//             ),
//           ),
//           Text(
//             value,
//             style: Theme.of(context).textTheme.bodyMedium?.copyWith(
//               fontWeight: FontWeight.w600,
//               color: isHighlight ? AppColors.primaryTeal : AppColors.textPrimary,
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildClaimCard(
//       BuildContext context,
//       String title,
//       String date,
//       String amount,
//       String status,
//       Color statusColor,
//       ) {
//     return Container(
//       margin: const EdgeInsets.only(bottom: 12),
//       padding: const EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         color: AppColors.backgroundGrey,
//         borderRadius: BorderRadius.circular(12),
//       ),
//       child: Row(
//         children: [
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   title,
//                   style: Theme.of(context).textTheme.titleMedium?.copyWith(
//                     fontWeight: FontWeight.w600,
//                     color: AppColors.textPrimary,
//                   ),
//                 ),
//                 const SizedBox(height: 4),
//                 Text(
//                   date,
//                   style: Theme.of(context).textTheme.bodySmall?.copyWith(
//                     color: AppColors.textSecondary,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//           Column(
//             crossAxisAlignment: CrossAxisAlignment.end,
//             children: [
//               Text(
//                 amount,
//                 style: Theme.of(context).textTheme.titleMedium?.copyWith(
//                   fontWeight: FontWeight.bold,
//                   color: AppColors.textPrimary,
//                 ),
//               ),
//               const SizedBox(height: 4),
//               Container(
//                 padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
//                 decoration: BoxDecoration(
//                   color: statusColor.withOpacity(0.1),
//                   borderRadius: BorderRadius.circular(6),
//                 ),
//                 child: Text(
//                   status,
//                   style: Theme.of(context).textTheme.bodySmall?.copyWith(
//                     color: statusColor,
//                     fontWeight: FontWeight.w600,
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ],
//       ),
//     );
//   }
// }
