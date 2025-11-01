// vitals_model.dart
class VitalsModel {
  final int heartRate;       // bpm
  final String bloodPressure; // e.g., "120/80"
  final double bloodSugar;   // mg/dL
  final int oxygenLevel;     // SpO2 %
  final double temperature;  // Celsius

  VitalsModel({
    required this.heartRate,
    required this.bloodPressure,
    required this.bloodSugar,
    required this.oxygenLevel,
    required this.temperature,
  });

  /// Returns "Normal", "Warning", or "Critical" for heart rate
  String getHeartRateStatus() {
    if (heartRate < 50 || heartRate > 120) return 'Critical';
    if (heartRate < 60 || heartRate > 100) return 'Warning';
    return 'Normal';
  }

  /// Returns status for blood pressure
  String getBloodPressureStatus() {
    final parts = bloodPressure.split('/');
    if (parts.length != 2) return 'Critical';
    final systolic = int.tryParse(parts[0]) ?? 0;
    final diastolic = int.tryParse(parts[1]) ?? 0;

    if (systolic < 90 || systolic > 180 || diastolic < 60 || diastolic > 120) {
      return 'Critical';
    }
    if (systolic < 100 || systolic > 140 || diastolic < 70 || diastolic > 90) {
      return 'Warning';
    }
    return 'Normal';
  }

  /// Returns status for blood sugar
  String getBloodSugarStatus() {
    if (bloodSugar < 70 || bloodSugar > 200) return 'Critical';
    if (bloodSugar < 80 || bloodSugar > 140) return 'Warning';
    return 'Normal';
  }

  /// Returns status for oxygen level
  String getOxygenLevelStatus() {
    if (oxygenLevel < 85) return 'Critical';
    if (oxygenLevel < 95) return 'Warning';
    return 'Normal';
  }

  /// Returns status for temperature
  String getTemperatureStatus() {
    if (temperature < 35 || temperature > 40) return 'Critical';
    if (temperature < 36 || temperature > 38) return 'Warning';
    return 'Normal';
  }
}
