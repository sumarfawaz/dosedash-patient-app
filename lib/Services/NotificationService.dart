import 'dart:async'; // For StreamSubscription
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  static FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static GlobalKey<NavigatorState> globalKey = GlobalKey<NavigatorState>();

  // Store the StreamSubscription reference
  StreamSubscription? orderSubscription;

  // Notification details including action buttons
  static NotificationDetails notificationDetails = const NotificationDetails(
    android: AndroidNotificationDetails(
      'channelId',
      'channelName',
      icon: '@mipmap/ic_launcher',
      importance: Importance.max,
      priority: Priority.high,
      playSound: true,
      actions: <AndroidNotificationAction>[
        AndroidNotificationAction('accept', 'Accept', showsUserInterface: true),
        AndroidNotificationAction('reject', 'Decline',
            showsUserInterface: true),
      ],
    ),
  );

  // Initialize method for notification settings
  Future<void> init() async {
    AndroidInitializationSettings androidInitializationSettings =
        const AndroidInitializationSettings('@mipmap/ic_launcher');
    InitializationSettings initializationSettings = InitializationSettings(
      android: androidInitializationSettings,
    );
    await flutterLocalNotificationsPlugin.initialize(initializationSettings,
        onDidReceiveNotificationResponse: notificationReponse,
        onDidReceiveBackgroundNotificationResponse:
            onDidReceiveBackgroundNotificationResponse);
  }

  void notificationReponse(NotificationResponse response) async {
    if (response.actionId == 'accept') {
      print('User accepted the notification');

      // Extract userId and orderId from the payload
      String? payload = response.payload;
      if (payload != null) {
        // Split the payload to extract userId and orderId
        List<String> payloadParts = payload.split(',');
        String userId = payloadParts[0].split(':').last.trim();
        String orderId = payloadParts[1].split(':').last.trim();

        // Call updateDeliveryPersons with the extracted values
        updateDeliveryPersons(orderId, userId);
      } else {
        print('No payload found.');
      }
    } else if (response.actionId == 'reject') {
      print('User rejected the notification');

      // Similar logic for reject case (if necessary)
      // Extract orderId from the payload
      String? payload = response.payload;
      if (payload != null) {
        String orderId = payload.split(',').last.split(':').last.trim();

        // Remove the first rider from the nearbyRiders list
        DocumentReference orderDoc =
            FirebaseFirestore.instance.collection('orderNotifier').doc(orderId);

        DocumentSnapshot docSnapshot = await orderDoc.get();
        var orderData = docSnapshot.data() as Map<String, dynamic>?;
        List<dynamic>? nearbyRiders = orderData?['nearByRiders'];

        if (nearbyRiders != null && nearbyRiders.isNotEmpty) {
          nearbyRiders.removeAt(0); // Remove the first rider

          await orderDoc.update({'nearByRiders': nearbyRiders});
          print('First rider removed from nearbyRiders.');
        } else {
          print('No nearby riders to remove.');
        }
      }
    } else {
      print('Notification tapped without action');
    }
  }

  // Handle background responses to notifications
  static void onDidReceiveBackgroundNotificationResponse(
      NotificationResponse notificationResponse) {
    print(
        'Background notification response received: ${notificationResponse.payload}');
    if (notificationResponse.actionId == 'accept') {
      print('User accepted the notification');
    } else if (notificationResponse.actionId == 'reject') {
      print('User rejected the notification');
    } else {
      print('Notification tapped without action');
    }
  }

  static void backgroundnotification(NotificationResponse) async {
    print("user clicked and was captured");
  }

  static Future<void> showNotification(
      {required String orderId,
      int id = 0,
      String? title,
      String? body,
      String? payload}) async {
    // Show the notification
    await flutterLocalNotificationsPlugin.show(
      id,
      title,
      body,
      notificationDetails,
      payload: payload, // Payload contains both userId and orderIdFromDocument
    );

    // Set a timer for 5 minutes (300000 milliseconds)
    Timer(const Duration(seconds: 10), () async {
      // After 5 minutes, check if there's been no response and remove the first rider
      DocumentReference orderDoc =
          FirebaseFirestore.instance.collection('orderNotifier').doc(orderId);

      // Get the current nearbyRiders list
      DocumentSnapshot docSnapshot = await orderDoc.get();
      var orderData = docSnapshot.data() as Map<String, dynamic>?;
      List<dynamic>? nearbyRiders = orderData?['nearByRiders'];

      if (nearbyRiders != null && nearbyRiders.isNotEmpty) {
        nearbyRiders.removeAt(0); // Remove the first rider

        // Update the document with the modified list
        await orderDoc.update({'nearByRiders': nearbyRiders});
        print('First rider removed from nearbyRiders due to timeout.');

        // Clear the notification from the phone's taskbar
        await flutterLocalNotificationsPlugin.cancel(id);
        print('Notification cancelled after 5 minutes.');
      } else {
        print('No nearby riders to remove after timeout.');
      }
    });
  }

  // static void onDidReceiveNotificationResponse(
  //     NotificationResponse response) async {
  //   if (response.actionId == 'accept') {
  //     print('User accepted the notification');
  //   } else if (response.actionId == 'reject') {
  //     print('User rejected the notification');

  //     // Get the document ID from the payload
  //     String? orderId = response.payload?.split(':').last.trim();

  //     if (orderId != null) {
  //       // Reference the specific document in the 'orderNotifier' collection
  //       DocumentReference orderDoc =
  //           FirebaseFirestore.instance.collection('orderNotifier').doc(orderId);

  //       // Get the current nearbyRiders list
  //       DocumentSnapshot docSnapshot = await orderDoc.get();
  //       var orderData = docSnapshot.data() as Map<String, dynamic>?;
  //       List<dynamic>? nearbyRiders = orderData?['nearByRiders'];

  //       if (nearbyRiders != null && nearbyRiders.isNotEmpty) {
  //         nearbyRiders.removeAt(0); // Remove the first rider

  //         // Update the document with the modified list
  //         await orderDoc.update({'nearByRiders': nearbyRiders});
  //         print('First rider removed from nearbyRiders.');
  //       } else {
  //         print('No nearby riders to remove.');
  //       }
  //     }
  //   } else {
  //     print('Notification tapped without action');
  //   }
  // }

  Future<void> pushNotifications(String? userId) async {
    // Save the subscription reference
    orderSubscription = FirebaseFirestore.instance
        .collection('orderNotifier')
        .where('orderStatus', isEqualTo: 'readyforpickup')
        .snapshots()
        .listen((QuerySnapshot snapshot) async {
      for (var doc in snapshot.docs) {
        var orderData =
            doc.data() as Map<String, dynamic>; // Cast Firestore data to Map

        print("The Order Data: $orderData");

        // Access the 'nearByRiders' list from the orderData
        List<dynamic>? nearbyRiders = orderData['nearByRiders'];
        String orderIdFromDocument = orderData['orderNotifierId'];
        // Check if the list is not null and has elements
        if (nearbyRiders != null && nearbyRiders.isNotEmpty) {
          String firstRider = nearbyRiders[0]; // Access the first element
          print("First Rider: $firstRider");

          print("User Id:");
          print(userId);

          print('order id from document');
          print(orderIdFromDocument);

          if (userId == firstRider) {
            // Trigger a notification when an order is ready for pickup
            await showNotification(
              orderId: orderIdFromDocument, // Pass the order ID
              id: doc.hashCode, // Unique notification ID based on document hash
              title: 'Order Ready for Pickup',
              body:
                  'Your order is ready for pickup. Order details: ${orderData.toString()}',
              // Include both userId and orderIdFromDocument in the payload
              payload: 'userId:$userId,orderId:$orderIdFromDocument',
            );
          }
        } else {
          print("No nearby riders found.");
        }
      }
    });
  }

  void updateDeliveryPersons(
      String orderId, String? nearbyDeliveryPerson) async {
    try {
      // Query the notifications collection to find the document with the given orderId
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('notifications')
          .where('orderId', isEqualTo: orderId)
          .get();

      // Check if any documents were found
      if (snapshot.docs.isNotEmpty) {
        // Loop through the results (even though there should be only one match)
        for (var doc in snapshot.docs) {
          // Update the deliveryPersonIds field in the matching document
          await FirebaseFirestore.instance
              .collection('notifications')
              .doc(doc.id)
              .update({
            'deliveryPersonIds':
                nearbyDeliveryPerson, // Update the delivery persons
          });

          print(
              'Delivery persons updated for notification with orderId: $orderId');

          // Delete the corresponding document in the 'orderNotifier' collection
          QuerySnapshot orderNotifierSnapshot = await FirebaseFirestore.instance
              .collection('orderNotifier')
              .where('orderNotifierId', isEqualTo: orderId)
              .get();

          if (orderNotifierSnapshot.docs.isNotEmpty) {
            for (var orderDoc in orderNotifierSnapshot.docs) {
              await FirebaseFirestore.instance
                  .collection('orderNotifier')
                  .doc(orderDoc.id)
                  .delete();

              print(
                  'Document from orderNotifier collection with orderNotifierId: $orderId deleted.');
            }
          }
        }
      } else {
        print('No notification found with orderId: $orderId');
      }
    } catch (e) {
      print('Error updating and deleting notification document: $e');
    }
  }

  // Method to cancel the Firestore subscription
  void cancelFirestoreListener() {
    orderSubscription?.cancel();
    orderSubscription = null;
    print('Firestore listener cancelled');
  }

  Future<void> cancelAllNotifications() async {
    await flutterLocalNotificationsPlugin
        .cancelAll(); // Cancel any active notifications
  }
}
