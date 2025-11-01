import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/routes/app_routes.dart';
import '../../../domain/usecases/monitor_vitals_usecase.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';
import 'package:url_launcher/url_launcher.dart';


class AiHealthAlertsScreen extends StatefulWidget {
  const AiHealthAlertsScreen({super.key});

  @override
  State<AiHealthAlertsScreen> createState() => _AiHealthAlertsScreenState();
}

class _AiHealthAlertsScreenState extends State<AiHealthAlertsScreen> {
  final MonitorVitalsUseCase _monitorVitalsUseCase = MonitorVitalsUseCase();

  final _systolicController = TextEditingController();
  final _diastolicController = TextEditingController();
  final _bloodSugarController = TextEditingController();
  final _heartRateController = TextEditingController();
  final _oxygenController = TextEditingController();
  final _temperatureController = TextEditingController();
  final _notesController = TextEditingController();

  bool _isLoading = false;
  bool _isAnalyzing = false;
  VitalsAnalysisResult? _analysisResult;
  List<VitalsData> _vitalsHistory = [];

  @override
  void initState() {
    super.initState();
    _loadVitalsHistory();
  }

  Future<void> _loadVitalsHistory() async {
    setState(() => _isLoading = true);
    try {
      final history = await _monitorVitalsUseCase.getVitalsHistory(limit: 7);
      if (mounted) {
        setState(() {
          _vitalsHistory = history;
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error loading vitals history: $e');
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _saveAndAnalyze() async {
    if (!_validateInput()) return;

    setState(() => _isAnalyzing = true);

    try {
      final vitals = VitalsData(
        systolic: double.tryParse(_systolicController.text),
        diastolic: double.tryParse(_diastolicController.text),
        bloodSugar: double.tryParse(_bloodSugarController.text),
        heartRate: int.tryParse(_heartRateController.text),
        oxygenSaturation: double.tryParse(_oxygenController.text),
        temperature: double.tryParse(_temperatureController.text),
        notes: _notesController.text.trim().isNotEmpty
            ? _notesController.text.trim()
            : null,
      );

      // Save vitals
      await _monitorVitalsUseCase.saveVitals(vitals: vitals);

      // Analyze vitals
      final analysis = await _monitorVitalsUseCase.analyzeVitals(
        vitals: vitals,
        history: _vitalsHistory,
      );

      if (mounted) {
        setState(() {
          _analysisResult = analysis;
          _isAnalyzing = false;
        });

        // Show analysis dialog
        _showAnalysisDialog();

        // Reload history
        _loadVitalsHistory();

        // Clear form
        _clearForm();
      }
    } catch (e) {
      print('Error analyzing vitals: $e');
      if (mounted) {
        setState(() => _isAnalyzing = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  bool _validateInput() {
    if (_systolicController.text.isEmpty &&
        _diastolicController.text.isEmpty &&
        _bloodSugarController.text.isEmpty &&
        _heartRateController.text.isEmpty &&
        _oxygenController.text.isEmpty &&
        _temperatureController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter at least one vital measurement'),
        ),
      );
      return false;
    }
    return true;
  }

  void _clearForm() {
    _systolicController.clear();
    _diastolicController.clear();
    _bloodSugarController.clear();
    _heartRateController.clear();
    _oxygenController.clear();
    _temperatureController.clear();
    _notesController.clear();
  }

  void _showAnalysisDialog() {
    if (_analysisResult == null) return;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(
              _analysisResult!.isCritical ? Icons.warning : Icons.info_outline,
              color: _getRiskLevelColor(_analysisResult!.riskLevel),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text('Risk Level: ${_analysisResult!.riskLevel}'),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (_analysisResult!.critical.isNotEmpty) ...[
                const Text(
                  '🚨 Critical Alerts:',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppColors.alertRed,
                  ),
                ),
                const SizedBox(height: 8),
                ..._analysisResult!.critical.map((msg) => Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Text(
                    '• $msg',
                    style: const TextStyle(color: AppColors.alertRed),
                  ),
                )),
                const SizedBox(height: 16),
              ],
              if (_analysisResult!.warnings.isNotEmpty) ...[
                const Text(
                  '⚠️ Warnings:',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.orange,
                  ),
                ),
                const SizedBox(height: 8),
                ..._analysisResult!.warnings.map((msg) => Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Text('• $msg'),
                )),
                const SizedBox(height: 16),
              ],
              if (_analysisResult!.recommendations.isNotEmpty) ...[
                const Text(
                  '💡 Recommendations:',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryTeal,
                  ),
                ),
                const SizedBox(height: 8),
                ..._analysisResult!.recommendations.map((msg) => Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Text('• $msg'),
                )),
              ],
              if (!_analysisResult!.hasIssues) ...[
                const Text(
                  '✅ All vitals are within normal range!',
                  style: TextStyle(
                    color: AppColors.successGreen,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ],
          ),
        ),
        actions: [
          if (_analysisResult!.isCritical)
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, AppRoutes.emergencyConfirmation);
              },
              child: const Text(
                'TRIGGER EMERGENCY',
                style: TextStyle(color: AppColors.alertRed),
              ),
            ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  Color _getRiskLevelColor(String riskLevel) {
    switch (riskLevel) {
      case 'CRITICAL':
        return AppColors.alertRed;
      case 'HIGH':
        return Colors.orange;
      case 'MODERATE':
        return Colors.yellow[700]!;
      default:
        return AppColors.successGreen;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        title: const Text('AI Health Alerts'),
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () {
              // TODO: Show full vitals history
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Full history coming soon')),
              );
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        child: Column(
          children: [
            _buildAIBanner(),
            const SizedBox(height: 16),
            _buildVitalsForm(),
            const SizedBox(height: 16),
            if (_vitalsHistory.isNotEmpty) _buildRecentReadings(),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildAIBanner() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF667eea), Color(0xFF764ba2)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.purple.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.psychology, color: Colors.white, size: 32),
          ),
          const SizedBox(width: 16),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'AI Health Monitoring',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Get instant AI-powered analysis of your vitals',
                  style: TextStyle(color: Colors.white70, fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVitalsForm() {
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
          const Text(
            'Enter Your Vitals',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),

          Row(
            children: [
              Expanded(
                child: CustomTextField(
                  controller: _systolicController,
                  label: 'Systolic (BP)',
                  hint: '120',
                  keyboardType: TextInputType.number,
                  prefixIcon: Icons.favorite,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: CustomTextField(
                  controller: _diastolicController,
                  label: 'Diastolic (BP)',
                  hint: '80',
                  keyboardType: TextInputType.number,
                  prefixIcon: Icons.favorite_border,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          Row(
            children: [
              Expanded(
                child: CustomTextField(
                  controller: _bloodSugarController,
                  label: 'Blood Sugar',
                  hint: '100 mg/dL',
                  keyboardType: TextInputType.number,
                  prefixIcon: Icons.bloodtype,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: CustomTextField(
                  controller: _heartRateController,
                  label: 'Heart Rate',
                  hint: '72 bpm',
                  keyboardType: TextInputType.number,
                  prefixIcon: Icons.monitor_heart,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          Row(
            children: [
              Expanded(
                child: CustomTextField(
                  controller: _oxygenController,
                  label: 'SpO2 (%)',
                  hint: '98',
                  keyboardType: TextInputType.number,
                  prefixIcon: Icons.air,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: CustomTextField(
                  controller: _temperatureController,
                  label: 'Temperature',
                  hint: '98.6 °F',
                  keyboardType: TextInputType.number,
                  prefixIcon: Icons.thermostat,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          CustomTextField(
            controller: _notesController,
            label: 'Notes (Optional)',
            hint: 'Any symptoms or observations...',
            maxLines: 2,
            prefixIcon: Icons.note_outlined,
          ),
          const SizedBox(height: 24),

          ElevatedButton(
            onPressed: _isAnalyzing ? null : () => _saveAndAnalyze(),
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(double.infinity, 50),
              backgroundColor: const Color(0xFF667eea),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: _isAnalyzing
                ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                color: Colors.white,
                strokeWidth: 2,
              ),
            )
                : const Text(
              'Analyze with AI',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),

          // CustomButton(
          //   text: 'Analyze with AI',
          //   onPressed: _isAnalyzing ? null : () => _saveAndAnalyze(),
          //   isLoading: _isAnalyzing,
          //   gradient: const LinearGradient(
          //     colors: [Color(0xFF667eea), Color(0xFF764ba2)],
          //   ),
          // ),
        ],
      ),
    );
  }

  Widget _buildRecentReadings() {
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
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Recent Readings',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              TextButton(
                onPressed: () {
                  // TODO: View all history
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Full history coming soon')),
                  );
                },
                child: const Text('View All'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ..._vitalsHistory.take(3).map((vitals) => _buildVitalsHistoryCard(vitals)),
        ],
      ),
    );
  }

  Widget _buildVitalsHistoryCard(VitalsData vitals) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.backgroundLight,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.backgroundGrey),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _formatDate(vitals.timestamp),
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                _formatTime(vitals.timestamp),
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 12,
            runSpacing: 8,
            children: [
              if (vitals.systolic != null && vitals.diastolic != null)
                _buildVitalChip('BP', '${vitals.systolic}/${vitals.diastolic}', Icons.favorite),
              if (vitals.bloodSugar != null)
                _buildVitalChip('Sugar', '${vitals.bloodSugar}', Icons.bloodtype),
              if (vitals.heartRate != null)
                _buildVitalChip('HR', '${vitals.heartRate}', Icons.monitor_heart),
              if (vitals.oxygenSaturation != null)
                _buildVitalChip('SpO2', '${vitals.oxygenSaturation}%', Icons.air),
              if (vitals.temperature != null)
                _buildVitalChip('Temp', '${vitals.temperature}°F', Icons.thermostat),
            ],
          ),
          if (vitals.notes != null && vitals.notes!.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              vitals.notes!,
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildVitalChip(String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.primaryTeal.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: AppColors.primaryTeal),
          const SizedBox(width: 4),
          Text(
            '$label: $value',
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.primaryTeal,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  String _formatTime(DateTime date) {
    final hour = date.hour > 12 ? date.hour - 12 : (date.hour == 0 ? 12 : date.hour);
    final period = date.hour >= 12 ? 'PM' : 'AM';
    return '${hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')} $period';
  }

  @override
  void dispose() {
    _systolicController.dispose();
    _diastolicController.dispose();
    _bloodSugarController.dispose();
    _heartRateController.dispose();
    _oxygenController.dispose();
    _temperatureController.dispose();
    _notesController.dispose();
    super.dispose();
  }
}

// import 'package:flutter/material.dart';
// import 'package:arogyaraksha_ai/core/constants/app_colors.dart';
// import 'package:arogyaraksha_ai/presentation/widgets/custom_button.dart';
// import 'package:flutter/material.dart';
//
// class AIHealthAlertsScreen extends StatelessWidget {
//   const AIHealthAlertsScreen({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: AppColors.backgroundLight,
//       appBar: AppBar(
//         title: const Text('AI Health Alerts'),
//       ),
//       body: SingleChildScrollView(
//         child: Column(
//           children: [
//             // AI Prediction Engine Stats
//             Container(
//               margin: const EdgeInsets.all(16),
//               padding: const EdgeInsets.all(20),
//               decoration: BoxDecoration(
//                 gradient: AppColors.blueGradient,
//                 borderRadius: BorderRadius.circular(16),
//                 boxShadow: [
//                   BoxShadow(
//                     color: AppColors.primaryTeal.withOpacity(0.3),
//                     blurRadius: 15,
//                     offset: const Offset(0, 8),
//                   ),
//                 ],
//               ),
//               child: Column(
//                 children: [
//                   const Icon(
//                     Icons.psychology_outlined,
//                     size: 48,
//                     color: AppColors.white,
//                   ),
//                   const SizedBox(height: 12),
//                   Text(
//                     'AI Health Prediction Engine',
//                     style: Theme.of(context).textTheme.titleLarge?.copyWith(
//                       color: AppColors.white,
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                   const SizedBox(height: 8),
//                   Text(
//                     'Smart health emergency response system',
//                     style: Theme.of(context).textTheme.bodyMedium?.copyWith(
//                       color: AppColors.white.withOpacity(0.9),
//                     ),
//                     textAlign: TextAlign.center,
//                   ),
//                   const SizedBox(height: 20),
//                   Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceAround,
//                     children: [
//                       _buildStatItem(context, '7', 'Active\nPrediction'),
//                       _buildStatItem(context, '2', 'Critical Alert'),
//                       _buildStatItem(context, '94%', 'Accuracy\nRate'),
//                     ],
//                   ),
//                 ],
//               ),
//             ),
//
//             const SizedBox(height: 8),
//
//             // Alert Cards
//             _buildAlertCard(
//               context,
//               'Rajesh kumar',
//               'CRITICAL',
//               'Cardiac event risk',
//               {
//                 'Heart rate': '50',
//                 'BP (mmHg)': '87%',
//                 'Blood sugar\n(100mg/dl)': 'Detected'
//               },
//               {'Tachycardia': '12 Sat 05%', 'O2 Sat 05%': 'Detected', 'GEDR': ''},
//               AppColors.alertRed,
//             ),
//
//             _buildAlertCard(
//               context,
//               'Rajesh kumar',
//               'High risk',
//               'Cardiac event risk',
//               {
//                 'Heart rate': '50',
//                 'BP (mmHg)': '87%',
//                 'Blood sugar\n(100mg/dl)': 'Detected'
//               },
//               {'Tachycardia': '12 Sat 05%', 'O2 Sat 05%': 'Detected', 'GEDR': ''},
//               AppColors.warningOrange,
//             ),
//
//             _buildAlertCard(
//               context,
//               'Rajesh kumar',
//               'Low risk',
//               'Cardiac event risk',
//               {
//                 'Heart rate': '50',
//                 'BP (mmHg)': '87%',
//                 'Blood sugar\n(100mg/dl)': 'Detected'
//               },
//               {'Tachycardia': '12 Sat 05%', 'O2 Sat 05%': 'Detected', 'GEDR': ''},
//               AppColors.successGreen,
//             ),
//
//             _buildAlertCard(
//               context,
//               'Rajesh kumar',
//               'CRITICAL',
//               'Cardiac event risk',
//               {
//                 'Heart rate': '50',
//                 'BP (mmHg)': '87%',
//                 'Blood sugar\n(100mg/dl)': 'Detected'
//               },
//               {'Tachycardia': '12 Sat 05%', 'O2 Sat 05%': 'Detected', 'GEDR': ''},
//               AppColors.alertRed,
//             ),
//
//             const SizedBox(height: 24),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget _buildStatItem(BuildContext context, String value, String label) {
//     return Column(
//       children: [
//         Text(
//           value,
//           style: Theme.of(context).textTheme.displaySmall?.copyWith(
//             color: AppColors.white,
//             fontWeight: FontWeight.bold,
//           ),
//         ),
//         const SizedBox(height: 4),
//         Text(
//           label,
//           style: Theme.of(context).textTheme.bodySmall?.copyWith(
//             color: AppColors.white.withOpacity(0.9),
//           ),
//           textAlign: TextAlign.center,
//         ),
//       ],
//     );
//   }
//
//   Widget _buildAlertCard(
//       BuildContext context,
//       String patientName,
//       String riskLevel,
//       String condition,
//       Map<String, String> vitals,
//       Map<String, String> symptoms,
//       Color statusColor,
//       ) {
//     return Container(
//       margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//       padding: const EdgeInsets.all(20),
//       decoration: BoxDecoration(
//         color: AppColors.white,
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
//           // Header
//           Row(
//             children: [
//               Expanded(
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(
//                       patientName,
//                       style: Theme.of(context).textTheme.titleLarge?.copyWith(
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                     const SizedBox(height: 4),
//                     Text(
//                       '45 years • Male',
//                       style: Theme.of(context).textTheme.bodySmall?.copyWith(
//                         color: AppColors.textSecondary,
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//               Container(
//                 padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
//                 decoration: BoxDecoration(
//                   color: statusColor.withOpacity(0.1),
//                   borderRadius: BorderRadius.circular(8),
//                 ),
//                 child: Text(
//                   riskLevel,
//                   style: Theme.of(context).textTheme.bodySmall?.copyWith(
//                     color: statusColor,
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//               ),
//             ],
//           ),
//
//           const SizedBox(height: 16),
//
//           // Alert Tag
//           Row(
//             children: [
//               Container(
//                 padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
//                 decoration: BoxDecoration(
//                   color: AppColors.alertRed,
//                   borderRadius: BorderRadius.circular(6),
//                 ),
//                 child: Text(
//                   'Alert Team',
//                   style: Theme.of(context).textTheme.bodySmall?.copyWith(
//                     color: AppColors.white,
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//               ),
//               const SizedBox(width: 8),
//               Container(
//                 padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
//                 decoration: BoxDecoration(
//                   color: AppColors.secondaryBlue,
//                   borderRadius: BorderRadius.circular(6),
//                 ),
//                 child: Text(
//                   'View Details',
//                   style: Theme.of(context).textTheme.bodySmall?.copyWith(
//                     color: AppColors.white,
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//               ),
//             ],
//           ),
//
//           const SizedBox(height: 16),
//
//           // Condition
//           Text(
//             condition,
//             style: Theme.of(context).textTheme.titleMedium?.copyWith(
//               fontWeight: FontWeight.w600,
//             ),
//           ),
//
//           const SizedBox(height: 16),
//
//           // Vitals
//           Container(
//             padding: const EdgeInsets.all(12),
//             decoration: BoxDecoration(
//               color: AppColors.backgroundLight,
//               borderRadius: BorderRadius.circular(12),
//             ),
//             child: Row(
//               mainAxisAlignment: MainAxisAlignment.spaceAround,
//               children: vitals.entries.map((entry) {
//                 return Column(
//                   children: [
//                     Text(
//                       entry.key,
//                       style: Theme.of(context).textTheme.bodySmall?.copyWith(
//                         color: AppColors.textSecondary,
//                       ),
//                       textAlign: TextAlign.center,
//                     ),
//                     const SizedBox(height: 4),
//                     Text(
//                       entry.value,
//                       style: Theme.of(context).textTheme.titleMedium?.copyWith(
//                         fontWeight: FontWeight.bold,
//                         color: statusColor,
//                       ),
//                     ),
//                   ],
//                 );
//               }).toList(),
//             ),
//           ),
//
//           const SizedBox(height: 16),
//
//           // Symptoms
//           Wrap(
//             spacing: 8,
//             runSpacing: 8,
//             children: [
//               _buildSymptomChip(context, 'Tachycardia'),
//               _buildSymptomChip(context, '12 Sat 05%'),
//               _buildSymptomChip(context, 'O2 Sat 05%'),
//               _buildSymptomChip(context, 'Detected'),
//               _buildSymptomChip(context, 'GEDR'),
//             ],
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildSymptomChip(BuildContext context, String label) {
//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
//       decoration: BoxDecoration(
//         color: AppColors.accentLightBlue.withOpacity(0.1),
//         borderRadius: BorderRadius.circular(8),
//       ),
//       child: Text(
//         label,
//         style: Theme.of(context).textTheme.bodySmall?.copyWith(
//           color: AppColors.accentLightBlue,
//           fontWeight: FontWeight.w500,
//         ),
//       ),
//     );
//   }
// }