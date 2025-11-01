import 'package:cloud_firestore/cloud_firestore.dart';

class EmergencyModel {
  final String id;
  final String userId;
  final String userName;
  final String userPhone;
  final String? userBloodGroup;
  final EmergencyLocation location;
  final EmergencyStatus status;
  final String emergencyType;
  final DateTime triggeredAt;
  final DateTime? respondedAt;
  final DateTime? completedAt;

  // Ambulance Details
  final String? ambulanceId;
  final String? ambulanceNumber;
  final String? driverName;
  final String? driverPhone;

  // Hospital Details
  final String? hospitalId;
  final String? hospitalName;
  final String? hospitalPhone;

  // Additional Info
  final List<String> notifiedContacts;
  final Map<String, dynamic>? medicalInfo;
  final String? notes;

  EmergencyModel({
    required this.id,
    required this.userId,
    required this.userName,
    required this.userPhone,
    this.userBloodGroup,
    required this.location,
    required this.status,
    this.emergencyType = 'general',
    required this.triggeredAt,
    this.respondedAt,
    this.completedAt,
    this.ambulanceId,
    this.ambulanceNumber,
    this.driverName,
    this.driverPhone,
    this.hospitalId,
    this.hospitalName,
    this.hospitalPhone,
    this.notifiedContacts = const [],
    this.medicalInfo,
    this.notes,
  });

  // From JSON (Firestore)
  factory EmergencyModel.fromJson(Map<String, dynamic> json) {
    return EmergencyModel(
      id: json['id'] ?? '',
      userId: json['userId'] ?? '',
      userName: json['userName'] ?? '',
      userPhone: json['userPhone'] ?? '',
      userBloodGroup: json['userBloodGroup'],
      location: EmergencyLocation.fromJson(json['location'] ?? {}),
      status: EmergencyStatus.values.firstWhere(
            (e) => e.toString() == 'EmergencyStatus.${json['status']}',
        orElse: () => EmergencyStatus.triggered,
      ),
      emergencyType: json['emergencyType'] ?? 'general',
      triggeredAt: (json['triggeredAt'] as Timestamp).toDate(),
      respondedAt: json['respondedAt'] != null
          ? (json['respondedAt'] as Timestamp).toDate()
          : null,
      completedAt: json['completedAt'] != null
          ? (json['completedAt'] as Timestamp).toDate()
          : null,
      ambulanceId: json['ambulanceId'],
      ambulanceNumber: json['ambulanceNumber'],
      driverName: json['driverName'],
      driverPhone: json['driverPhone'],
      hospitalId: json['hospitalId'],
      hospitalName: json['hospitalName'],
      hospitalPhone: json['hospitalPhone'],
      notifiedContacts: List<String>.from(json['notifiedContacts'] ?? []),
      medicalInfo: json['medicalInfo'],
      notes: json['notes'],
    );
  }

