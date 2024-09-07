import 'package:DoseDash/Pages/DeliveryPersonScreens/DeliveriesScreen.dart';
import 'package:DoseDash/Pages/DeliveryPersonScreens/RouteScreen.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PickupPointsScreen extends StatelessWidget {
  final List<String> pharmacyAddresses;
  final List<String> pharmacyNames;
  final String patientAddress;
  final String notificationId; // ID of the notification to be deleted
  final VoidCallback onDecline; // Callback to notify when the notification is declined

  const PickupPointsScreen({
    Key? key,
    required this.pharmacyAddresses,
    required this.pharmacyNames,
    required this.patientAddress,
    required this.notificationId,
    required this.onDecline,
  }) : super(key: key);

  Future<List<LatLng>> _convertAddressesToCoordinates(List<String> addresses) async {
    List<LatLng> coordinates = [];
    for (String address in addresses) {
      try {
        List<Location> locations = await locationFromAddress(address);
        if (locations.isNotEmpty) {
          coordinates.add(LatLng(locations[0].latitude, locations[0].longitude));
        } else {
          print('No locations found for address: $address');
        }
      } catch (e) {
        print('Error converting address to coordinates: $e');
      }
    }
    return coordinates;
  }

  void _handleDecline(BuildContext context) async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirm'),
          content: Text('Are you sure you want to decline this order?'),
          actions: [
            TextButton(
              child: Text('No'),
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
            ),
            TextButton(
              child: Text('Yes'),
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
                onDecline(); // Notify the DeliveriesScreen to update the list
                FirebaseFirestore.instance.collection('notifications').doc(notificationId).delete(); // Delete the notification document
                Navigator.of(context).pop(); // Go back to the previous screen
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Deliveries for You'),
        backgroundColor: Color(0xFF69F0AE), // Green app bar
        centerTitle: true,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Pickup Points',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              itemCount: pharmacyAddresses.length,
              itemBuilder: (context, index) {
                return Card(
                  margin: EdgeInsets.symmetric(vertical: 8.0),
                  elevation: 4.0,
                  child: ListTile(
                    title: Text(pharmacyNames[index]),
                    subtitle: Text(pharmacyAddresses[index]),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Delivery Address',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Card(
            margin: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            elevation: 4.0,
            child: ListTile(
              title: Text('Patient Address'),
              subtitle: Text(patientAddress),
            ),
          ),
          SizedBox(height: 16), // Add some space below the delivery address
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(
                onPressed: () async {
                  // Show a loading indicator until the coordinates are fetched
                  showDialog(
                    context: context,
                    barrierDismissible: false,
                    builder: (BuildContext context) {
                      return Center(child: CircularProgressIndicator());
                    },
                  );

                  try {
                    // Convert addresses to coordinates
                    List<LatLng> pharmacyCoords = await _convertAddressesToCoordinates(pharmacyAddresses);
                    LatLng patientCoords = (await _convertAddressesToCoordinates([patientAddress]))[0];

                    // Close the loading dialog
                    Navigator.pop(context);

                    // Navigate to RouteScreen with coordinates
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => RouteScreen(
                          pharmacyCoords: pharmacyCoords,
                          patientCoords: patientCoords,
                        ),
                      ),
                    );
                  } catch (e) {
                    print('Error: $e');
                    // Close the loading dialog
                    Navigator.pop(context);
                    // Show an error dialog
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: Text('Error'),
                          content: Text('Could not load map coordinates. Please try again.'),
                          actions: [
                            TextButton(
                              child: Text('OK'),
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                            ),
                          ],
                        );
                      },
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF4CAF50), // Green color
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  padding: EdgeInsets.symmetric(vertical: 16.0, horizontal: 32.0), // Increase button size
                  textStyle: TextStyle(fontSize: 18), // Increase text size
                ),
                child: Text('Accept', style: TextStyle(color: Colors.white)),
              ),
              ElevatedButton(
                onPressed: () => _handleDecline(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red, // Red color
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  padding: EdgeInsets.symmetric(vertical: 16.0, horizontal: 32.0), // Increase button size
                  textStyle: TextStyle(fontSize: 18), // Increase text size
                ),
                child: Text('Decline', style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
          SizedBox(height: 16), // Add some space below the buttons
        ],
      ),
    );
  }
}
