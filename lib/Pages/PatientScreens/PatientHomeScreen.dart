import 'dart:convert'; // Import for base64 decoding
import 'package:DoseDash/Algorithms/GetUserLocation.dart';
import 'package:DoseDash/Pages/PatientScreens/UploadPrescription.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:hexcolor/hexcolor.dart';
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
    //_getUserLocation();
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
    LocationService locationService = LocationService();
    LatLng? userLocation = await locationService.getUserLocation();
    print("User Location  $userLocation");
    List<String> nearbyPharmacyUIDs =
        await locationService.getNearbyPharmacies(userLocation!);

    if (nearbyPharmacyUIDs.isNotEmpty) {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('medicines')
          .where('pharmacyId', whereIn: nearbyPharmacyUIDs)
          .get();

      setState(() {
        _medicines = querySnapshot.docs.map((doc) {
          return Medicine(
            id: doc.id,
            name: doc['medicineName'],
            brand: doc['brandName'],
            price: doc['unitPrice'],
            pharmacyId: doc['pharmacyId'],
            image: doc['medicineImageBase64'],
          );
        }).toList();
        _filteredMedicines = _medicines;
      });
    }
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
                SizedBox(
                  height: 20,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      labelText: 'Search Medicines',
                      prefixIcon: Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius:
                            BorderRadius.circular(20.0), // Rounded corners
                        borderSide: BorderSide.none, // Remove border outline
                      ),
                      filled: true, // Enable background color
                      fillColor: Colors.grey[200], // Set background color
                    ),
                    onChanged: _onSearchTextChanged,
                  ),
                ),
                SizedBox(height: 10),
                Expanded(
                  child: GridView.builder(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 3 / 4, // Adjust ratio for card layout
                    ),
                    itemCount: _filteredMedicines.length,
                    itemBuilder: (context, index) {
                      var medicine = _filteredMedicines[index];
                      return Card(
                        color: Colors.white, // Card background color
                        elevation: 5, // Elevation (shadow) for the card
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                              20), // Rounded corners for the Card
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Expanded(
                              child: medicine.image.isNotEmpty
                                  ? ClipRRect(
                                      borderRadius: BorderRadius.vertical(
                                          top: Radius.circular(20)),
                                      child: Image.memory(
                                        base64Decode(medicine.image),
                                        fit: BoxFit.contain,
                                      ),
                                    )
                                  : ClipRRect(
                                      borderRadius: BorderRadius.vertical(
                                          top: Radius.circular(20)),
                                      child:
                                          Container(), // Placeholder if no image
                                    ),
                            ),
                            // Dark grey background color for the section below the image
                            Container(
                              decoration: BoxDecoration(
                                color: Color(
                                    0xFF686D76), // Dark grey background color
                                borderRadius: BorderRadius.vertical(
                                  bottom: Radius.circular(
                                      20), // Rounded bottom corners to match the card
                                ),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(
                                    8.0), // Padding around the text and button
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      medicine.name,
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                        color: Colors
                                            .white, // Text color for better visibility on dark grey background
                                      ),
                                    ),
                                    SizedBox(height: 4),
                                    Text(
                                      medicine.brand,
                                      style: TextStyle(
                                        color: Colors.grey[
                                            400], // Light grey for the brand text
                                      ),
                                    ),
                                    SizedBox(height: 4),
                                    Text(
                                      '\රු${medicine.price.toStringAsFixed(2)}',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Colors
                                            .white, // Text color for better visibility
                                      ),
                                    ),
                                    SizedBox(
                                        height:
                                            8), // Add some spacing before the button
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment
                                          .center, // Center the button
                                      children: [
                                        SizedBox(
                                          width: 150, // Button width
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
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: Color(
                                                  0xFF11BA63), // Button background color
                                              elevation:
                                                  5, // Elevation for shadow
                                              shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(
                                                    20.0), // Rounded corners for button
                                              ),
                                            ),
                                            child: Text(
                                              'Buy',
                                              style: TextStyle(
                                                color: Colors
                                                    .white, // Text color inside button
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                )
              ],
            ),
    );
  }

  void _addToCart(Medicine medicine) {
    setState(() {
      globalCart.add(medicine);
    });
  }

  /*@override
  Widget build(BuildContext context) {
    super.build(
        context); // Call to super.build for AutomaticKeepAliveClientMixin
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(120.0),
        child: ClipRRect(
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(30.0),
            bottomRight: Radius.circular(30.0),
          ),
          child: Container(
            padding: EdgeInsets.only(top: 40.0, left: 16.0, right: 16.0),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color.fromARGB(131, 54, 221, 104),
                  Color.fromARGB(255, 69, 234, 143)
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.5),
                  blurRadius: 10.0,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'DoseDash Delivery',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color.fromARGB(255, 19, 19, 19),
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.account_circle, size: 35),
                      onPressed: () {
                        _setProfilePicture(context);
                      },
                    ),
                  ],
                ),
                SizedBox(height: 1),
                if (_userData != null)
                  Text(
                    'Welcome, ${_userData!['firstname']} ${_userData!['lastname']}!',
                    style: TextStyle(
                      fontSize: 20, /*fontWeight: FontWeight.bold*/
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),*/

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(120.0),
        child: ClipRRect(
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(30.0),
            bottomRight: Radius.circular(30.0),
          ),
          child: Container(
            padding: EdgeInsets.only(top: 40.0, left: 16.0, right: 16.0),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color.fromARGB(131, 54, 221, 104),
                  Color.fromARGB(255, 69, 234, 143)
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 10.0,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'DoseDash Patient',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color.fromARGB(255, 19, 19, 19),
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.logout, size: 35),
                      onPressed: () {
                        _setProfilePicture(context);
                      },
                    ),
                  ],
                ),
                SizedBox(height: 1),
                if (_userData != null)
                  Text(
                    'Welcome, ${_userData!['firstname']} ${_userData!['lastname']}!',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color.fromARGB(168, 23, 22, 22),
                    ),
                  ),
              ],
            ),
          ),
        ),
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
            icon: Icon(Icons.label, size: 30),
            label: 'Order History',
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
  final String image;
  final String brand;
  final double price;
  int quantity;
  final String pharmacyId;

  Medicine({
    required this.id,
    required this.name,
    required this.image,
    required this.brand,
    required this.price,
    this.quantity = 1,
    required this.pharmacyId,
  });
}
