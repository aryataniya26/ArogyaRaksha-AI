import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../data/repositories/emergency_repository.dart';
import '../../data/models/emergency_model.dart';
import '../../data/models/user_model.dart';
import '../../data/services/location_service.dart';
import '../../data/services/sms_service.dart';

class TriggerEmergencyUseCase {
  final EmergencyRepository _emergencyRepo;
  final LocationService _locationService;
  final SmsService _smsService;
  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  TriggerEmergencyUseCase({
    EmergencyRepository? emergencyRepo,
    LocationService? locationService,
    SmsService? smsService,
    FirebaseAuth? auth,
    FirebaseFirestore? firestore,
  })  : _emergencyRepo = emergencyRepo ?? EmergencyRepository(),
        _locationService = locationService ?? LocationService(),
        _smsService = smsService ?? SmsService(),
        _auth = auth ?? FirebaseAuth.instance,
        _firestore = firestore ?? FirebaseFirestore.instance;

  /// Execute emergency trigger workflow
  ///
  /// Steps:
  /// 1. Get user data from Firestore
  /// 2. Get current GPS location
  /// 3. Create emergency record
  /// 4. Send SMS to emergency contacts
  /// 5. Update status progression
  /// 6. Return emergency ID
  Future<TriggerEmergencyResult> execute({
    String emergencyType = 'general',
    String? userId,
  }) async {
    try {
      // Step 1: Get user ID
      final currentUserId = userId ?? _auth.currentUser?.uid;
      if (currentUserId == null) {
        return TriggerEmergencyResult.failure('User not logged in');
      }

      // Step 2: Get user data
      final userDoc = await _firestore.collection('users').doc(currentUserId).get();
      if (!userDoc.exists) {
        return TriggerEmergencyResult.failure('User data not found');
      }

      final userData = UserModel.fromJson(userDoc.data()!);

      // Step 3: Get current location
      final location = await _locationService.getCurrentLocation();
      if (location == null) {
        return TriggerEmergencyResult.failure(
          'Could not get location. Please enable location services.',
        );
      }

      // Step 4: Create emergency model
      final emergency = EmergencyModel(
        id: '',
        userId: currentUserId,
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
          'disabilities': userData.medicalInfo.disabilities,
        },
      );

      // Step 5: Save to Firestore
      final emergencyId = await _emergencyRepo.createEmergency(emergency);

      // Step 6: Update status to locating (already captured)
      await _emergencyRepo.updateEmergencyStatus(
        emergencyId: emergencyId,
        status: EmergencyStatus.locating,
      );

      // Step 7: Update status to notifying
      await _emergencyRepo.updateEmergencyStatus(
        emergencyId: emergencyId,
        status: EmergencyStatus.notifying,
      );

      // Step 8: Send SMS to emergency contacts
      List<String> notifiedContacts = [];
      if (userData.emergencyContacts.isNotEmpty) {
        notifiedContacts = await _smsService.sendEmergencySmsToContacts(
          contacts: userData.emergencyContacts,
          userName: userData.name,
          location: location,
          bloodGroup: userData.bloodGroup,
        );

        // Update notified contacts in Firebase
        await _emergencyRepo.updateNotifiedContacts(
          emergencyId: emergencyId,
          contacts: notifiedContacts,
        );
      }

      // Step 9: Update status to ambulance searching
      await _emergencyRepo.updateEmergencyStatus(
        emergencyId: emergencyId,
        status: EmergencyStatus.ambulanceSearching,
      );

      // Step 10: Find nearest ambulance (TODO: Implement ambulance API)
      // final ambulances = await _findNearestAmbulances(location);
      // if (ambulances.isNotEmpty) {
      //   await _assignAmbulance(emergencyId, ambulances.first);
      // }

      // Step 11: Find nearest hospital (TODO: Implement hospital API)
      // final hospitals = await _findNearestHospitals(location);
      // if (hospitals.isNotEmpty) {
      //   await _assignHospital(emergencyId, hospitals.first);
      // }

      // Return success result
      return TriggerEmergencyResult.success(
        emergencyId: emergencyId,
        message: 'Emergency triggered successfully',
        notifiedContacts: notifiedContacts,
      );
    } catch (e) {
      return TriggerEmergencyResult.failure(e.toString());
    }
  }

  /// Find nearest ambulances (Placeholder - implement with actual API)
  Future<List<Map<String, dynamic>>> _findNearestAmbulances(
      EmergencyLocation location,
      ) async {
    // TODO: Implement ambulance provider API
    // Examples:
    // - Call 108 emergency service API
    // - Integrate with Ola/Uber ambulance service
    // - Use third-party ambulance aggregator

    // For now, return mock data
    return [
      {
        'id': 'AMB001',
        'number': 'MH-01-AB-1234',
        'driver_name': 'Rajesh Kumar',
        'driver_phone': '+919876543210',
        'distance_km': 2.5,
        'eta_minutes': 8,
      },
    ];
  }

  /// Find nearest hospitals (Placeholder - implement with actual API)
  Future<List<Map<String, dynamic>>> _findNearestHospitals(
      EmergencyLocation location,
      ) async {
    // TODO: Implement hospital finder API
    // Examples:
    // - Google Places API
    // - Custom hospital database
    // - Government hospital registry API

    // For now, return mock data
    return [
      {
        'id': 'HOSP001',
        'name': 'City General Hospital',
        'phone': '+912212345678',
        'address': '123 MG Road, Mumbai',
        'distance_km': 3.2,
        'has_emergency': true,
        'has_icu': true,
      },
    ];
  }

  /// Assign ambulance to emergency
  Future<void> _assignAmbulance(
      String emergencyId,
      Map<String, dynamic> ambulance,
      ) async {
    await _emergencyRepo.updateAmbulanceDetails(
      emergencyId: emergencyId,
      ambulanceId: ambulance['id'],
      ambulanceNumber: ambulance['number'],
      driverName: ambulance['driver_name'],
      driverPhone: ambulance['driver_phone'],
    );
  }

  /// Assign hospital to emergency
  Future<void> _assignHospital(
      String emergencyId,
      Map<String, dynamic> hospital,
      ) async {
    await _emergencyRepo.updateHospitalDetails(
      emergencyId: emergencyId,
      hospitalId: hospital['id'],
      hospitalName: hospital['name'],
      hospitalPhone: hospital['phone'],
    );
  }
}

