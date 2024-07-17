import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OrdersScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Orders'),
      ),
      body: FutureBuilder<String>(
        future: _fetchPharmacyId(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError || !snapshot.hasData) {
            return Center(child: Text('Error fetching pharmacy ID'));
          }
          String pharmacyId = snapshot.data!;

          return StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('orders')
                .where('pharmacyId', isEqualTo: pharmacyId)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              }
              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return Center(child: Text('No orders found.'));
              }

              return ListView.builder(
                itemCount: snapshot.data!.docs.length,
                itemBuilder: (context, index) {
                  var order = snapshot.data!.docs[index];
                  return Card(
                    margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    child: ListTile(
                      title: Text('Order ID: ${order.id}'),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Patient Name: ${order['user_name']}'),
                          Text('Phone Number: ${order['phone_number']}'),
                          Text('Status: ${order['orderStatus']}'),
                        ],
                      ),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                OrderDetailsScreen(order: order),
                          ),
                        );
                      },
                      trailing: ElevatedButton(
                        onPressed: () {
                          _completeOrder(order.id);
                        },
                        child: Text('Complete Order'),
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }

  Future<String> _fetchPharmacyId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? pharmacyId = prefs.getString('userid');
    return pharmacyId ?? '';
  }

  void _completeOrder(String orderId) {
    FirebaseFirestore.instance.collection('orders').doc(orderId).update({
      'orderStatus': 'completed',
    }).then((value) {
      print('Order $orderId completed successfully');
    }).catchError((error) {
      print('Failed to complete order: $error');
    });
  }
}

class OrderDetailsScreen extends StatelessWidget {
  final QueryDocumentSnapshot order;

  OrderDetailsScreen({required this.order});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Order Details'),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Order ID: ${order.id}',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),
          ListTile(
            title: Text('Patient Name: ${order['user_name']}'),
          ),
          ListTile(
            title: Text('Phone Number: ${order['phone_number']}'),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: order['orderItems'].length,
              itemBuilder: (context, index) {
                var item = order['orderItems'][index];
                return ListTile(
                  title: Text(item['name']),
                  subtitle: Text('Quantity: ${item['quantity']}'),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
