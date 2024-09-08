import 'package:DoseDash/Algorithms/GetUserLocation.dart';
import 'package:DoseDash/Pages/PatientScreens/CartScreen.dart';
import 'package:DoseDash/Services/stripe_service.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OrderSummarySheet extends StatelessWidget {
  final DocumentReference orderSummaryRef;
  final Future<void> Function() onCancel;
  final Future<void> Function() onProceedToPayment;
  final Future<void> Function() onClearCart; // Add this line

  OrderSummarySheet({
    required this.orderSummaryRef,
    required this.onCancel,
    required this.onProceedToPayment,
    required this.onClearCart, // Add this line
  });

  Future<void> _confirmCancel(BuildContext context) async {
    bool? confirm = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Cancel Order Summary'),
          content: Text(
              'Are you sure you want to cancel the order summary? This will delete it.'),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(true), // Confirm
              child: Text('Yes'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(false), // Cancel
              child: Text('No'),
            ),
          ],
        );
      },
    );

    if (confirm == true) {
      try {
        // Delete the order summary document from Firestore
        await orderSummaryRef.delete();

        // Notify parent or main widget to update state if needed
        await onCancel();

        // Close the Order Summary Sheet and return to the Cart Screen
        Navigator.of(context).pop(); // Close the sheet
      } catch (e) {
        print('Error canceling order summary: $e');
      }
    }
  }

  Future<void> _proceedToPayment(BuildContext context) async {
    // Fetch the total amount for the payment
    DocumentSnapshot orderSummaryDoc = await orderSummaryRef.get();
    double totalPrice = orderSummaryDoc['totalPrice'] as double;

    // Convert totalPrice to the smallest currency unit (e.g., cents) and ensure it's an int
    int amount =
        (totalPrice * 100).toInt(); // Convert to the smallest currency unit

    try {
      // Call Stripe service for payment
      bool paymentSuccessful = await StripeService.initPaymentSheet(
        context,
        amount.toString(),
        'LKR',
      );

      if (paymentSuccessful) {
        // Payment successful, clear the cart
        await onClearCart(); // Call the callback to clear the cart
        await _placeOrder(context);
      } else {
        // Handle payment failure or cancellation
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Payment failed or was canceled')),
        );
      }
    } catch (e) {
      // Handle payment process errors
      print('Payment process failed: $e');
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Payment failed')));
    }
  }

  Future<void> _placeOrder(BuildContext context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userId = prefs.getString('userid');
    if (userId != null) {
      try {
        // Fetch user data
        User? user = FirebaseAuth.instance.currentUser;
        DocumentSnapshot userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .get();
        Map<String, dynamic>? userData =
            userDoc.data() as Map<String, dynamic>?;

        if (userData != null) {
          // Get user location
          LocationService locationService = LocationService();
          LatLng? userLocation = await locationService.getUserLocation();

          if (userLocation != null) {
            List<String> nearbyDeliveryPersons =
                await locationService.getNearbyDeliveryPersons(userLocation);

            // Retrieve the order items from the order summary
            DocumentSnapshot orderSummaryDoc = await orderSummaryRef.get();
            List<dynamic> orderItems = orderSummaryDoc['orderItems'];
            double totalPrice = orderSummaryDoc['totalPrice'] ?? 0.0;

            Map<String, List<Map<String, dynamic>>> groupedOrderItems = {};
            Map<String, Map<String, dynamic>> pharmacyDetails = {};

            for (var item in orderItems) {
              var medicine = item as Map<String, dynamic>;
              var orderItem = {
                'medicineId': medicine['medicineId'],
                'name': medicine['name'],
                'brand': medicine['brand'],
                'price': medicine['price'],
                'quantity': medicine['quantity'],
                'pharmacyId': medicine['pharmacyId'],
              };

              if (!groupedOrderItems.containsKey(medicine['pharmacyId'])) {
                groupedOrderItems[medicine['pharmacyId']] = [];
              }
              groupedOrderItems[medicine['pharmacyId']]!.add(orderItem);

              if (!pharmacyDetails.containsKey(medicine['pharmacyId'])) {
                DocumentSnapshot pharmacyDoc = await FirebaseFirestore.instance
                    .collection('pharmacies')
                    .doc(medicine['pharmacyId'])
                    .get();

                if (pharmacyDoc.exists) {
                  pharmacyDetails[medicine['pharmacyId']] = {
                    'address': pharmacyDoc['address'],
                    'name': pharmacyDoc['pharmacyName'],
                  };
                } else {
                  print('Pharmacy not found for ID: ${medicine['pharmacyId']}');
                }
              }
            }

            List<String> pharmacyNames = pharmacyDetails.values
                .map((details) => details['name'] as String)
                .toList();
            List<String> pharmacyAddresses = pharmacyDetails.values
                .map((details) => details['address'] as String)
                .toList();

            // Add the order to Firestore
            for (var entry in groupedOrderItems.entries) {
              String pharmacyId = entry.key;
              List<Map<String, dynamic>> orderItems = entry.value;

              await FirebaseFirestore.instance.collection('orders').add({
                'userId': userId,
                'pharmacyId': pharmacyId,
                'user_name': '${userData['firstname']} ${userData['lastname']}',
                'user_address': '${userData['address']}',
                'phone_number': userData['phone'] ?? '',
                'orderItems': orderItems,
                'orderStatus': 'on progress',
                'timestamp': FieldValue.serverTimestamp(),
              });
            }

            try {
              await FirebaseFirestore.instance.collection('notifications').add({
                'deliveryPersonIds': nearbyDeliveryPersons,
                'userId': userId,
                'orderItems':
                    groupedOrderItems.values.expand((items) => items).toList(),
                'orderStatus': 'pending',
                'timestamp': FieldValue.serverTimestamp(),
                'notificationType': 'order',
                'patient_name':
                    '${userData['firstname']} ${userData['lastname']}',
                'patient_address': '${userData['address']}',
                'pharmacy_name': pharmacyNames,
                'pharmacy_address': pharmacyAddresses,
                'totalPrice': totalPrice, // Include total price
              });

              // Clear cart items on successful payment
              bool cartCleared = await prefs.remove('cartItems');
              if (cartCleared) {
                // Notify parent or main widget to update state if needed
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Order placed successfully!')),
                );
              } else {
                print('Failed to clear cart items.');
              }

              // Close the Order Summary Sheet and return to the Cart Screen
              Navigator.of(context).pop(); // Close the sheet
            } catch (e) {
              print('Error placing order: $e');
              ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Failed to place order')));
            }
          }
        }
      } catch (e) {
        print('Error placing order: $e');
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Failed to place order')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: Icon(Icons.cancel, color: Colors.red),
                onPressed: () =>
                    _confirmCancel(context), // Show confirmation dialog
              ),
              Text(
                'Order Summary',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              Container(width: 48), // Alignment container
            ],
          ),
          FutureBuilder<DocumentSnapshot>(
            future: orderSummaryRef.get(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              } else if (!snapshot.hasData || !snapshot.data!.exists) {
                return Center(child: Text('No order details found.'));
              } else {
                DocumentSnapshot orderSummaryDoc = snapshot.data!;
                List<dynamic> orderItems = orderSummaryDoc['orderItems'];
                double totalPrice = orderSummaryDoc['totalPrice'] ?? 0.0;

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Order Items:',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold)),
                    ListView.builder(
                      shrinkWrap: true,
                      itemCount: orderItems.length,
                      itemBuilder: (context, index) {
                        Map<String, dynamic> item = orderItems[index];
                        return ListTile(
                          title: Text(item['name']),
                          subtitle: Text('Quantity: ${item['quantity']}'),
                          trailing: Text('Price: ${item['price']}'),
                        );
                      },
                    ),
                    SizedBox(height: 10),
                    Text('Total Price: $totalPrice',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold)),
                    SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () =>
                          _proceedToPayment(context), // Proceed to payment
                      child: Text('Proceed to Payment'),
                    ),
                  ],
                );
              }
            },
          ),
        ],
      ),
    );
  }
}
