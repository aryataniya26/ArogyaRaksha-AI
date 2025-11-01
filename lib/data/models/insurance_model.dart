class InsuranceModel {
  final String id;
  final String userId;
  final String provider;
  final String policyNumber;
  final String policyType;
  final double coverageAmount;
  final double usedAmount;
  final DateTime validFrom;
  final DateTime validUntil;
  final bool isActive;
  final List<String> coveredServices;

  InsuranceModel({
    required this.id,
    required this.userId,
    required this.provider,
    required this.policyNumber,
    required this.policyType,
    required this.coverageAmount,
    required this.usedAmount,
    required this.validFrom,
    required this.validUntil,
    required this.isActive,
    required this.coveredServices,
  });

  factory InsuranceModel.fromJson(Map<String, dynamic> json) {
    return InsuranceModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      provider: json['provider'] as String,
      policyNumber: json['policy_number'] as String,
      policyType: json['policy_type'] as String,
      coverageAmount: (json['coverage_amount'] as num).toDouble(),
      usedAmount: (json['used_amount'] as num).toDouble(),
      validFrom: DateTime.parse(json['valid_from'] as String),
      validUntil: DateTime.parse(json['valid_until'] as String),
      isActive: json['is_active'] as bool,
      coveredServices: List<String>.from(json['covered_services'] as List),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'provider': provider,
      'policy_number': policyNumber,
      'policy_type': policyType,
      'coverage_amount': coverageAmount,
      'used_amount': usedAmount,
      'valid_from': validFrom.toIso8601String(),
      'valid_until': validUntil.toIso8601String(),
      'is_active': isActive,
      'covered_services': coveredServices,
    };
  }

  double get availableAmount => coverageAmount - usedAmount;
  bool get isValid => isActive && DateTime.now().isBefore(validUntil);
  int get daysUntilExpiry => validUntil.difference(DateTime.now()).inDays;
}