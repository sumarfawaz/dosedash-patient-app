import 'package:DoseDash/Pages/MapScreens/MapScreen.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/services.dart';

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

  Future<void> _updateUserAddress(String newAddress) async {
    if (_userId != null) {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(_userId)
          .update({
        'address': newAddress,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Address updated successfully')),
      );
    }
  }

  void _openMapScreen() async {
    final selectedLocation = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Mapscreen(userRole: 'patient'),
      ),
    );
    if (selectedLocation != null) {
      setState(() {
        _addressController.text = selectedLocation;
      });
      _updateUserAddress(selectedLocation); // Call method to update Firestore
    }
  }

  bool _validateInputs() {
    if (_firstnameController.text.isEmpty ||
        _lastnameController.text.isEmpty ||
        _phoneController.text.isEmpty ||
        _addressController.text.isEmpty) {
      return false;
    }
    if (_phoneController.text.length != 10) {
      return false;
    }
    return true;
  }

  Future<void> _updateUserData() async {
    if (_validateInputs()) {
      if (_userId != null) {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(_userId)
            .update({
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
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Please fill all fields and ensure the phone number is 10 digits',
          ),
        ),
      );
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
                      labelText: 'First Name',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  SizedBox(height: 20),
                  TextField(
                    controller: _lastnameController,
                    decoration: InputDecoration(
                      labelText: 'Last Name',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  SizedBox(height: 20),
                  TextField(
                    controller: _phoneController,
                    decoration: InputDecoration(
                      labelText: 'Phone',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(10),
                    ],
                  ),
                  SizedBox(height: 20),



                  GestureDetector(
                    onTap: _openMapScreen,
                    child: TextField(
                      decoration: InputDecoration(
                        labelText: 'Click to Find Address *',
                        border: OutlineInputBorder(),
                      ),
                      controller: _addressController,
                      enabled: false, // Makes the field not editable directly by the user
                    ),
                  ),

                  
                  SizedBox(height: 20),
                  TextField(
                    controller: TextEditingController(text: _userData?['email']),
                    decoration: InputDecoration(
                      labelText: 'Email',
                      border: OutlineInputBorder(),
                    ),
                    enabled: false,
                  ),
                  SizedBox(height: 20),
                  TextField(
                    controller: TextEditingController(text: _userData?['agerange']),
                    decoration: InputDecoration(
                      labelText: 'Age Range',
                      border: OutlineInputBorder(),
                    ),
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