  // To JSON (Firestore)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'userName': userName,
      'userPhone': userPhone,
      'userBloodGroup': userBloodGroup,
      'location': location.toJson(),
      'status': status.toString().split('.').last,
      'emergencyType': emergencyType,
      'triggeredAt': Timestamp.fromDate(triggeredAt),
      'respondedAt': respondedAt != null ? Timestamp.fromDate(respondedAt!) : null,
      'completedAt': completedAt != null ? Timestamp.fromDate(completedAt!) : null,
      'ambulanceId': ambulanceId,
      'ambulanceNumber': ambulanceNumber,
      'driverName': driverName,
      'driverPhone': driverPhone,
      'hospitalId': hospitalId,
      'hospitalName': hospitalName,
      'hospitalPhone': hospitalPhone,
      'notifiedContacts': notifiedContacts,
      'medicalInfo': medicalInfo,
      'notes': notes,
    };
  }

  // Copy with method
  EmergencyModel copyWith({
    String? id,
    String? userId,
    String? userName,
    String? userPhone,
    String? userBloodGroup,
    EmergencyLocation? location,
    EmergencyStatus? status,
    String? emergencyType,
    DateTime? triggeredAt,
    DateTime? respondedAt,
    DateTime? completedAt,
    String? ambulanceId,
    String? ambulanceNumber,
    String? driverName,
    String? driverPhone,
    String? hospitalId,
    String? hospitalName,
    String? hospitalPhone,
    List<String>? notifiedContacts,
    Map<String, dynamic>? medicalInfo,
    String? notes,
  }) {
    return EmergencyModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      userPhone: userPhone ?? this.userPhone,
      userBloodGroup: userBloodGroup ?? this.userBloodGroup,
      location: location ?? this.location,
      status: status ?? this.status,
      emergencyType: emergencyType ?? this.emergencyType,
      triggeredAt: triggeredAt ?? this.triggeredAt,
      respondedAt: respondedAt ?? this.respondedAt,
      completedAt: completedAt ?? this.completedAt,
      ambulanceId: ambulanceId ?? this.ambulanceId,
      ambulanceNumber: ambulanceNumber ?? this.ambulanceNumber,
      driverName: driverName ?? this.driverName,
      driverPhone: driverPhone ?? this.driverPhone,
      hospitalId: hospitalId ?? this.hospitalId,
      hospitalName: hospitalName ?? this.hospitalName,
      hospitalPhone: hospitalPhone ?? this.hospitalPhone,
      notifiedContacts: notifiedContacts ?? this.notifiedContacts,
      medicalInfo: medicalInfo ?? this.medicalInfo,
      notes: notes ?? this.notes,
    );
  }
}

// Emergency Location Model
class EmergencyLocation {
  final double latitude;
  final double longitude;
  final String? address;
  final String? city;
  final String? state;
  final double? accuracy;

  EmergencyLocation({
    required this.latitude,
    required this.longitude,
    this.address,
    this.city,
    this.state,
    this.accuracy,
  });

  factory EmergencyLocation.fromJson(Map<String, dynamic> json) {
    return EmergencyLocation(
      latitude: json['latitude']?.toDouble() ?? 0.0,
      longitude: json['longitude']?.toDouble() ?? 0.0,
      address: json['address'],
      city: json['city'],
      state: json['state'],
      accuracy: json['accuracy']?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'latitude': latitude,
      'longitude': longitude,
      'address': address,
      'city': city,
      'state': state,
      'accuracy': accuracy,
    };
  }

  // Get Google Maps URL
  String get mapsUrl => 'https://www.google.com/maps?q=$latitude,$longitude';
}

// Emergency Status Enum
enum EmergencyStatus {
  triggered,        // Emergency just triggered
  locating,         // Getting location
  notifying,        // Sending SMS to contacts
  ambulanceSearching, // Searching for ambulance
  ambulanceAssigned,  // Ambulance assigned
  ambulanceEnRoute,   // Ambulance on the way
  ambulanceArrived,   // Ambulance reached
  hospitalEnRoute,    // Going to hospital
  hospitalArrived,    // Reached hospital
  completed,          // Emergency resolved
  cancelled,          // User cancelled
}

// Extension for Status Display
extension EmergencyStatusExtension on EmergencyStatus {
  String get displayName {
    switch (this) {
      case EmergencyStatus.triggered:
        return 'Emergency Triggered';
      case EmergencyStatus.locating:
        return 'Getting Your Location';
      case EmergencyStatus.notifying:
        return 'Notifying Contacts';
      case EmergencyStatus.ambulanceSearching:
        return 'Searching Ambulance';
      case EmergencyStatus.ambulanceAssigned:
        return 'Ambulance Assigned';
      case EmergencyStatus.ambulanceEnRoute:
        return 'Ambulance On The Way';
      case EmergencyStatus.ambulanceArrived:
        return 'Ambulance Arrived';
      case EmergencyStatus.hospitalEnRoute:
        return 'Going to Hospital';
      case EmergencyStatus.hospitalArrived:
        return 'Reached Hospital';
      case EmergencyStatus.completed:
        return 'Emergency Resolved';
      case EmergencyStatus.cancelled:
        return 'Cancelled';
    }
  }

