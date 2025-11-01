import 'package:flutter/material.dart';
import '../../data/repositories/auth_repository.dart';
import '../../data/models/user_model.dart';

// settings_viewmodel.dart
class SettingsViewModel extends ChangeNotifier {
  bool _emergencyAlerts = true;
  bool _healthReminders = true;
  bool _biometricAuth = false;

  bool get emergencyAlerts => _emergencyAlerts;
  bool get healthReminders => _healthReminders;
  bool get biometricAuth => _biometricAuth;

  void toggleEmergencyAlerts(bool value) {
    _emergencyAlerts = value;
    notifyListeners();
  }

  void toggleHealthReminders(bool value) {
    _healthReminders = value;
    notifyListeners();
  }

  void toggleBiometricAuth(bool value) {
    _biometricAuth = value;
    notifyListeners();
  }
}