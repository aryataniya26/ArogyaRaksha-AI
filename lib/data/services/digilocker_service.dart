// data/services/digilocker_service.dart
import 'package:dio/dio.dart';
import '../../core/constants/api_endpoints.dart';

class DigiLockerService {
  static final Dio _dio = Dio();

  static Future<String?> authenticate() async {
    // OAuth 2.0 authentication flow
    try {
      final response = await _dio.post(
        ApiEndpoints.digiLockerAuth,
        data: {
          'client_id': 'YOUR_CLIENT_ID',
          'response_type': 'code',
          'redirect_uri': 'YOUR_REDIRECT_URI',
        },
      );
      return response.data['auth_code'];
    } catch (e) {
      print('DigiLocker auth error: $e');
      return null;
    }
  }

  static Future<Map<String, dynamic>?> fetchDocuments(String authToken) async {
    try {
      final response = await _dio.get(
        ApiEndpoints.digiLockerDocuments,
        options: Options(
          headers: {'Authorization': 'Bearer $authToken'},
        ),
      );
      return response.data;
    } catch (e) {
      print('DigiLocker fetch error: $e');
      return null;
    }
  }

  static Future<Map<String, dynamic>?> getProfile(String authToken) async {
    try {
      final response = await _dio.get(
        ApiEndpoints.digiLockerProfile,
        options: Options(
          headers: {'Authorization': 'Bearer $authToken'},
        ),
      );
      return response.data;
    } catch (e) {
      print('DigiLocker profile error: $e');
      return null;
    }
  }
}