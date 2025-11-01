import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String uid;
  final String email;
  final String name;
  final String phone;
  final String? gender;
  final String? aadhaar;
  final String bloodGroup;
  final int age;
  final String? address;
  final String? photoURL;

  // Emergency Contacts
  final List<EmergencyContact> emergencyContacts;

  // Medical Info
  final MedicalInfo medicalInfo;

  // Insurance Details
  final InsuranceInfo? insurance;

  final DateTime? createdAt;
  final DateTime? updatedAt;
  final bool isActive;

  UserModel({
    required this.uid,
    required this.email,
    required this.name,
    required this.phone,
    this.gender,
    this.aadhaar,
    this.bloodGroup = '',
    this.age = 0,
    this.address,
    this.photoURL,
    this.emergencyContacts = const [],
    MedicalInfo? medicalInfo,
    this.insurance,
    this.createdAt,
    this.updatedAt,
    this.isActive = true,
  }) : medicalInfo = medicalInfo ?? MedicalInfo();

  // From JSON (Firestore)
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      uid: json['uid'] ?? '',
      email: json['email'] ?? '',
      name: json['name'] ?? '',
      phone: json['phone'] ?? '',
      gender: json['gender'],
      aadhaar: json['aadhaar'],
      bloodGroup: json['bloodGroup'] ?? '',
      age: json['age'] ?? 0,
      address: json['address'],
      photoURL: json['photoURL'],
      emergencyContacts: (json['emergencyContacts'] as List?)
          ?.map((e) => EmergencyContact.fromJson(e))
          .toList() ?? [],
      medicalInfo: json['medicalInfo'] != null
          ? MedicalInfo.fromJson(json['medicalInfo'])
          : MedicalInfo(),
      insurance: json['insurance'] != null
          ? InsuranceInfo.fromJson(json['insurance'])
          : null,
      createdAt: (json['createdAt'] as Timestamp?)?.toDate(),
      updatedAt: (json['updatedAt'] as Timestamp?)?.toDate(),
      isActive: json['isActive'] ?? true,
    );
  }

  // To JSON (Firestore)
  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'email': email,
      'name': name,
      'phone': phone,
      'gender': gender,
      'aadhaar': aadhaar,
      'bloodGroup': bloodGroup,
      'age': age,
      'address': address,
      'photoURL': photoURL,
      'emergencyContacts': emergencyContacts.map((e) => e.toJson()).toList(),
      'medicalInfo': medicalInfo.toJson(),
      'insurance': insurance?.toJson(),
      'createdAt': createdAt != null
          ? Timestamp.fromDate(createdAt!)
          : FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
      'isActive': isActive,
    };
  }

  // Copy with method
  UserModel copyWith({
    String? uid,
    String? email,
    String? name,
    String? phone,
    String? gender,
    String? aadhaar,
    String? bloodGroup,
    int? age,
    String? address,
    String? photoURL,
    List<EmergencyContact>? emergencyContacts,
    MedicalInfo? medicalInfo,
    InsuranceInfo? insurance,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isActive,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      gender: gender ?? this.gender,
      aadhaar: aadhaar ?? this.aadhaar,
      bloodGroup: bloodGroup ?? this.bloodGroup,
      age: age ?? this.age,
      address: address ?? this.address,
      photoURL: photoURL ?? this.photoURL,
      emergencyContacts: emergencyContacts ?? this.emergencyContacts,
      medicalInfo: medicalInfo ?? this.medicalInfo,
      insurance: insurance ?? this.insurance,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isActive: isActive ?? this.isActive,
    );
  }
}

// Emergency Contact Model
class EmergencyContact {
  final String name;
  final String relation;
  final String phone;
  final bool isPrimary;

  EmergencyContact({
    required this.name,
    required this.relation,
    required this.phone,
    this.isPrimary = false,
  });

  factory EmergencyContact.fromJson(Map<String, dynamic> json) {
    return EmergencyContact(
      name: json['name'] ?? '',
      relation: json['relation'] ?? '',
      phone: json['phone'] ?? '',
      isPrimary: json['isPrimary'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'relation': relation,
      'phone': phone,
      'isPrimary': isPrimary,
    };
  }
}

// Medical Info Model
class MedicalInfo {
  final List<String> conditions;
  final List<String> allergies;
  final List<String> medications;
  final List<String> chronicDiseases;
  final String? disabilities;
  final String? lastCheckup;

