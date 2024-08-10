import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_places_flutter/google_places_flutter.dart';
import 'package:google_places_flutter/model/place_type.dart';
import 'package:google_places_flutter/model/prediction.dart';
import 'package:geolocator/geolocator.dart';

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
  Circle? _userLocationCircle;
  final String googleApiKey =
      'AIzaSyCKAixG6wsvD6xYd27f6U_XHms5D8-jONk'; // Replace with your Google API Key
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _getUserLocation();
  }

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
      print(_selectedLocation.toString());
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a location on the map.'),
        ),
      );
    }
  }

  Future<void> _getUserLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Check if location services are enabled
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Location services are not enabled, request the user to enable it
      return;
    }

    // Check for location permissions
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // Permissions are denied, exit
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Permissions are denied forever, handle appropriately
      return;
    }

    // Get the current location of the user
    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    LatLng userLocation = LatLng(position.latitude, position.longitude);

    setState(() {
      _userLocationCircle = Circle(
        circleId: CircleId('user_location'),
        center: userLocation,
        radius: 100, // Radius in meters
        strokeColor: Colors.blueAccent,
        strokeWidth: 2,
        fillColor: Colors.blueAccent.withOpacity(0.5),
      );

      // Move the camera to the user's location
      mapController.animateCamera(CameraUpdate.newLatLngZoom(userLocation, 15));
    });
  }

  Widget placesAutoCompleteTextField() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20),
      child: GooglePlaceAutoCompleteTextField(
        textEditingController: _searchController,
        googleAPIKey: "AIzaSyCKAixG6wsvD6xYd27f6U_XHms5D8-jONk",
        inputDecoration: InputDecoration(
          hintText: "Search your location",
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
        ),
        debounceTime: 400,
        countries: ["LK"],
        isLatLngRequired: true,
        getPlaceDetailWithLatLng: (Prediction prediction) {
          // Debugging: Print prediction details
          print("getPlaceDetailWithLatLng callback triggered");
          print(
              "Prediction details: lat=${prediction.lat}, lng=${prediction.lng}");

          // Update marker on map
          if (prediction.lat != null && prediction.lng != null) {
            _updateMarker(
                LatLng(prediction.lat as double, prediction.lng as double));
          } else {
            print("Latitude or Longitude is null");
          }
        },
        itemClick: (Prediction prediction) {
          // Debugging: Print prediction description
          print("itemClick callback triggered");
          print("Prediction description: ${prediction.description}");

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
            circles: _userLocationCircle != null ? {_userLocationCircle!} : {},
          ),
          Positioned(
            top: 20,
            left: 20,
            right: 20,
            child: placesAutoCompleteTextField(),
          ),
          Positioned(
            bottom: 20,
            left: MediaQuery.of(context).size.width * 0.25,
            right: MediaQuery.of(context).size.width * 0.25,
            child: SizedBox(
              width: MediaQuery.of(context).size.width * 0.5,
              height: 50,
              child: ElevatedButton(
                onPressed: _onDone,
                child: const Text('Done'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
