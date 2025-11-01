import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/emergency_model.dart';

class EmergencyRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'emergencies';

  // Create new emergency
  Future<String> createEmergency(EmergencyModel emergency) async {
    try {
      final docRef = await _firestore.collection(_collection).add(emergency.toJson());
      return docRef.id;
    } catch (e) {
      print('Error creating emergency: $e');
      rethrow;
    }
  }

  // Get emergency by ID
  Future<EmergencyModel?> getEmergency(String emergencyId) async {
    try {
      final doc = await _firestore.collection(_collection).doc(emergencyId).get();

      if (doc.exists) {
        return EmergencyModel.fromJson({
          ...doc.data()!,
          'id': doc.id,
        });
      }
      return null;
    } catch (e) {
      print('Error getting emergency: $e');
      return null;
    }
  }

  // Update emergency status
  Future<void> updateEmergencyStatus({
    required String emergencyId,
    required EmergencyStatus status,
  }) async {
    try {
      await _firestore.collection(_collection).doc(emergencyId).update({
        'status': status.toString().split('.').last,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error updating emergency status: $e');
      rethrow;
    }
  }

  // Update ambulance details
  Future<void> updateAmbulanceDetails({
    required String emergencyId,
    required String ambulanceId,
    required String ambulanceNumber,
    required String driverName,
    required String driverPhone,
  }) async {
    try {
      await _firestore.collection(_collection).doc(emergencyId).update({
        'ambulanceId': ambulanceId,
        'ambulanceNumber': ambulanceNumber,
        'driverName': driverName,
        'driverPhone': driverPhone,
        'status': EmergencyStatus.ambulanceAssigned.toString().split('.').last,
        'respondedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error updating ambulance details: $e');
      rethrow;
    }
  }

  // Update hospital details
  Future<void> updateHospitalDetails({
    required String emergencyId,
    required String hospitalId,
    required String hospitalName,
    required String hospitalPhone,
  }) async {
    try {
      await _firestore.collection(_collection).doc(emergencyId).update({
        'hospitalId': hospitalId,
        'hospitalName': hospitalName,
        'hospitalPhone': hospitalPhone,
      });
    } catch (e) {
      print('Error updating hospital details: $e');
      rethrow;
    }
  }

  // Complete emergency
  Future<void> completeEmergency(String emergencyId) async {
    try {
      await _firestore.collection(_collection).doc(emergencyId).update({
        'status': EmergencyStatus.completed.toString().split('.').last,
        'completedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error completing emergency: $e');
      rethrow;
    }
  }

  // Cancel emergency
  Future<void> cancelEmergency(String emergencyId) async {
    try {
      await _firestore.collection(_collection).doc(emergencyId).update({
        'status': EmergencyStatus.cancelled.toString().split('.').last,
        'completedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error cancelling emergency: $e');
      rethrow;
    }
  }

  // Get user's emergency history
  Future<List<EmergencyModel>> getUserEmergencies(String userId) async {
    try {
      final querySnapshot = await _firestore
          .collection(_collection)
          .where('userId', isEqualTo: userId)
          .orderBy('triggeredAt', descending: true)
          .get();

      return querySnapshot.docs.map((doc) {
        return EmergencyModel.fromJson({
          ...doc.data(),
          'id': doc.id,
        });
      }).toList();
    } catch (e) {
      print('Error getting user emergencies: $e');
      return [];
    }
  }

  // Get active emergencies for user
  Future<List<EmergencyModel>> getActiveEmergencies(String userId) async {
    try {
      final querySnapshot = await _firestore
          .collection(_collection)
          .where('userId', isEqualTo: userId)
          .where('status', whereIn: [
        EmergencyStatus.triggered.toString().split('.').last,
        EmergencyStatus.locating.toString().split('.').last,
        EmergencyStatus.notifying.toString().split('.').last,
        EmergencyStatus.ambulanceSearching.toString().split('.').last,
        EmergencyStatus.ambulanceAssigned.toString().split('.').last,
        EmergencyStatus.ambulanceEnRoute.toString().split('.').last,
        EmergencyStatus.hospitalEnRoute.toString().split('.').last,
      ])
          .orderBy('triggeredAt', descending: true)
          .get();

      return querySnapshot.docs.map((doc) {
        return EmergencyModel.fromJson({
          ...doc.data(),
          'id': doc.id,
        });
      }).toList();
    } catch (e) {
      print('Error getting active emergencies: $e');
      return [];
    }
  }

  // Listen to emergency updates in real-time
  Stream<EmergencyModel?> listenToEmergency(String emergencyId) {
    return _firestore
        .collection(_collection)
        .doc(emergencyId)
        .snapshots()
        .map((doc) {
      if (doc.exists) {
        return EmergencyModel.fromJson({
          ...doc.data()!,
          'id': doc.id,
        });
      }
      return null;
    });
  }

  // Add note to emergency
  Future<void> addNote({
    required String emergencyId,
    required String note,
  }) async {
    try {
      await _firestore.collection(_collection).doc(emergencyId).update({
        'notes': note,
      });
    } catch (e) {
      print('Error adding note: $e');
      rethrow;
    }
  }

  // Update notified contacts
  Future<void> updateNotifiedContacts({
    required String emergencyId,
    required List<String> contacts,
  }) async {
    try {
      await _firestore.collection(_collection).doc(emergencyId).update({
        'notifiedContacts': contacts,
      });
    } catch (e) {
      print('Error updating notified contacts: $e');
      rethrow;
    }
  }
}



// // emergency_repository.dart
// import '../models/emergency_model.dart';
// import 'package:arogyaraksha_ai/data/services/api_service.dart';
//
// class EmergencyRepository {
//   Future<EmergencyModel> triggerEmergency(Map<String, dynamic> data) async {
//     final response = await ApiService.post('/emergency/trigger', data: data);
//     return EmergencyModel.fromJson(response.data);
//   }
//
//   Future<List<EmergencyModel>> getHistory() async {
//     final response = await ApiService.get('/emergency/history');
//     return (response.data as List).map((e) => EmergencyModel.fromJson(e)).toList();
//   }
//
//   Future<EmergencyModel> getStatus(String emergencyId) async {
//     final response = await ApiService.get('/emergency/status/$emergencyId');
//     return EmergencyModel.fromJson(response.data);
//   }
//
//   Future<void> cancelEmergency(String emergencyId) async {
//     await ApiService.post('/emergency/cancel/$emergencyId');
//   }
// }