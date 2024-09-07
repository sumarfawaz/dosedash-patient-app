import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class OrderDetailsScreen extends StatelessWidget {
  final QueryDocumentSnapshot notification; // Adjusted parameter name

  OrderDetailsScreen({required this.notification}); // Adjusted parameter name

  @override
  Widget build(BuildContext context) {
    // Retrieve and ensure correct type for total price
    double totalPrice = (notification['totalPrice'] as num).toDouble();
    List<dynamic> orderItems = List.from(notification['orderItems']);
    List<String> pharmacyNames = List<String>.from(notification['pharmacy_name']);
    String patientName = notification['patient_name'] ?? 'Unknown';
    String orderStatus = notification['orderStatus'] ?? 'Unknown';
    Timestamp timestamp = notification['timestamp'];

    // Format order date and time
    String formattedDate = timestamp.toDate().toLocal().toString();

    // Create a map to get pharmacy names by pharmacy ID
    Map<String, String> pharmacyDetails = {};
    for (var i = 0; i < pharmacyNames.length; i++) {
      pharmacyDetails[orderItems[i]['pharmacyId'] ?? 'Unknown'] = pharmacyNames[i];
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Order Details'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Card for Order ID
                  Card(
                    elevation: 4,
                    child: ListTile(
                      title: Text(
                        'Notification ID: ${notification.id}',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  SizedBox(height: 10),
                  // Card for Order Status and Date
                  Card(
                    elevation: 4,
                    child: Column(
                      children: [
                        ListTile(
                          title: Text(
                            'Order Status: $orderStatus',
                            style: TextStyle(fontSize: 16),
                          ),
                        ),
                        ListTile(
                          title: Text(
                            'Date: $formattedDate',
                            style: TextStyle(fontSize: 16),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 10),
                  // Card for Patient Name
                  Card(
                    elevation: 4,
                    child: ListTile(
                      title: Text(
                        'Patient Name',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      trailing: Text(
                        patientName,
                        style: TextStyle(fontSize: 18),
                      ),
                    ),
                  ),
                  SizedBox(height: 10),
                  // Card for Total Price
                  Card(
                    elevation: 4,
                    child: ListTile(
                      title: Text(
                        'Total Price',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      trailing: Text(
                        '₨${totalPrice.toStringAsFixed(2)}',
                        style: TextStyle(fontSize: 18, color: Colors.green),
                      ),
                    ),
                  ),
                  SizedBox(height: 10),
                  // Order Items Section
                  Text(
                    'Order Items:',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  Expanded(
                    child: ListView.builder(
                      itemCount: orderItems.length,
                      itemBuilder: (context, index) {
                        var item = orderItems[index];
                        if (item is Map<String, dynamic>) {
                          String pharmacyId = item['pharmacyId'] ?? 'Unknown';
                          String pharmacyName = pharmacyDetails[pharmacyId] ?? 'Unknown Pharmacy';

                          return Card(
                            elevation: 2,
                            child: ListTile(
                              title: Text(item['name'] ?? 'Unknown Item'),
                              subtitle: Text(
                                '${item['quantity'] ?? 0} x ₨${item['price']?.toStringAsFixed(2) ?? '0.00'}',
                              ),
                              trailing: Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    '₨${((item['quantity'] ?? 0) * (item['price']?.toDouble() ?? 0.0)).toStringAsFixed(2)}',
                                    style: TextStyle(color: Colors.green),
                                  ),
                                  SizedBox(height: 4),
                                  Text(
                                    'Pharmacy: $pharmacyName',
                                    style: TextStyle(fontSize: 12, color: Colors.grey),
                                  ),
                                ],
                              ),
                            ),
                          );
                        } else {
                          return Container(); // Handle unexpected data
                        }
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Track Order Button
          Padding(
            padding: const EdgeInsets.all(40.0),
            child: Center(
              child: ElevatedButton(
                onPressed: null, // Disable button
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30.0),
                  ),
                  padding: EdgeInsets.symmetric(vertical: 15, horizontal: 30),
                ),
                child: Text(
                  'Track Order',
                  style: TextStyle(fontSize: 18),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
