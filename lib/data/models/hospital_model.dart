class HospitalModel {
  final String id;
  final String name;
  final String address;
  final double latitude;
  final double longitude;
  final String phone;
  final String? email;
  final int totalBeds;
  final int availableBeds;
  final int icuBeds;
  final int availableIcuBeds;
  final bool emergencyAvailable;
  final List<String> departments;
  final double rating;
  final double distanceKm;

  HospitalModel({
    required this.id,
    required this.name,
    required this.address,
    required this.latitude,
    required this.longitude,
    required this.phone,
    this.email,
    required this.totalBeds,
    required this.availableBeds,
    required this.icuBeds,
    required this.availableIcuBeds,
    required this.emergencyAvailable,
    required this.departments,
    required this.rating,
    required this.distanceKm,
  });

  factory HospitalModel.fromJson(Map<String, dynamic> json) {
    return HospitalModel(
      id: json['id'] as String,
      name: json['name'] as String,
      address: json['address'] as String,
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      phone: json['phone'] as String,
      email: json['email'] as String?,
      totalBeds: json['total_beds'] as int,
      availableBeds: json['available_beds'] as int,
      icuBeds: json['icu_beds'] as int,
      availableIcuBeds: json['available_icu_beds'] as int,
      emergencyAvailable: json['emergency_available'] as bool,
      departments: List<String>.from(json['departments'] as List),
      rating: (json['rating'] as num).toDouble(),
      distanceKm: (json['distance_km'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'address': address,
      'latitude': latitude,
      'longitude': longitude,
      'phone': phone,
      'email': email,
      'total_beds': totalBeds,
      'available_beds': availableBeds,
      'icu_beds': icuBeds,
      'available_icu_beds': availableIcuBeds,
      'emergency_available': emergencyAvailable,
      'departments': departments,
      'rating': rating,
      'distance_km': distanceKm,
    };
  }

  int get occupancyPercentage {
    if (totalBeds == 0) return 0;
    return ((totalBeds - availableBeds) / totalBeds * 100).round();
  }

  bool get hasAvailableBeds => availableBeds > 0;
  bool get hasAvailableIcuBeds => availableIcuBeds > 0;
}

