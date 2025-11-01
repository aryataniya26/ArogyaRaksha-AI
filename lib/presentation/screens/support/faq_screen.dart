import 'package:flutter/material.dart';
import 'package:arogyaraksha_ai/core/constants/app_colors.dart';


class FaqScreen extends StatelessWidget {
  const FaqScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        title: const Text('FAQ & Help'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildFaqItem(
            context,
            'How do I trigger an emergency?',
            'Press the red SOS button on the home screen or use the physical emergency device. You can also use voice command "Emergency! Help!"',
            Icons.emergency_outlined,
          ),
          _buildFaqItem(
            context,
            'What if I don\'t have internet?',
            'The app has offline mode with SMS backup. Emergency alerts will be sent via SMS to 108 and registered contacts.',
            Icons.signal_wifi_off,
          ),
          _buildFaqItem(
            context,
            'How does insurance validation work?',
            'We integrate with DigiLocker, Ayushman Bharat, and private insurers to verify your coverage in real-time before hospital arrival.',
            Icons.verified_user_outlined,
          ),
          _buildFaqItem(
            context,
            'Can I use the app in regional languages?',
            'Yes! The app supports Telugu, Hindi, and English. Change language in Settings.',
            Icons.language_outlined,
          ),
          _buildFaqItem(
            context,
            'How do I pair the physical device?',
            'Go to Settings → Device Pairing. Turn on Bluetooth and follow on-screen instructions to pair your wearable emergency button.',
            Icons.bluetooth_outlined,
          ),
          _buildFaqItem(
            context,
            'What vitals can I monitor?',
            'Track Heart Rate, Blood Pressure, Blood Sugar, Oxygen Level, Temperature, and Weight. AI analyzes data for predictive alerts.',
            Icons.favorite_outlined,
          ),
          _buildFaqItem(
            context,
            'How to request blood?',
            'Go to Blood Request screen, select your blood group, and tap Request. Nearby donors and blood banks will be notified.',
            Icons.bloodtype_outlined,
          ),
          _buildFaqItem(
            context,
            'Is my data secure?',
            'Yes! All data is encrypted and stored securely. We comply with government health data privacy standards.',
            Icons.security_outlined,
          ),
        ],
      ),
    );
  }

  Widget _buildFaqItem(
      BuildContext context,
      String question,
      String answer,
      IconData icon,
      ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          leading: Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              gradient: AppColors.primaryGradient,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: AppColors.white),
          ),
          title: Text(
            question,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Text(
                answer,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondary,
                  height: 1.5,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}