import 'package:DoseDash/Pages/AuthenticationScreen.dart';
import 'package:DoseDash/Pages/PatientScreens/PatientHomeScreen.dart';
import 'package:DoseDash/Pages/PharmacyScreens/PharmacyHomeScreen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Authservice {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> signup({
    required String email,
    required String password,
    required String firstname,
    required String lastname,
    required String agerange,
    required String address,
    required String city,
    required String phone,
    required BuildContext context,
  }) async {
    try {
      // Create a new user with email and password
      UserCredential userCredential = await _auth
          .createUserWithEmailAndPassword(email: email, password: password);

      // Retrieve the current user
      User? user = userCredential.user;

      if (user != null) {
        // Get the ID token
        String? token = await user.getIdToken();

        // Save the token locally
        //await saveToken(token!,);

        // Create a new document in Firestore with the user's data
        await _firestore.collection('users').doc(user.uid).set({
          'email': email,
          'firstname': firstname,
          'lastname': lastname,
          'agerange': agerange,
          'address': address,
          'city': city,
          'phone': phone,
          'role': 'patient', // Default role based on the registration screen
          'uid': user.uid,
        });

        // Save the token locally and the role
        await saveToken(token!, 'patient', user.uid);

        // Navigate to the next screen after registration
        WidgetsBinding.instance.addPostFrameCallback((_) {
          Navigator.pushReplacementNamed(context, '/');
        });
      }
    } on FirebaseAuthException catch (e) {
      String message = '';
      if (e.code == 'weak-password') {
        message = 'The password provided is too weak.';
      } else if (e.code == 'email-already-in-use') {
        message = 'An account already exists with that email.';
      }
      Fluttertoast.showToast(
        msg: message,
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.SNACKBAR,
        backgroundColor: Colors.black54,
        textColor: Colors.white,
        fontSize: 14.0,
      );
    } catch (e) {
      Fluttertoast.showToast(
        msg: 'An error occurred. Please try again.',
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.SNACKBAR,
        backgroundColor: Colors.black54,
        textColor: Colors.white,
        fontSize: 14.0,
      );
    }
  }

  Future<void> signupPharmacy({
    required String email,
    required String password,
    required String licenseNo,
    required String pharmacyName,
    required String address,
    required String city,
    required String phone,
    required String bankName,
    required String bankAccountNo,
    required String bankBranch,
    required BuildContext context,
  }) async {
    try {
      UserCredential userCredential = await _auth
          .createUserWithEmailAndPassword(email: email, password: password);

      User? user = userCredential.user;

      if (user != null) {
        // Storing pharmacy information in Firestore
        await _firestore.collection('pharmacies').doc(user.uid).set({
          'licenseNo': licenseNo,
          'pharmacyName': pharmacyName,
          'address': address,
          'city': city,
          'phone': phone,
          'bankName': bankName,
          'bankAccountNo': bankAccountNo,
          'bankBranch': bankBranch,
          'email': email,
          'role': 'pharmacy',
          'uid': user.uid,
        });

        // Retrieving and storing the token and UID in SharedPreferences
        String? token = await user.getIdToken();
        await saveToken(token!, 'pharmacy', user.uid);

        Fluttertoast.showToast(msg: "Registration Successful");
        Navigator.pushNamed(context, '/');
      }
    } on FirebaseAuthException catch (e) {
      Fluttertoast.showToast(msg: e.message ?? "Registration failed");
    } catch (e) {
      Fluttertoast.showToast(msg: "An error occurred. Please try again.");
    }
  }

  Future<void> signin({
    required String email,
    required String password,
    required BuildContext context,
  }) async {
    try {
      // Sign in with email and password
      await _auth.signInWithEmailAndPassword(email: email, password: password);

      // Retrieve the current user
      User? user = _auth.currentUser;

      if (user != null) {
        // Get the ID token
        String? token = await user.getIdToken();

        // Check the users collection first
        DocumentSnapshot userDoc =
            await _firestore.collection('users').doc(user.uid).get();

        if (userDoc.exists) {
          String role = userDoc['role'];
          String userid = userDoc['uid'];

          // Save the token locally
          await saveToken(token!, role, userid);

          // Navigate to the appropriate screen based on the role
          if (role == 'patient') {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                  builder: (BuildContext context) => Patienthomescreen()),
            );
          }
        } else {
          // If not found in users, check the pharmacies collection
          DocumentSnapshot pharmacyDoc =
              await _firestore.collection('pharmacies').doc(user.uid).get();

          if (pharmacyDoc.exists) {
            String role = pharmacyDoc['role'];
            String userid = pharmacyDoc['uid'];

            // Save the token locally
            await saveToken(token!, role, userid);

            // Navigate to the pharmacy home screen if role is pharmacy
            if (role == 'pharmacy') {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                    builder: (BuildContext context) => PharmacyHomeScreen()),
              );
            }
          } else {
            Fluttertoast.showToast(
              msg: 'User data not found.',
              toastLength: Toast.LENGTH_LONG,
              gravity: ToastGravity.SNACKBAR,
              backgroundColor: Colors.black54,
              textColor: Colors.white,
              fontSize: 14.0,
            );
          }
        }
      }
    } on FirebaseAuthException catch (e) {
      String message = '';
      if (e.code == 'invalid-email') {
        message = 'No user found for that email.';
      } else if (e.code == 'wrong-password') {
        message = 'Wrong password provided for that user.';
      }
      Fluttertoast.showToast(
        msg: message,
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.SNACKBAR,
        backgroundColor: Colors.black54,
        textColor: Colors.white,
        fontSize: 14.0,
      );
    } catch (e) {
      // Log the error message
      print('Error: $e');
      Fluttertoast.showToast(
        msg: 'An error occurred. Please try again.',
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.SNACKBAR,
        backgroundColor: Colors.black54,
        textColor: Colors.white,
        fontSize: 14.0,
      );
    }
  }

  Future<void> signout({required BuildContext context}) async {
    await _auth.signOut();
    clearToken();
    await Future.delayed(const Duration(seconds: 1));
    Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            builder: (BuildContext context) => AuthenticationScreen()));
  }

  Future<void> saveToken(String token, String role, String userID) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString("userid", userID);
    prefs.setString('auth_token', token); //saving the session token
    prefs.setString('role', role); //saving the role
  }

  Future<void> clearToken() async {
    final prefs = await SharedPreferences.getInstance();
    print(prefs.get('auth_token'));
    print(prefs.get('role'));
    prefs.remove('userid');
    prefs.remove('auth_token');
    prefs.remove('role');
  }
}
