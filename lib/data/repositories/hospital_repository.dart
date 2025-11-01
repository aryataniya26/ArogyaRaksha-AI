import '../models/hospital_model.dart';
import 'package:arogyaraksha_ai/data/services/api_service.dart';

class HospitalRepository {
Future<List<HospitalModel>> getNearestHospitals(double lat, double lng) async {
final response = await ApiService.get('/hospitals/nearest', queryParameters: {
'latitude': lat,
'longitude': lng,
});
return (response.data as List).map((e) => HospitalModel.fromJson(e)).toList();
}

Future<void> sendPatientData(String hospitalId, Map<String, dynamic> data) async {
await ApiService.post('/hospitals/$hospitalId/patient-data', data: data);
}
}