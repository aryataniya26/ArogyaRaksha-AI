import 'package:flutter/material.dart';
import 'package:arogyaraksha_ai/core/constants/app_colors.dart';
import 'package:arogyaraksha_ai/presentation/widgets/custom_button.dart';
class DevicePairingScreen extends StatefulWidget {
  const DevicePairingScreen({super.key});

  @override
  State<DevicePairingScreen> createState() => _DevicePairingScreenState();
}

class _DevicePairingScreenState extends State<DevicePairingScreen> {
  bool _isScanning = false;
  bool _isPaired = false;
  List<Map<String, String>> _devices = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        title: const Text('Device Pairing'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
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
                    _isPaired ? Icons.bluetooth_connected : Icons.bluetooth,
                    size: 80,
                    color: AppColors.white,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    _isPaired ? 'Device Connected' : 'Pair Emergency Device',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: AppColors.white,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _isPaired
                        ? 'Your device is ready to use'
                        : 'Connect your wearable emergency button',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.white.withOpacity(0.9),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            if (!_isPaired) ...[
              CustomButton(
                text: _isScanning ? 'Scanning...' : 'Scan for Devices',
                onPressed: _startScanning,
                gradient: AppColors.primaryGradient,
                icon: Icons.search,
                isLoading: _isScanning,
              ),
              const SizedBox(height: 24),
              if (_devices.isNotEmpty) ...[
                Text(
                  'Available Devices',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                ..._devices.map((device) => _buildDeviceCard(device)),
              ],
            ] else ...[
              _buildDeviceInfo(),
              const SizedBox(height: 24),
              CustomButton(
                text: 'Disconnect Device',
                onPressed: () {
                  setState(() {
                    _isPaired = false;
                    _devices.clear();
                  });
                },
                backgroundColor: AppColors.alertRed,
                icon: Icons.bluetooth_disabled,
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _startScanning() {
    setState(() {
      _isScanning = true;
    });

    Future.delayed(const Duration(seconds: 2), () {
      setState(() {
        _isScanning = false;
        _devices = [
          {'name': 'ArogyaRaksha Button', 'id': 'AR-001', 'signal': 'Strong'},
          {'name': 'Emergency Locket', 'id': 'AR-002', 'signal': 'Medium'},
        ];
      });
    });
  }

  Widget _buildDeviceCard(Map<String, String> device) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
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
              gradient: AppColors.primaryGradient,
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(Icons.watch, color: AppColors.white, size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  device['name']!,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'ID: ${device['id']} • ${device['signal']} Signal',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _isPaired = true;
              });
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryTeal,
              foregroundColor: AppColors.white,
            ),
            child: const Text('Connect'),
          ),
        ],
      ),
    );
  }

  Widget _buildDeviceInfo() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          _buildInfoRow('Device Name', 'ArogyaRaksha Button'),
          const Divider(height: 24),
          _buildInfoRow('Device ID', 'AR-001'),
          const Divider(height: 24),
          _buildInfoRow('Battery', '85%'),
          const Divider(height: 24),
          _buildInfoRow('Signal Strength', 'Strong'),
          const Divider(height: 24),
          _buildInfoRow('Last Sync', 'Just now'),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        Text(
          value,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}