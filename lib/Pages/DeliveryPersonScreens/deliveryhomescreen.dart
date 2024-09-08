import 'dart:async';
import 'package:DoseDash/Pages/DeliveryPersonScreens/DeliveriesScreen.dart';
import 'package:DoseDash/Pages/DeliveryPersonScreens/DeliveryProfileScreen.dart';
import 'package:DoseDash/Services/NotificationService.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:DoseDash/Services/AuthService.dart';

class DeliveryHomeScreen extends StatefulWidget {
  const DeliveryHomeScreen({Key? key}) : super(key: key);

  @override
  _DeliveryHomeScreenState createState() => _DeliveryHomeScreenState();
}

class _DeliveryHomeScreenState extends State<DeliveryHomeScreen> {
  User? _user;
  Map<String, dynamic>? _deliveryData;
  List<QueryDocumentSnapshot> _deliveryDataActive = [];
  int _selectedIndex = 0;
  int _completedOrders = 0;
  LatLng? _liveLocation;
  StreamSubscription<Position>? _positionStreamSubscription;
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  NotificationService notificationService = NotificationService();

  @override
  void initState() {
    super.initState();
    _fetchDeliveryPersonData();
    _startLocationUpdates();
    // _initializeNotifications();
    // _pushNotifications();

    //notificationService.init();
    //notificationService.pushNotifications();
    _notification();
  }

  @override
  void dispose() {
    _positionStreamSubscription?.cancel();
    notificationService.cancelAllNotifications();
    super.dispose();
  }

