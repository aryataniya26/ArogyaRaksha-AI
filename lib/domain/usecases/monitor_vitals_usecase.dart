import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class MonitorVitalsUseCase {
  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  MonitorVitalsUseCase({
    FirebaseAuth? auth,
    FirebaseFirestore? firestore,
  })  : _auth = auth ?? FirebaseAuth.instance,
        _firestore = firestore ?? FirebaseFirestore.instance;

  /// Save vitals data
  Future<void> saveVitals({
    required VitalsData vitals,
    String? userId,
  }) async {
    try {
      final currentUserId = userId ?? _auth.currentUser?.uid;
      if (currentUserId == null) throw Exception('User not logged in');

      await _firestore
          .collection('users')
          .doc(currentUserId)
          .collection('vitals')
          .add(vitals.toJson());
    } catch (e) {
      throw Exception('Failed to save vitals: $e');
    }
  }

  /// Get vitals history
  Future<List<VitalsData>> getVitalsHistory({
    String? userId,
    int limit = 30,
  }) async {
    try {
      final currentUserId = userId ?? _auth.currentUser?.uid;
      if (currentUserId == null) throw Exception('User not logged in');

      final snapshot = await _firestore
          .collection('users')
          .doc(currentUserId)
          .collection('vitals')
          .orderBy('timestamp', descending: true)
          .limit(limit)
          .get();

      return snapshot.docs
          .map((doc) => VitalsData.fromJson(doc.data()))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch vitals history: $e');
    }
  }

  /// Get latest vitals
  Future<VitalsData?> getLatestVitals({String? userId}) async {
    try {
      final history = await getVitalsHistory(userId: userId, limit: 1);
      return history.isNotEmpty ? history.first : null;
    } catch (e) {
      return null;
    }
  }

  /// Analyze vitals and detect anomalies
  Future<VitalsAnalysisResult> analyzeVitals({
    required VitalsData vitals,
    List<VitalsData>? history,
  }) async {
    List<String> warnings = [];
    List<String> critical = [];
    List<String> recommendations = [];

    // Blood Pressure Analysis
    if (vitals.systolic != null && vitals.diastolic != null) {
      final sys = vitals.systolic!;
      final dia = vitals.diastolic!;

      if (sys >= 180 || dia >= 120) {
        critical.add('CRITICAL: Hypertensive Crisis - Seek immediate medical attention');
      } else if (sys >= 140 || dia >= 90) {
        warnings.add('High Blood Pressure detected');
        recommendations.add('Monitor BP regularly and consult doctor');
      } else if (sys < 90 || dia < 60) {
        warnings.add('Low Blood Pressure detected');
        recommendations.add('Stay hydrated and avoid sudden movements');
      }
    }

    // Blood Sugar Analysis
    if (vitals.bloodSugar != null) {
      final sugar = vitals.bloodSugar!;

      if (sugar >= 300) {
        critical.add('CRITICAL: Very High Blood Sugar - Seek immediate medical help');
      } else if (sugar >= 200) {
        warnings.add('High Blood Sugar detected');
        recommendations.add('Check with doctor about diabetes management');
      } else if (sugar < 70) {
        warnings.add('Low Blood Sugar detected');
        recommendations.add('Consume glucose or sugary drink immediately');
      }
    }

    // Heart Rate Analysis
    if (vitals.heartRate != null) {
      final hr = vitals.heartRate!;

      if (hr > 120) {
        warnings.add('Elevated Heart Rate');
        recommendations.add('Rest and monitor. Consult doctor if persistent');
      } else if (hr < 50) {
        warnings.add('Low Heart Rate');
        recommendations.add('Consult doctor if accompanied by dizziness');
      }
    }

    // Oxygen Saturation Analysis
    if (vitals.oxygenSaturation != null) {
      final spo2 = vitals.oxygenSaturation!;

      if (spo2 < 90) {
        critical.add('CRITICAL: Low Oxygen Saturation - Seek immediate medical help');
      } else if (spo2 < 94) {
        warnings.add('Below normal Oxygen Saturation');
        recommendations.add('Monitor closely and consult doctor');
      }
    }

    // Temperature Analysis
    if (vitals.temperature != null) {
      final temp = vitals.temperature!;

      if (temp >= 103) {
        critical.add('CRITICAL: Very High Fever - Seek immediate medical attention');
      } else if (temp >= 100.4) {
        warnings.add('Fever detected');
        recommendations.add('Take fever medication and stay hydrated');
      } else if (temp < 95) {
        warnings.add('Low Body Temperature');
        recommendations.add('Warm up and monitor temperature');
      }
    }

    // Overall risk assessment
    String riskLevel;
    if (critical.isNotEmpty) {
      riskLevel = 'CRITICAL';
    } else if (warnings.length >= 3) {
      riskLevel = 'HIGH';
    } else if (warnings.isNotEmpty) {
      riskLevel = 'MODERATE';
    } else {
      riskLevel = 'NORMAL';
    }

    return VitalsAnalysisResult(
      riskLevel: riskLevel,
      warnings: warnings,
      critical: critical,
      recommendations: recommendations,
      timestamp: DateTime.now(),
    );
  }
}

