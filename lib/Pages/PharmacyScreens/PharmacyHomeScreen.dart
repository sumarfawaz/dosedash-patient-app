import 'package:DoseDash/Pages/PharmacyScreens/MedicinesScreen.dart';
import 'package:DoseDash/Pages/PharmacyScreens/OrderScreen.dart';
import 'package:DoseDash/Pages/PharmacyScreens/UploadMedicines.dart';
import 'package:DoseDash/Services/AuthService.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PharmacyHomeScreen extends StatefulWidget {
  const PharmacyHomeScreen({Key? key}) : super(key: key);

  @override
  _PharmacyHomeScreenState createState() => _PharmacyHomeScreenState();
}

class _PharmacyHomeScreenState extends State<PharmacyHomeScreen> {
  User? _user;
  Map<String, dynamic>? _pharmacyData;
  int _selectedIndex = 0;
  int _ongoingOrders = 0;
  int _completedOrders = 0;
  int _totalMedicines = 0;

  @override
  void initState() {
    super.initState();
    _fetchPharmacyData();
  }

  Future<void> _fetchPharmacyData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? authToken = prefs.getString('auth_token');
    String? userId = prefs.getString('userid');

    if (authToken != null) {
      _user = FirebaseAuth.instance.currentUser;

      if (_user != null) {
        DocumentSnapshot pharmacyDoc = await FirebaseFirestore.instance
            .collection('pharmacies')
            .doc(userId)
            .get();

        QuerySnapshot ordersSnapshot =
            await FirebaseFirestore.instance.collection('orders').get();

        int ongoingOrders = 0;
        int completedOrders = 0;

        for (var order in ordersSnapshot.docs) {
          List orderItems = order['orderItems'];
          for (var item in orderItems) {
            if (item['pharmacyId'] == userId) {
              if (order['orderStatus'] == 'on progress') {
                ongoingOrders++;
              } else if (order['orderStatus'] == 'completed') {
                completedOrders++;
              }
              break;
            }
          }
        }

        // Fetch total medicines count
        QuerySnapshot medicinesSnapshot = await FirebaseFirestore.instance
            .collection('medicines')
            .where('pharmacyId', isEqualTo: userId)
            .get();

        setState(() {
          _pharmacyData = pharmacyDoc.data() as Map<String, dynamic>?;
          _ongoingOrders = ongoingOrders;
          _completedOrders = completedOrders;
          _totalMedicines =
              medicinesSnapshot.size; // Set the count of medicines
        });
      }
    } else {
      print("Auth token is not available.");
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  List<Widget> _buildScreens() {
    return [
      _buildDashboard(),
      _buildOrdersScreen(),
      _buildMedicinesScreen(),
      _buildUploadMedicineScreen(),
    ];
  }

  Widget _buildDashboard() {
    return _pharmacyData == null
        ? Center(child: CircularProgressIndicator())
        : SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Welcome, ${_pharmacyData!['pharmacyName']}!',
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
                        title: 'License No',
                        value: _pharmacyData!['licenseNo'] ?? 'N/A',
                      ),
                      _buildInfoCard(
                        title: 'City',
                        value: _pharmacyData!['city'] ?? 'N/A',
                      ),
                      _buildInfoCard(
                        title: 'Contact',
                        value: _pharmacyData!['phone'] ?? 'N/A',
                      ),
                      _buildInfoCard(
                        title: 'Ongoing Orders',
                        value: _ongoingOrders.toString(),
                      ),
                      _buildInfoCard(
                        title: 'Completed Orders',
                        value: _completedOrders.toString(),
                      ),
                      _buildInfoCard(
                        title: 'Total Medicines',
                        value: _totalMedicines.toString(),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
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

  Widget _buildOrdersScreen() {
    return OrdersScreen();
  }

  Widget _buildMedicinesScreen() {
    return MedicinesScreen();
  }

  Widget _buildUploadMedicineScreen() {
    return UploadMedicineScreen();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('DoseDash Pharmacy'),
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
            icon: Icon(Icons.add_to_queue),
            label: 'Orders',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.medical_services),
            label: 'Medicines',
          ),
          BottomNavigationBarItem(
              icon: Icon(Icons.upload_file),
              label: 'Upload Medicine',
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
          content: Text('Logout from your Pharmacy Store?'),
          actions: [
            TextButton(
              onPressed: () async {
                await Authservice().signout(context: context);
              },
              child: Text('Yes'),
            ),
          ],
        );
      },
    );
  }
}
