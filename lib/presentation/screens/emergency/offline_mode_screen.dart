// screens/emergency/offline_mode_screen.dart
import 'package:flutter/material.dart';
import 'package:arogyaraksha_ai/core/constants/app_colors.dart';

class OfflineModeScreen extends StatelessWidget {
  const OfflineModeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        title: const Text('Offline Mode'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                children: [
                  Icon(
                    Icons.signal_wifi_off,
                    size: 80,
                    color: AppColors.cardBackground,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Offline Emergency Mode',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: AppColors.cardBackground,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Emergency alert will be sent via SMS',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: AppColors.cardBackground.withOpacity(0.9),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            _buildFeatureCard(
              context,
              Icons.sms_outlined,
              'SMS Alert',
              'Emergency SMS sent to registered contacts and 108',
            ),
            const SizedBox(height: 16),
            _buildFeatureCard(
              context,
              Icons.location_on_outlined,
              'Location Sharing',
              'Your last known GPS location will be shared',
            ),
            const SizedBox(height: 16),
            _buildFeatureCard(
              context,
              Icons.medical_information_outlined,
              'Medical Info',
              'Cached medical details and insurance info included',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureCard(
      BuildContext context,
      IconData icon,
      String title,
      String description,
      ) {
    return Container(
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
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              gradient: AppColors.primaryGradient,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: AppColors.cardBackground, size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}