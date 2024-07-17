import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SplashScreenModel extends ChangeNotifier {
  late FocusNode unfocusNode;

  bool _isLoading = true; // Track loading state
  bool get isLoading => _isLoading; // Getter for loading state
  bool _isLoggedIn = false; // Track login state
  bool get isLoggedIn => _isLoggedIn; // Getter for login state
  String? _role; // Store user role
  String? get role => _role; // Getter for user role

  SplashScreenModel() {
    unfocusNode = FocusNode();
    // Add a small delay before navigating to allow time for any initialization
    Future.delayed(Duration(seconds: 2), () {
      checkLoginStatus();
    });
  }

  Future<void> checkLoginStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? authToken = prefs.getString('auth_token');
    _role = prefs.getString('role'); // Retrieve user role

    if (authToken != null) {
      _isLoggedIn = true; // User is logged in
    } else {
      _isLoggedIn = false; // User is not logged in
    }
    _isLoading = false; // Loading state completes
    notifyListeners(); // Notify listeners about changes
  }

  void navigateToHome(BuildContext context) {
    Navigator.pushReplacementNamed(context, '/patienthome');
  }

  void navigateToPharmacyHome(BuildContext context) {
    Navigator.pushReplacementNamed(context, '/pharmacyhome');
  }

  void navigateToAuthentication(BuildContext context) {
    Navigator.pushReplacementNamed(context, '/authentication');
  }

  @override
  void dispose() {
    unfocusNode.dispose();
    super.dispose();
  }
}