  MedicalInfo({
    this.conditions = const [],
    this.allergies = const [],
    this.medications = const [],
    this.chronicDiseases = const [],
    this.disabilities,
    this.lastCheckup,
  });

  factory MedicalInfo.fromJson(Map<String, dynamic> json) {
    return MedicalInfo(
      conditions: List<String>.from(json['conditions'] ?? []),
      allergies: List<String>.from(json['allergies'] ?? []),
      medications: List<String>.from(json['medications'] ?? []),
      chronicDiseases: List<String>.from(json['chronicDiseases'] ?? []),
      disabilities: json['disabilities'],
      lastCheckup: json['lastCheckup'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'conditions': conditions,
      'allergies': allergies,
      'medications': medications,
      'chronicDiseases': chronicDiseases,
      'disabilities': disabilities,
      'lastCheckup': lastCheckup,
    };
  }
}

// Insurance Info Model
class InsuranceInfo {
  final String provider;
  final String policyNumber;
  final String? validTill;
  final String? coverage;
  final String? status; // Active, Expired, Pending

  InsuranceInfo({
    required this.provider,
    required this.policyNumber,
    this.validTill,
    this.coverage,
    this.status = 'Active',
  });

  factory InsuranceInfo.fromJson(Map<String, dynamic> json) {
    return InsuranceInfo(
      provider: json['provider'] ?? '',
      policyNumber: json['policyNumber'] ?? '',
      validTill: json['validTill'],
      coverage: json['coverage'],
      status: json['status'] ?? 'Active',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'provider': provider,
      'policyNumber': policyNumber,
      'validTill': validTill,
      'coverage': coverage,
      'status': status,
    };
  }
}


// import 'package:cloud_firestore/cloud_firestore.dart';
//
// class UserModel {
//   final String uid;
//   final String email;
//   final String name;
//   final String phone;
//   final String bloodGroup;
//   final int age;
//   final List<String> medicalHistory;
//   final Map<String, dynamic> insuranceDetails;
//   final DateTime? createdAt;
//   final DateTime? updatedAt;
//   final bool isActive;
//
//   UserModel({
//     required this.uid,
//     required this.email,
//     required this.name,
//     required this.phone,
//     this.bloodGroup = '',
//     this.age = 0,
//     this.medicalHistory = const [],
//     this.insuranceDetails = const {},
//     this.createdAt,
//     this.updatedAt,
//     this.isActive = true,
//   });
//
//   // From JSON (Firestore)
//   factory UserModel.fromJson(Map<String, dynamic> json) {
//     return UserModel(
//       uid: json['uid'] ?? '',
//       email: json['email'] ?? '',
//       name: json['name'] ?? '',
//       phone: json['phone'] ?? '',
//       bloodGroup: json['bloodGroup'] ?? '',
//       age: json['age'] ?? 0,
//       medicalHistory: List<String>.from(json['medicalHistory'] ?? []),
//       insuranceDetails: Map<String, dynamic>.from(json['insuranceDetails'] ?? {}),
//       createdAt: (json['createdAt'] as Timestamp?)?.toDate(),
//       updatedAt: (json['updatedAt'] as Timestamp?)?.toDate(),
//       isActive: json['isActive'] ?? true,
//     );
//   }
//
//   // To JSON (Firestore)
//   Map<String, dynamic> toJson() {
//     return {
//       'uid': uid,
//       'email': email,
//       'name': name,
//       'phone': phone,
//       'bloodGroup': bloodGroup,
//       'age': age,
//       'medicalHistory': medicalHistory,
//       'insuranceDetails': insuranceDetails,
//       'createdAt': createdAt != null ? Timestamp.fromDate(createdAt!) : FieldValue.serverTimestamp(),
//       'updatedAt': FieldValue.serverTimestamp(),
//       'isActive': isActive,
//     };
//   }
//
//   // Copy with method
//   UserModel copyWith({
//     String? uid,
//     String? email,
//     String? name,
//     String? phone,
//     String? bloodGroup,
//     int? age,
//     List<String>? medicalHistory,
//     Map<String, dynamic>? insuranceDetails,
//     DateTime? createdAt,
//     DateTime? updatedAt,
//     bool? isActive,
//   }) {
//     return UserModel(
//       uid: uid ?? this.uid,
//       email: email ?? this.email,
//       name: name ?? this.name,
//       phone: phone ?? this.phone,
//       bloodGroup: bloodGroup ?? this.bloodGroup,
//       age: age ?? this.age,
//       medicalHistory: medicalHistory ?? this.medicalHistory,
//       insuranceDetails: insuranceDetails ?? this.insuranceDetails,
//       createdAt: createdAt ?? this.createdAt,
//       updatedAt: updatedAt ?? this.updatedAt,
//       isActive: isActive ?? this.isActive,
//     );
//   }
//
//   @override
//   String toString() {
//     return 'UserModel(uid: $uid, email: $email, name: $name, phone: $phone)';
//   }
// }
//
//
//
// // class UserModel {
// //   final String id;
// //   final String name;
// //   final String email;
// //   final String? phone;
// //   final int? age;
// //   final String? gender;
// //   final String? bloodGroup;
// //   final String? address;
// //   final String? profileImage;
// //   final String? allergies;
// //   final String? insuranceProvider;
// //   final String? policyId;
// //   final DateTime? lastCheckup;
// //   final DateTime createdAt;
// //   final DateTime updatedAt;
// //
// //   UserModel({
// //     required this.id,
// //     required this.name,
// //     required this.email,
// //     this.phone,
// //     this.age,
// //     this.gender,
// //     this.bloodGroup,
// //     this.address,
// //     this.profileImage,
// //     this.allergies,
// //     this.insuranceProvider,
// //     this.policyId,
// //     this.lastCheckup,
// //     required this.createdAt,
// //     required this.updatedAt,
// //   });
// //
// //   // From JSON
// //   factory UserModel.fromJson(Map<String, dynamic> json) {
// //     return UserModel(
// //       id: json['id'] as String,
// //       name: json['name'] as String,
// //       email: json['email'] as String,
// //       phone: json['phone'] as String?,
// //       age: json['age'] as int?,
// //       gender: json['gender'] as String?,
// //       bloodGroup: json['blood_group'] as String?,
// //       address: json['address'] as String?,
// //       profileImage: json['profile_image'] as String?,
// //       allergies: json['allergies'] as String?,
// //       insuranceProvider: json['insurance_provider'] as String?,
// //       policyId: json['policy_id'] as String?,
// //       lastCheckup: json['last_checkup'] != null
// //           ? DateTime.parse(json['last_checkup'] as String)
// //           : null,
// //       createdAt: DateTime.parse(json['created_at'] as String),
// //       updatedAt: DateTime.parse(json['updated_at'] as String),
// //     );
// //   }
// //
// //   // To JSON
// //   Map<String, dynamic> toJson() {
// //     return {
// //       'id': id,
// //       'name': name,
// //       'email': email,
// //       'phone': phone,
// //       'age': age,
// //       'gender': gender,
// //       'blood_group': bloodGroup,
// //       'address': address,
// //       'profile_image': profileImage,
// //       'allergies': allergies,
// //       'insurance_provider': insuranceProvider,
// //       'policy_id': policyId,
// //       'last_checkup': lastCheckup?.toIso8601String(),
// //       'created_at': createdAt.toIso8601String(),
// //       'updated_at': updatedAt.toIso8601String(),
// //     };
// //   }
// //
// //   // Copy With
// //   UserModel copyWith({
// //     String? id,
// //     String? name,
// //     String? email,
// //     String? phone,
// //     int? age,
// //     String? gender,
// //     String? bloodGroup,
// //     String? address,
// //     String? profileImage,
// //     String? allergies,
// //     String? insuranceProvider,
// //     String? policyId,
// //     DateTime? lastCheckup,
// //     DateTime? createdAt,
// //     DateTime? updatedAt,
// //   }) {
// //     return UserModel(
// //       id: id ?? this.id,
// //       name: name ?? this.name,
// //       email: email ?? this.email,
// //       phone: phone ?? this.phone,
// //       age: age ?? this.age,
// //       gender: gender ?? this.gender,
// //       bloodGroup: bloodGroup ?? this.bloodGroup,
// //       address: address ?? this.address,
// //       profileImage: profileImage ?? this.profileImage,
// //       allergies: allergies ?? this.allergies,
// //       insuranceProvider: insuranceProvider ?? this.insuranceProvider,
// //       policyId: policyId ?? this.policyId,
// //       lastCheckup: lastCheckup ?? this.lastCheckup,
// //       createdAt: createdAt ?? this.createdAt,
// //       updatedAt: updatedAt ?? this.updatedAt,
// //     );
// //   }
// // }