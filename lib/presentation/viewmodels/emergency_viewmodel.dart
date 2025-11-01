import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../data/repositories/emergency_repository.dart';
import '../../data/models/emergency_model.dart';
import '../../data/models/user_model.dart';
import '../../data/services/location_service.dart';
import '../../data/services/sms_service.dart';

class EmergencyViewModel extends ChangeNotifier {
  final EmergencyRepository _emergencyRepository = EmergencyRepository();
  final LocationService _locationService = LocationService();
  final SmsService _smsService = SmsService();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  EmergencyModel? _currentEmergency;
  List<EmergencyModel> _emergencyHistory = [];
  bool _isLoading = false;
  String? _errorMessage;

  // Getters
  EmergencyModel? get currentEmergency => _currentEmergency;
  List<EmergencyModel> get emergencyHistory => _emergencyHistory;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // Trigger Emergency
  Future<String?> triggerEmergency({
    String emergencyType = 'general',
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Get current user
      final userId = _auth.currentUser?.uid;
      if (userId == null) {
        throw Exception('User not logged in');
      }

      // Get user data
      final userDoc = await _firestore.collection('users').doc(userId).get();
      if (!userDoc.exists) {
        throw Exception('User data not found');
      }

      final userData = UserModel.fromJson(userDoc.data()!);

      // Get current location
      final location = await _locationService.getCurrentLocation();
      if (location == null) {
        throw Exception('Could not get location. Please enable location services.');
      }

      // Create emergency model
      final emergency = EmergencyModel(
        id: '',
        userId: userId,
        userName: userData.name,
        userPhone: userData.phone,
        userBloodGroup: userData.bloodGroup.isNotEmpty ? userData.bloodGroup : null,
        location: location,
        status: EmergencyStatus.triggered,
        emergencyType: emergencyType,
        triggeredAt: DateTime.now(),
        medicalInfo: {
          'allergies': userData.medicalInfo.allergies,
          'conditions': userData.medicalInfo.conditions,
          'medications': userData.medicalInfo.medications,
          'chronicDiseases': userData.medicalInfo.chronicDiseases,
        },
      );

      // Save to Firebase
      final emergencyId = await _emergencyRepository.createEmergency(emergency);

      // Update status to locating
      await _emergencyRepository.updateEmergencyStatus(
        emergencyId: emergencyId,
        status: EmergencyStatus.locating,
      );

      // Update status to notifying
      await _emergencyRepository.updateEmergencyStatus(
        emergencyId: emergencyId,
        status: EmergencyStatus.notifying,
      );

      // Send SMS to emergency contacts
      List<String> notifiedContacts = [];
      if (userData.emergencyContacts.isNotEmpty) {
        notifiedContacts = await _smsService.sendEmergencySmsToContacts(
          contacts: userData.emergencyContacts,
          userName: userData.name,
          location: location,
          bloodGroup: userData.bloodGroup,
        );

        await _emergencyRepository.updateNotifiedContacts(
          emergencyId: emergencyId,
          contacts: notifiedContacts,
        );
      }

      // Update status to ambulance searching
      await _emergencyRepository.updateEmergencyStatus(
        emergencyId: emergencyId,
        status: EmergencyStatus.ambulanceSearching,
      );

      // Get updated emergency
      _currentEmergency = await _emergencyRepository.getEmergency(emergencyId);

      _isLoading = false;
      notifyListeners();

      return emergencyId;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return null;
    }
  }

