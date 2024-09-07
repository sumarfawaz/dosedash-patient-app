
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:DoseDash/Algorithms/GetUserLocation.dart';
import 'package:DoseDash/Services/stripe_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
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
      int amount = (_totalPrice * 100).toInt();
      await StripeService.initPaymentSheet(context, amount.toString(), 'LKR');
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
        LocationService locationService = LocationService();
        LatLng? userLocation = await locationService.getUserLocation();

        if (userLocation != null) {
          List<String> nearbyDeliveryPersons =
              await locationService.getNearbyDeliveryPersons(userLocation);
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
              'user_name':
                  '${_userData!['firstname']} ${_userData!['lastname']}',
              'phone_number': _userData!['phone'] ?? '',
              'orderItems': orderItems,
              'orderStatus': 'on progress',
              'timestamp': FieldValue.serverTimestamp(),
            });

            try {
              for (String deliveryPersonId in nearbyDeliveryPersons) {
                await FirebaseFirestore.instance
                    .collection('notifications')
                    .add({
                  'deliveryPersonId': deliveryPersonId,
                  'userId': userId,
                  'orderItems': orderItems,
                  'orderStatus': 'pending',
                  'timestamp': FieldValue.serverTimestamp(),
                  'notificationType': 'order',
                });
              }
            } catch (e) {
              print('Error adding notification: $e');
            }
          }

          // Check if the widget is still mounted before showing SnackBar and updating state
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Order placed successfully')),
            );

            setState(() {
              widget.globalCart.clear();
              _totalPrice = 0.0;
            });
          }
        } else {
          print('Unable to get user location.');
        }
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
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text("Your Cart"),
        titleTextStyle: TextStyle(
            fontWeight: FontWeight.bold, color: Colors.black, fontSize: 26),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
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
                      return Dismissible(
                        key: Key(item.id),
                        direction: DismissDirection.endToStart,
                        onDismissed: (direction) {
                          setState(() {
                            widget.globalCart.removeAt(index);
                          });
                        },
                        background: Container(
                          color: Colors.red,
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Icon(Icons.delete, color: Colors.white),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          child: OrderedItemCard(
                            title: item.name,
                            description: item.brand,
                            numOfItem: item.quantity,
                            price: item.price,
                          ),
                        ),
                      );
                    },
                  ),
          ),
          if (widget.globalCart.isNotEmpty)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      offset: Offset(0, -1),
                      blurRadius: 6,
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Total:',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF22A45D),
                          ),
                        ),
                        Text(
                          '\රු${_totalPrice.toStringAsFixed(2)}',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF22A45D),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          backgroundColor: const Color(0xFF22A45D),
                        ),
                        onPressed: _handlePayment,
                        child: Text(
                          'Place Order'.toUpperCase(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// Components
class OrderedItemCard extends StatelessWidget {
  final int numOfItem;
  final String? title, description;
  final double? price;

  const OrderedItemCard({
    required this.numOfItem,
    required this.title,
    required this.description,
    required this.price,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            NumOfItems(numOfItem: numOfItem),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title!,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description!,
                    style: Theme.of(context).textTheme.bodyMedium,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Text(
              "\රු${price!.toStringAsFixed(2)}",
              style: Theme.of(context)
                  .textTheme
                  .labelSmall!
                  .copyWith(color: const Color(0xFF22A45D)),
            ),
          ],
        ),
        const SizedBox(height: 8),
        const Divider(),
      ],
    );
  }
}

class NumOfItems extends StatelessWidget {
  final int numOfItem;

  const NumOfItems({required this.numOfItem});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 24,
      width: 24,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.all(Radius.circular(4)),
        border: Border.all(
          width: 0.5,
          color: const Color(0xFF868686).withOpacity(0.3),
        ),
      ),
      child: Text(
        numOfItem.toString(),
        style: Theme.of(context)
            .textTheme
            .labelLarge!
            .copyWith(color: const Color(0xFF22A45D)),
      ),
    );
  }
}
