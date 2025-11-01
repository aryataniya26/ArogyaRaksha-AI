// vitals_repository.dart
import '../models/vitals_model.dart';

class VitalsRepository {
  final List<VitalsModel> _vitalsHistory = [];

  /// Add new vitals data
  Future<void> addVitals(Map<String, dynamic> vitalsData) async {
    final vitals = VitalsModel(
      heartRate: vitalsData['heartRate'],
      bloodPressure: vitalsData['bloodPressure'],
      bloodSugar: vitalsData['bloodSugar'],
      oxygenLevel: vitalsData['oxygenLevel'],
      temperature: vitalsData['temperature'],
    );
    _vitalsHistory.add(vitals);
  }

  /// Fetch all vitals history
  Future<List<VitalsModel>> getVitalsHistory(String userId) async {
    return _vitalsHistory;
  }

  /// Fetch latest vitals
  Future<VitalsModel?> getLatestVitals(String userId) async {
    if (_vitalsHistory.isEmpty) return null;
    return _vitalsHistory.last;
  }
}
