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
