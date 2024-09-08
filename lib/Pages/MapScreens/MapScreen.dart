import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_places_flutter/model/place_details.dart';
import 'package:uuid/uuid.dart';
import 'package:http/http.dart' as http;
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';


class Mapscreen extends StatefulWidget {
  
   final String userRole; // Add userRole parameter
  const Mapscreen({super.key, required this.userRole}); // Update constructor


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
      'AIzaSyAxPH9a0OR1Ako_KsrRC3z6_wXOlFtfTWM'; // Replace with your Google API Key
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

  void _onDone() async {
  if (_selectedLocation != null) {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        _selectedLocation!.latitude,
        _selectedLocation!.longitude,
      );

      if (placemarks.isNotEmpty) {
        Placemark place = placemarks[0];

     
        
        String address = [
          place.name,
          place.street,
          place.locality,
          place.subAdministrativeArea,
          place.administrativeArea,
          place.postalCode,
          place.country
        ].where((element) => element != null && element.isNotEmpty).join(', ');

    

       if (widget.userRole == 'pharmacy') {
            String coordinates = "${_selectedLocation!.latitude}, ${_selectedLocation!.longitude}";
            Navigator.pop(context, {'address': address, 'coordinates': coordinates});
          } else {
            if (address.isNotEmpty) {
              Navigator.pop(context, address);
            } else {
              Navigator.pop(context, "${_selectedLocation!.latitude}, ${_selectedLocation!.longitude}");
            }
          }
        } else {
          Navigator.pop(context, "${_selectedLocation!.latitude}, ${_selectedLocation!.longitude}");
        }
      } catch (e) {
        Navigator.pop(context, "${_selectedLocation!.latitude}, ${_selectedLocation!.longitude}");
      }
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Location Picker'),
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
            child: GoogleMapSearchPlacesApi(
              onPlaceSelected: (LatLng location) {
                _updateMarker(location);
              },
            ),
          ),
          Positioned(
            left: 20,
            bottom: 100,
            child: FloatingActionButton(
              onPressed: _getUserLocation,
              child: const Icon(Icons.my_location),
              backgroundColor: Colors.blueAccent,
            ),
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

class GoogleMapSearchPlacesApi extends StatefulWidget {
  final Function(LatLng) onPlaceSelected;

  const GoogleMapSearchPlacesApi({Key? key, required this.onPlaceSelected})
      : super(key: key);

  @override
  _GoogleMapSearchPlacesApiState createState() =>
      _GoogleMapSearchPlacesApiState();
}

class _GoogleMapSearchPlacesApiState extends State<GoogleMapSearchPlacesApi> {
  final _controller = TextEditingController();
  var uuid = const Uuid();
  String _sessionToken = '1234567890';
  List<dynamic> _placeList = [];

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onChanged);
  }

  _onChanged() {
    if (_controller.text.isEmpty) {
      setState(() {
        _placeList.clear();
      });
      return;
    }

    setState(() {
      _sessionToken = uuid.v4();
    });
    getSuggestion(_controller.text);
  }

  void getSuggestion(String input) async {
    const String PLACES_API_KEY =
        "AIzaSyAxPH9a0OR1Ako_KsrRC3z6_wXOlFtfTWM"; // Use your actual Google API key

    try {
      String baseURL =
          'https://maps.googleapis.com/maps/api/place/autocomplete/json';
      String request =
          '$baseURL?input=$input&key=$PLACES_API_KEY&sessiontoken=$_sessionToken&language=en&components=country:LK&types=geocode';
      var response = await http.get(Uri.parse(request));
      var data = json.decode(response.body);

      if (response.statusCode == 200) {
        setState(() {
          _placeList = data['predictions'];
        });
      } else {
        throw Exception('Failed to load predictions');
      }
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Align(
          alignment: Alignment.topCenter,
          child: TextField(
            controller: _controller,
            decoration: InputDecoration(
              hintText: "Search your location here",
              focusColor: Colors.white,
              floatingLabelBehavior: FloatingLabelBehavior.never,
              prefixIcon: const Icon(Icons.map),
              suffixIcon: IconButton(
                icon: const Icon(Icons.cancel),
                onPressed: () {
                  _controller.clear();
                },
              ),
            ),
          ),
        ),
        Container(
          height: 200, // Set a fixed height for the search results
          child: ListView.builder(
            itemCount: _placeList.length,
            itemBuilder: (context, index) {
              return GestureDetector(
                onTap: () async {
                  // Fetch place details and update marker
                  String placeId = _placeList[index]["place_id"];
                  String detailsRequest =
                      'https://maps.googleapis.com/maps/api/place/details/json?place_id=$placeId&key=AIzaSyAxPH9a0OR1Ako_KsrRC3z6_wXOlFtfTWM';
                  var detailsResponse =
                      await http.get(Uri.parse(detailsRequest));
                  var detailsData = json.decode(detailsResponse.body);

                  if (detailsResponse.statusCode == 200) {
                    var location =
                        detailsData['result']['geometry']['location'];
                    LatLng latLng = LatLng(location['lat'], location['lng']);

                    // Clear the search field and place list
                    setState(() {
                      _controller.clear();
                      _placeList.clear();
                    });

                    // Call the callback to update the marker on the map
                    widget.onPlaceSelected(latLng);
                  }
                },
                child: ListTile(
                  title: Text(_placeList[index]["description"]),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}