/// Result class for TriggerEmergencyUseCase
class TriggerEmergencyResult {
  final bool isSuccess;
  final String? emergencyId;
  final String message;
  final List<String> notifiedContacts;

  TriggerEmergencyResult._({
    required this.isSuccess,
    this.emergencyId,
    required this.message,
    this.notifiedContacts = const [],
  });

  factory TriggerEmergencyResult.success({
    required String emergencyId,
    required String message,
    List<String> notifiedContacts = const [],
  }) {
    return TriggerEmergencyResult._(
      isSuccess: true,
      emergencyId: emergencyId,
      message: message,
      notifiedContacts: notifiedContacts,
    );
  }

  factory TriggerEmergencyResult.failure(String message) {
    return TriggerEmergencyResult._(
      isSuccess: false,
      message: message,
    );
  }
}

/// Usage Example:
///
/// ```dart
/// final useCase = TriggerEmergencyUseCase();
/// final result = await useCase.execute(emergencyType: 'cardiac');
///
/// if (result.isSuccess) {
///   print('Emergency ID: ${result.emergencyId}');
///   print('Notified: ${result.notifiedContacts.length} contacts');
/// } else {
///   print('Error: ${result.message}');
/// }
/// ```


// // trigger_emergency_usecase.dart
// import '../../data/repositories/emergency_repository.dart';
// import '../../data/repositories/ambulance_repository.dart';
// import '../../data/repositories/hospital_repository.dart';
// import '../../data/models/emergency_model.dart';
//
// class TriggerEmergencyUseCase {
//   final EmergencyRepository _emergencyRepo;
//   final AmbulanceRepository _ambulanceRepo;
//   final HospitalRepository _hospitalRepo;
//
//   TriggerEmergencyUseCase(
//       this._emergencyRepo,
//       this._ambulanceRepo,
//       this._hospitalRepo,
//       );
//
//   Future<EmergencyModel> execute({
//     required double latitude,
//     required double longitude,
//     required String emergencyType,
//     required String userId,
//   }) async {
//     // 1. Trigger Emergency
//     final emergency = await _emergencyRepo.triggerEmergency({
//       'user_id': userId,
//       'latitude': latitude,
//       'longitude': longitude,
//       'emergency_type': emergencyType,
//       'status': 'triggered',
//     });
//
//     // 2. Find nearest ambulance
//     final ambulances = await _ambulanceRepo.getNearestAmbulances(
//       latitude,
//       longitude,
//     );
//
//     // 3. Find nearest hospitals
//     final hospitals = await _hospitalRepo.getNearestHospitals(
//       latitude,
//       longitude,
//     );
//
//     // 4. Send notifications (handled by backend)
//
//     return emergency;
//   }
// }