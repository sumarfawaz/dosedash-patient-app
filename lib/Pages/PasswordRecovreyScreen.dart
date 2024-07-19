import 'package:DoseDash/Services/AuthService.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class PasswordRecoveryScreen extends StatefulWidget {
  @override
  _PasswordRecoveryScreenState createState() => _PasswordRecoveryScreenState();
}

class _PasswordRecoveryScreenState extends State<PasswordRecoveryScreen> {
  final TextEditingController _emailController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Recover Password'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _emailController,
              decoration: InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.emailAddress,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                final email = _emailController.text.trim();
                if (email.isNotEmpty) {
                  await Authservice().recoverPassword(
                    email: email,
                    context: context,
                  );
                } else {
                  Fluttertoast.showToast(
                    msg: 'Please enter your email.',
                    toastLength: Toast.LENGTH_LONG,
                    gravity: ToastGravity.SNACKBAR,
                    backgroundColor: Colors.black54,
                    textColor: Colors.white,
                    fontSize: 14.0,
                  );
                }
              },
              child: Text('Send Password Reset Email'),
            ),
          ],
        ),
      ),
    );
  }
}
