import 'package:DoseDash/Pages/DeliveryPersonScreens/DeliveriesScreen.dart';
import 'package:DoseDash/Pages/DeliveryPersonScreens/DeliveryProfileScreen.dart';
import 'package:DoseDash/Pages/PatientScreens/ProfileScreen.dart';
import 'package:DoseDash/Pages/PharmacyScreens/MedicinesScreen.dart';
import 'package:DoseDash/Pages/PharmacyScreens/OrderScreen.dart';
import 'package:DoseDash/Pages/PharmacyScreens/UploadMedicines.dart';
import 'package:DoseDash/Services/AuthService.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Define the DeliveryHomeScreen widget as a stateful widget to maintain state
class DeliveryHomeScreen extends StatefulWidget {
  const DeliveryHomeScreen({Key? key}) : super(key: key);

  @override
  _DeliveryHomeScreenState createState() => _DeliveryHomeScreenState();
}

// Define the state for PharmacyHomeScreen
class _DeliveryHomeScreenState extends State<DeliveryHomeScreen> {
  User? _user; // Firebase user object to hold the authenticated user
  Map<String, dynamic>? _deliveryData; // Holds delivery person data fetched from Firestore
  int _selectedIndex = 0; // Index of the selected item in the bottom navigation bar
 
  int _completedOrders = 0; // Number of completed orders


  // Initialize the state
  @override
  void initState() {
    super.initState();
    _fetchDeliveryPersonData(); // Fetch pharmacy data when the screen is initialized
  }

  // Fetch pharmacy data from Firestore and update the state
  Future<void> _fetchDeliveryPersonData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? authToken = prefs.getString('auth_token'); // Get the auth token from shared preferences
    String? userId = prefs.getString('userid'); // Get the user ID from shared preferences

    if (authToken != null) {
      _user = FirebaseAuth.instance.currentUser; // Get the current Firebase user

      if (_user != null) {
        // Fetch pharmacy document from Firestore using the user ID
        DocumentSnapshot deliveryDoc = await FirebaseFirestore.instance
            .collection('DeliveryPersons')
            .doc(userId)
            .get();

        // Fetch all orders from Firestore
        //QuerySnapshot ordersSnapshot =
           // await FirebaseFirestore.instance.collection('orders').get();


       


        // Update the state with fetched data
        setState(() {
          _deliveryData = deliveryDoc.data() as Map<String, dynamic>?; // Store deliveryperson data
          
        });
      }
    } else {
      print("Auth token is not available."); // Print a message if auth token is not available
    }
  }

  // Update the selected index when a bottom navigation item is tapped
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index; // Update the selected index
    });
  }

  // Build the list of screens for bottom navigation
  List<Widget> _buildScreens() {
    return [
      _buildDashboard(), // Dashboard screen
      _buildDeliveriesScreen(), // Orders screen
      _buildprofileScreen(), // Medicines screen
      
    ];
  }

//----------------------------------------------------------------------------------------------------------------------



  // Build the dashboard screen with pharmacy details
  Widget _buildDashboard() {
    return _deliveryData == null
        ? Center(child: CircularProgressIndicator()) // Show a loading indicator if data is not yet fetched
        : SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0), // Add padding to the dashboard
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start, // Align content to the start
                children: [
                  Text(
                    'Welcome, ${_deliveryData!['First Name']} ${_deliveryData!['Last Name']}!' , // Display delivery person name
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold), // Style the text
                  ),
                  SizedBox(height: 20), // Add space below the text
                  // GridView to display pharmacy information in cards
                  GridView.count(
                    shrinkWrap: true, // Let the grid view take up only necessary space
                    physics: NeverScrollableScrollPhysics(), // Disable scrolling for the grid view
                    crossAxisCount: 2, // Display two columns
                    crossAxisSpacing: 10, // Add space between columns
                    mainAxisSpacing: 10, // Add space between rows
                    children: [
                      _buildInfoCard(
                        title: 'License ID', // Display license ID
                        value: _deliveryData!['License ID'] ?? 'N/A',
                      ),
                      _buildInfoCard(
                        title: 'City', // Display city
                        value: _deliveryData!['city'] ?? 'N/A',
                      ),
                      _buildInfoCard(
                        title: 'Contact', // Display contact number
                        value: _deliveryData!['phone Number'] ?? 'N/A',
                      ),
                      _buildInfoCard(
                        title: 'Address', // Display Address
                        value: _deliveryData!['Address'] ?? 'N/A',
                      ),
                       _buildInfoCard(
                        title: 'Vehicle number', // Display vehicle number
                        value: _deliveryData!['vehicle Number'] ?? 'N/A',
                      ),
                      _buildInfoCard(
                        title: 'Completed Orders', // Display completed orders count
                        value: _completedOrders.toString(),
                      ),
                      
                    ],
                  ),
                ],
              ),
            ),
          );
  }

  // Build a card widget to display pharmacy information
  Widget _buildInfoCard({required String title, required dynamic value}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white, // Set background color to white
        borderRadius: BorderRadius.circular(8), // Round the corners
        boxShadow: [
          BoxShadow(
            color: Colors.black12, // Set shadow color
            blurRadius: 6, // Blur effect
            offset: Offset(0, 2), // Offset the shadow
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0), // Add padding inside the card
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center, // Center the content vertically
          children: [
            Text(
              title, // Display the title
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.grey[700], // Set text color
              ),
            ),
            SizedBox(height: 10), // Add space below the title
            Text(
              value.toString(), // Display the value
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black, // Set text color
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Build the orders screen
  Widget _buildDeliveriesScreen() {
    return DeliveriesScreen(); // Return the Deliveries Screen
  }

  // Build the medicines screen
  Widget _buildprofileScreen() {
    return ProfileScreen2(); // Return the Profilescreen
  }

 





//----------------------------------------------------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('DoseDash Pharmacy'), // Set the title of the app bar
        automaticallyImplyLeading: false, // Don't show the back button
        backgroundColor: Colors.greenAccent, // Set the background color
        actions: [
          IconButton(
            icon: Icon(Icons.account_circle), // Set the profile icon
            iconSize: 35, // Set the icon size
            onPressed: () {
              _setProfilePicture(context); // Show the logout dialog when tapped
            },
          ),
        ],
      ),
      body: _buildScreens().elementAt(_selectedIndex), // Display the selected screen
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home), // Home icon
            label: 'Home', // Home label
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.delivery_dining_sharp), // Orders icon
            label: 'Deliveries', // Orders label
          ),
        
          BottomNavigationBarItem(
              icon: Icon(Icons.person), // Upload icon
              label: 'Profile', // Upload label
              backgroundColor: Colors.white),
        ],
        currentIndex: _selectedIndex, // Set the current selected index
        selectedItemColor: Colors.greenAccent, // Color for the selected item
        unselectedItemColor: Colors.blueGrey, // Color for unselected items
        selectedLabelStyle: TextStyle(fontSize: 12), // Style for the selected label
        unselectedLabelStyle: TextStyle(fontSize: 12), // Style for unselected labels
        showUnselectedLabels: true, // Show labels for unselected items
        onTap: _onItemTapped, // Update the index when an item is tapped
        iconSize: 30, // Set the icon size
      ),
    );
  }

  // Show dialog to confirm logout
  void _setProfilePicture(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Logout'), // Title of the dialog
          content: Text('Logout from your Delivery System?'), // Message of the dialog
          actions: [
            TextButton(
              onPressed: () async {
                await Authservice().signout(context: context); // Call signout function on "Yes"
              },
              child: Text('Yes'), // Text for the button
            ),
          ],
        );
      },
    );
  }
}
 