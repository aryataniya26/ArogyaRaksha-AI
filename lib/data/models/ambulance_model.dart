class AmbulanceModel {
  final String id;
  final String driverName;
  final String driverPhone;
  final String vehicleNumber;
  final double latitude;
  final double longitude;
  final String status; // available / assigned / busy
  final double distance; // in kilometers

  AmbulanceModel({
    required this.id,
    required this.driverName,
    required this.driverPhone,
    required this.vehicleNumber,
    required this.latitude,
    required this.longitude,
    required this.status,
    required this.distance,
  });

  // Factory constructor to create object from JSON
  factory AmbulanceModel.fromJson(Map<String, dynamic> json) {
    return AmbulanceModel(
      id: json['id'] ?? '',
      driverName: json['driver_name'] ?? '',
      driverPhone: json['driver_phone'] ?? '',
      vehicleNumber: json['vehicle_number'] ?? '',
      latitude: (json['latitude'] ?? 0).toDouble(),
      longitude: (json['longitude'] ?? 0).toDouble(),
      status: json['status'] ?? 'available',
      distance: (json['distance'] ?? 0).toDouble(),
    );
  }

  // Convert object to JSON (for sending data to API)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'driver_name': driverName,
      'driver_phone': driverPhone,
      'vehicle_number': vehicleNumber,
      'latitude': latitude,
      'longitude': longitude,
      'status': status,
      'distance': distance,
    };
  }
}
