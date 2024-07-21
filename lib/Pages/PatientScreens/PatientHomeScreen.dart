import 'dart:convert'; // Import for base64 decoding
import 'package:DoseDash/Pages/PatientScreens/UploadPrescription.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../Services/AuthService.dart';
import 'CartScreen.dart';
import 'ProfileScreen.dart';
import 'MedicineDetailScreen.dart';

class Patienthomescreen extends StatefulWidget {
  const Patienthomescreen({Key? key}) : super(key: key);

  @override
  _PatientHomeScreenState createState() => _PatientHomeScreenState();
}

class _PatientHomeScreenState extends State<Patienthomescreen>
    with AutomaticKeepAliveClientMixin {
  User? _user;
  Map<String, dynamic>? _userData;
  int _selectedIndex = 0;
  List<Medicine> _medicines = [];
  List<Medicine> _filteredMedicines = [];
  TextEditingController _searchController = TextEditingController();
  List<Medicine> globalCart = [];
  DateTime? _lastTap;

  @override
  void initState() {
    super.initState();
    _fetchUserData();
    _fetchMedicines();
  }

  Future<void> _fetchUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? authToken = prefs.getString('auth_token');
    String? userId = prefs.getString('userid');

    if (authToken != null) {
      _user = FirebaseAuth.instance.currentUser;

      if (_user != null) {
        DocumentSnapshot userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .get();

        setState(() {
          _userData = userDoc.data() as Map<String, dynamic>?;
        });
      }
    } else {
      print("Auth token is not available.");
    }
  }

  Future<void> _fetchMedicines() async {
    QuerySnapshot querySnapshot =
        await FirebaseFirestore.instance.collection('medicines').get();

    setState(() {
      _medicines = querySnapshot.docs.map((doc) {
        return Medicine(
          id: doc.id,
          name: doc['medicineName'],
          brand: doc['brandName'],
          price: doc['unitPrice'],
          pharmacyId: doc['pharmacyId'],
          image: doc[
              'medicineImageBase64'], // Assuming the image is stored as base64
        );
      }).toList();
      _filteredMedicines = _medicines;
    });
  }

  void _onItemTapped(int index) {
    if (_selectedIndex == index && index == 0) {
      DateTime now = DateTime.now();
      if (_lastTap != null &&
          now.difference(_lastTap!) < Duration(seconds: 1)) {
        Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
      }
      _lastTap = now;
    }

    setState(() {
      _selectedIndex = index;
    });
  }

  void _onSearchTextChanged(String text) {
    setState(() {
      _filteredMedicines = _medicines
          .where((medicine) =>
              medicine.name.toLowerCase().contains(text.toLowerCase()))
          .toList();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_selectedIndex == 0) {
      _fetchMedicines();
      _fetchUserData();
    }
  }

  Widget _getSelectedScreen() {
    switch (_selectedIndex) {
      case 1:
        return CartScreen(globalCart: globalCart);
      case 2:
        return UploadPrescriptionScreen();
      case 3:
        return ProfileScreen();
      default:
        return _buildHomeScreen();
    }
  }

  Widget _buildHomeScreen() {
    super.build(context);
    return Center(
      child: _userData == null
          ? CircularProgressIndicator()
          : Column(
              children: [
                Text(
                  'Welcome, ${_userData!['firstname']} ${_userData!['lastname']}!',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      labelText: 'Search Medicines',
                      prefixIcon: Icon(Icons.search),
                      border: OutlineInputBorder(),
                    ),
                    onChanged: _onSearchTextChanged,
                  ),
                ),
                SizedBox(height: 20),
                Expanded(
                  child: GridView.builder(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      childAspectRatio: 3 / 4, // Adjust ratio for card layout
                    ),
                    itemCount: _filteredMedicines.length,
                    itemBuilder: (context, index) {
                      var medicine = _filteredMedicines[index];
                      return Card(
                        elevation: 5,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Expanded(
                              child: medicine.image.isNotEmpty
                                  ? Image.memory(
                                      base64Decode(medicine.image),
                                      fit: BoxFit.cover,
                                    )
                                  : Container(), // Placeholder if no image
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    medicine.name,
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                  SizedBox(height: 4),
                                  Text(
                                    medicine.brand,
                                    style: TextStyle(color: Colors.grey),
                                  ),
                                  SizedBox(height: 4),
                                  Text(
                                    '\රු${medicine.price.toStringAsFixed(2)}',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 8.0),
                              child: ElevatedButton(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          MedicineDetailScreen(
                                        medicine: medicine,
                                        addToCart: _addToCart,
                                      ),
                                    ),
                                  );
                                },
                                child: Text('Buy'),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
    );
  }

  void _addToCart(Medicine medicine) {
    setState(() {
      globalCart.add(medicine);
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(
        context); // Call to super.build for AutomaticKeepAliveClientMixin
    return Scaffold(
      appBar: AppBar(
        title: Text('DoseDash'),
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
      body: _getSelectedScreen(),
      bottomNavigationBar: BottomNavigationBar(
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: GestureDetector(
              onDoubleTap: () {
                Navigator.pushNamedAndRemoveUntil(
                    context, '/', (route) => false);
              },
              child: Icon(Icons.home, size: 30),
            ),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_cart, size: 30),
            label: 'Cart',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.upload, size: 30),
            label: 'Upload',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_circle, size: 30),
            label: 'Profile',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.greenAccent,
        unselectedItemColor: Colors.blueGrey,
        selectedLabelStyle: TextStyle(fontSize: 12),
        unselectedLabelStyle: TextStyle(fontSize: 12),
        showUnselectedLabels: true,
        onTap: _onItemTapped,
        iconSize: 30, // Set the uniform icon size
      ),
    );
  }

  void _setProfilePicture(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Logout'),
          content: Text('Logout from your Patient Hub?'),
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

  @override
  bool get wantKeepAlive => true; // Ensure the state is kept alive
}

class Medicine {
  final String id;
  final String name;
  final String brand;
  final double price;
  final String pharmacyId;
  final String image; // Add this field to store base64 image string
  int quantity;

  Medicine({
    required this.id,
    required this.name,
    required this.brand,
    required this.price,
    required this.pharmacyId,
    required this.image,
    this.quantity = 1,
  });
}
