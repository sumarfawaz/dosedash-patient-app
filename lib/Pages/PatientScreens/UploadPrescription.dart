import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'OrderDetailsScreen.dart'; // Ensure this import matches your file structure

class UploadPrescriptionScreen extends StatefulWidget {
  @override
  _UploadPrescriptionScreenState createState() => _UploadPrescriptionScreenState();
}

class _UploadPrescriptionScreenState extends State<UploadPrescriptionScreen> {
  String? _userId;

  @override
  void initState() {
    super.initState();
    _fetchUserId();
  }

  Future<void> _fetchUserId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _userId = prefs.getString('userid');
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Order List'),
        automaticallyImplyLeading: false,
        centerTitle: true,
      ),
      body: _userId != null
          ? StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('notifications')
                  .where('userId', isEqualTo: _userId)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(
                      child: Text(
                    'No orders found.',
                    style: TextStyle(fontSize: 24),
                  ));
                }

                return ListView.builder(
                  itemCount: snapshot.data!.docs.length,
                  itemBuilder: (context, index) {
                    var notification = snapshot.data!.docs[index];
                    return Card(
                      margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                      elevation: 4,
                      child: ListTile(
                        title: Text('Order ID: ${notification.id}'),
                        subtitle: Text('Status: ${notification['orderStatus']}'),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  OrderDetailsScreen(notification: notification),
                            ),
                          );
                        },
                      ),
                    );
                  },
                );
              },
            )
          : Center(
              child: CircularProgressIndicator(),
            ),
    );
  }
}
