import 'package:DoseDash/Services/AuthService.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class AuthenticationScreen extends StatefulWidget {
  AuthenticationScreen({super.key});

  @override
  _AuthenticationScreenState createState() => _AuthenticationScreenState();
}

class _AuthenticationScreenState extends State<AuthenticationScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  // Focus nodes for email and password fields
  final FocusNode _emailFocus = FocusNode();
  final FocusNode _passwordFocus = FocusNode();

  bool _agreeToTerms = false; // State to track if user agrees to terms

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Authentication'),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Image at the top
          Image.asset(
            'assets/images/logo.png',
            width: 200,
            height: 200,
            fit: BoxFit.cover,
          ),
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      'Login to your Account',
                      textAlign: TextAlign.left,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    SizedBox(height: 20),
                    TextField(
                      decoration: InputDecoration(
                        labelText: 'Email',
                        border: OutlineInputBorder(),
                      ),
                      controller: _emailController,
                      focusNode: _emailFocus,
                    ),
                    SizedBox(height: 20),
                    TextField(
                      decoration: InputDecoration(
                        labelText: 'Password',
                        border: OutlineInputBorder(),
                      ),
                      obscureText: true,
                      controller: _passwordController,
                      focusNode: _passwordFocus,
                    ),
                    SizedBox(height: 20),
                    Row(
                      children: [
                        Checkbox(
                          value: _agreeToTerms,
                          onChanged: (value) {
                            setState(() {
                              _agreeToTerms = value!;
                            });
                          },
                        ),
                        Text(
                          "I Agree to ",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 16,
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            // Navigate to the terms and conditions screen
                            Navigator.pushNamed(context, '/terms_conditions');
                          },
                          child: Text(
                            'Terms and Conditions',
                            style: TextStyle(
                              color: Colors.blue,
                              decoration: TextDecoration.underline,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                ElevatedButton(
                  onPressed: () async {
                    if (_emailController.text.isEmpty) {
                      Fluttertoast.showToast(msg: "Email cannot be empty");
                      FocusScope.of(context).requestFocus(_emailFocus);
                    } else if (_passwordController.text.isEmpty) {
                      Fluttertoast.showToast(msg: "Password cannot be empty");
                      FocusScope.of(context).requestFocus(_passwordFocus);
                    } else if (!_agreeToTerms) {
                      Fluttertoast.showToast(
                          msg: "Please agree to Terms and Conditions");
                    } else {
                      await Authservice().signin(
                          email: _emailController.text,
                          password: _passwordController.text,
                          context: context);
                    }
                  },
                  child: Text('Login'),
                ),
                SizedBox(height: 20), // Add spacing between button and link
                GestureDetector(
                  onTap: () {
                    // Navigate to the registration screen
                    Navigator.pushNamed(context, '/register');
                  },
                  child: Container(
                    alignment: Alignment.center,
                    child: Text(
                      'No Account? Click here',
                      style: TextStyle(
                        color: Colors.blue,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
