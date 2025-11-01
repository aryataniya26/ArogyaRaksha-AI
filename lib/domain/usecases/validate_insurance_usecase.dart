import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../data/models/user_model.dart';

class ValidateInsuranceUseCase {
  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  ValidateInsuranceUseCase({
    FirebaseAuth? auth,
    FirebaseFirestore? firestore,
  })  : _auth = auth ?? FirebaseAuth.instance,
        _firestore = firestore ?? FirebaseFirestore.instance;

  /// Validate insurance coverage for the current user
  ///
  /// TODO: Integrate with actual insurance APIs:
  /// - Ayushman Bharat (https://abdm.gov.in)
  /// - Aarogyasri (State Government)
  /// - Private insurers (HDFC, Star Health, etc.)
  /// - DigiLocker for policy documents
  Future<InsuranceValidationResult> execute({String? userId}) async {
    try {
      // Get user ID
      final currentUserId = userId ?? _auth.currentUser?.uid;
      if (currentUserId == null) {
        return InsuranceValidationResult.failure('User not logged in');
      }

      // Get user data
      final userDoc = await _firestore.collection('users').doc(currentUserId).get();
      if (!userDoc.exists) {
        return InsuranceValidationResult.failure('User data not found');
      }

      final userData = UserModel.fromJson(userDoc.data()!);

      // Check if user has insurance
      if (userData.insurance == null) {
        return InsuranceValidationResult.notInsured();
      }

      final insurance = userData.insurance!;

      // Validate insurance details
      // TODO: Call actual insurance provider API
      final validationStatus = await _validateWithProvider(insurance);

      if (validationStatus.isValid) {
        return InsuranceValidationResult.success(
          provider: insurance.provider,
          policyNumber: insurance.policyNumber,
          coverage: insurance.coverage ?? 'N/A',
          validTill: insurance.validTill ?? 'N/A',
          status: insurance.status ?? 'Active',
          benefits: _getInsuranceBenefits(insurance.provider),
        );
      } else {
        return InsuranceValidationResult.invalid(
          reason: validationStatus.reason,
        );
      }
    } catch (e) {
      return InsuranceValidationResult.failure(e.toString());
    }
  }

  /// Validate with insurance provider API (Mock)
  Future<_ValidationStatus> _validateWithProvider(InsuranceInfo insurance) async {
    // TODO: Implement actual API calls
    // Examples:
    // - Ayushman Bharat: https://nha.gov.in/api/beneficiary/verify
    // - DigiLocker: Fetch insurance documents
    // - Private insurers: Custom APIs

    await Future.delayed(const Duration(seconds: 2));

    // Mock validation
    return _ValidationStatus(
      isValid: true,
      reason: 'Policy is active',
    );
  }

  /// Get insurance benefits based on provider
  List<String> _getInsuranceBenefits(String provider) {
    // Common benefits mapping
    final benefitsMap = {
      'Ayushman Bharat': [
        'Cashless treatment at empanelled hospitals',
        'Coverage up to ₹5 lakhs per family per year',
        'Pre and post-hospitalization expenses',
        'Covers secondary and tertiary care',
      ],
      'Aarogyasri': [
        'Free treatment for listed diseases',
        'Coverage in network hospitals',
        'Emergency transport support',
        'Follow-up care included',
      ],
      'Star Health': [
        'Cashless hospitalization',
        'Room rent coverage',
        'Day care procedures',
        'Ambulance charges',
      ],
      'HDFC Ergo': [
        'Wide hospital network',
        'No claim bonus',
        'Daily cash allowance',
        'Restoration of sum insured',
      ],
    };

    return benefitsMap[provider] ?? [
      'Standard hospitalization coverage',
      'Emergency treatment',
      'Cashless facility at network hospitals',
    ];
  }

  /// Check if insurance covers specific treatment
  Future<bool> checkCoverageForTreatment({
    required String userId,
    required String treatmentType,
  }) async {
    try {
      final result = await execute(userId: userId);

      if (!result.isValid) return false;

      // TODO: Implement treatment-specific coverage check
      // For now, return true if insurance is valid
      return true;
    } catch (e) {
      return false;
    }
  }
}

/// Insurance Validation Result
class InsuranceValidationResult {
  final bool isValid;
  final bool hasInsurance;
  final String? provider;
  final String? policyNumber;
  final String? coverage;
  final String? validTill;
  final String? status;
  final List<String> benefits;
  final String message;

  InsuranceValidationResult._({
    required this.isValid,
    required this.hasInsurance,
    this.provider,
    this.policyNumber,
    this.coverage,
    this.validTill,
    this.status,
    this.benefits = const [],
    required this.message,
  });

  factory InsuranceValidationResult.success({
    required String provider,
    required String policyNumber,
    required String coverage,
    required String validTill,
    required String status,
    List<String> benefits = const [],
  }) {
    return InsuranceValidationResult._(
      isValid: true,
      hasInsurance: true,
      provider: provider,
      policyNumber: policyNumber,
      coverage: coverage,
      validTill: validTill,
      status: status,
      benefits: benefits,
      message: 'Insurance is valid and active',
    );
  }

  factory InsuranceValidationResult.notInsured() {
    return InsuranceValidationResult._(
      isValid: false,
      hasInsurance: false,
      message: 'No insurance information found',
    );
  }

  factory InsuranceValidationResult.invalid({required String reason}) {
    return InsuranceValidationResult._(
      isValid: false,
      hasInsurance: true,
      message: 'Insurance validation failed: $reason',
    );
  }

  factory InsuranceValidationResult.failure(String error) {
    return InsuranceValidationResult._(
      isValid: false,
      hasInsurance: false,
      message: 'Error validating insurance: $error',
    );
  }
}

/// Internal validation status
class _ValidationStatus {
  final bool isValid;
  final String reason;

  _ValidationStatus({
    required this.isValid,
    required this.reason,
  });
}


// // validate_insurance_usecase.dart
// import '../../data/repositories/insurance_repository.dart';
// import '../../data/models/hospital_model.dart';
// import 'package:arogyaraksha_ai/data/models/insurance_model.dart';
// class ValidateInsuranceUseCase {
//   final InsuranceRepository _repository;
//
//   ValidateInsuranceUseCase(this._repository);
//
//   Future<InsuranceModel> execute(String policyNumber) async {
//     final insurance = await _repository.verifyInsurance(policyNumber);
//
//     if (!insurance.isValid) {
//       throw Exception('Insurance policy is not valid or expired');
//     }
//
//     return insurance;
//   }
//
//   Future<bool> checkCoverage(String policyNumber, double estimatedCost) async {
//     final insurance = await execute(policyNumber);
//     return insurance.availableAmount >= estimatedCost;
//   }
// }
//
