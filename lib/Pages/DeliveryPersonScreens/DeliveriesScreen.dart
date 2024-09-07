import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class DeliveriesScreen extends StatefulWidget {
  const DeliveriesScreen({super.key});

  @override
  State<DeliveriesScreen> createState() => _DeliveriesScreenState();
}

class _DeliveriesScreenState extends State<DeliveriesScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Deliveries'),
        automaticallyImplyLeading: false, // Disable the default back arrow
        centerTitle: true,
      ),

      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: _fetchNotifications(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            // Show a loading indicator while waiting for data
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            // Display error message if an error occurs
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final notifications = snapshot.data ?? [];

          if (notifications.isEmpty) {
            // Show a message when there are no notifications
            return Center(child: Text('No new deliveries.'));
          }

          return ListView.builder(
            itemCount: notifications.length,
            itemBuilder: (context, index) {
              final notification = notifications[index];
              return ListTile(
                title: Text('Order from ${notification['userId']}'),
                // Show additional details if available
                subtitle: Text('Order items: ${notification['orderItems']?.length ?? 0}'),
                trailing: Text('Status: ${notification['status']}'),
              );
            },
          );
        },
      ),
    );
  }

  // Fetch notifications for the current delivery person
  Stream<List<Map<String, dynamic>>> _fetchNotifications() {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId != null) {
      // Query Firestore for notifications matching the deliveryPersonId
      return FirebaseFirestore.instance
          .collection('notifications')
          .where('deliveryPersonId', isEqualTo: userId)
          .snapshots()
          .map((snapshot) => snapshot.docs
              .map((doc) => doc.data())
              .toList());
    } else {
      // Return an empty list if user ID is not available
      return Stream.value([]);
    }
  }
}
