import 'package:DoseDash/Algorithms/GetUserLocation.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({Key? key}) : super(key: key);

  @override
  _OrdersScreenState createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  List<Medicine> _medicines = [];
  List<Medicine> _filteredMedicines = [];
  String pharmacyId = '';

  @override
  void initState() {
    super.initState();
    _fetchPharmacyId().then((value) {
      setState(() {
        pharmacyId = value;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Orders'),
        automaticallyImplyLeading: false,
        centerTitle: true,
      ),
      body: pharmacyId.isEmpty
          ? Center(child: CircularProgressIndicator())
          : StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('orders')
                  .where('pharmacyId', isEqualTo: pharmacyId)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(child: Text('No orders found.'));
                }

                return ListView.builder(
                  itemCount: snapshot.data!.docs.length,
                  itemBuilder: (context, index) {
                    var order = snapshot.data!.docs[index];
                    return Card(
                      margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      child: ListTile(
                        title: Text('Order ID: ${order.id}'),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Patient Name: ${order['user_name']}'),
                            Text('Phone Number: ${order['phone_number']}'),
                            Text('Status: ${order['orderStatus']}'),
                          ],
                        ),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  OrderDetailsScreen(order: order),
                            ),
                          );
                        },
                        trailing: ElevatedButton(
                          onPressed: () {
                            _completeOrder(order.id);
                          },
                          child: Text('Complete Order'),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
    );
  }

  // Fetching pharmacy ID from shared preferences
  Future<String> _fetchPharmacyId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? pharmacyId = prefs.getString('userid');
    return pharmacyId ?? '';
  }

  // Complete order method
  Future<void> _completeOrder(String orderId) async {
    try {
      // Fetching Pharmacy Location as a geocoordinate
      QuerySnapshot pharmacyQuery = await FirebaseFirestore.instance
          .collection('pharmacies')
          .where('uid', isEqualTo: pharmacyId)
          .get();

      if (pharmacyQuery.docs.isNotEmpty) {
        var pharmacyDoc = pharmacyQuery.docs.first;

        // Assuming the location is stored as a GeoPoint in the pharmacy document
        String geoPointString = pharmacyDoc['coordinates']; // Firestore String
        List<String> latLng = geoPointString.split(',');

// Parse the latitude and longitude from the string
        double latitude = double.parse(latLng[0]);
        double longitude = double.parse(latLng[1]);

// Create the GeoPoint object
        GeoPoint geoPoint = GeoPoint(latitude, longitude);

        // Convert GeoPoint to LatLng for Google Maps usage
        LatLng pharmacyLocation = LatLng(geoPoint.latitude, geoPoint.longitude);

        LocationService locationService = LocationService();

        // Now use the pharmacyLocation as the user's location to get nearby delivery persons
        List<String> nearbyDeliveryPersons =
            await locationService.getNearbyDeliveryPersons(pharmacyLocation);

        print('Nearby delivery persons: $nearbyDeliveryPersons');

        //Creating a new collection called orderNotifier in fire base
        //Adding both orderId and list of deliveryPersons ids
        //Setting orderStatus as readyforpickup
        await FirebaseFirestore.instance.collection('orderNotifier').add({
          'orderNotifierId': orderId,
          'nearByRiders': nearbyDeliveryPersons,
          'orderStatus': 'readyforpickup',
          'timestamp': FieldValue.serverTimestamp(),
        });
        print('order is been stored in the order notifier collection');
      } else {
        print('Pharmacy not found.');
      }
    } catch (e) {
      print('Error completing order: $e');
    }
  }
}

class OrderDetailsScreen extends StatelessWidget {
  final QueryDocumentSnapshot order;

  OrderDetailsScreen({required this.order});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Order Details'),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Order ID: ${order.id}',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),
          ListTile(
            title: Text('Patient Name: ${order['user_name']}'),
          ),
          ListTile(
            title: Text('Phone Number: ${order['phone_number']}'),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: order['orderItems'].length,
              itemBuilder: (context, index) {
                var item = order['orderItems'][index];
                return ListTile(
                  title: Text(item['name']),
                  subtitle: Text('Quantity: ${item['quantity']}'),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// Example Medicine class (adjust as per your data structure)
class Medicine {
  final String id;
  final String name;
  final String brand;
  final double price;
  final String pharmacyId;
  final String image;

  Medicine({
    required this.id,
    required this.name,
    required this.brand,
    required this.price,
    required this.pharmacyId,
    required this.image,
  });
}
