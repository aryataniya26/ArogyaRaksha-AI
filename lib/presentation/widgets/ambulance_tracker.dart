import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../../core/constants/app_colors.dart';

class AmbulanceTracker extends StatefulWidget {
  final double latitude;
  final double longitude;

  const AmbulanceTracker({
    Key? key,
    required this.latitude,
    required this.longitude,
  }) : super(key: key);

  @override
  State<AmbulanceTracker> createState() => _AmbulanceTrackerState();
}

class _AmbulanceTrackerState extends State<AmbulanceTracker> {
  late GoogleMapController mapController;

  @override
  Widget build(BuildContext context) {
    final LatLng location = LatLng(widget.latitude, widget.longitude);

    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: GoogleMap(
        initialCameraPosition: CameraPosition(
          target: location,
          zoom: 15,
        ),
        markers: {
          Marker(
            markerId: const MarkerId('ambulance'),
            position: location,
            infoWindow: const InfoWindow(title: 'Ambulance Location'),
            icon: BitmapDescriptor.defaultMarkerWithHue(
              BitmapDescriptor.hueGreen,
            ),
          ),
        },
        onMapCreated: (controller) => mapController = controller,
        zoomControlsEnabled: false,
        myLocationEnabled: false,
        compassEnabled: true,
        mapToolbarEnabled: false,
      ),
    );
  }
}

