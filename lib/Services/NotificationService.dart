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
    } else if (response.actionId == 'reject') {
      print('User rejected the notification');

      // Get the document ID from the payload
      String? orderId = response.payload?.split(':').last.trim();

      if (orderId != null) {
        // Reference the specific document in the 'orderNotifier' collection
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
      String? body}) async {
    // Show the notification
    await flutterLocalNotificationsPlugin.show(
      id,
      title,
      body,
      notificationDetails,
      payload: 'OrderID: $orderId', // Use the order ID in the payload
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

  void notificationTapBackground(NotificationResponse notificationResponse) {
    // ignore: avoid_print
    print('notification(${notificationResponse.id}) action tapped: '
        '${notificationResponse.actionId} with'
        ' payload: ${notificationResponse.payload}');
  }

// Method to push notifications based on Firestore updates
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

        // Check if the list is not null and has elements
        if (nearbyRiders != null && nearbyRiders.isNotEmpty) {
          String firstRider = nearbyRiders[0]; // Access the first element
          print("First Rider: $firstRider");

          if (userId == firstRider) {
            // Trigger a notification when an order is ready for pickup
            await showNotification(
              orderId: doc.id, // Pass the order ID
              id: doc.hashCode, // Unique notification ID based on document hash
              title: 'Order Ready for Pickup',
              body:
                  'Your order is ready for pickup. Order details: ${orderData.toString()}',
            );
          }
        } else {
          print("No nearby riders found.");
        }
      }
    });
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