/// Vitals Data Model
class VitalsData {
  final double? systolic;
  final double? diastolic;
  final double? bloodSugar;
  final int? heartRate;
  final double? oxygenSaturation;
  final double? temperature;
  final String? notes;
  final DateTime timestamp;

  VitalsData({
    this.systolic,
    this.diastolic,
    this.bloodSugar,
    this.heartRate,
    this.oxygenSaturation,
    this.temperature,
    this.notes,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  factory VitalsData.fromJson(Map<String, dynamic> json) {
    return VitalsData(
      systolic: json['systolic']?.toDouble(),
      diastolic: json['diastolic']?.toDouble(),
      bloodSugar: json['bloodSugar']?.toDouble(),
      heartRate: json['heartRate'],
      oxygenSaturation: json['oxygenSaturation']?.toDouble(),
      temperature: json['temperature']?.toDouble(),
      notes: json['notes'],
      timestamp: (json['timestamp'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'systolic': systolic,
      'diastolic': diastolic,
      'bloodSugar': bloodSugar,
      'heartRate': heartRate,
      'oxygenSaturation': oxygenSaturation,
      'temperature': temperature,
      'notes': notes,
      'timestamp': Timestamp.fromDate(timestamp),
    };
  }
}

/// Vitals Analysis Result
class VitalsAnalysisResult {
  final String riskLevel; // NORMAL, MODERATE, HIGH, CRITICAL
  final List<String> warnings;
  final List<String> critical;
  final List<String> recommendations;
  final DateTime timestamp;

  VitalsAnalysisResult({
    required this.riskLevel,
    required this.warnings,
    required this.critical,
    required this.recommendations,
    required this.timestamp,
  });

  bool get hasIssues => warnings.isNotEmpty || critical.isNotEmpty;
  bool get isCritical => critical.isNotEmpty;
}



// // monitor_vitals_usecase.dart
// import '../../data/repositories/vitals_repository.dart';
// import '../../data/models/vitals_model.dart';
//
// class MonitorVitalsUseCase {
//   final VitalsRepository _repository;
//
//   MonitorVitalsUseCase(this._repository);
//
//   /// Adds new vitals data
//   Future<void> addVitals(Map<String, dynamic> vitalsData) async {
//     try {
//       await _repository.addVitals(vitalsData);
//     } catch (e) {
//       rethrow;
//     }
//   }
//
//   /// Fetch history of vitals
//   Future<List<VitalsModel>> getHistory(String userId) async {
//     try {
//       return await _repository.getVitalsHistory(userId);
//     } catch (e) {
//       return [];
//     }
//   }
//
//   /// Fetch latest vitals
//   Future<VitalsModel?> getLatest(String userId) async {
//     try {
//       return await _repository.getLatestVitals(userId);
//     } catch (e) {
//       return null;
//     }
//   }
//
//   /// Analyze vitals
//   Future<Map<String, String>> analyzeVitals(VitalsModel vitals) async {
//     return {
//       'heart_rate': vitals.getHeartRateStatus(),
//       'blood_pressure': vitals.getBloodPressureStatus(),
//       'blood_sugar': vitals.getBloodSugarStatus(),
//       'oxygen_level': vitals.getOxygenLevelStatus(),
//       'temperature': vitals.getTemperatureStatus(),
//     };
//   }
//
//   /// Check if vitals indicate an emergency
//   Future<bool> isEmergency(VitalsModel vitals) async {
//     final analysis = await analyzeVitals(vitals);
//     return analysis.values.any((status) => status.toLowerCase() == 'critical');
//   }
// }
