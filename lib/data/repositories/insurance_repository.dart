// insurance_repository.dart
import '../services/api_service.dart';
import 'package:arogyaraksha_ai/data/services/api_service.dart';
import 'package:arogyaraksha_ai/data/models/insurance_model.dart';
class InsuranceRepository {
  Future<InsuranceModel> verifyInsurance(String policyNumber) async {
    final response = await ApiService.post('/insurance/verify', data: {
      'policy_number': policyNumber,
    });
    return InsuranceModel.fromJson(response.data);
  }

  Future<InsuranceModel> getInsuranceDetails(String userId) async {
    final response = await ApiService.get('/insurance/details/$userId');
    return InsuranceModel.fromJson(response.data);
  }
}