  Future<void> _notification() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? authToken = prefs.getString('auth_token');
    String? userId = prefs.getString('userid');
    notificationService.init();
    notificationService.pushNotifications(userId);
  }

  Future<void> _fetchDeliveryPersonData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? authToken = prefs.getString('auth_token');
    String? userId = prefs.getString('userid');

    if (authToken != null) {
      _user = FirebaseAuth.instance.currentUser;

      if (_user != null) {
        DocumentSnapshot deliveryDoc = await FirebaseFirestore.instance
            .collection('DeliveryPersons')
            .doc(userId)
            .get();

        setState(() {
          _deliveryData = deliveryDoc.data() as Map<String, dynamic>?;
        });
      }
    } else {
      print("Auth token is not available.");
    }
  }

  Future<void> _updateLiveLocation() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userId = prefs.getString('userid');

    if (userId != null && _liveLocation != null) {
      await FirebaseFirestore.instance
          .collection('DeliveryPersons')
          .doc(userId)
          .update({
        'geolocation': '${_liveLocation!.latitude},${_liveLocation!.longitude}',
        'lastUpdated': FieldValue.serverTimestamp(),
      });
    }
  }

  // Future<void> _pushNotifications() async {
  //   FirebaseFirestore.instance
  //       .collection('orders')
  //       .where('orderStatus', isEqualTo: 'readyforpickup')
  //       .snapshots()
  //       .listen((QuerySnapshot snapshot) {
  //     for (var doc in snapshot.docs) {
  //       var orderData = doc.data();
  //       showLocalNotification(orderData);
  //     }
  //   });
  // }

  // void _initializeNotifications() {
  //   const AndroidInitializationSettings initializationSettingsAndroid =
  //       AndroidInitializationSettings('ic_launcher');

  //   const InitializationSettings initializationSettings =
  //       InitializationSettings(android: initializationSettingsAndroid);

  //   flutterLocalNotificationsPlugin.initialize(initializationSettings);
  // }

  // void showLocalNotification(orderData) async {
  //   const AndroidNotificationDetails androidPlatformChannelSpecifics =
  //       AndroidNotificationDetails(
  //     'DoseDash_channel',
  //     'DoseDash Delivery',
  //     channelDescription: 'Order Notification',
  //     icon:
  //         "ic_launcher", // Make sure this icon exists in your res/mipmap folder
  //     importance: Importance.max,
  //     priority: Priority.high,
  //   );

  //   const NotificationDetails platformChannelSpecifics =
  //       NotificationDetails(android: androidPlatformChannelSpecifics);

  //   await flutterLocalNotificationsPlugin.show(
  //     0,
  //     'Order Ready for Pickup',
  //     'Order is ready for pickup.',
  //     platformChannelSpecifics,
  //     payload: 'item x',
  //   );
  // }

  void _startLocationUpdates() {
    Position? _lastPosition;
    _positionStreamSubscription =
        Geolocator.getPositionStream().listen((Position position) {
      if (_lastPosition != null &&
          Geolocator.distanceBetween(
                  _lastPosition!.latitude,
                  _lastPosition!.longitude,
                  position.latitude,
                  position.longitude) <
              5) {
        return;
      }
      _lastPosition = position;
      setState(() {
        _liveLocation = LatLng(position.latitude, position.longitude);
      });
      _updateLiveLocation();
    });
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  List<Widget> _buildScreens() {
    return [
      _buildDashboard(),
      _buildDeliveriesScreen(),
      _buildProfileScreen(),
    ];
  }

  Widget _buildDashboard() {
    return _deliveryData == null
        ? Center(child: CircularProgressIndicator())
        : SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Welcome, ${_deliveryData!['First Name']} ${_deliveryData!['Last Name']}!',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 20),
                  GridView.count(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    crossAxisCount: 2,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                    children: [
                      _buildInfoCard(
                        title: 'License ID',
                        value: _deliveryData!['License ID'] ?? 'N/A',
                      ),
                      _buildInfoCard(
                        title: 'Age',
                        value: _deliveryData!['agerange'] ?? 'N/A',
                      ),
                      _buildInfoCard(
                        title: 'Contact',
                        value: _deliveryData!['phone Number'] ?? 'N/A',
                      ),
                      _buildInfoCard(
                        title: 'Vehicle number',
                        value: _deliveryData!['vehicle Number'] ?? 'N/A',
                      ),
                      _buildInfoCard(
                        title: 'Completed Orders',
                        value: _completedOrders.toString(),
                      ),
                      _buildInfoCard(
                        title: 'Active Status',
                        value:
                            _deliveryData!['active'].toString().toUpperCase() ??
                                'N/A', // Dynamically display the active status
                      ),
                    ],
                  ),
                  SizedBox(height: 20),
                  Center(
                      child: ElevatedButton(
                    onPressed: () {
                      _changeActiveStatus();
                    },
                    child: Text('CHANGE ACTIVE STATUS'),
                  ))
                ],
              ),
            ),
          );
  }

  Future<void> _changeActiveStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userId = prefs.getString('userid');

    try {
      // Query the DeliveryPersons collection to find the document by user ID
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('DeliveryPersons')
          .where('uid', isEqualTo: userId)
          .get();

      // Check if any documents were found
      if (snapshot.docs.isNotEmpty) {
        // Loop through the results (even though there should be only one match)
        for (var doc in snapshot.docs) {
          // Get the current value of the 'active' field
          String currentStatus = doc['active'];

          // Determine the new status based on the current status
          String newStatus = (currentStatus == 'online') ? 'offline' : 'online';

          // Update the document with the new status
          await FirebaseFirestore.instance
              .collection('DeliveryPersons')
              .doc(doc.id)
              .update({
            'active': newStatus, // Toggle the active field
          });

          print('Updated active status to $newStatus for userId: $userId');
        }

        // Refetch the delivery data to reflect the changes in the UI
        await _fetchDeliveryPersonData();
      } else {
        print('No matching delivery persons found for userId: $userId');
      }
    } catch (e) {
      print(e);
    }
  }

  Widget _buildInfoCard({required String title, required dynamic value}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 6,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.grey[700],
              ),
            ),
            SizedBox(height: 10),
            Text(
              value.toString(),
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDeliveriesScreen() {
    return DeliveriesScreen();
  }

  Widget _buildProfileScreen() {
    return ProfileScreen2();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('DoseDash Delivery'),
        automaticallyImplyLeading: false,
        backgroundColor: Colors.greenAccent,
        actions: [
          IconButton(
            icon: Icon(Icons.account_circle),
            iconSize: 35,
            onPressed: () {
              _setProfilePicture(context);
            },
          ),
        ],
      ),
      body: _buildScreens().elementAt(_selectedIndex),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.delivery_dining_sharp),
            label: 'Deliveries',
          ),
          BottomNavigationBarItem(
              icon: Icon(Icons.person),
              label: 'Profile',
              backgroundColor: Colors.white),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.greenAccent,
        unselectedItemColor: Colors.blueGrey,
        selectedLabelStyle: TextStyle(fontSize: 12),
        unselectedLabelStyle: TextStyle(fontSize: 12),
        showUnselectedLabels: true,
        onTap: _onItemTapped,
        iconSize: 30,
      ),
    );
  }

  void _setProfilePicture(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Logout'),
          content: Text('Logout from your Delivery System?'),
          actions: [
            TextButton(
              onPressed: () async {
                _logout(context);
              },
              child: Text('Yes'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _logout(BuildContext context) async {
    // Cancel any background tasks (location, notification)
    _positionStreamSubscription?.cancel(); // Cancel location stream

    // If you have any notification subscriptions, stop them here as well
    notificationService
        .cancelAllNotifications(); // Cancel any active notifications

    notificationService.cancelFirestoreListener();

    await Authservice().signout(context: context); // Perform the logout
  }
}
