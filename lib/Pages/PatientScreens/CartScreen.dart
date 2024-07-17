import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:DoseDash/Pages/PatientScreens/PatientHomeScreen.dart';

class CartScreen extends StatefulWidget {
  final List<Medicine> globalCart;

  CartScreen({required this.globalCart});

  @override
  _CartScreenState createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  double _totalPrice = 0.0;
  User? _user;
  Map<String, dynamic>? _userData;

  @override
  void initState() {
    super.initState();
    _calculateTotalPrice();
  }

  void _calculateTotalPrice() {
    _totalPrice = widget.globalCart
        .fold(0.0, (sum, item) => sum + (item.price * item.quantity));
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

          // Ensure _userData is not null and contains necessary fields
          if (_userData != null) {
            // Optionally handle defaults if fields are missing
            _userData!['firstname'] ??= '';
            _userData!['lastname'] ??= '';
            _userData!['phone'] ??= '';
          }
        });
      }
    } else {
      print("Auth token is not available.");
    }
  }

  void _placeOrder() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userId = prefs.getString('userid');

    if (userId != null) {
      // Ensure _userData is fetched before proceeding
      if (_userData == null) {
        await _fetchUserData(); // Fetch user data if not already fetched
      }

      // Check again if _userData is now available
      if (_userData != null) {
        // Prepare the order data
        List<Map<String, dynamic>> orderItems = widget.globalCart
            .map((medicine) => {
                  'medicineId': medicine.id,
                  'name': medicine.name,
                  'brand': medicine.brand,
                  'price': medicine.price,
                  'quantity': medicine.quantity,
                  'pharmacyId':
                      medicine.pharmacyId, // Access pharmacyId from medicine
                })
            .toList();

        // Add the order to Firestore
        await FirebaseFirestore.instance.collection('orders').add({
          'userId': userId,
          'pharmacyId': orderItems.isNotEmpty
              ? orderItems.first['pharmacyId']
              : '', // Use the first medicine's pharmacyId as an example
          'user_name': '${_userData!['firstname']} ${_userData!['lastname']}',
          'phone_number': _userData!['phone'] ?? '',
          'orderItems': orderItems,
          'orderStatus': 'on progress', // Set initial order status
          'timestamp':
              FieldValue.serverTimestamp(), // Timestamp when order is placed
        });

        // Show success message or navigate back
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Order placed successfully')),
        );

        // Clear the cart after placing the order
        setState(() {
          widget.globalCart.clear();
          _totalPrice = 0.0;
        });

        // Optionally, navigate to a success or confirmation screen
        // Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => OrderConfirmationScreen()));
      } else {
        // Handle case where _userData is still null
        print('User data not available. Cannot place order.');
        // Optionally show a message or retry fetching user data
      }
    } else {
      print('User ID not available. Cannot place order.');
      // Handle case where userId is null (should ideally not happen if logged in)
    }
  }

  @override
  Widget build(BuildContext context) {
    _calculateTotalPrice();
    return Scaffold(
      appBar: AppBar(
        title: Text('Cart'),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: widget.globalCart.length,
              itemBuilder: (context, index) {
                var item = widget.globalCart[index];
                return ListTile(
                  title: Text(item.name),
                  subtitle: Text(
                      '${item.brand}\n\$${item.price.toStringAsFixed(2)} x ${item.quantity} = \$${(item.price * item.quantity).toStringAsFixed(2)}'),
                  trailing: IconButton(
                    icon: Icon(Icons.remove_shopping_cart),
                    onPressed: () {
                      setState(() {
                        widget.globalCart.removeAt(index);
                      });
                    },
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Total: \$${_totalPrice.toStringAsFixed(2)}',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.right,
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _placeOrder,
                  child: Text('Place Order'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
