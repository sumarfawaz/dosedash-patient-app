import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class Mapscreen extends StatefulWidget {
  const Mapscreen({super.key});

  @override
  State<Mapscreen> createState() => _MapscreenState();
}

class _MapscreenState extends State<Mapscreen> {
  late GoogleMapController mapController; // Controller to interact with the GoogleMap
  final LatLng _center = const LatLng(6.927079, 79.861244); // Default location (Colombo)
  LatLng? _selectedLocation; // Variable to store the location selected by the user
  Marker? _selectedMarker; // Marker to represent the selected location on the map

  // Method called when the map is created
  void _onMapCreated(GoogleMapController controller) {
    mapController = controller; // Initialize the map controller
  }

  // Method called when the user taps on the map
  void _onMapTapped(LatLng location) {
    setState(() {
      _selectedLocation = location; // Store the tapped location
      _selectedMarker = Marker(
        markerId: MarkerId('selected_location'), // Unique ID for the marker
        position: location, // Position the marker at the tapped location
      );
    });
  }

  // Method called when the "Done" button is pressed
  void _onDone() {
    if (_selectedLocation != null) {
      // If a location has been selected
      Navigator.pop(context, _selectedLocation); // Return the selected location to the previous screen
    } else {
      // If no location has been selected, show a message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a location on the map.'), // Error message
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Maps Sample App'), // Title of the app bar
        backgroundColor: Colors.green[700], // Background color of the app bar
      ),
      body: Stack(
        children: [
          // Google Map widget
          GoogleMap(
            onMapCreated: _onMapCreated, // Initialize the map when it's created
            initialCameraPosition: CameraPosition(
              target: _center, // Set the initial camera position to Colombo
              zoom: 12, // Initial zoom level
            ),
            onTap: _onMapTapped, // Add a marker when the map is tapped
            markers: _selectedMarker != null ? {_selectedMarker!} : {}, // Display the selected marker if it exists
          ),
          // Positioned widget to place the "Done" button at the bottom
          Positioned(
            bottom: 20,
            left: 20,
            right: 20,
            child: ElevatedButton(
              onPressed: _onDone, // Call the _onDone method when the button is pressed
              child: const Text('Done'), // Text on the button
            ),
          ),
        ],
      ),
    );
  }
}
