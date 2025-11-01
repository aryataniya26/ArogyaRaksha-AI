import 'package:flutter/material.dart';
import 'package:arogyaraksha_ai/core/constants/app_colors.dart';
import 'package:arogyaraksha_ai/presentation/widgets/custom_button.dart';

class DeviceStatusScreen extends StatelessWidget {
  const DeviceStatusScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        title: const Text('Device Status'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildStatusCard(
            context,
            'Battery Level',
            '85%',
            Icons.battery_charging_full,
            AppColors.successGreen,
            'Good',
          ),
          _buildStatusCard(
            context,
            'Signal Strength',
            'Strong',
            Icons.signal_cellular_alt,
            AppColors.successGreen,
            'Connected',
          ),
          _buildStatusCard(
            context,
            'Bluetooth',
            'Active',
            Icons.bluetooth_connected,
            AppColors.primaryTeal,
            'Paired',
          ),
          _buildStatusCard(
            context,
            'GSM Module',
            'Online',
            Icons.cell_tower,
            AppColors.successGreen,
            'Ready',
          ),
          _buildStatusCard(
            context,
            'Last Activity',
            '2 mins ago',
            Icons.history,
            AppColors.textSecondary,
            'Recent',
          ),
          const SizedBox(height: 16),
          CustomButton(
            text: 'Test Emergency Button',
            onPressed: () {},
            gradient: AppColors.emergencyGradient,
            icon: Icons.notifications_active,
          ),
        ],
      ),
    );
  }

  Widget _buildStatusCard(
      BuildContext context,
      String title,
      String value,
      IconData icon,
      Color color,
      String status,
      ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
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
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              status,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: color,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}