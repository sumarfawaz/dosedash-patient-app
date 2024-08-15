import 'package:DoseDash/Services/stripe_service.dart';
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

 

Future<void> _handlePayment() async {
    try {
      // Convert total price to cents (Stripe expects amounts in cents)
      int amount = (_totalPrice * 100).toInt();

      // Initialize the payment sheet
      await StripeService.initPaymentSheet(context, amount.toString(), 'LKR');

      // On successful payment, place the order
      _placeOrder();
    } catch (e) {
      print('Payment failed: $e');
    }
  }


   void _placeOrder() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userId = prefs.getString('userid');

    if (userId != null) {
      if (_userData == null) {
        await _fetchUserData();
      }

      if (_userData != null) {
        Map<String, List<Map<String, dynamic>>> groupedOrderItems = {};
        for (var medicine in widget.globalCart) {
          var orderItem = {
            'medicineId': medicine.id,
            'name': medicine.name,
            'brand': medicine.brand,
            'price': medicine.price,
            'quantity': medicine.quantity,
            'pharmacyId': medicine.pharmacyId,
          };

          if (!groupedOrderItems.containsKey(medicine.pharmacyId)) {
            groupedOrderItems[medicine.pharmacyId] = [];
          }
          groupedOrderItems[medicine.pharmacyId]!.add(orderItem);
        }

        for (var entry in groupedOrderItems.entries) {
          String pharmacyId = entry.key;
          List<Map<String, dynamic>> orderItems = entry.value;

          await FirebaseFirestore.instance.collection('orders').add({
            'userId': userId,
            'pharmacyId': pharmacyId,
            'user_name': '${_userData!['firstname']} ${_userData!['lastname']}',
            'phone_number': _userData!['phone'] ?? '',
            'orderItems': orderItems,
            'orderStatus': 'on progress',
            'timestamp': FieldValue.serverTimestamp(),
          });
        }

        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Order placed successfully')));

        setState(() {
          widget.globalCart.clear();
          _totalPrice = 0.0;
        });

      } else {
        print('User data not available. Cannot place order.');
      }
    } else {
      print('User ID not available. Cannot place order.');
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
                    onPressed:  _handlePayment,
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
