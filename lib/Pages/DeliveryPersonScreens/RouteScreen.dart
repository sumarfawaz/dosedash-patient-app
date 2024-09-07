import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart'; // For getting current location
import 'package:url_launcher/url_launcher.dart'; // For launching Google Maps
import 'package:permission_handler/permission_handler.dart'; // For handling permissions

class RouteScreen extends StatefulWidget {
  final List<LatLng> pharmacyCoords;
  final LatLng patientCoords;

  RouteScreen({required this.pharmacyCoords, required this.patientCoords});

  @override
  _RouteScreenState createState() => _RouteScreenState();
}

class _RouteScreenState extends State<RouteScreen> {
  late GoogleMapController mapController;
  Set<Polyline> _polylines = {};
  Set<Marker> _markers = {};
  LatLng? _currentLocation;

  @override
  void initState() {
    super.initState();
    _checkPermissionsAndGetLocation();
  }

  Future<void> _checkPermissionsAndGetLocation() async {
    // Request location permission
    PermissionStatus permissionStatus = await Permission.location.request();
    if (permissionStatus.isGranted) {
      // Permission granted, get location
      _getCurrentLocation();
    } else {
      // Permission denied, handle accordingly
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Location permission is required to show route.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _getCurrentLocation() async {
    try {
      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
      setState(() {
        _currentLocation = LatLng(position.latitude, position.longitude);
        _setMarkersAndPolyline();
      });
    } catch (e) {
      // Handle location retrieval error
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error retrieving location: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

 void _setMarkersAndPolyline() {
  if (_currentLocation == null) return;

  // Add current location marker
  _markers.add(Marker(
    markerId: MarkerId('currentLocation'),
    position: _currentLocation!,
    icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
    infoWindow: InfoWindow(title: "Current Location"),
  ));

  // Add pharmacy markers
  for (var i = 0; i < widget.pharmacyCoords.length; i++) {
    _markers.add(Marker(
      markerId: MarkerId('pharmacy$i'),
      position: widget.pharmacyCoords[i],
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueOrange),
      infoWindow: InfoWindow(title: "Pharmacy ${i + 1}"),
    ));
  }

  // Add patient marker
  _markers.add(Marker(
    markerId: MarkerId('patientAddress'),
    position: widget.patientCoords,
    icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
    infoWindow: InfoWindow(title: "Patient Address"),
  ));

  // Create a polyline
  List<LatLng> routePoints = [];
  routePoints.add(_currentLocation!);
  routePoints.addAll(widget.pharmacyCoords);
  routePoints.add(widget.patientCoords);

  _polylines.add(Polyline(
    polylineId: PolylineId('route'),
    points: routePoints,
    color: Colors.blue,
    width: 5,
    geodesic: true, // Ensures the polyline follows Earth's curvature
  ));
}


Future<void> _launchGoogleMaps() async {
  if (_currentLocation == null) return;

  // Base URL for Google Maps Directions API
  String googleMapsUrl =
      'https://www.google.com/maps/dir/?api=1&origin=${_currentLocation!.latitude},${_currentLocation!.longitude}';

  // Add waypoints if available
  if (widget.pharmacyCoords.isNotEmpty) {
    googleMapsUrl += '&waypoints=';
    for (int i = 0; i < widget.pharmacyCoords.length; i++) {
      if (i > 0) googleMapsUrl += '|'; // Separate waypoints with '|'
      googleMapsUrl += '${widget.pharmacyCoords[i].latitude},${widget.pharmacyCoords[i].longitude}';
    }
  }

  // Add destination
  googleMapsUrl += '&destination=${widget.patientCoords.latitude},${widget.patientCoords.longitude}&travelmode=driving';

  // Print URL for debugging
  print(googleMapsUrl);

  // Launch Google Maps with the URL
  if (await canLaunch(googleMapsUrl)) {
    await launch(googleMapsUrl);
  } else {
    throw 'Could not launch Google Maps';
  }
}






  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Delivery Route')),
      body: Column(
        children: [
          Expanded(
            child: _currentLocation == null
                ? Center(child: CircularProgressIndicator())
                : GoogleMap(
                    initialCameraPosition: CameraPosition(
                      target: _currentLocation!,
                      zoom: 12,
                    ),
                    polylines: _polylines,
                    markers: _markers,
                    onMapCreated: (GoogleMapController controller) {
                      mapController = controller;
                    },
                  ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton(
              onPressed: _launchGoogleMaps,
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 16.0, horizontal: 32.0),
                backgroundColor: Colors.green,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              child: Text(
                'Open in Google Maps',
                style: TextStyle(fontSize: 18, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