  // Load Emergency History
  Future<void> loadEmergencyHistory() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) {
        throw Exception('User not logged in');
      }

      _emergencyHistory = await _emergencyRepository.getUserEmergencies(userId);

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  // Load Active Emergencies
  Future<void> loadActiveEmergencies() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) {
        throw Exception('User not logged in');
      }

      final activeEmergencies = await _emergencyRepository.getActiveEmergencies(userId);

      if (activeEmergencies.isNotEmpty) {
        _currentEmergency = activeEmergencies.first;
      }

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  // Get Emergency by ID
  Future<void> getEmergency(String emergencyId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _currentEmergency = await _emergencyRepository.getEmergency(emergencyId);

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  // Update Emergency Status
  Future<void> updateStatus({
    required String emergencyId,
    required EmergencyStatus status,
  }) async {
    try {
      await _emergencyRepository.updateEmergencyStatus(
        emergencyId: emergencyId,
        status: status,
      );

      // Reload current emergency
      if (_currentEmergency?.id == emergencyId) {
        _currentEmergency = await _emergencyRepository.getEmergency(emergencyId);
        notifyListeners();
      }
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  // Assign Ambulance
  Future<void> assignAmbulance({
    required String emergencyId,
    required String ambulanceId,
    required String ambulanceNumber,
    required String driverName,
    required String driverPhone,
  }) async {
    try {
      await _emergencyRepository.updateAmbulanceDetails(
        emergencyId: emergencyId,
        ambulanceId: ambulanceId,
        ambulanceNumber: ambulanceNumber,
        driverName: driverName,
        driverPhone: driverPhone,
      );

      // Send SMS to emergency contacts
      if (_currentEmergency != null && _currentEmergency!.notifiedContacts.isNotEmpty) {
        await _smsService.sendAmbulanceDetailsSms(
          contactNumbers: _currentEmergency!.notifiedContacts,
          ambulanceNumber: ambulanceNumber,
          driverName: driverName,
          driverPhone: driverPhone,
        );
      }

      // Reload current emergency
      _currentEmergency = await _emergencyRepository.getEmergency(emergencyId);
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  // Assign Hospital
  Future<void> assignHospital({
    required String emergencyId,
    required String hospitalId,
    required String hospitalName,
    required String hospitalPhone,
  }) async {
    try {
      await _emergencyRepository.updateHospitalDetails(
        emergencyId: emergencyId,
        hospitalId: hospitalId,
        hospitalName: hospitalName,
        hospitalPhone: hospitalPhone,
      );

      // Reload current emergency
      _currentEmergency = await _emergencyRepository.getEmergency(emergencyId);
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  // Complete Emergency
  Future<void> completeEmergency(String emergencyId) async {
    try {
      await _emergencyRepository.completeEmergency(emergencyId);

      if (_currentEmergency?.id == emergencyId) {
        _currentEmergency = await _emergencyRepository.getEmergency(emergencyId);
        notifyListeners();
      }
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  // Cancel Emergency
  Future<void> cancelEmergency(String emergencyId) async {
    try {
      await _emergencyRepository.cancelEmergency(emergencyId);

      if (_currentEmergency?.id == emergencyId) {
        _currentEmergency = null;
      }

      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  // Add Note to Emergency
  Future<void> addNote({
    required String emergencyId,
    required String note,
  }) async {
    try {
      await _emergencyRepository.addNote(
        emergencyId: emergencyId,
        note: note,
      );

      // Reload current emergency
      if (_currentEmergency?.id == emergencyId) {
        _currentEmergency = await _emergencyRepository.getEmergency(emergencyId);
        notifyListeners();
      }
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  // Listen to Emergency Updates (Stream)
  Stream<EmergencyModel?> listenToEmergency(String emergencyId) {
    return _emergencyRepository.listenToEmergency(emergencyId);
  }

  // Clear Error
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  // Clear Current Emergency
  void clearCurrentEmergency() {
    _currentEmergency = null;
    notifyListeners();
  }

  @override
  void dispose() {
    super.dispose();
  }
}



// import 'package:flutter/material.dart';
// import '../../data/repositories/auth_repository.dart';
// import '../../data/models/user_model.dart';
//
// // emergency_viewmodel.dart
// import '../../data/repositories/emergency_repository.dart';
// import '../../data/models/emergency_model.dart';
//
// class EmergencyViewModel extends ChangeNotifier {
//   final EmergencyRepository _repository = EmergencyRepository();
//
//   EmergencyModel? _currentEmergency;
//   List<EmergencyModel> _emergencyHistory = [];
//   bool _isLoading = false;
//
//   EmergencyModel? get currentEmergency => _currentEmergency;
//   List<EmergencyModel> get emergencyHistory => _emergencyHistory;
//   bool get isLoading => _isLoading;
//
//   Future<void> triggerEmergency(double lat, double lng, String type) async {
//     _isLoading = true;
//     notifyListeners();
//
//     try {
//       _currentEmergency = await _repository.triggerEmergency({
//         'latitude': lat,
//         'longitude': lng,
//         'emergency_type': type,
//       });
//       _isLoading = false;
//       notifyListeners();
//     } catch (e) {
//       _isLoading = false;
//       notifyListeners();
//       rethrow;
//     }
//   }
//
//   Future<void> loadHistory() async {
//     _isLoading = true;
//     notifyListeners();
//
//     try {
//       _emergencyHistory = await _repository.getHistory();
//       _isLoading = false;
//       notifyListeners();
//     } catch (e) {
//       _isLoading = false;
//       notifyListeners();
//     }
//   }
//
//   Future<void> cancelEmergency(String id) async {
//     await _repository.cancelEmergency(id);
//     _currentEmergency = null;
//     notifyListeners();
//   }
// }
