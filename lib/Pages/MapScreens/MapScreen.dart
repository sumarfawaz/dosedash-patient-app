import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_api_availability/google_api_availability.dart';

class Mapscreen extends StatefulWidget {
  const Mapscreen({super.key});

  @override
  State<Mapscreen> createState() => _MapscreenState();
}

class _MapscreenState extends State<Mapscreen> {
  late GoogleMapController mapController;
  final LatLng _center = const LatLng(-33.86, 151.20);
  String _googlePlayServicesStatus = "Unknown";

  @override
  void initState() {
    super.initState();
    _checkGooglePlayServices();
  }

  Future<void> _checkGooglePlayServices() async {
    GooglePlayServicesAvailability availability = await GoogleApiAvailability
        .instance
        .checkGooglePlayServicesAvailability();
    setState(() {
      switch (availability) {
        case GooglePlayServicesAvailability.success:
          _googlePlayServicesStatus = "Google Play Services available";
          break;
        case GooglePlayServicesAvailability.serviceMissing:
          _googlePlayServicesStatus = "Google Play Services missing";
          break;
        case GooglePlayServicesAvailability.serviceUpdating:
          _googlePlayServicesStatus = "Google Play Services updating";
          break;
        case GooglePlayServicesAvailability.serviceVersionUpdateRequired:
          _googlePlayServicesStatus = "Google Play Services update required";
          break;
        case GooglePlayServicesAvailability.serviceDisabled:
          _googlePlayServicesStatus = "Google Play Services disabled";
          break;
        case GooglePlayServicesAvailability.serviceInvalid:
          _googlePlayServicesStatus = "Google Play Services invalid";
          break;
        default:
          _googlePlayServicesStatus = "Unknown Google Play Services status";
          break;
      }
    });
  }

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
    // Perform any additional setup with the map controller if needed
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Maps Sample App'),
        backgroundColor: Colors.green[700],
      ),
      body: Stack(
        children: [
          GoogleMap(
            onMapCreated: _onMapCreated,
            initialCameraPosition: CameraPosition(
              target: LatLng(37.7749, -122.4194), // Default to San Francisco
              zoom: 12,
            ),
          ),
        ],
      ),
    );
  }
}
