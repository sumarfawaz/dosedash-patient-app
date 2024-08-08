// Import necessary packages
import 'package:DoseDash/Pages/AuthenticationScreen.dart';
import 'package:DoseDash/Pages/DeliveryPersonScreens/DeliveryhomeScreen.dart';
import 'package:DoseDash/Pages/PatientScreens/PatientHomeScreen.dart';
import 'package:DoseDash/Pages/PharmacyScreens/PharmacyHomeScreen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Define the Authservice class
class Authservice {
  // Initialize Firebase Authentication and Firestore instances
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;



//----------------------------------------------------------------------------------------------------------------------

  // Signup function for patients
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

      if (user!= null) {
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
      // Handle Firebase Authentication exceptions
      String message = '';
      if (e.code == 'invalid-email') {
        message = 'Invalid email address.';
      } else if (e.code == 'user-not-found') {
        message = 'No user found for that email.';
      } else if (e.code == 'wrong-password') {
        message = 'Wrong password provided for that user.';
      } else if (e.code == 'user-disabled') {
        message = 'This user has been disabled.';
      } else if (e.code == 'too-many-requests') {
        message = 'Too many login attempts. Please try again later.';
      } else if (e.code == 'operation-not-allowed') {
        message = 'Email/password accounts are not enabled.';
      } else {
        message = e.message?? 'An undefined error occurred.';
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
      // Handle general exceptions
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

//----------------------------------------------------------------------------------------------------------------------



  // Signup function for pharmacies
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
      // Create a new user with email and password
      UserCredential userCredential = await _auth
         .createUserWithEmailAndPassword(email: email, password: password);

      User? user = userCredential.user;

      if (user!= null) {
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

//----------------------------------------------------------------------------------------------------------------------

  // Signup function for delivery personnel

    Future<void> signupDeliveryPerson({
    required String deliverypersonFName,
    required String deliverypersonLName,
    required String deliveryPersonAddress,
    required String phoneNumber,
    required String vehicleNumber,
    required String NICnumber,
    required String LicenseID,
    required String city,
    required String bankName,
    required String bankAccountNo,
    required String bankBranch,
    required String email,
    required String password,
    required String agerange,

    required BuildContext context,
  }) async {
    try {
      // Create a new user with email and password
      UserCredential userCredential = await _auth
         .createUserWithEmailAndPassword(email: email, password: password);

      User? user = userCredential.user;

      if (user!= null) {
        // Storing pharmacy information in Firestore
        await _firestore.collection('DeliveryPersons').doc(user.uid).set({
          'First Name': deliverypersonFName,
          'Last Name': deliverypersonLName,
          'Address': deliveryPersonAddress,
          'phone Number': phoneNumber,
          'vehicle Number': vehicleNumber,
          'NIC number': NICnumber,
          'License ID': LicenseID,
          'city': city,
          'agerange': agerange,
          'bank Name': bankName,
          'bank Account.No': bankAccountNo,
          'bank Branch': bankBranch,
          'email': email,
          'role': 'Deliveryperson',
          'uid': user.uid,
        });

        // Retrieving and storing the token and UID in SharedPreferences
        String? token = await user.getIdToken();
        await saveToken(token!, 'Deliveryperson', user.uid);

        Fluttertoast.showToast(msg: "Registration Successful");
        Navigator.pushNamed(context, '/');
      }
    } on FirebaseAuthException catch (e) {
      Fluttertoast.showToast(msg: e.message ?? "Registration failed");
    } catch (e) {
      Fluttertoast.showToast(msg: "An error occurred. Please try again.");
    }
  }



//---------------------------------------------------------------------------------------------------------------------------


 // Signin function
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
        // User found in users collection
        String role = userDoc['role'];
        String userid = userDoc['uid'];

        // Save the token locally
        await saveToken(token!, role, userid);

        // Navigate to the appropriate screen based on the role
        if (role == 'patient') {
          // Navigate to patient home screen
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
          // User found in pharmacies collection
          String role = pharmacyDoc['role'];
          String userid = pharmacyDoc['uid'];

          // Save the token locally
          await saveToken(token!, role, userid);

          // Navigate to the pharmacy home screen if role is pharmacy
          if (role == 'pharmacy') {
            // Navigate to pharmacy home screen
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                  builder: (BuildContext context) => PharmacyHomeScreen()),
            );
          }
        } else {
          // If not found in pharmacies, check the delivery persons collection
          DocumentSnapshot deliveryPersonDoc =
              await _firestore.collection('DeliveryPersons').doc(user.uid).get();

          if (deliveryPersonDoc.exists) {
            // User found in delivery persons collection
            String role = deliveryPersonDoc['role'];
            String userid = deliveryPersonDoc['uid'];

            // Save the token locally
            await saveToken(token!, role, userid);

            // Navigate to the delivery person home screen if role is delivery person
            if (role == 'Deliveryperson') {
              // Navigate to delivery person home screen
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                    builder: (BuildContext context) => DeliveryHomeScreen()),
              );
            }
          } else {
            // User data not found in any collection
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
    }
  } on FirebaseAuthException catch (e) {
    // Handle Firebase Authentication exceptions
    String message = '';
    if (e.code == 'invalid-email') {
      message = 'Invalid email address.';
    } else if (e.code == 'user-not-found') {
      message = 'No user found for that email.';
    } else if (e.code == 'wrong-password') {
      message = 'Wrong password provided for that user.';
    } else if (e.code == 'user-disabled') {
      message = 'This user has been disabled.';
    } else if (e.code == 'too-many-requests') {
      message = 'Too many login attempts. Please try again later.';
    } else if (e.code == 'operation-not-allowed') {
      message = 'Email/password accounts are not enabled.';
    } else {
      message = e.message ?? 'An undefined error occurred.';
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
    // Handle general exceptions
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


//----------------------------------------------------------------------------------------------------------------------



  // Recover password function
  Future<void> recoverPassword({
    required String email,
    required BuildContext context,
  }) async {
    try {
      // Send password reset email
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);

      // Show success toast
      Fluttertoast.showToast(
        msg: 'Password reset email sent.',
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.SNACKBAR,
        backgroundColor: Colors.black54,
        textColor: Colors.white,
        fontSize: 14.0,
      );
    } on FirebaseAuthException catch (e) {
      // Handle Firebase Authentication exceptions
      String message = '';
      if (e.code == 'invalid-email') {
        message = 'Invalid email address.';
      } else if (e.code == 'user-not-found') {
        message = 'No user found for that email.';
      } else {
        message = e.message ?? 'An error occurred. Please try again.';
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
      // Handle general exceptions
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


//----------------------------------------------------------------------------------------------------------------------


  // Signout function
  Future<void> signout({required BuildContext context}) async {
    await _auth.signOut();
    clearToken();
    await Future.delayed(const Duration(seconds: 1));
    Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            builder: (BuildContext context) => AuthenticationScreen()));
  }
//----------------------------------------------------------------------------------------------------------------------


  // Save token function
  Future<void> saveToken(String token, String role, String userID) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString("userid", userID);
    prefs.setString('auth_token', token); //saving the session token
    prefs.setString('role', role); //saving the role
  }

  // Clear token function
  Future<void> clearToken() async {
    final prefs = await SharedPreferences.getInstance();
    print(prefs.get('auth_token'));
    print(prefs.get('role'));
    prefs.remove('userid');
    prefs.remove('auth_token');
    prefs.remove('role');
  }
}



//--------------------------------------------------------------------------------------------------------------------------