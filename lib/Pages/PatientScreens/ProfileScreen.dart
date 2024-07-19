import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  TextEditingController _firstnameController = TextEditingController();
  TextEditingController _lastnameController = TextEditingController();
  TextEditingController _phoneController = TextEditingController();
  TextEditingController _addressController = TextEditingController();

  String? _userId;
  bool _isLoading = true;
  Map<String, dynamic>? _userData;

  @override
  void initState() {
    super.initState();
    _fetchUserId();
  }

  Future<void> _fetchUserId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _userId = prefs.getString('userid');
    if (_userId != null) {
      _fetchUserData();
    }
  }

  Future<void> _fetchUserData() async {
    if (_userId != null) {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(_userId)
          .get();
      setState(() {
        _userData = userDoc.data() as Map<String, dynamic>?;
        if (_userData != null) {
          _firstnameController.text = _userData!['firstname'] ?? '';
          _lastnameController.text = _userData!['lastname'] ?? '';
          _phoneController.text = _userData!['phone'] ?? '';
          _addressController.text = _userData!['address'] ?? '';
        }
        _isLoading = false;
      });
    }
  }

  Future<void> _updateUserData() async {
    if (_userId != null) {
      await FirebaseFirestore.instance.collection('users').doc(_userId).update({
        'firstname': _firstnameController.text,
        'lastname': _lastnameController.text,
        'phone': _phoneController.text,
        'address': _addressController.text,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Profile updated successfully')),
      );

      Navigator.pushNamed(context, '/');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Profile'),
        automaticallyImplyLeading: false,
        centerTitle: true,
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: ListView(
                children: [
                  SizedBox(height: 20),
                  TextField(
                    controller: _firstnameController,
                    decoration: InputDecoration(
                        labelText: 'First Name', border: OutlineInputBorder()),
                  ),
                  SizedBox(height: 20),
                  TextField(
                    controller: _lastnameController,
                    decoration: InputDecoration(
                        labelText: 'Last Name', border: OutlineInputBorder()),
                  ),
                  SizedBox(height: 20),
                  TextField(
                    controller: _phoneController,
                    decoration: InputDecoration(
                        labelText: 'Phone', border: OutlineInputBorder()),
                  ),
                  SizedBox(height: 20),
                  TextField(
                    controller: _addressController,
                    decoration: InputDecoration(
                        labelText: 'Address', border: OutlineInputBorder()),
                  ),
                  SizedBox(height: 20),
                  TextField(
                    controller:
                        TextEditingController(text: _userData?['email']),
                    decoration: InputDecoration(
                        labelText: 'Email', border: OutlineInputBorder()),
                    enabled: false,
                  ),
                  SizedBox(height: 20),
                  TextField(
                    controller:
                        TextEditingController(text: _userData?['agerange']),
                    decoration: InputDecoration(
                        labelText: 'Age Range', border: OutlineInputBorder()),
                    enabled: false,
                  ),
                  SizedBox(height: 20),
                  TextField(
                    controller: TextEditingController(text: _userData?['city']),
                    decoration: InputDecoration(
                        labelText: 'City', border: OutlineInputBorder()),
                    enabled: false,
                  ),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _updateUserData,
                    child: Text('Update Profile'),
                  ),
                ],
              ),
            ),
    );
  }
}
