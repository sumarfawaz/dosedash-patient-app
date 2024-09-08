import 'package:DoseDash/Pages/DeliveryPersonScreens/PickupPointsScreen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class DeliveriesScreen extends StatefulWidget {
  const DeliveriesScreen({Key? key}) : super(key: key);

  @override
  _DeliveriesScreenState createState() => _DeliveriesScreenState();
}

class _DeliveriesScreenState extends State<DeliveriesScreen> {
  List<QueryDocumentSnapshot<Map<String, dynamic>>> _localNotifications = [];

  Stream<List<QueryDocumentSnapshot<Map<String, dynamic>>>>
      _fetchNotifications() {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      print('No user is logged in.');
      return Stream.empty(); // Return an empty stream if no user is logged in
    }
    final userId = user.uid;
    print('Fetching notifications for user: $userId');

    return FirebaseFirestore.instance
        .collection('notifications')
        .where('deliveryPersonIds', isEqualTo: userId)
        .where('notificationType',
            isEqualTo: 'order') // Filter by notification type
        .snapshots()
        .map((snapshot) {
      print('Received snapshot with ${snapshot.docs.length} documents.');

      // Use a Map to store the latest notification for each order
      final notificationsMap =
          <String, QueryDocumentSnapshot<Map<String, dynamic>>>{};

      for (final doc in snapshot.docs) {
        final notification = doc.data();
        final timestamp = notification['timestamp']
            as Timestamp?; // Use timestamp or another unique field

        if (timestamp != null) {
          // Use timestamp to create a unique key
          final key =
              '${userId}_${timestamp.seconds}'; // Create a unique key using userId and timestamp

          // Add or replace the notification in the map
          notificationsMap[key] = doc;
        }
      }

      return notificationsMap.values.toList();
    });
  }

  void _handleDecline(String notificationId) {
    print('Attempting to remove notification with ID: $notificationId');
    setState(() {
      _localNotifications.removeWhere((notification) {
        final shouldRemove = notification.id == notificationId;
        if (shouldRemove) {
          print('Removing notification with ID: ${notification.id}');
        }
        return shouldRemove;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Deliveries'),
        automaticallyImplyLeading: false, // Disable the default back arrow
        centerTitle: true,
      ),
      body: StreamBuilder<List<QueryDocumentSnapshot<Map<String, dynamic>>>>(
        stream: _fetchNotifications(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            print('Error: ${snapshot.error}');
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final notifications =
              snapshot.data ?? []; // Use the data from the stream
          print('Notifications count: ${notifications.length}');

          if (notifications.isEmpty) {
            return const Center(child: Text('No new deliveries.'));
          }

          return ListView.builder(
            itemCount: notifications.length,
            itemBuilder: (context, index) {
              final notification = notifications[index].data();
              final pharmacyAddresses =
                  List<String>.from(notification['pharmacy_address'] ?? []);
              final pharmacyNames =
                  List<String>.from(notification['pharmacy_name'] ?? []);
              final patientName = notification['patient_name'] ?? 'Unknown';
              final orderItems = List<Map<String, dynamic>>.from(
                  notification['orderItems'] ?? []);
              final orderItemCount = orderItems.length;
              final pharmacyCount = pharmacyAddresses.length;

              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => PickupPointsScreen(
                        pharmacyAddresses: pharmacyAddresses,
                        pharmacyNames: pharmacyNames,
                        patientAddress: notification['patient_address'] ??
                            'Address not available',
                        notificationId:
                            notifications[index].id, // Pass notification ID
                        onDecline: () {
                          _handleDecline(notifications[index].id);
                        },
                      ),
                    ),
                  );
                },
                child: Card(
                  margin: const EdgeInsets.symmetric(
                      vertical: 8.0, horizontal: 16.0),
                  elevation: 5.0,
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(16.0),
                    title: Text('Delivery for $patientName'),
                    subtitle: Text(
                        'Order Items: $orderItemCount\nPickup Locations: $pharmacyCount'),
                    trailing: const Icon(Icons.arrow_forward),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
