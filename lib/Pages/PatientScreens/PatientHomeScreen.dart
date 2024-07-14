import 'package:DoseDash/Services/AuthService.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Patienthomescreen extends StatefulWidget {
  const Patienthomescreen({Key? key}) : super(key: key);

  @override
  _PatienthomescreenState createState() => _PatienthomescreenState();
}

class _PatienthomescreenState extends State<Patienthomescreen> {
  User? _user;
  Map<String, dynamic>? _userData;

  @override
  void initState() {
    super.initState();
    _fetchUserData();
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
            .doc(userId)//using userid to get the information of the user because the document ID in the collection 'users' in the firebase uses the user's ID 
            .get();

        setState(() {
          _userData = userDoc.data() as Map<String, dynamic>?;
        });
      }
    } else {
      // Handle the case where the auth token is not available
      print("Auth token is not available.");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('DoseDash'),
        automaticallyImplyLeading: false,
        backgroundColor: Colors.greenAccent,
        actions: [
          IconButton(
            icon: Icon(Icons.account_circle),
            iconSize: 35,
            onPressed: () {
              _setProfilePicture(context);
            },
          ),
        ],
      ),
      body: Center(
        child: _userData == null
            ? CircularProgressIndicator()
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Welcome, ${_userData!['firstname']} ${_userData!['lastname']}!',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 20),
                  Text(
                    'Age Range: ${_userData!['agerange']}',
                    style: TextStyle(fontSize: 18),
                  ),
                  Text(
                    'City: ${_userData!['city']}',
                    style: TextStyle(fontSize: 18),
                  ),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () async {
                      await Authservice().signout(context: context);
                    },
                    child: Text('Logout'),
                  ),
                ],
              ),
      ),
    );
  }

  void _setProfilePicture(BuildContext context) {
    // Function to handle profile picture setting
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Set Profile Picture'),
          content: Text('This will be available very soon'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Close'),
            ),
          ],
        );
      },
    );
  }
}
