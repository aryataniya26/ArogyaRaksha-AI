// ambulance_repository.dart
import '../models/ambulance_model.dart';
import 'package:arogyaraksha_ai/data/services/api_service.dart';

class AmbulanceRepository {
  Future<List<AmbulanceModel>> getNearestAmbulances(double lat, double lng) async {
    final response = await ApiService.get('/ambulance/nearest', queryParameters: {
      'latitude': lat,
      'longitude': lng,
    });
    return (response.data as List).map((e) => AmbulanceModel.fromJson(e)).toList();
  }

  Future<AmbulanceModel> trackAmbulance(String ambulanceId) async {
    final response = await ApiService.get('/ambulance/track/$ambulanceId');
    return AmbulanceModel.fromJson(response.data);
  }
}