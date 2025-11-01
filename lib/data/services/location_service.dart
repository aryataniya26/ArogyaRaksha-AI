import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import '../models/emergency_model.dart';

class LocationService {
  static final LocationService _instance = LocationService._internal();
  factory LocationService() => _instance;
  LocationService._internal();

  // Check if location services are enabled
  Future<bool> isLocationServiceEnabled() async {
    return await Geolocator.isLocationServiceEnabled();
  }

  // Check location permission
  Future<LocationPermission> checkPermission() async {
    return await Geolocator.checkPermission();
  }

  // Request location permission
  Future<LocationPermission> requestPermission() async {
    return await Geolocator.requestPermission();
  }

  // Get current location with full details
  Future<EmergencyLocation?> getCurrentLocation() async {
    try {
      // Check if location service is enabled
      bool serviceEnabled = await isLocationServiceEnabled();
      if (!serviceEnabled) {
        throw Exception('Location services are disabled');
      }

      // Check permission
      LocationPermission permission = await checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await requestPermission();
        if (permission == LocationPermission.denied) {
          throw Exception('Location permission denied');
        }
      }

      if (permission == LocationPermission.deniedForever) {
        throw Exception('Location permissions are permanently denied');
      }

      // Get current position
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 10),
      );

      // Get address from coordinates
      String? address;
      String? city;
      String? state;

      try {
        List<Placemark> placemarks = await placemarkFromCoordinates(
          position.latitude,
          position.longitude,
        );

        if (placemarks.isNotEmpty) {
          Placemark place = placemarks.first;
          address = '${place.street}, ${place.subLocality}, ${place.locality}';
          city = place.locality;
          state = place.administrativeArea;
        }
      } catch (e) {
        print('Error getting address: $e');
      }

      return EmergencyLocation(
        latitude: position.latitude,
        longitude: position.longitude,
        address: address,
        city: city,
        state: state,
        accuracy: position.accuracy,
      );
    } catch (e) {
      print('Error getting location: $e');
      return null;
    }
  }

  // Get location stream for live tracking
  Stream<Position> getLocationStream() {
    return Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 10, // Update every 10 meters
      ),
    );
  }

  // Calculate distance between two points in meters
  double calculateDistance(
      double startLat,
      double startLng,
      double endLat,
      double endLng,
      ) {
    return Geolocator.distanceBetween(startLat, startLng, endLat, endLng);
  }

  // Calculate distance in kilometers
  double calculateDistanceInKm(
      double startLat,
      double startLng,
      double endLat,
      double endLng,
      ) {
    return calculateDistance(startLat, startLng, endLat, endLng) / 1000;
  }

  // Open location in maps
  Future<void> openInMaps(double latitude, double longitude) async {
    final url = 'https://www.google.com/maps/search/?api=1&query=$latitude,$longitude';
    // TODO: Use url_launcher to open the URL
    print('Open in maps: $url');
  }

  // Get last known location (faster but may be old)
  Future<Position?> getLastKnownLocation() async {
    try {
      return await Geolocator.getLastKnownPosition();
    } catch (e) {
      print('Error getting last known location: $e');
      return null;
    }
  }

  // Check if location is within service area (example: within 100km of a point)
  bool isWithinServiceArea(
      double userLat,
      double userLng,
      double centerLat,
      double centerLng,
      double radiusKm,
      ) {
    double distance = calculateDistanceInKm(userLat, userLng, centerLat, centerLng);
    return distance <= radiusKm;
  }
}




// import 'package:geolocator/geolocator.dart';
//
// class LocationService {
//   static Future<Position?> getCurrentLocation() async {
//     bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
//     if (!serviceEnabled) return null;
//
//     LocationPermission permission = await Geolocator.checkPermission();
//     if (permission == LocationPermission.denied) {
//       permission = await Geolocator.requestPermission();
//     }
//
//     return await Geolocator.getCurrentPosition();
//   }
// }