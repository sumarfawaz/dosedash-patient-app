import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_places_flutter/google_places_flutter.dart';
import 'package:google_places_flutter/model/place_type.dart';
import 'package:google_places_flutter/model/prediction.dart';

class Mapscreen extends StatefulWidget {
  const Mapscreen({super.key});

  @override
  State<Mapscreen> createState() => _MapscreenState();
}

class _MapscreenState extends State<Mapscreen> {
  late GoogleMapController mapController;
  final LatLng _center =
      const LatLng(6.927079, 79.861244); // Default location (Colombo)
  LatLng? _selectedLocation;
  Marker? _selectedMarker;
  final String googleApiKey =
      'AIzaSyC67yTbeH3KMgJ4K7w6UDDMoRZ_39z7Vmg'; // Replace with your Google API Key
  final TextEditingController _searchController = TextEditingController();

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  void _onMapTapped(LatLng location) {
    _updateMarker(location);
  }

  void _updateMarker(LatLng location) {
    setState(() {
      _selectedLocation = location;
      _selectedMarker = Marker(
        markerId: const MarkerId('selected_location'),
        position: location,
      );
    });
    mapController.animateCamera(CameraUpdate.newLatLng(location));
  }

  void _onDone() {
    if (_selectedLocation != null) {
      Navigator.pop(context, _selectedLocation);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a location on the map.'),
        ),
      );
    }
  }

  Widget placesAutoCompleteTextField() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20),
      child: GooglePlaceAutoCompleteTextField(
        textEditingController: _searchController,
        googleAPIKey: "AIzaSyB7Gq4LVJViPLWFx82uh1eLlKFPMhu7Wvs",
        inputDecoration: InputDecoration(
          hintText: "Search your location",
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
        ),
        debounceTime: 400,
        countries: ["LK"],
        isLatLngRequired: true,
        getPlaceDetailWithLatLng: (Prediction prediction) {
          print("Place details: ${prediction.lat}, ${prediction.lng}");
          _updateMarker(
              LatLng(prediction.lat as double, prediction.lng as double));
        },
        itemClick: (Prediction prediction) {
          _searchController.text = prediction.description ?? "";
          _searchController.selection = TextSelection.fromPosition(
              TextPosition(offset: prediction.description?.length ?? 0));
        },
        itemBuilder: (context, index, Prediction prediction) {
          return Container(
            padding: EdgeInsets.all(10),
            child: Row(
              children: [
                Icon(Icons.location_on),
                SizedBox(width: 7),
                Expanded(child: Text("${prediction.description ?? ""}")),
              ],
            ),
          );
        },
        seperatedBuilder: Divider(),
        isCrossBtnShown: true,
        containerHorizontalPadding: 10,
        placeType: PlaceType.geocode,
      ),
    );
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
              target: _center,
              zoom: 12,
            ),
            onTap: _onMapTapped,
            markers: _selectedMarker != null ? {_selectedMarker!} : {},
          ),
          Positioned(
            top: 20,
            left: 20,
            right: 20,
            child: placesAutoCompleteTextField(),
          ),
          Positioned(
            bottom: 20,
            left: 20,
            right: 20,
            child: ElevatedButton(
              onPressed: _onDone,
              child: const Text('Done'),
            ),
          ),
        ],
      ),
    );
  }
}

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