  String get description {
    switch (this) {
      case EmergencyStatus.triggered:
        return 'Please stay calm, help is on the way';
      case EmergencyStatus.locating:
        return 'Pinpointing your exact location...';
      case EmergencyStatus.notifying:
        return 'Alerting your emergency contacts...';
      case EmergencyStatus.ambulanceSearching:
        return 'Finding nearest ambulance...';
      case EmergencyStatus.ambulanceAssigned:
        return 'Ambulance has been assigned to you';
      case EmergencyStatus.ambulanceEnRoute:
        return 'Ambulance is coming to your location';
      case EmergencyStatus.ambulanceArrived:
        return 'Ambulance has reached your location';
      case EmergencyStatus.hospitalEnRoute:
        return 'On the way to hospital';
      case EmergencyStatus.hospitalArrived:
        return 'You have reached the hospital';
      case EmergencyStatus.completed:
        return 'Emergency has been resolved';
      case EmergencyStatus.cancelled:
        return 'Emergency was cancelled';
    }
  }
}




// import 'ambulance_model.dart';
//
// class EmergencyModel {
//   final String emergencyId;
//   final String userId;
//   final String name;
//   final String phone;
//   final String emergencyType; // e.g. cardiac, stroke, pregnancy, accident
//   final double latitude;
//   final double longitude;
//   final String timestamp;
//   final String status; // pending, accepted, enroute, completed
//   final AmbulanceModel? assignedAmbulance;
//   final String insuranceStatus; // approved / pending / none
//   final String hospitalName;
//   final bool isOfflineTriggered;
//
//   EmergencyModel({
//     required this.emergencyId,
//     required this.userId,
//     required this.name,
//     required this.phone,
//     required this.emergencyType,
//     required this.latitude,
//     required this.longitude,
//     required this.timestamp,
//     required this.status,
//     this.assignedAmbulance,
//     required this.insuranceStatus,
//     required this.hospitalName,
//     required this.isOfflineTriggered,
//   });
//
//   factory EmergencyModel.fromJson(Map<String, dynamic> json) {
//     return EmergencyModel(
//       emergencyId: json['emergency_id'] ?? '',
//       userId: json['user_id'] ?? '',
//       name: json['name'] ?? '',
//       phone: json['phone'] ?? '',
//       emergencyType: json['emergency_type'] ?? '',
//       latitude: (json['latitude'] ?? 0).toDouble(),
//       longitude: (json['longitude'] ?? 0).toDouble(),
//       timestamp: json['timestamp'] ?? '',
//       status: json['status'] ?? 'pending',
//       assignedAmbulance: json['assigned_ambulance'] != null
//           ? AmbulanceModel.fromJson(json['assigned_ambulance'])
//           : null,
//       insuranceStatus: json['insurance_status'] ?? 'pending',
//       hospitalName: json['hospital_name'] ?? '',
//       isOfflineTriggered: json['is_offline_triggered'] ?? false,
//     );
//   }
//
//   Map<String, dynamic> toJson() {
//     return {
//       'emergency_id': emergencyId,
//       'user_id': userId,
//       'name': name,
//       'phone': phone,
//       'emergency_type': emergencyType,
//       'latitude': latitude,
//       'longitude': longitude,
//       'timestamp': timestamp,
//       'status': status,
//       'assigned_ambulance':
//       assignedAmbulance != null ? assignedAmbulance!.toJson() : null,
//       'insurance_status': insuranceStatus,
//       'hospital_name': hospitalName,
//       'is_offline_triggered': isOfflineTriggered,
//     };
//   }
// }
