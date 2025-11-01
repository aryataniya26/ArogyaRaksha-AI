import 'package:flutter/material.dart';
import 'package:arogyaraksha_ai/core/constants/app_colors.dart';

class VitalsMonitoringScreen extends StatelessWidget {
  const VitalsMonitoringScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        title: const Text('Health Vitals'),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.history),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Today's Summary
            Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primaryTeal.withOpacity(0.3),
                    blurRadius: 15,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.favorite,
                        color: AppColors.white,
                        size: 28,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'Today\'s Health Status',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: AppColors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildStatusItem(context, 'Normal', '4'),
                      Container(
                        width: 1,
                        height: 40,
                        color: AppColors.white.withOpacity(0.3),
                      ),
                      _buildStatusItem(context, 'Warning', '1'),
                      Container(
                        width: 1,
                        height: 40,
                        color: AppColors.white.withOpacity(0.3),
                      ),
                      _buildStatusItem(context, 'Critical', '0'),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 8),

            // Vitals Cards
            _buildVitalCard(
              context,
              'Heart Rate',
              '72',
              'bpm',
              Icons.favorite_outlined,
              AppColors.alertRed,
              'Normal',
              AppColors.successGreen,
              60,
              100,
            ),

            _buildVitalCard(
              context,
              'Blood Pressure',
              '120/80',
              'mmHg',
              Icons.bloodtype_outlined,
              AppColors.secondaryBlue,
              'Normal',
              AppColors.successGreen,
              90,
              140,
            ),

            _buildVitalCard(
              context,
              'Blood Sugar',
              '95',
              'mg/dL',
              Icons.water_drop_outlined,
              AppColors.warningOrange,
              'Normal',
              AppColors.successGreen,
              70,
              100,
            ),

            _buildVitalCard(
              context,
              'Oxygen Level',
              '98',
              '%',
              Icons.air_outlined,
              AppColors.accentLightBlue,
              'Normal',
              AppColors.successGreen,
              95,
              100,
            ),

            _buildVitalCard(
              context,
              'Body Temperature',
              '36.8',
              '°C',
              Icons.thermostat_outlined,
              AppColors.warningAmber,
              'Normal',
              AppColors.successGreen,
              36,
              37,
            ),

            _buildVitalCard(
              context,
              'Weight',
              '68',
              'kg',
              Icons.monitor_weight_outlined,
              AppColors.primaryTeal,
              'Stable',
              AppColors.successGreen,
              65,
              70,
            ),

            const SizedBox(height: 24),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {},
        icon: const Icon(Icons.add),
        label: const Text('Add Reading'),
        backgroundColor: AppColors.primaryTeal,
      ),
    );
  }

  Widget _buildStatusItem(BuildContext context, String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            color: AppColors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: AppColors.white.withOpacity(0.9),
          ),
        ),
      ],
    );
  }

  Widget _buildVitalCard(
      BuildContext context,
      String title,
      String value,
      String unit,
      IconData icon,
      Color iconColor,
      String status,
      Color statusColor,
      double minRange,
      double maxRange,
      ) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.white,
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
        children: [
          Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  icon,
                  color: iconColor,
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          value,
                          style: Theme.of(context)
                              .textTheme
                              .headlineSmall
                              ?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Padding(
                          padding: const EdgeInsets.only(bottom: 4),
                          child: Text(
                            unit,
                            style:
                            Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  status,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: statusColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Range Indicator
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Normal Range: $minRange - $maxRange $unit',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  Text(
                    'Updated: Just now',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.textLight,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: 0.7,
                  minHeight: 8,
                  backgroundColor: AppColors.backgroundGrey,
                  valueColor: AlwaysStoppedAnimation<Color>(statusColor),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}