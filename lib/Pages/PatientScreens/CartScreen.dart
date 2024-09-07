import 'dart:async';
import 'package:DoseDash/Algorithms/GetUserLocation.dart';
import 'package:DoseDash/CustomWidgets/OrderSummarySheet.dart';
import 'package:DoseDash/Pages/PatientScreens/PatientHomeScreen.dart';
import 'package:DoseDash/Services/stripe_service.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
    _fetchUserData();
  }

  void _calculateTotalPrice() {
    _totalPrice = widget.globalCart.fold(0.0, (sum, item) => sum + (item.price * item.quantity));
  }

  Future<void> _fetchUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? authToken = prefs.getString('auth_token');
    String? userId = prefs.getString('userid');

    if (authToken != null) {
      _user = FirebaseAuth.instance.currentUser;

      if (_user != null) {
        DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection('users').doc(userId).get();

        setState(() {
          _userData = userDoc.data() as Map<String, dynamic>?;

          if (_userData != null) {
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

 Future<void> _handlePlaceOrder() async {
  try {
    // Save order to Firestore
    DocumentReference orderSummaryRef = await FirebaseFirestore.instance.collection('orderSummary').add({
      'totalPrice': _totalPrice,
      'orderItems': widget.globalCart.map((item) => {
        'medicineId': item.id,
        'name': item.name,
        'brand': item.brand,
        'price': item.price,
        'quantity': item.quantity,
        'pharmacyId': item.pharmacyId,
      }).toList(),
      'timestamp': FieldValue.serverTimestamp(),
    });

    // Show the order summary sheet
    Completer<bool> sheetClosedCompleter = Completer<bool>();
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return OrderSummarySheet(
          orderSummaryRef: orderSummaryRef,
          onProceedToPayment: () async {
            // Payment is successful, clear the cart
            setState(() {
              widget.globalCart.clear();
            });
            sheetClosedCompleter.complete(true);
          },
          onCancel: () {
            sheetClosedCompleter.complete(true); // Close the bottom sheet
            return Future.value(); // Add a return statement
          },
          onClearCart: () async {
            setState(() {
              widget.globalCart.clear(); // Clear the cart
            });
          },
        );
      },
    );

    await sheetClosedCompleter.future; // Wait for the sheet to be closed
  } catch (e) {
    print('Error saving order to Firestore: $e');
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to place order')));
  }
}



  @override
  Widget build(BuildContext context) {
    _calculateTotalPrice();
    return Scaffold(
      appBar: AppBar(
        title: Text('Cart'),
        automaticallyImplyLeading: false,
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: widget.globalCart.isEmpty
                ? Center(
                    child: Text(
                      'Your cart is empty',
                      style: TextStyle(fontSize: 24),
                    ),
                  )
                : ListView.builder(
                    itemCount: widget.globalCart.length,
                    itemBuilder: (context, index) {
                      var item = widget.globalCart[index];
                      return ListTile(
                        title: Text(item.name),
                        subtitle: Text(
                          '${item.brand}\n\රු${item.price.toStringAsFixed(2)} x ${item.quantity} = \රු${(item.price * item.quantity).toStringAsFixed(2)}',
                        ),
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
          if (widget.globalCart.isNotEmpty)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Total: \රු${_totalPrice.toStringAsFixed(2)}',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.right,
                  ),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _handlePlaceOrder,
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
